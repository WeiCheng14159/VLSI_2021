`include "AXI_define.svh"

module Wx
	import axi_pkg::*;
(
	input logic clk,
	input logic rst,
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
	output data_arb_lock_t data_arb_lock
);

logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic WLAST_M;
logic WVALID_M;

data_arb_lock_t data_arb_lock_next;

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    data_arb_lock <= LOCK_NO;
  end else begin
    data_arb_lock <= data_arb_lock_next;
  end
end // State

wire BVALID_S = BVALID_S0 | BVALID_S1 | BVALID_S2;
always_comb begin 
	data_arb_lock_next = LOCK_NO;
  unique case(data_arb_lock)
    LOCK_S0: data_arb_lock_next = (BVALID_S) ? LOCK_NO : LOCK_S0;
		LOCK_S1: data_arb_lock_next = (BVALID_S) ? LOCK_NO : LOCK_S1;
		LOCK_S2: data_arb_lock_next = (BVALID_S) ? LOCK_NO : LOCK_S2;
    LOCK_NO: begin
			if      (AWVALID_S0) data_arb_lock_next = LOCK_S0;
			else if (AWVALID_S1) data_arb_lock_next = LOCK_S1;
			else if (AWVALID_S2) data_arb_lock_next = LOCK_S2;
			else                 data_arb_lock_next = LOCK_NO;
		end
  endcase

end // Next state (C)

always_comb begin
	unique case(data_arb_lock)
    LOCK_S0: begin
			{WDATA_S0, WDATA_S1, WDATA_S2} = {WDATA_M1, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
			{WSTRB_S0, WSTRB_S1, WSTRB_S2} = {WSTRB_M1, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
			{WLAST_S0, WLAST_S1, WLAST_S2} = {WLAST_M1, 1'b0, 1'b0};
			{WVALID_S0, WVALID_S1, WVALID_S2} = {WVALID_M1, 1'b0, 1'b0};
			WREADY_M1 = WREADY_S0;
		end
    LOCK_S1: begin
			{WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, WDATA_M1, `AXI_DATA_BITS'b0};
			{WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, WSTRB_M1, `AXI_STRB_BITS'b0};
			{WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, WLAST_M1, 1'b0};
			{WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, WVALID_M1, 1'b0};
			WREADY_M1 = WREADY_S1;
		end
		LOCK_S2: begin
			{WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, WDATA_M1};
			{WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, WSTRB_M1};
			{WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, WLAST_M1};
			{WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, WVALID_M1};
			WREADY_M1 = WREADY_S2;
		end
    LOCK_NO: begin 
			{WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
			{WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
			{WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, 1'b0};
			{WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b0};
			WREADY_M1 = 1'b0;
		end
  endcase
end

endmodule
