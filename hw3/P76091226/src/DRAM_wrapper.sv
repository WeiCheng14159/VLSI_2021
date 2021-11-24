`include "AXI_define.svh"
`include "dram_wrapper_pkg.sv"

`define DRAM_STATE_BITS 2
module DRAM_wrapper
  import dram_wrapper_pkg::*;
(
    input logic clk,
    input logic rstn,
    AXI_slave_intf.slave slave,
    input logic [DATA_SIZE-1:0] DRAM_Q,
    input logic DRAM_valid,
    output logic DRAM_CSn,
    output logic DRAM_RASn,
    output logic DRAM_CASn,
    output logic [WEB_SIZE-1:0] DRAM_WEn,
    output logic [ADDR_SIZE-1:0] DRAM_A,
    output logic [DATA_SIZE-1:0] DRAM_D
);

  dram_wrapper_state_t curr_state, next_state;

  logic [`AXI_IDS_BITS-1:0] ID_r;
  logic [`AXI_LEN_BITS-1:0] LEN_r;
  logic [`AXI_SIZE_BITS-1:0] SIZE_r;
  logic [`AXI_BURST_BITS-1:0] BURST_r;
  logic CASn_prev;
  logic ARx_hs_done, Rx_hs_done, AWx_hs_done, Wx_hs_done, Bx_hs_done;
  logic row_hit, changeRow;
  logic read_done, write_done;

  // logic [`AXI_DATA_BITS-1:0] RDATA_r;
  logic [`AXI_LEN_BITS-1:0] rcnt;
  logic [`AXI_LEN_BITS-1:0] addrcnt;
  logic [`AXI_LEN_BITS-1:0] rcnt_add;
  logic [`AXI_LEN_BITS-1:0] addrcnt_add;
  logic [ROW_ADDR_SIZE-1:0] ROW, ROW_prev;
  logic [COL_ADDR_SIZE-1:0] COL;
  logic [`AXI_ADDR_BITS-1:0] DRAM_ADDR, DRAM_ADDR_prev;

  assign ARx_hs_done = slave.ARREADY & slave.ARVALID;
  assign AWx_hs_done = slave.AWREADY & slave.AWVALID;
  assign Wx_hs_done = slave.WREADY & slave.WVALID;
  assign Bx_hs_done = slave.BREADY & slave.BVALID;
  assign Rx_hs_done = slave.RREADY & slave.RVALID;

  // DRAM address
  assign DRAM_ADDR = slave.AWVALID ? slave.AWADDR : slave.ARVALID ? slave.ARADDR : EMPTY_ADDR;
  assign ROW = DRAM_ADDR[22:12];
  assign COL = DRAM_ADDR[11:2];

  // AXI signal
  assign slave.BID = ID_r;
  assign slave.RID = ID_r;
  assign slave.RDATA = (slave.RVALID) ? DRAM_D : EMPTY_DATA;
  assign slave.BRESP = `AXI_RESP_OKAY;
  assign slave.RRESP = `AXI_RESP_OKAY;
  assign slave.RLAST = rcnt == LEN_r;
  assign rcnt_add = rcnt + `AXI_LEN_BITS'b1;
  assign addrcnt_add = addrcnt + `AXI_LEN_BITS'b1;
  assign changeRow = ROW_prev != ROW;
  // assign finish = (Bx_hs_done & slave.WLAST) | (Rx_hs_done & slave.RLAST);
  assign DRAM_D = slave.WDATA;

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
      curr_state[ACT_BIT]: next_state = (slave.AWVALID) ? WRITE : READ;
      curr_state[READ_BIT]: begin
        if (read_done) begin
          next_state = PRE;
        end else begin
          next_state = READ;
        end
      end
      curr_state[WRITE_BIT]: begin
        if (write_done) begin
          next_state = WRITE_RESP;
        end else begin
          next_state = WRITE;
        end
      end
      curr_state[WRITE_RESP_BIT]: next_state = PRE;
      curr_state[PRE_BIT]: next_state = IDLE;
    endcase
  end  // Next state (C)

  // DRAM control signal
  always_comb begin
    DRAM_CSn = CS_DIS;
    DRAM_RASn = RAS_DIS;
    DRAM_CASn = CAS_DIS;
    DRAM_A = EMPTY_ADDR;
    DRAM_WEn = {WEB_SIZE{WEB_DIS}};

    case (curr_state)
      IDLE: ;
      ACT: begin
        DRAM_CSn = CS_ENB;
        DRAM_RASn = RAS_ENB;
        DRAM_CASn = CAS_DIS;
        DRAM_A = ROW;
        DRAM_WEn = {WEB_SIZE{WEB_DIS}};
      end
      READ: begin
        DRAM_CSn = CS_ENB;
        DRAM_RASn = RAS_DIS;
        DRAM_CASn = CAS_ENB;
        DRAM_A = {1'b0, COL};
        DRAM_WEn = {WEB_SIZE{WEB_DIS}};
      end
      WRITE: begin
        DRAM_CSn = CS_ENB;
        DRAM_RASn = RAS_DIS;
        DRAM_CASn = CAS_ENB;
        DRAM_A = EMPTY_ADDR;
        DRAM_WEn = {WEB_SIZE{WEB_DIS}};
      end
      WRITE_RESP: ;
      PRE: begin
        DRAM_CSn = CS_ENB;
        DRAM_RASn = RAS_ENB;
        DRAM_CASn = CAS_DIS;
        DRAM_A = EMPTY_ADDR;
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

    case (curr_state)
      IDLE: begin
        slave.ARREADY = ~slave.AWVALID;
        slave.AWREADY = 1'b1;
        slave.WREADY  = 1'b0;
        slave.RVALID  = 1'b0;
        slave.BVALID  = 1'b0;
      end
      ACT: begin
        slave.ARREADY = 1'b0;
        slave.AWREADY = 1'b0;
        slave.WREADY  = 1'b0;
        slave.RVALID  = 1'b0;
        slave.BVALID  = 1'b0;
      end
      READ: begin
        slave.ARREADY = 1'b0;
        slave.AWREADY = 1'b0;
        slave.WREADY  = 1'b0;
        slave.RVALID  = 1'b1;
        slave.BVALID  = 1'b0;
      end
      WRITE: begin
        slave.ARREADY = 1'b0;
        slave.AWREADY = 1'b0;
        slave.WREADY  = 1'b0;
        slave.RVALID  = 1'b0;
        slave.BVALID  = 1'b0;
      end
      WRITE_RESP: begin
        slave.ARREADY = 1'b0;
        slave.AWREADY = 1'b0;
        slave.WREADY  = 1'b0;
        slave.RVALID  = 1'b0;
        slave.BVALID  = 1'b1;
      end
      PRE: begin
        slave.ARREADY = 1'b0;
        slave.AWREADY = 1'b0;
        slave.WREADY  = 1'b0;
        slave.RVALID  = 1'b0;
        slave.BVALID  = 1'b0;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      DRAM_ADDR_prev  <= `AXI_ADDR_BITS'b0;
      ID_r    <= `AXI_IDS_BITS'b0;
      BURST_r <= `AXI_BURST_INC;
      LEN_r   <= `AXI_LEN_BITS'b0;
      SIZE_r  <= `AXI_SIZE_BITS'b0;
      // RDATA_r <= `AXI_DATA_BITS'b0;
      // rcnt <= `AXI_LEN_BITS'b0;
      // addrcnt <= `AXI_LEN_BITS'b0;
      CASn_prev <= 1'b0;
      ROW_prev <= 11'b0;
    end else begin
      DRAM_ADDR_prev  <= (ARx_hs_done) ? slave.ARADDR : (AWx_hs_done) ? slave.AWADDR : DRAM_ADDR_prev;
      ID_r <= (ARx_hs_done) ? slave.ARID : (AWx_hs_done) ? slave.AWID : ID_r;
      BURST_r    <= (ARx_hs_done) ? slave.ARBURST :(AWx_hs_done) ? slave.AWBURST : BURST_r;
      LEN_r <= (ARx_hs_done) ? slave.ARLEN : (AWx_hs_done) ? slave.AWLEN : LEN_r;
      SIZE_r <= (ARx_hs_done) ? slave.ARSIZE : (AWx_hs_done) ? slave.AWSIZE : SIZE_r;
      // RDATA_r <= (mem.read) ? mem.rdata : RDATA_r;
      // rcnt <= (Rx_hs_done & slave.RLAST) ? `AXI_LEN_BITS'b0 : (Rx_hs_done) ? rcnt_add : rcnt;
      // addrcnt <= ((Rx_hs_done & slave.RLAST) | (Bx_hs_done & slave.WLAST)) ? `AXI_LEN_BITS'b0 : (~DRAM_CASn) ? addrcnt_add:addrcnt;
      CASn_prev <= DRAM_CASn;
      ROW_prev <= ROW;
    end
  end

endmodule
