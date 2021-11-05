
`include "AXI.sv"

module AXI_wrapper
(
  input logic ACLK,
  input logic ARESETn,

  /* Interface connection */
  AXI2CPU_interface.axi_ports axi2cpu_interface,
  AXI2SRAM_interface.axi_ports axi2sram0_interface,
  AXI2SRAM_interface.axi_ports axi2sram1_interface
);

AXI axi (
  .ACLK(ACLK), .ARESETn(ARESETn),
  
	// AXI to master 0 (IF-stage)
		// READ ADDRESS0
		.ARID_M0   (axi2cpu_interface.ARID_M0),
		.ARADDR_M0 (axi2cpu_interface.ARADDR_M0),
		.ARLEN_M0  (axi2cpu_interface.ARLEN_M0),
		.ARSIZE_M0 (axi2cpu_interface.ARSIZE_M0),
		.ARBURST_M0(axi2cpu_interface.ARBURST_M0),
		.ARVALID_M0(axi2cpu_interface.ARVALID_M0),
		.ARREADY_M0(axi2cpu_interface.ARREADY_M0),
		// READ DATA0
		.RID_M0   (axi2cpu_interface.RID_M0),
		.RDATA_M0 (axi2cpu_interface.RDATA_M0),
		.RRESP_M0 (axi2cpu_interface.RRESP_M0),
		.RLAST_M0 (axi2cpu_interface.RLAST_M0),
		.RVALID_M0(axi2cpu_interface.RVALID_M0),
		.RREADY_M0(axi2cpu_interface.RREADY_M0),
	
	// AXI to master 1 (MEM-stage)
		// WRITE ADDRESS
		.AWID_M1   (axi2cpu_interface.AWID_M1),
		.AWADDR_M1 (axi2cpu_interface.AWADDR_M1),
		.AWLEN_M1  (axi2cpu_interface.AWLEN_M1),
		.AWSIZE_M1 (axi2cpu_interface.AWSIZE_M1),
		.AWBURST_M1(axi2cpu_interface.AWBURST_M1),
		.AWVALID_M1(axi2cpu_interface.AWVALID_M1),
		.AWREADY_M1(axi2cpu_interface.AWREADY_M1),
		// WRITE DATA
		.WDATA_M1 (axi2cpu_interface.WDATA_M1),
		.WSTRB_M1 (axi2cpu_interface.WSTRB_M1),
		.WLAST_M1 (axi2cpu_interface.WLAST_M1),
		.WVALID_M1(axi2cpu_interface.WVALID_M1),
		.WREADY_M1(axi2cpu_interface.WREADY_M1),
		// WRITE RESPONSE
		.BID_M1   (axi2cpu_interface.BID_M1),
		.BRESP_M1 (axi2cpu_interface.BRESP_M1),
		.BVALID_M1(axi2cpu_interface.BVALID_M1),
		.BREADY_M1(axi2cpu_interface.BREADY_M1),
		// READ ADDRESS1
		.ARID_M1   (axi2cpu_interface.ARID_M1),
		.ARADDR_M1 (axi2cpu_interface.ARADDR_M1),
		.ARLEN_M1  (axi2cpu_interface.ARLEN_M1),
		.ARSIZE_M1 (axi2cpu_interface.ARSIZE_M1),
		.ARBURST_M1(axi2cpu_interface.ARBURST_M1),
		.ARVALID_M1(axi2cpu_interface.ARVALID_M1),
		.ARREADY_M1(axi2cpu_interface.ARREADY_M1),
		// READ DATA1
		.RID_M1   (axi2cpu_interface.RID_M1),
		.RDATA_M1 (axi2cpu_interface.RDATA_M1),
		.RRESP_M1 (axi2cpu_interface.RRESP_M1),
		.RLAST_M1 (axi2cpu_interface.RLAST_M1),
		.RVALID_M1(axi2cpu_interface.RVALID_M1),
		.RREADY_M1(axi2cpu_interface.RREADY_M1),

	// AXI to slave 0 (IM)
		// WRITE ADDRESS0
		.AWID_S0   (axi2sram0_interface.AWID),
		.AWADDR_S0 (axi2sram0_interface.AWADDR),
		.AWLEN_S0  (axi2sram0_interface.AWLEN),
		.AWSIZE_S0 (axi2sram0_interface.AWSIZE),
		.AWBURST_S0(axi2sram0_interface.AWBURST),
		.AWVALID_S0(axi2sram0_interface.AWVALID),
		.AWREADY_S0(axi2sram0_interface.AWREADY),
		// WRITE DATA0
		.WDATA_S0 (axi2sram0_interface.WDATA),
		.WSTRB_S0 (axi2sram0_interface.WSTRB),
		.WLAST_S0 (axi2sram0_interface.WLAST),
		.WVALID_S0(axi2sram0_interface.WVALID),
		.WREADY_S0(axi2sram0_interface.WREADY),
		// WRITE RESPONSE0
		.BID_S0   (axi2sram0_interface.BID),
		.BRESP_S0 (axi2sram0_interface.BRESP),
		.BVALID_S0(axi2sram0_interface.BVALID),
		.BREADY_S0(axi2sram0_interface.BREADY),
		// READ ADDRESS0
		.ARID_S0   (axi2sram0_interface.ARID),
		.ARADDR_S0 (axi2sram0_interface.ARADDR),
		.ARLEN_S0  (axi2sram0_interface.ARLEN),
		.ARSIZE_S0 (axi2sram0_interface.ARSIZE),
		.ARBURST_S0(axi2sram0_interface.ARBURST),
		.ARVALID_S0(axi2sram0_interface.ARVALID),
		.ARREADY_S0(axi2sram0_interface.ARREADY),
		// READ DATA0
		.RID_S0   (axi2sram0_interface.RID),
		.RDATA_S0 (axi2sram0_interface.RDATA),
		.RRESP_S0 (axi2sram0_interface.RRESP),
		.RLAST_S0 (axi2sram0_interface.RLAST),
		.RVALID_S0(axi2sram0_interface.RVALID),
		.RREADY_S0(axi2sram0_interface.RREADY),
	
	// AXI to slave 1 (DM)
		// WRITE ADDRESS1
		.AWID_S1   (axi2sram1_interface.AWID),
		.AWADDR_S1 (axi2sram1_interface.AWADDR),
		.AWLEN_S1  (axi2sram1_interface.AWLEN),
		.AWSIZE_S1 (axi2sram1_interface.AWSIZE),
		.AWBURST_S1(axi2sram1_interface.AWBURST),
		.AWVALID_S1(axi2sram1_interface.AWVALID),
		.AWREADY_S1(axi2sram1_interface.AWREADY),
		// WRITE DATA1
		.WDATA_S1 (axi2sram1_interface.WDATA),
		.WSTRB_S1 (axi2sram1_interface.WSTRB),
		.WLAST_S1 (axi2sram1_interface.WLAST),
		.WVALID_S1(axi2sram1_interface.WVALID),
		.WREADY_S1(axi2sram1_interface.WREADY),
		// WRITE RESPONSE1
		.BID_S1   (axi2sram1_interface.BID),
		.BRESP_S1 (axi2sram1_interface.BRESP),
		.BVALID_S1(axi2sram1_interface.BVALID),
		.BREADY_S1(axi2sram1_interface.BREADY),
		// READ ADDRESS1
		.ARID_S1   (axi2sram1_interface.ARID),
		.ARADDR_S1 (axi2sram1_interface.ARADDR),
		.ARLEN_S1  (axi2sram1_interface.ARLEN),
		.ARSIZE_S1 (axi2sram1_interface.ARSIZE),
		.ARBURST_S1(axi2sram1_interface.ARBURST),
		.ARVALID_S1(axi2sram1_interface.ARVALID),
		.ARREADY_S1(axi2sram1_interface.ARREADY),
		// READ DATA1
		.RID_S1   (axi2sram1_interface.RID),
		.RDATA_S1 (axi2sram1_interface.RDATA),
		.RRESP_S1 (axi2sram1_interface.RRESP),
		.RLAST_S1 (axi2sram1_interface.RLAST),
		.RVALID_S1(axi2sram1_interface.RVALID),
		.RREADY_S1(axi2sram1_interface.RREADY)
);

endmodule
