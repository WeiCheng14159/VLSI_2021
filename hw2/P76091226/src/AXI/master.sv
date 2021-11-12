`include "AXI_define.svh"
`include "master_pkg.sv"

module master
  import master_pkg::*;
(
    input logic clk,
    input logic rstn,
    // AWx
    output logic [`AXI_ID_BITS-1:0] AWID_M,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
    output logic [1:0] AWBURST_M,
    output logic AWVALID_M,
    input logic AWREADY_M,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_M,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
    output logic WLAST_M,
    output logic WVALID_M,
    input logic WREADY_M,
    // Bx
    input logic [`AXI_ID_BITS-1:0] BID_M,
    input logic [1:0] BRESP_M,
    input logic BVALID_M,
    output logic BREADY_M,
    // ARx
    output logic [`AXI_ID_BITS-1:0] ARID_M,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
    output logic [1:0] ARBURST_M,
    output logic ARVALID_M,
    input logic ARREADY_M,
    // Rx
    input logic [`AXI_ID_BITS-1:0] RID_M,
    input logic [`AXI_DATA_BITS-1:0] RDATA_M,
    input logic [1:0] RRESP_M,
    input logic RLAST_M,
    input logic RVALID_M,
    output logic RREADY_M,
    //interface for cpu
    input logic read,
    input logic write,
    input logic [`AXI_STRB_BITS-1:0] w_type,
    input logic [`AXI_DATA_BITS-1:0] data_in,
    input logic [`AXI_ADDR_BITS-1:0] addr,
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall
);

  logic [`AXI_ID_BITS-1:0] master_ID;
  logic ar_fin, r_fin, aw_fin, w_fin, b_fin;
  logic read_stall, write_stall;
  logic r;
  logic [`AXI_DATA_BITS-1:0] RDATA_r;
  lock_state_t
      ar_lock, aw_lock, w_lock, rx_wait, wx_wait, rready_lock, bready_lock;

  assign master_ID = `AXI_ID_BITS'b0;
  // ARx
  assign ARID_M = master_ID;
  assign ARLEN_M = `AXI_LEN_BITS'b0;
  assign ARSIZE_M = `AXI_SIZE_BITS'b10;
  assign ARBURST_M = 2'b0;
  assign ARVALID_M = (rx_wait) ? 1'b0 : (ar_lock | read) & r;
  assign ARADDR_M = addr;
  // Rx
  assign RREADY_M = (  /*aw_fin |*/ rready_lock);
  // AWx
  assign AWID_M = master_ID;
  assign AWVALID_M = (wx_wait) ? 1'b0 : (aw_lock | write);
  assign AWLEN_M = `AXI_LEN_BITS'b0;
  assign AWSIZE_M = `AXI_SIZE_BITS'b10;
  assign AWBURST_M = 2'b0;
  assign AWADDR_M = addr;
  // Wx
  assign WVALID_M =  /* aw_fin | */ w_lock;
  assign WDATA_M = data_in;
  assign WSTRB_M = w_type;
  assign WLAST_M = 1'b1;
  // Bx
  assign BREADY_M = bready_lock | w_fin;
  // *_fin
  assign ar_fin = ARREADY_M & ARVALID_M;
  assign r_fin = RREADY_M & RVALID_M;
  assign aw_fin = AWREADY_M & AWVALID_M;
  assign w_fin = WREADY_M & WVALID_M;
  assign b_fin = BREADY_M & BVALID_M;
  // CPU interface
  assign data_out = (r_fin) ? RDATA_M : RDATA_r;
  assign write_stall = write & ~w_fin;
  assign read_stall = read & ~r_fin;
  assign stall = read_stall | write_stall;

  always_ff @( posedge clk or negedge rstn ) begin
    if(~rstn)
      r <= 1'b0;
    else
      r <= 1'b1;
  end

  // ar_lock
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) ar_lock <= UNLOCK;
    else
      ar_lock <= (ar_lock == LOCK && ARREADY_M) ? UNLOCK : (ARVALID_M && ~ARREADY_M) ? LOCK : ar_lock;
  end

  // aw_lock
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) aw_lock <= UNLOCK;
    else
      aw_lock <= (aw_lock == LOCK && AWREADY_M) ? UNLOCK : (AWVALID_M && ~AWREADY_M) ? LOCK : aw_lock;
  end

  // w_lock
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) w_lock <= UNLOCK;
    else
      w_lock <= (w_lock == LOCK && WREADY_M) ? UNLOCK : (WVALID_M && ~WREADY_M) ? LOCK : w_lock;
  end

  // bready_lock
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) bready_lock <= UNLOCK;
    else
      bready_lock <= (bready_lock == LOCK && BVALID_M) ? UNLOCK : (w_fin) ? LOCK : bready_lock;
  end

  // rready_lock
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) rready_lock <= UNLOCK;
    else
      rready_lock <= (rready_lock == LOCK && RVALID_M) ? UNLOCK : (ar_fin) ? LOCK : rready_lock;
  end

  // rx_wait
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) rx_wait <= UNLOCK;
    else
      rx_wait <= (rx_wait == LOCK && r_fin) ? UNLOCK : (ar_fin & ~(RREADY_M && RVALID_M)) ? LOCK : rx_wait;
  end

  // wx_wait
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) wx_wait <= UNLOCK;
    else
      wx_wait <= (wx_wait == LOCK && b_fin) ? UNLOCK : (aw_fin & ~b_fin) ? LOCK : wx_wait;
  end

  // RDATA_r
  always @(posedge clk or negedge rstn) begin
    if (~rstn) RDATA_r <= `AXI_DATA_BITS'b0;
    else RDATA_r <= (r_fin) ? RDATA_M : RDATA_r;
  end

endmodule
