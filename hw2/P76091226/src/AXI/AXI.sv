//================================================
// Auther:      Chen Tsung-Chi (Michael)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "AXI_define.svh"

module AXI(

	input ACLK,
	input ARESETn,

	// AXI to master 0 (IF-stage)
		// READ ADDRESS0
		input [`AXI_ID_BITS-1:0] ARID_M0,
		input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
		input [`AXI_LEN_BITS-1:0] ARLEN_M0,
		input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
		input [1:0] ARBURST_M0,
		input ARVALID_M0,
		output reg ARREADY_M0,
		// READ DATA0
		output reg [`AXI_ID_BITS-1:0] RID_M0,
		output reg [`AXI_DATA_BITS-1:0] RDATA_M0,
		output reg [1:0] RRESP_M0,
		output reg RLAST_M0,
		output reg RVALID_M0,
		input RREADY_M0,
	
	// AXI to master 1 (MEM-stage)
		// WRITE ADDRESS
		input [`AXI_ID_BITS-1:0] AWID_M1,
		input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
		input [`AXI_LEN_BITS-1:0] AWLEN_M1,
		input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
		input [1:0] AWBURST_M1,
		input AWVALID_M1,
		output reg AWREADY_M1,
		// WRITE DATA
		input [`AXI_DATA_BITS-1:0] WDATA_M1,
		input [`AXI_STRB_BITS-1:0] WSTRB_M1,
		input WLAST_M1,
		input WVALID_M1,
		output reg WREADY_M1,
		// WRITE RESPONSE
		output reg [`AXI_ID_BITS-1:0] BID_M1,
		output reg [1:0] BRESP_M1,
		output reg BVALID_M1,
		input BREADY_M1,
		// READ ADDRESS1
		input [`AXI_ID_BITS-1:0] ARID_M1,
		input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
		input [`AXI_LEN_BITS-1:0] ARLEN_M1,
		input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
		input [1:0] ARBURST_M1,
		input ARVALID_M1,
		output reg ARREADY_M1,
		// READ DATA1
		output reg [`AXI_ID_BITS-1:0] RID_M1,
		output reg [`AXI_DATA_BITS-1:0] RDATA_M1,
		output reg [1:0] RRESP_M1,
		output reg RLAST_M1,
		output reg RVALID_M1,
		input RREADY_M1,

	// AXI to slave 0 (IM)
		// WRITE ADDRESS0
		output reg [`AXI_IDS_BITS-1:0] AWID_S0,
		output reg [`AXI_ADDR_BITS-1:0] AWADDR_S0,
		output reg [`AXI_LEN_BITS-1:0] AWLEN_S0,
		output reg [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
		output reg [1:0] AWBURST_S0,
		output reg AWVALID_S0,
		input AWREADY_S0,
		// WRITE DATA0
		output reg [`AXI_DATA_BITS-1:0] WDATA_S0,
		output reg [`AXI_STRB_BITS-1:0] WSTRB_S0,
		output reg WLAST_S0,
		output reg WVALID_S0,
		input WREADY_S0,
		// WRITE RESPONSE0
		input [`AXI_IDS_BITS-1:0] BID_S0,
		input [1:0] BRESP_S0,
		input BVALID_S0,
		output reg BREADY_S0,
		// READ ADDRESS0
		output reg [`AXI_IDS_BITS-1:0] ARID_S0,
		output reg [`AXI_ADDR_BITS-1:0] ARADDR_S0,
		output reg [`AXI_LEN_BITS-1:0] ARLEN_S0,
		output reg [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
		output reg [1:0] ARBURST_S0,
		output reg ARVALID_S0,
		input ARREADY_S0,
		// READ DATA0
		input [`AXI_IDS_BITS-1:0] RID_S0,
		input [`AXI_DATA_BITS-1:0] RDATA_S0,
		input [1:0] RRESP_S0,
		input RLAST_S0,
		input RVALID_S0,
		output reg RREADY_S0,
	
	// AXI to slave 1 (DM)
		// WRITE ADDRESS1
		output reg [`AXI_IDS_BITS-1:0] AWID_S1,
		output reg [`AXI_ADDR_BITS-1:0] AWADDR_S1,
		output reg [`AXI_LEN_BITS-1:0] AWLEN_S1,
		output reg [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
		output reg [1:0] AWBURST_S1,
		output reg AWVALID_S1,
		input AWREADY_S1,
		// WRITE DATA1
		output reg [`AXI_DATA_BITS-1:0] WDATA_S1,
		output reg [`AXI_STRB_BITS-1:0] WSTRB_S1,
		output reg WLAST_S1,
		output reg WVALID_S1,
		input WREADY_S1,
		// WRITE RESPONSE1
		input [`AXI_IDS_BITS-1:0] BID_S1,
		input [1:0] BRESP_S1,
		input BVALID_S1,
		output reg BREADY_S1,
		// READ ADDRESS1
		output reg [`AXI_IDS_BITS-1:0] ARID_S1,
		output reg [`AXI_ADDR_BITS-1:0] ARADDR_S1,
		output reg [`AXI_LEN_BITS-1:0] ARLEN_S1,
		output reg [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
		output reg [1:0] ARBURST_S1,
		output reg ARVALID_S1,
		input ARREADY_S1,
		// READ DATA1
		input [`AXI_IDS_BITS-1:0] RID_S1,
		input [`AXI_DATA_BITS-1:0] RDATA_S1,
		input [1:0] RRESP_S1,
		input RLAST_S1,
		input RVALID_S1,
		output reg RREADY_S1
	
	/* Interface connection (not used) */
	// AXI2CPU_interface.axi_ports axi2cpu_interface,
	// AXI2SRAM_interface.axi_ports axi2sram0_interface,
	// AXI2SRAM_interface.axi_ports axi2sram1_interface
);

localparam EMPTY_ADDR = 32'h0, EMPTY_DATA = 32'h0;

logic rr_ptr;
always_ff @(posedge ACLK, posedge ARESETn) begin
	if(ARESETn)
		rr_ptr <= 1'b0;
	else
		rr_ptr <= ~rr_ptr;
end

// SASD architecture
// Master 0 : CPU IF stage
// Master 1 : CPU MEM stage
// Slave 0 : SRAM IM
// Slave 1 : SRAM DM

// AWx arbitration

// ARx arbitration
always_comb begin
	// default values to avoid latch 
		// ARID
		{ARID_S0, ARID_S1} = { {4'b0000, 4'b0000}, {4'b0000, 4'b0001} }; 
		// ARREADY
		{ARREADY_M0, ARREADY_M1} = {1'b0, 1'b0};
		// ARADDR
		{ARADDR_S0, ARADDR_S1} = {EMPTY_ADDR, EMPTY_ADDR};
		// ARLEN
		{ARLEN_S0, ARLEN_S1} = {4'b0, 4'b0};
		// ARSIZE
		{ARSIZE_S0, ARSIZE_S1} = {3'b0, 3'b0};
		// ARBURST
		{ARBURST_S0, ARBURST_S1} = {2'b0, 2'b0};
		// ARVALID
		{ARVALID_S0, ARVALID_S1} = {1'b0, 1'b0};

	// ARID, AWID, WID: axi add additional 4 bits
	{ARID_S0, ARID_S1} = { {ARID_M0, 4'b0000}, {ARID_M1, 4'b0001} }; 
	if(rr_ptr == 1'b0 && ARVALID_M0) begin // master 0 turn and master 0 needs
		
		// ARREADY
		{ARREADY_M0, ARREADY_M1} = {1'b1, 1'b0};
		// ADADDR, ARLEN, ARSIZE, ARBURST
		if(ARADDR_M0 >= EMPTY_ADDR && ARADDR_M0 < 32'h0001_0000) begin // slave 0
			{ARADDR_S0, ARADDR_S1} = {ARADDR_M0, EMPTY_ADDR};
			{ARLEN_S0, ARLEN_S1} = {ARLEN_M0, 4'b0};
			{ARSIZE_S0, ARSIZE_S1} = {ARSIZE_M0, 3'b0};
			{ARBURST_S0, ARBURST_S1} = {ARBURST_M0, 2'b0};
			{ARVALID_S0, ARVALID_S1} = {ARVALID_M0, 1'b0};
		end else if (ARADDR_M0 >= 32'h0001_0000 && ARADDR_M0 < 32'h0010_0000) begin // slave 1
			{ARADDR_S0, ARADDR_S1} = {EMPTY_ADDR, ARADDR_M0};
			{ARLEN_S0, ARLEN_S1} = {4'b0, ARLEN_M0};
			{ARSIZE_S0, ARSIZE_S1} = {3'b0, ARSIZE_M0};
			{ARBURST_S0, ARBURST_S1} = {2'b0, ARBURST_M0};
			{ARVALID_S0, ARVALID_S1} = {1'b0, ARVALID_M0};
		end // default slave 

	end else if (rr_ptr == 1'b1 && ARVALID_M1)begin // master 1 turn and master 1 needs
		
		// ARREADY
		{ARREADY_M0, ARREADY_M1} = {1'b0, 1'b1};
		// ADADDR, ARLEN, ARSIZE, ARBURST
		if(ARADDR_M1 >= EMPTY_ADDR && ARADDR_M1 < 32'h0001_0000) begin // slave 0
			{ARADDR_S0, ARADDR_S1} = {ARADDR_M1, EMPTY_ADDR};
			{ARLEN_S0, ARLEN_S1} = {ARLEN_M1, 4'b0};
			{ARSIZE_S0, ARSIZE_S1} = {ARSIZE_M1, 3'b0};
			{ARBURST_S0, ARBURST_S1} = {ARBURST_M1, 2'b0};
			{ARVALID_S0, ARVALID_S1} = {ARVALID_M1, 1'b0};
		end else if (ARADDR_M1 >= 32'h0001_0000 && ARADDR_M1 < 32'h0010_0000) begin // slave 1
			{ARADDR_S0, ARADDR_S1} = {EMPTY_ADDR, ARADDR_M1};
			{ARLEN_S0, ARLEN_S1} = {4'b0, ARLEN_M1};
			{ARSIZE_S0, ARSIZE_S1} = {3'b0, ARSIZE_M1};
			{ARBURST_S0, ARBURST_S1} = {2'b0, ARBURST_M1};
			{ARVALID_S0, ARVALID_S1} = {1'b0, ARVALID_M1};
		end // default slave 

	end // no requests or requests have to wait

end

// Wx Bx arbitration



// Rx arbitration
always_comb begin
	// default values to avoid latch 
		// RID
		{RID_M0, RID_M1} = { 4'b0000, 4'b0000 }; 
		// RDATA
		{RDATA_M0, RDATA_M1} = {EMPTY_DATA, EMPTY_DATA};
		// RRESP
		{RRESP_M0, RRESP_M1} = {2'b0, 2'b0};
		// RLAST
		{RLAST_M0, RLAST_M1} = {1'b0, 1'b0};
		// RVALID
		{RVALID_M0, RVALID_M1} = {1'b0, 1'b0};

	if(rr_ptr == 1'b0 && RREADY_M0) begin // master 0 turn and master 0 needs
		
		if(RID_S0[3:0] == 4'b0000) begin // slave 0 send to master 0
			{RID_M0, RID_M1} = { RID_S0[7:4], 4'b0000 }; 
			{RDATA_M0, RDATA_M1} = { RDATA_S0, EMPTY_DATA };
			{RRESP_M0, RRESP_M1} = { RRESP_S0, 2'b0 };
			{RLAST_M0, RLAST_M1} = { RLAST_S0, 1'b0 };
			{RVALID_M0, RVALID_M1} = { RVALID_S0, 1'b0 };
		end else if (RID_S1[3:0] == 4'b0000) begin // slave 1 send to master 0
			{RID_M0, RID_M1} = { RID_S1[7:4], 4'b0000 }; 
			{RDATA_M0, RDATA_M1} = { RDATA_S1, EMPTY_DATA };
			{RRESP_M0, RRESP_M1} = { RRESP_S1, 2'b0 };
			{RLAST_M0, RLAST_M1} = { RLAST_S1, 1'b0 };
			{RVALID_M0, RVALID_M1} = { RVALID_S1, 1'b0 };
		end // unknown slave

	end else if (rr_ptr == 1'b1 && RREADY_M1)begin // master 1 turn and master 1 needs
		
		if(RID_S0[3:0] == 4'b0000) begin // slave 0 send to master 1
			{RID_M0, RID_M1} = { 4'b0000, RID_S0[7:4] }; 
			{RDATA_M0, RDATA_M1} = { EMPTY_DATA, RDATA_S0 };
			{RRESP_M0, RRESP_M1} = { 2'b0, RRESP_S0 };
			{RLAST_M0, RLAST_M1} = { 1'b0, RLAST_S0 };
			{RVALID_M0, RVALID_M1} = { 1'b0, RVALID_S0 };
		end else if (RID_S1[3:0] == 4'b0000) begin // slave 1 send to master 1
			{RID_M0, RID_M1} = { 4'b0000, RID_S1[7:4] }; 
			{RDATA_M0, RDATA_M1} = { EMPTY_DATA, RDATA_S1 };
			{RRESP_M0, RRESP_M1} = { 2'b0, RRESP_S1 };
			{RLAST_M0, RLAST_M1} = { 1'b0, RLAST_S1 };
			{RVALID_M0, RVALID_M1} = { 1'b0, RVALID_S1 };
		end // unknown slave

	end // no requests or requests have to wait

end // Rx arbitration

endmodule


