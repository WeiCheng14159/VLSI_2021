`include "AXI_define.svh"

module Wx
  import axi_pkg::*;
(
  input logic clk,
  input logic rstn,
    // Master 1
  input logic [`AXI_DATA_BITS-1:0] WDATA_M1,
  input logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
  input logic WLAST_M1,
  input logic WVALID_M1,
  output logic WREADY_M1,
  input logic BVALID_S0,
    // Slave 0
  output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
  output logic WLAST_S0,
  output logic WVALID_S0,
  input logic WREADY_S0,
  input logic AWVALID_S0,
  input logic BVALID_S1,
    // Slave 1
  output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
  output logic WLAST_S1,
  output logic WVALID_S1,
  input logic WREADY_S1,
  input logic AWVALID_S1,
    // Slave 2
  output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
  output logic WLAST_S2,
  output logic WVALID_S2,
  input logic WREADY_S2,
  input logic AWVALID_S2,
  input logic BVALID_S2,
    // Data lock
  output write_data_arb_lock_t write_data_arb_lock
);

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic WLAST_M;
logic WVALID_M;

write_data_arb_lock_t write_data_arb_lock_next;

always_ff @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    write_data_arb_lock <= WLOCK_NO;
  end else begin
    write_data_arb_lock <= write_data_arb_lock_next;
  end
end // State

wire BVALID_S = BVALID_S0 | BVALID_S1 | BVALID_S2;
always_comb begin 
  write_data_arb_lock_next = WLOCK_NO;
  unique case(write_data_arb_lock)
    WLOCK_S0        : write_data_arb_lock_next = (WVALID_S0) ? WLOCK_S0_WVALID : WLOCK_S0;
    WLOCK_S0_WVALID : write_data_arb_lock_next = (BVALID_S) ? WLOCK_NO : WLOCK_S0_WVALID;
    WLOCK_S1        : write_data_arb_lock_next = (WVALID_S1) ? WLOCK_S1_WVALID : WLOCK_S1;
    WLOCK_S1_WVALID : write_data_arb_lock_next = (BVALID_S) ? WLOCK_NO  : WLOCK_S1_WVALID;
    WLOCK_S2        : write_data_arb_lock_next = (WVALID_S2) ? WLOCK_S2_WVALID : WLOCK_S2;
    WLOCK_S2_WVALID : write_data_arb_lock_next = (BVALID_S) ? WLOCK_NO : WLOCK_S2_WVALID;
    WLOCK_NO        : begin
      if      (AWVALID_S0) write_data_arb_lock_next = WLOCK_S0;
      else if (AWVALID_S1) write_data_arb_lock_next = WLOCK_S1;
      else if (AWVALID_S2) write_data_arb_lock_next = WLOCK_S2;
      else                 write_data_arb_lock_next = WLOCK_NO;
    end
  endcase

end // Next state (C)

always_comb begin
  // Default
  {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
  {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
  {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, 1'b0};
  {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b0};
  
  unique case(write_data_arb_lock)
    WLOCK_S0: begin
      {WVALID_S0, WVALID_S1, WVALID_S2} = {WVALID_M1, 1'b0, 1'b0};
    end
    WLOCK_S0_WVALID: begin
      {WDATA_S0, WDATA_S1, WDATA_S2} = {WDATA_M1, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {WSTRB_M1, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {WLAST_M1, 1'b0, 1'b0};
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b1, 1'b0, 1'b0};
      WREADY_M1 = WREADY_S0;
    end
    WLOCK_S1: begin
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, WVALID_M1, 1'b0};
    end
    WLOCK_S1_WVALID: begin
      {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, WDATA_M1, `AXI_DATA_BITS'b0};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, WSTRB_M1, `AXI_STRB_BITS'b0};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, WLAST_M1, 1'b0};
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b1, 1'b0};
      WREADY_M1 = WREADY_S1;
    end
    WLOCK_S2: begin
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, WVALID_M1};
    end
    WLOCK_S2_WVALID: begin
      {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, WDATA_M1};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, WSTRB_M1};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, WLAST_M1};
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b1};
      WREADY_M1 = WREADY_S2;
    end
    WLOCK_NO: begin 
      {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, 1'b0};
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b0};
      WREADY_M1 = 1'b0;
    end
  endcase
end

endmodule
