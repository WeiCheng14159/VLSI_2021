`include "AXI_define.svh"

module Bx
	import axi_pkg::*;
(
	input logic clk,
	input logic rstn,
		// Master 0
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input logic BREADY_M1,
		// Slave 0
	input logic [`AXI_IDS_BITS-1:0] BID_S0,
	input logic [1:0] BRESP_S0,
	input logic BVALID_S0,
	output logic BREADY_S0,
		// Slave 1
	input logic [`AXI_IDS_BITS-1:0] BID_S1,
	input logic [1:0] BRESP_S1,
	input logic BVALID_S1,
	output logic BREADY_S1,
		// Slave 2
	input logic [`AXI_IDS_BITS-1:0] BID_S2,
	input logic [1:0] BRESP_S2,
	input logic BVALID_S2,
	output logic BREADY_S2,
		// Data lock
	input data_arb_lock_t data_arb_lock
);

logic [`AXI_IDS_BITS-1:0] BID_S;
logic [1:0] BRESP_S;
logic BVALID_S;
logic BREADY_S;

assign BREADY_S = BREADY_M1;

always_comb begin
	unique case(data_arb_lock)
    LOCK_S0: begin
			BID_S = BID_S0;
			BRESP_S = BRESP_S0;
			BVALID_S = BVALID_S0;
			{BREADY_S0, BREADY_S1, BREADY_S2} = {BREADY_S, 1'b0, 1'b0};
		end
    LOCK_S1: begin
			BID_S = BID_S1;
			BRESP_S = BRESP_S1;
			BVALID_S = BVALID_S1;
			{BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, BREADY_S, 1'b0};
		end
		LOCK_S2: begin
			BID_S = BID_S2;
			BRESP_S = BRESP_S2;
			BVALID_S = BVALID_S2;
			{BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, BREADY_S};
		end
    LOCK_NO: begin 
			BID_S = 0;
			BRESP_S = 1'b0;
			BVALID_S = 1'b0;
			{BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, 1'b0};
		end
  endcase
end

always_comb begin
	unique case(DATA_DECODER(BID_S))
		MASTER_1: begin
			BID_M1 = BID_S[`AXI_IDS_BITS-1:4];
			BRESP_M1 = BRESP_S;
			BVALID_M1 = BVALID_S;
		end
	endcase
end

endmodule
