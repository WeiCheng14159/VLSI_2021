`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "AXI.sv"
`include "util.sv"
`include "AXI2CPU.sv"
`include "AXI2SRAM.sv"

module top(
    input logic clk, 
    input logic rst
);

logic                rst_sync;

reset_sync i_reset_sync(
  .clk(clk), 
  .rst_async(rst), 
  .rst_sync(rst_sync)
);

AXI2CPU_interface axi2cpu ();
AXI2SRAM_interface axi2sram0 ();
AXI2SRAM_interface axi2sram1 ();

CPU_wrapper cpu0 (
  .clk, .rst, 
  .cpu2axi_interface(axi2cpu.cpu_ports)
);

AXI axi (
  .ACLK(clk), .ARESETn(~rst),
  
	// AXI to master 0 (IF-stage)
		// READ ADDRESS0
		.ARID_M0(axi2cpu.cpu_ports.ARID_M0),
		.ARADDR_M0(axi2cpu.cpu_ports.ARADDR_M0),
		.ARLEN_M0(axi2cpu.cpu_ports.ARLEN_M0),
		.ARSIZE_M0(axi2cpu.cpu_ports.ARSIZE_M0),
		.ARBURST_M0(axi2cpu.cpu_ports.ARBURST_M0),
		.ARVALID_M0(axi2cpu.cpu_ports.ARVALID_M0),
		.ARREADY_M0(axi2cpu.cpu_ports.ARREADY_M0),
		// READ DATA0
		.RID_M0(axi2cpu.cpu_ports.RID_M0),
		.RDATA_M0(axi2cpu.cpu_ports.RDATA_M0),
		.RRESP_M0(axi2cpu.cpu_ports.RRESP_M0),
		.RLAST_M0(axi2cpu.cpu_ports.RLAST_M0),
		.RVALID_M0(axi2cpu.cpu_ports.RVALID_M0),
		.RREADY_M0(axi2cpu.cpu_ports.RREADY_M0),
	
	// AXI to master 1 (MEM-stage)
		// WRITE ADDRESS
		.AWID_M1(axi2cpu.cpu_ports.AWID_M1),
		.AWADDR_M1(axi2cpu.cpu_ports.AWADDR_M1),
		.AWLEN_M1(axi2cpu.cpu_ports.AWLEN_M1),
		.AWSIZE_M1(axi2cpu.cpu_ports.AWSIZE_M1),
		.AWBURST_M1(axi2cpu.cpu_ports.AWBURST_M1),
		.AWVALID_M1(axi2cpu.cpu_ports.AWVALID_M1),
		.AWREADY_M1(axi2cpu.cpu_ports.AWREADY_M1),
		// WRITE DATA
		.WDATA_M1(axi2cpu.cpu_ports.WDATA_M1),
		.WSTRB_M1(axi2cpu.cpu_ports.WSTRB_M1),
		.WLAST_M1(axi2cpu.cpu_ports.WLAST_M1),
		.WVALID_M1(axi2cpu.cpu_ports.WVALID_M1),
		.WREADY_M1(axi2cpu.cpu_ports.WREADY_M1),
		// WRITE RESPONSE
		.BID_M1(axi2cpu.cpu_ports.BID_M1),
		.BRESP_M1(axi2cpu.cpu_ports.BRESP_M1),
		.BVALID_M1(axi2cpu.cpu_ports.BVALID_M1),
		.BREADY_M1(axi2cpu.cpu_ports.BREADY_M1),
		// READ ADDRESS1
		.ARID_M1(axi2cpu.cpu_ports.ARID_M1),
		.ARADDR_M1(axi2cpu.cpu_ports.ARADDR_M1),
		.ARLEN_M1(axi2cpu.cpu_ports.ARLEN_M1),
		.ARSIZE_M1(axi2cpu.cpu_ports.ARSIZE_M1),
		.ARBURST_M1(axi2cpu.cpu_ports.ARBURST_M1),
		.ARVALID_M1(axi2cpu.cpu_ports.ARVALID_M1),
		.ARREADY_M1(axi2cpu.cpu_ports.ARREADY_M1),
		// READ DATA1
		.RID_M1(axi2cpu.cpu_ports.RID_M1),
		.RDATA_M1(axi2cpu.cpu_ports.RDATA_M1),
		.RRESP_M1(axi2cpu.cpu_ports.RRESP_M1),
		.RLAST_M1(axi2cpu.cpu_ports.RLAST_M1),
		.RVALID_M1(axi2cpu.cpu_ports.RVALID_M1),
		.RREADY_M1(axi2cpu.cpu_ports.RREADY_M1),

	// AXI to slave 0 (IM)
		// WRITE ADDRESS0
		.AWID_S0(axi2sram0.sram_ports.AWID),
		.AWADDR_S0(axi2sram0.sram_ports.AWADDR),
		.AWLEN_S0(axi2sram0.sram_ports.AWLEN),
		.AWSIZE_S0(axi2sram0.sram_ports.AWSIZE),
		.AWBURST_S0(axi2sram0.sram_ports.AWBURST),
		.AWVALID_S0(axi2sram0.sram_ports.AWVALID),
		.AWREADY_S0(axi2sram0.sram_ports.AWREADY),
		// WRITE DATA0
		.WDATA_S0(axi2sram0.sram_ports.WDATA),
		.WSTRB_S0(axi2sram0.sram_ports.WSTRB),
		.WLAST_S0(axi2sram0.sram_ports.WLAST),
		.WVALID_S0(axi2sram0.sram_ports.WVALID),
		.WREADY_S0(axi2sram0.sram_ports.WREADY),
		// WRITE RESPONSE0
		.BID_S0(axi2sram0.sram_ports.BID),
		.BRESP_S0(axi2sram0.sram_ports.BRESP),
		.BVALID_S0(axi2sram0.sram_ports.BVALID),
		.BREADY_S0(axi2sram0.sram_ports.BREADY),
		// READ ADDRESS0
		.ARID_S0(axi2sram0.sram_ports.ARID),
		.ARADDR_S0(axi2sram0.sram_ports.ARADDR),
		.ARLEN_S0(axi2sram0.sram_ports.ARLEN),
		.ARSIZE_S0(axi2sram0.sram_ports.ARSIZE),
		.ARBURST_S0(axi2sram0.sram_ports.ARBURST),
		.ARVALID_S0(axi2sram0.sram_ports.ARVALID),
		.ARREADY_S0(axi2sram0.sram_ports.ARREADY),
		// READ DATA0
		.RID_S0(axi2sram0.sram_ports.RID),
		.RDATA_S0(axi2sram0.sram_ports.RDATA),
		.RRESP_S0(axi2sram0.sram_ports.RRESP),
		.RLAST_S0(axi2sram0.sram_ports.RLAST),
		.RVALID_S0(axi2sram0.sram_ports.RVALID),
		.RREADY_S0(axi2sram0.sram_ports.RREADY),
	
	// AXI to slave 1 (DM)
		// WRITE ADDRESS1
		.AWID_S1(axi2sram1.sram_ports.AWID),
		.AWADDR_S1(axi2sram1.sram_ports.AWADDR),
		.AWLEN_S1(axi2sram1.sram_ports.AWLEN),
		.AWSIZE_S1(axi2sram1.sram_ports.AWSIZE),
		.AWBURST_S1(axi2sram1.sram_ports.AWBURST),
		.AWVALID_S1(axi2sram1.sram_ports.AWVALID),
		.AWREADY_S1(axi2sram1.sram_ports.AWREADY),
		// WRITE DATA1
		.WDATA_S1(axi2sram1.sram_ports.WDATA),
		.WSTRB_S1(axi2sram1.sram_ports.WSTRB),
		.WLAST_S1(axi2sram1.sram_ports.WLAST),
		.WVALID_S1(axi2sram1.sram_ports.WVALID),
		.WREADY_S1(axi2sram1.sram_ports.WREADY),
		// WRITE RESPONSE1
		.BID_S1(axi2sram1.sram_ports.BID),
		.BRESP_S1(axi2sram1.sram_ports.BRESP),
		.BVALID_S1(axi2sram1.sram_ports.BVALID),
		.BREADY_S1(axi2sram1.sram_ports.BREADY),
		// READ ADDRESS1
		.ARID_S1(axi2sram1.sram_ports.ARID),
		.ARADDR_S1(axi2sram1.sram_ports.ARADDR),
		.ARLEN_S1(axi2sram1.sram_ports.ARLEN),
		.ARSIZE_S1(axi2sram1.sram_ports.ARSIZE),
		.ARBURST_S1(axi2sram1.sram_ports.ARBURST),
		.ARVALID_S1(axi2sram1.sram_ports.ARVALID),
		.ARREADY_S1(axi2sram1.sram_ports.ARREADY),
		// READ DATA1
		.RID_S1(axi2sram1.sram_ports.RID),
		.RDATA_S1(axi2sram1.sram_ports.RDATA),
		.RRESP_S1(axi2sram1.sram_ports.RRESP),
		.RLAST_S1(axi2sram1.sram_ports.RLAST),
		.RVALID_S1(axi2sram1.sram_ports.RVALID),
		.RREADY_S1(axi2sram1.sram_ports.RREADY)
);

SRAM_wrapper IM1(
  .clk, .rst, .sram2axi_interface(axi2sram0.sram_ports)
);

SRAM_wrapper DM1(
  .clk, .rst, .sram2axi_interface(axi2sram1.sram_ports)
);

endmodule
