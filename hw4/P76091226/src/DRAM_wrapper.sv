`include "pkg_include.sv"

module DRAM_wrapper
  import dram_wrapper_pkg::*;
(
    input  logic                                clk,
    input  logic                                rstn,
           AXI_slave_intf.slave                 slave,
    // DRAM module
    input  logic                [DATA_SIZE-1:0] DRAM_Q,
    input  logic                                DRAM_valid,
    output logic                                DRAM_CSn,
    output logic                                DRAM_RASn,
    output logic                                DRAM_CASn,
    output logic                [ WEB_SIZE-1:0] DRAM_WEn,
    output logic                [ADDR_SIZE-1:0] DRAM_A,
    output logic                [DATA_SIZE-1:0] DRAM_D
);

  dram_wrapper_state_t curr_state, next_state;

  logic     [  `AXI_IDS_BITS-1:0] ID_r;
  logic     [  `AXI_LEN_BITS-1:0] LEN_r;
  logic     [ `AXI_SIZE_BITS-1:0] SIZE_r;
  logic     [`AXI_BURST_BITS-1:0] BURST_r;
  logic     [ `AXI_DATA_BITS-1:0] WDATA_r;
  logic     [       WEB_SIZE-1:0] WSTRB_r;
  dram_op_t                       dram_op;
  logic     [                2:0] RAS_counter;

  logic ARx_hs_done, Rx_hs_done, AWx_hs_done, Wx_hs_done, Bx_hs_done;
  logic change_row, write_done;

  logic [`AXI_DATA_BITS-1:0] RDATA_r;
  logic [ `AXI_LEN_BITS-1:0] len_cnt;

  logic [ ROW_ADDR_SIZE-1:0] ROW;
  logic [ ROW_ADDR_SIZE-1:0] ROW_prev;
  logic [ COL_ADDR_SIZE-1:0] COL;
  logic [`AXI_ADDR_BITS-1:0] DRAM_ADDR_r;

  assign ARx_hs_done = slave.ARREADY & slave.ARVALID;
  assign AWx_hs_done = slave.AWREADY & slave.AWVALID;
  assign Wx_hs_done = slave.WREADY & slave.WVALID;
  assign Bx_hs_done = slave.BREADY & slave.BVALID;
  assign Rx_hs_done = slave.RREADY & slave.RVALID;

  // DRAM address
  assign ROW = DRAM_ADDR_r[22:12];
  assign COL = DRAM_ADDR_r[11:2] + len_cnt;

  // AXI signal
  assign slave.BID = ID_r;
  assign slave.RID = ID_r;
  assign slave.RDATA = (slave.RVALID) ? DRAM_Q : RDATA_r;
  assign slave.BRESP = `AXI_RESP_OKAY;
  assign slave.RRESP = `AXI_RESP_OKAY;
  assign slave.RLAST = ((len_cnt == LEN_r) & (Rx_hs_done));
  assign change_row = (ROW_prev != ROW);
  // assign finish = (Bx_hs_done & slave.WLAST) | (Rx_hs_done & slave.RLAST);
  assign DRAM_D = WDATA_r;
  assign write_done = (RAS_counter == 3'h0);

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end  // State

  always_comb begin
    next_state = IDLE;
    unique case (1'b1)
      curr_state[IDLE_BIT]:
      next_state = (slave.AWVALID | slave.ARVALID) ? ACT : IDLE;
      curr_state[ACT_BIT]: next_state = (dram_op == DRAM_WRITE) ? WRITE : READ;
      curr_state[READ_BIT]:
      next_state = (Rx_hs_done & slave.RLAST) ? PRE : READ;
      curr_state[WRITE_BIT]: next_state = (write_done) ? WRITE_RESP : WRITE;
      curr_state[WRITE_RESP_BIT]: next_state = (Bx_hs_done) ? PRE : WRITE_RESP;
      curr_state[PRE_BIT]: next_state = IDLE;
    endcase
  end  // Next state (C)

  // DRAM control signal
  always_comb begin
    DRAM_CSn = CS_ENB;
    DRAM_RASn = RAS_DIS;
    DRAM_CASn = CAS_DIS;
    DRAM_A = {1'b0, COL};
    DRAM_WEn = {WEB_SIZE{WEB_DIS}};

    unique case (1'b1)
      curr_state[IDLE_BIT]: ;
      curr_state[ACT_BIT]: begin
        DRAM_RASn = (change_row) ? RAS_ENB : RAS_DIS;
        DRAM_CASn = CAS_DIS;
        DRAM_A = ROW;
        DRAM_WEn = {WEB_SIZE{WEB_DIS}};
      end
      curr_state[READ_BIT]: begin
        DRAM_RASn = RAS_DIS;
        DRAM_CASn = (|RAS_counter) ? CAS_DIS : CAS_ENB;
        DRAM_A = {1'b0, COL};
        DRAM_WEn = {WEB_SIZE{WEB_DIS}};
      end
      curr_state[WRITE_BIT]: begin
        DRAM_RASn = RAS_DIS;
        DRAM_CASn = (|RAS_counter) ? CAS_DIS : CAS_ENB;
        DRAM_A = {1'b0, COL};
        DRAM_WEn = (~|RAS_counter) ? (1'b1 == WEB_ENB) ? WSTRB_r : ~WSTRB_r : {WEB_SIZE{WEB_DIS}};
      end
      curr_state[WRITE_RESP_BIT]: ;
      curr_state[PRE_BIT]: begin
        DRAM_RASn = RAS_ENB;
        DRAM_CASn = CAS_DIS;
        DRAM_A = ROW;
        DRAM_WEn = {WEB_SIZE{WEB_ENB}};
      end
    endcase
  end

  // AXI control signal
  always_comb begin
    slave.ARREADY = 1'b0;
    slave.AWREADY = 1'b0;
    slave.WREADY  = 1'b0;
    slave.RVALID  = 1'b0;
    slave.BVALID  = 1'b0;

    case (1'b1)
      curr_state[IDLE_BIT]: begin
        slave.ARREADY = ~slave.AWVALID;
        slave.AWREADY = 1'b1;
        slave.WREADY  = 1'b1;
      end
      curr_state[ACT_BIT]: ;
      curr_state[READ_BIT]: slave.RVALID = DRAM_valid;
      curr_state[WRITE_BIT]: ;
      curr_state[WRITE_RESP_BIT]: slave.BVALID = 1'b1;
      curr_state[PRE_BIT]: ;
    endcase
  end

  // AXI related
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ID_r    <= `AXI_IDS_BITS'b0;
      BURST_r <= `AXI_BURST_INC;
      LEN_r   <= `AXI_LEN_BITS'b0;
      SIZE_r  <= `AXI_SIZE_BITS'b0;
      WDATA_r <= `AXI_DATA_BITS'b0;
      RDATA_r <= `AXI_DATA_BITS'b0;
      WSTRB_r <= {WEB_SIZE{WEB_DIS}};
    end else begin
      ID_r <= (ARx_hs_done) ? slave.ARID : (AWx_hs_done) ? slave.AWID : ID_r;
      BURST_r <= (ARx_hs_done) ? slave.ARBURST :(AWx_hs_done) ? slave.AWBURST : BURST_r;
      LEN_r <= (ARx_hs_done) ? slave.ARLEN : (AWx_hs_done) ? slave.AWLEN : LEN_r;
      SIZE_r <= (ARx_hs_done) ? slave.ARSIZE : (AWx_hs_done) ? slave.AWSIZE : SIZE_r;
      WDATA_r <= (Wx_hs_done) ? slave.WDATA : WDATA_r;
      RDATA_r <= (Rx_hs_done) ? slave.RDATA : RDATA_r;
      WSTRB_r <= (Wx_hs_done) ? slave.WSTRB : WSTRB_r;
    end
  end

  // RAS_counter
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) RAS_counter <= 3'b1;
    else RAS_counter <= (DRAM_RASn == RAS_ENB) ? (tRCD - 1) : (RAS_counter - 1);
  end

  // DRAM related
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      DRAM_ADDR_r <= `AXI_ADDR_BITS'b0;
      len_cnt <= `AXI_LEN_BITS'b0;
      dram_op <= DRAM_NO;
      ROW_prev <= {ROW_ADDR_SIZE{1'b0}};
    end else begin
      DRAM_ADDR_r  <= (ARx_hs_done) ? slave.ARADDR : (AWx_hs_done) ? slave.AWADDR : DRAM_ADDR_r;
      len_cnt <= (Rx_hs_done & slave.RLAST) ? `AXI_LEN_BITS'b0 : (Rx_hs_done) ? (len_cnt + `AXI_LEN_BITS'b1) : len_cnt;
      dram_op <= (ARx_hs_done) ? DRAM_READ : (AWx_hs_done) ? DRAM_WRITE : dram_op;
      ROW_prev <= (ARx_hs_done | AWx_hs_done) ? ROW : ROW_prev;
    end
  end

endmodule
