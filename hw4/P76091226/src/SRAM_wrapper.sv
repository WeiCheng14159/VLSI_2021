`include "pkg_include.sv"

module SRAM_wrapper
  import sram_wrapper_pkg::*;
(
    input logic                clk,
    input logic                rstn,
          AXI_slave_intf.slave slave
);

  // SRAM module
  logic [13:0] A;
  logic [`AXI_DATA_BITS-1:0] DI;
  logic [`AXI_DATA_BITS-1:0] DO;
  logic [`AXI_STRB_BITS-1:0] WEB;
  logic CS;
  logic OE;

  sram_wrapper_state_t curr_state, next_state;

  logic ARx_hs_done, Rx_hs_done, AW_hs_done, Wx_hs_done, Bx_hs_done;

  logic [13:0] A_r;
  logic [`AXI_IDS_BITS-1:0] ID_r;
  logic [`AXI_LEN_BITS-1:0] LEN_r;
  logic Wx_hs_done_r;
  logic [`AXI_LEN_BITS-1:0] len_cnt;

  // Handshake signal
  assign AW_hs_done = slave.AWVALID & slave.AWREADY;
  assign Wx_hs_done = slave.WVALID & slave.WREADY;
  assign Bx_hs_done = slave.BVALID & slave.BREADY;
  assign ARx_hs_done = slave.ARVALID & slave.ARREADY;
  assign Rx_hs_done = slave.RVALID & slave.RREADY;
  // Rx
  assign slave.RLAST = (len_cnt == LEN_r);
  assign slave.RDATA = DO;
  assign slave.RID = ID_r;
  assign slave.RRESP = `AXI_RESP_OKAY;
  // Bx
  assign slave.BID = ID_r;
  assign slave.BRESP = `AXI_RESP_OKAY;
  // Wx
  assign DI = slave.WDATA;

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end  // State

  always_comb begin
    case (curr_state)
      IDLE: begin
        next_state = (slave.AWVALID) ? WRITE : (slave.ARVALID) ? READ : IDLE;
      end
      READ: begin
        next_state = (Rx_hs_done & slave.RLAST) ? ((slave.AWVALID) ? WRITE : (slave.ARVALID) ? READ : IDLE) : READ;
      end
      WRITE: begin
        next_state = (Bx_hs_done) ? ((slave.ARVALID) ? READ : (slave.AWVALID) ? WRITE : IDLE) : WRITE;
      end
      default: next_state = curr_state;
    endcase
  end  // Next state (C)

  always_comb begin
    slave.AWREADY = 1'b0;
    slave.WREADY = 1'b0;
    slave.BVALID = 1'b0;
    slave.ARREADY = 1'b0;
    slave.RVALID = 1'b0;
    CS = 1'b0;
    OE = 1'b0;
    A = A_r;

    case (curr_state)
      IDLE: begin
        slave.AWREADY = 1'b1;
        slave.WREADY = 1'b1;
        slave.BVALID = 1'b0;
        slave.ARREADY = ~slave.AWVALID;
        slave.RVALID = 1'b0;
        CS = slave.AWVALID | slave.ARVALID;
        OE = ~slave.AWVALID & slave.ARVALID;
        A = (slave.AWVALID) ? slave.AWADDR[15:2] : slave.ARADDR[15:2];
      end
      READ: begin
        slave.AWREADY = slave.RLAST & Rx_hs_done;
        slave.WREADY = slave.RLAST & Rx_hs_done;
        slave.BVALID = 1'b0;
        slave.ARREADY = slave.RLAST & Rx_hs_done & ~slave.AWVALID;
        slave.RVALID = 1'b1;
        CS = 1'b1;
        OE = 1'b1;
        A = (slave.RLAST & Rx_hs_done) ? (slave.AWVALID ? slave.AWADDR[15:2] : A_r ) : (A_r + len_cnt + 1);
      end
      WRITE: begin
        slave.AWREADY = 1'b0;
        slave.WREADY = 1'b0;
        slave.BVALID = Wx_hs_done_r;
        slave.ARREADY = slave.WLAST & Bx_hs_done & ~slave.AWVALID;
        slave.RVALID = 1'b0;
        CS = 1'b1;
        OE = 1'b0;
        A = (slave.WLAST & Bx_hs_done) ? (slave.AWVALID ? slave.AWADDR[15:2] : slave.ARADDR[15:2]) : A_r[13:2];
      end
      default: ;
    endcase
  end


  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      len_cnt <= `AXI_LEN_BITS'b0;
    end else if (curr_state[READ_BIT]) begin
      len_cnt <= (slave.RLAST & Rx_hs_done) ? `AXI_LEN_BITS'b0 : (Rx_hs_done) ? len_cnt + `AXI_LEN_BITS'b1 : len_cnt;
    end else if (curr_state[WRITE_BIT]) begin
      len_cnt <= (slave.WLAST & Bx_hs_done) ? `AXI_LEN_BITS'b0 : (Bx_hs_done) ? len_cnt + `AXI_LEN_BITS'b1 : len_cnt;
    end else if (curr_state[IDLE_BIT]) begin
      len_cnt <= `AXI_LEN_BITS'b0;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      Wx_hs_done_r <= 1'b0;
    end else begin
      Wx_hs_done_r  <= (Bx_hs_done) ? 1'b0 : (Wx_hs_done) ? (slave.WLAST) ? 1'b1 : 1'b0 : Wx_hs_done_r;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      A_r   <= 14'b0;
      ID_r  <= `AXI_IDS_BITS'b0;
      LEN_r <= `AXI_LEN_BITS'b0;
    end else begin
      A_r       <= (AW_hs_done) ? slave.AWADDR [15:2]   : (ARx_hs_done) ? slave.ARADDR [15:2]   : A_r;
      ID_r <= (AW_hs_done) ? slave.AWID : (ARx_hs_done) ? slave.ARID : ID_r;
      LEN_r <= (AW_hs_done) ? slave.AWLEN : (ARx_hs_done) ? slave.ARLEN : LEN_r;
    end

  end

  always_comb begin
    WEB = {WEB_DIS, WEB_DIS, WEB_DIS, WEB_DIS};
    if (slave.WVALID) begin
      WEB[0] = (slave.WSTRB[0]) ? WEB_ENB : WEB_DIS;
      WEB[1] = (slave.WSTRB[1]) ? WEB_ENB : WEB_DIS;
      WEB[2] = (slave.WSTRB[2]) ? WEB_ENB : WEB_DIS;
      WEB[3] = (slave.WSTRB[3]) ? WEB_ENB : WEB_DIS;
    end
  end

  SRAM i_SRAM (
      .A0  (A[0]),
      .A1  (A[1]),
      .A2  (A[2]),
      .A3  (A[3]),
      .A4  (A[4]),
      .A5  (A[5]),
      .A6  (A[6]),
      .A7  (A[7]),
      .A8  (A[8]),
      .A9  (A[9]),
      .A10 (A[10]),
      .A11 (A[11]),
      .A12 (A[12]),
      .A13 (A[13]),
      .DO0 (DO[0]),
      .DO1 (DO[1]),
      .DO2 (DO[2]),
      .DO3 (DO[3]),
      .DO4 (DO[4]),
      .DO5 (DO[5]),
      .DO6 (DO[6]),
      .DO7 (DO[7]),
      .DO8 (DO[8]),
      .DO9 (DO[9]),
      .DO10(DO[10]),
      .DO11(DO[11]),
      .DO12(DO[12]),
      .DO13(DO[13]),
      .DO14(DO[14]),
      .DO15(DO[15]),
      .DO16(DO[16]),
      .DO17(DO[17]),
      .DO18(DO[18]),
      .DO19(DO[19]),
      .DO20(DO[20]),
      .DO21(DO[21]),
      .DO22(DO[22]),
      .DO23(DO[23]),
      .DO24(DO[24]),
      .DO25(DO[25]),
      .DO26(DO[26]),
      .DO27(DO[27]),
      .DO28(DO[28]),
      .DO29(DO[29]),
      .DO30(DO[30]),
      .DO31(DO[31]),
      .DI0 (DI[0]),
      .DI1 (DI[1]),
      .DI2 (DI[2]),
      .DI3 (DI[3]),
      .DI4 (DI[4]),
      .DI5 (DI[5]),
      .DI6 (DI[6]),
      .DI7 (DI[7]),
      .DI8 (DI[8]),
      .DI9 (DI[9]),
      .DI10(DI[10]),
      .DI11(DI[11]),
      .DI12(DI[12]),
      .DI13(DI[13]),
      .DI14(DI[14]),
      .DI15(DI[15]),
      .DI16(DI[16]),
      .DI17(DI[17]),
      .DI18(DI[18]),
      .DI19(DI[19]),
      .DI20(DI[20]),
      .DI21(DI[21]),
      .DI22(DI[22]),
      .DI23(DI[23]),
      .DI24(DI[24]),
      .DI25(DI[25]),
      .DI26(DI[26]),
      .DI27(DI[27]),
      .DI28(DI[28]),
      .DI29(DI[29]),
      .DI30(DI[30]),
      .DI31(DI[31]),
      .CK  (clk),
      .WEB0(WEB[0]),
      .WEB1(WEB[1]),
      .WEB2(WEB[2]),
      .WEB3(WEB[3]),
      .OE  (OE),
      .CS  (CS)
  );

endmodule
