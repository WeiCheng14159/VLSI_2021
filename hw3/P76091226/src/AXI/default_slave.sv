`include "AXI_define.svh"
module default_slave
  import axi_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    input  logic [ `AXI_IDS_BITS-1:0] ARID_DEFAULT,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT,
    input  logic [ `AXI_LEN_BITS-1:0] ARLEN_DEFAULT,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT,
    input  logic [               1:0] ARBURST_DEFAULT,
    input  logic                      ARVALID_DEFAULT,
    output logic                      ARREADY_DEFAULT,

    input  logic [ `AXI_IDS_BITS-1:0] AWID_DEFAULT,
    input  logic [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT,
    input  logic [ `AXI_LEN_BITS-1:0] AWLEN_DEFAULT,
    input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT,
    input  logic [               1:0] AWBURST_DEFAULT,
    input  logic                      AWVALID_DEFAULT,
    output logic                      AWREADY_DEFAULT,

    input logic [`AXI_DATA_BITS-1:0] WDATA_DEFAULT,
    input logic [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT,
    input logic WLAST_DEFAULT,
    input logic WVALID_DEFAULT,
    output logic WREADY_DEFAULT,
    output logic [`AXI_IDS_BITS-1:0] BID_DEFAULT,
    output logic [1:0] BRESP_DEFAULT,
    output logic BVALID_DEFAULT,
    input logic BREADY_DEFAULT,

    output logic [`AXI_IDS_BITS-1:0] RID_DEFAULT,
    output logic [`AXI_DATA_BITS-1:0] RDATA_DEFAULT,
    output logic [1:0] RRESP_DEFAULT,
    output logic RLAST_DEFAULT,
    output logic RVALID_DEFAULT,
    input logic RREADY_DEFAULT
);

  logic lockAR;
  logic AR_FIN;

  assign AR_FIN = ARREADY_DEFAULT & ARVALID_DEFAULT;
  assign RRESP_DEFAULT = `AXI_RESP_DECERR;
  assign RDATA_DEFAULT = `AXI_DATA_BITS'b0;
  //assign RLAST_DEFAULT = 1'b1;

  logic [`AXI_LEN_BITS-1:0] ARLEN_cnt;
  assign RLAST_DEFAULT = (RVALID_DEFAULT && ARLEN_cnt == `AXI_LEN_BITS'b0) ? 1'b1 : 1'b0;

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ARLEN_cnt <= `AXI_LEN_BITS'b0;
    end else begin
      ARLEN_cnt <= (ARREADY_DEFAULT & ARVALID_DEFAULT) ? ARLEN_DEFAULT : (RREADY_DEFAULT) ? (ARLEN_cnt - 1) : ARLEN_cnt;
    end
  end

  // Read channel
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      RVALID_DEFAULT <= 1'b0;
      RID_DEFAULT <= {AXI_MASTER_2_ID, `AXI_ID_BITS'b0};
      ARREADY_DEFAULT <= 1'b1;
      lockAR <= 1'b0;
    end else begin
      RVALID_DEFAULT <= (RVALID_DEFAULT & RREADY_DEFAULT) ? 1'b0 : (AR_FIN) ? 1'b1 : RVALID_DEFAULT;
      RID_DEFAULT <= (AR_FIN) ? ARID_DEFAULT : RID_DEFAULT;
      ARREADY_DEFAULT <= ((lockAR & ~RREADY_DEFAULT) | AR_FIN) ? 1'b0 : 1'b1;
      lockAR <= (lockAR & RREADY_DEFAULT) ? 1'b0 : (AR_FIN) ? 1'b1 : lockAR;
    end
  end

  // logic lockB;
  logic lockAW;
  logic lockW;
  logic AW_FIN;
  logic W_FIN;

  assign BRESP_DEFAULT = `AXI_RESP_DECERR;
  //assign BVALID_DEFAULT = (AW_FIN & W_FIN) | (lockAW & W_FIN) | (lockAW & lockW) | lockB; 
  //assign BID_DEFAULT = (lockB) ? AWID_DEFAULT_REG : AWID_DEFAULT;
  assign AW_FIN = AWREADY_DEFAULT & AWVALID_DEFAULT;
  assign W_FIN = WREADY_DEFAULT & WVALID_DEFAULT;

  // Write channel
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      BVALID_DEFAULT <= 1'b0;
      BID_DEFAULT <= {AXI_MASTER_2_ID, `AXI_ID_BITS'b0};
      AWREADY_DEFAULT <= 1'b0;
      WREADY_DEFAULT <= 1'b0;
      lockAW <= 1'b0;
      lockW <= 1'b0;
    end else begin
      BVALID_DEFAULT <= (BVALID_DEFAULT & BREADY_DEFAULT) ? 1'b0 : ((AW_FIN & W_FIN) | (lockAW & W_FIN) | (lockW & AW_FIN)) ? 1'b1: BVALID_DEFAULT;
      BID_DEFAULT <= (AW_FIN) ? AWID_DEFAULT : BID_DEFAULT;
      AWREADY_DEFAULT <= ((lockAW & ~BREADY_DEFAULT) | AW_FIN) ? 1'b0 : 1'b1;
      WREADY_DEFAULT <= ((lockW & ~BREADY_DEFAULT) | W_FIN) ? 1'b0 : 1'b1;
      lockAW <= (lockAW & BREADY_DEFAULT) ? 1'b0 : (AW_FIN) ? 1'b1 : lockAW;
      lockW <= (lockW & BREADY_DEFAULT) ? 1'b0 : (W_FIN) ? 1'b1 : lockW;
    end
  end

endmodule
