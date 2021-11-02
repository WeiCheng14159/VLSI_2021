`include "AXI_define.svh"

module Rx
	import axi_pkg::*;
(
	input logic clk,
	input logic rst,
		// Master 0 
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input  logic RREADY_M0,
		// Master 1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input logic RREADY_M1,
		// Slave 0
	input logic [`AXI_IDS_BITS-1:0] RID_S0,
	input logic [`AXI_DATA_BITS-1:0] RDATA_S0,
	input logic [1:0] RRESP_S0,
	input logic RLAST_S0,
	input logic RVALID_S0,
	output logic RREADY_S0,
		// Slave 1
	input logic [`AXI_IDS_BITS-1:0] RID_S1,
	input logic [`AXI_DATA_BITS-1:0] RDATA_S1,
	input logic [1:0] RRESP_S1,
	input logic RLAST_S1,
	input logic RVALID_S1,
	output logic RREADY_S1,
		// Slave 2
	input logic [`AXI_IDS_BITS-1:0] RID_S2,
	input logic [`AXI_DATA_BITS-1:0] RDATA_S2,
	input logic [1:0] RRESP_S2,
	input logic RLAST_S2,
	input logic RVALID_S2,
	output logic RREADY_S2
);

logic [`AXI_IDS_BITS-1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [1:0] RRESP_S;
logic RLAST_S;
logic RVALID_S;

logic READY_from_master;

data_arb_lock_t data_arb_lock, data_arb_lock_next;

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    data_arb_lock <= LOCK_NO;
  end else begin
    data_arb_lock <= data_arb_lock_next;
  end
end // State

always_comb begin 
	data_arb_lock_next = LOCK_NO;
  unique case(data_arb_lock)
    LOCK_S0: data_arb_lock_next = (READY_from_master) ? LOCK_NO : LOCK_S0;
		LOCK_S1: data_arb_lock_next = (READY_from_master) ? LOCK_NO : LOCK_S1;
		LOCK_S2: data_arb_lock_next = (READY_from_master) ? LOCK_NO : LOCK_S2;
    LOCK_NO: begin
			if      (RVALID_S0) data_arb_lock_next = LOCK_S0;
			else if (RVALID_S1) data_arb_lock_next = LOCK_S1;
			else if (RVALID_S2) data_arb_lock_next = LOCK_S2;
			else                data_arb_lock_next = LOCK_NO;
		end
  endcase
end // Next state (C)

always_comb begin
	unique case(data_arb_lock)
    LOCK_S0: begin
			RID_S = RID_S0;
			RDATA_S = RDATA_S0;
			RRESP_S = RRESP_S0;
			RLAST_S = RLAST_S0;
			RVALID_S = RVALID_S0;
			{RREADY_S0, RREADY_S1, RREADY_S2} = {READY_from_master, 1'b0, 1'b0};
		end
    LOCK_S1: begin
			RID_S = RID_S1;
			RDATA_S = RDATA_S1;
			RRESP_S = RRESP_S1;
			RLAST_S = RLAST_S1;
			RVALID_S = RVALID_S1;
			{RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, READY_from_master, 1'b0};
		end
		LOCK_S2: begin
			RID_S = RID_S2;
			RDATA_S = RDATA_S2;
			RRESP_S = RRESP_S2;
			RLAST_S = RLAST_S2;
			RVALID_S = RVALID_S2;
			{RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, READY_from_master};
		end
    LOCK_NO: begin 
			RID_S = 0;
			RDATA_S = 0;
			RRESP_S = 0;
			RLAST_S = 0;
			RVALID_S = 0;		
			{RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, 1'b0};
		end
  endcase
end

always_comb begin
	unique case(DATA_DECODER(RID_S))
		MASTER_0: begin
			{RID_M0, RID_M1} = {RID_S, `AXI_ID_BITS'b0};
			{RDATA_M0, RDATA_M1} = {RDATA_S, `AXI_DATA_BITS'b0};
			{RRESP_M0, RRESP_M1} = {RRESP_S, 2'b0};
			{RLAST_M0, RLAST_M1} = {RLAST_S, 1'b0};
			{RVALID_M0, RVALID_M1} = {RVALID_S, 1'b0};
			READY_from_master = RREADY_M0;
		end
		MASTER_1: begin
			{RID_M0, RID_M1} = {`AXI_ID_BITS'b0, RID_S};
			{RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, RDATA_S};
			{RRESP_M0, RRESP_M1} = {2'b0, RRESP_S};
			{RLAST_M0, RLAST_M1} = {1'b0, RLAST_S};
			{RVALID_M0, RVALID_M1} = {1'b0, RVALID_S};
			READY_from_master = RREADY_M1;
		end
		MASTER_2: begin
			{RID_M0, RID_M1} = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
			{RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
			{RRESP_M0, RRESP_M1} = {2'b0, 2'b0};
			{RLAST_M0, RLAST_M1} = {1'b0, 1'b0};
			{RVALID_M0, RVALID_M1} = {1'b0, 1'b0};
			READY_from_master = 1'b0;
		end
	endcase
end

endmodule
