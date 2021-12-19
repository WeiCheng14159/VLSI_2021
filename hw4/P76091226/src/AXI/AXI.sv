//================================================
// Auther:      Chen Tsung-Chi (Michael)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "pkg_include.sv"
`include "default_slave.sv"
`include "ARx.sv"
`include "Rx.sv"
`include "AWx.sv"
`include "Wx.sv"
`include "Bx.sv"

module AXI
  import axi_pkg::*;
(
    input logic ACLK,
    input logic ARESETn,
    // Master
    AXI_master_intf.bridge master0,
    AXI_master_intf.bridge master1,
    AXI_master_intf.bridge master2,
    // Slave
    AXI_slave_intf.bridge slave0,
    AXI_slave_intf.bridge slave1,
    AXI_slave_intf.bridge slave2,
    AXI_slave_intf.bridge slave3,
    AXI_slave_intf.bridge slave4,
    AXI_slave_intf.bridge slave5,
    AXI_slave_intf.bridge slave6
);

  // ARx
  ARx ARx (
      .clk(ACLK),
      .rstn(ARESETn),
      // Master 0
      .ARID_M0(master0.ARID),
      .ARADDR_M0(master0.ARADDR),
      .ARLEN_M0(master0.ARLEN),
      .ARSIZE_M0(master0.ARSIZE),
      .ARBURST_M0(master0.ARBURST),
      .ARVALID_M0(master0.ARVALID),
      .ARREADY_M0(master0.ARREADY),
      .RREADY_M0(master0.RREADY),
      .RLAST_M0(master0.RLAST),
      // Master 1
      .ARID_M1(master1.ARID),
      .ARADDR_M1(master1.ARADDR),
      .ARLEN_M1(master1.ARLEN),
      .ARSIZE_M1(master1.ARSIZE),
      .ARBURST_M1(master1.ARBURST),
      .ARVALID_M1(master1.ARVALID),
      .ARREADY_M1(master1.ARREADY),
      .RREADY_M1(master1.RREADY),
      .RLAST_M1(master1.RLAST),
      // Master 2
      .ARID_M2(master2.ARID),
      .ARADDR_M2(master2.ARADDR),
      .ARLEN_M2(master2.ARLEN),
      .ARSIZE_M2(master2.ARSIZE),
      .ARBURST_M2(master2.ARBURST),
      .ARVALID_M2(master2.ARVALID),
      .ARREADY_M2(master2.ARREADY),
      .RREADY_M2(master2.RREADY),
      .RLAST_M2(master2.RLAST),
      // Slave resp
      .ARREADY_S0(slave0.ARREADY),
      .ARREADY_S1(slave1.ARREADY),
      .ARREADY_S2(slave2.ARREADY),
      .ARREADY_S3(slave3.ARREADY),
      .ARREADY_S4(slave4.ARREADY),
      .ARREADY_S5(slave5.ARREADY),
      .ARREADY_S6(slave6.ARREADY),
      // Slave 0
      .ARID_S0(slave0.ARID),
      .ARADDR_S0(slave0.ARADDR),
      .ARLEN_S0(slave0.ARLEN),
      .ARSIZE_S0(slave0.ARSIZE),
      .ARBURST_S0(slave0.ARBURST),
      .ARVALID_S0(slave0.ARVALID),
      .RLAST_S0(slave0.RLAST),
      .RREADY_S0(slave0.RREADY),
      // Slave 1
      .ARID_S1(slave1.ARID),
      .ARADDR_S1(slave1.ARADDR),
      .ARLEN_S1(slave1.ARLEN),
      .ARSIZE_S1(slave1.ARSIZE),
      .ARBURST_S1(slave1.ARBURST),
      .ARVALID_S1(slave1.ARVALID),
      .RLAST_S1(slave1.RLAST),
      .RREADY_S1(slave1.RREADY),
      // Slave 2
      .ARID_S2(slave2.ARID),
      .ARADDR_S2(slave2.ARADDR),
      .ARLEN_S2(slave2.ARLEN),
      .ARSIZE_S2(slave2.ARSIZE),
      .ARBURST_S2(slave2.ARBURST),
      .ARVALID_S2(slave2.ARVALID),
      .RLAST_S2(slave2.RLAST),
      .RREADY_S2(slave2.RREADY),
      // Slave 3
      .ARID_S3(slave3.ARID),
      .ARADDR_S3(slave3.ARADDR),
      .ARLEN_S3(slave3.ARLEN),
      .ARSIZE_S3(slave3.ARSIZE),
      .ARBURST_S3(slave3.ARBURST),
      .ARVALID_S3(slave3.ARVALID),
      .RLAST_S3(slave3.RLAST),
      .RREADY_S3(slave3.RREADY),
      // Slave 4
      .ARID_S4(slave4.ARID),
      .ARADDR_S4(slave4.ARADDR),
      .ARLEN_S4(slave4.ARLEN),
      .ARSIZE_S4(slave4.ARSIZE),
      .ARBURST_S4(slave4.ARBURST),
      .ARVALID_S4(slave4.ARVALID),
      .RLAST_S4(slave4.RLAST),
      .RREADY_S4(slave4.RREADY),
      // Slave 5
      .ARID_S5(slave5.ARID),
      .ARADDR_S5(slave5.ARADDR),
      .ARLEN_S5(slave5.ARLEN),
      .ARSIZE_S5(slave5.ARSIZE),
      .ARBURST_S5(slave5.ARBURST),
      .ARVALID_S5(slave5.ARVALID),
      .RLAST_S5(slave5.RLAST),
      .RREADY_S5(slave5.RREADY),
      // Slave 6
      .ARID_S6(slave6.ARID),
      .ARADDR_S6(slave6.ARADDR),
      .ARLEN_S6(slave6.ARLEN),
      .ARSIZE_S6(slave6.ARSIZE),
      .ARBURST_S6(slave6.ARBURST),
      .ARVALID_S6(slave6.ARVALID),
      .RLAST_S6(slave6.RLAST),
      .RREADY_S6(slave6.RREADY)
  );

  // Rx
  Rx Rx (
      .clk(ACLK),
      .rstn(ARESETn),
      // Master 0 
      .RID_M0(master0.RID),
      .RDATA_M0(master0.RDATA),
      .RLAST_M0(master0.RLAST),
      .RRESP_M0(master0.RRESP),
      .RVALID_M0(master0.RVALID),
      .RREADY_M0(master0.RREADY),
      // Master 1
      .RID_M1(master1.RID),
      .RDATA_M1(master1.RDATA),
      .RRESP_M1(master1.RRESP),
      .RLAST_M1(master1.RLAST),
      .RVALID_M1(master1.RVALID),
      .RREADY_M1(master1.RREADY),
      // Master 2
      .RID_M2(master2.RID),
      .RDATA_M2(master2.RDATA),
      .RRESP_M2(master2.RRESP),
      .RLAST_M2(master2.RLAST),
      .RVALID_M2(master2.RVALID),
      .RREADY_M2(master2.RREADY),
      // Slave 0
      .RID_S0(slave0.RID),
      .RDATA_S0(slave0.RDATA),
      .RRESP_S0(slave0.RRESP),
      .RLAST_S0(slave0.RLAST),
      .RVALID_S0(slave0.RVALID),
      .RREADY_S0(slave0.RREADY),
      // Slave 1
      .RID_S1(slave1.RID),
      .RDATA_S1(slave1.RDATA),
      .RRESP_S1(slave1.RRESP),
      .RLAST_S1(slave1.RLAST),
      .RVALID_S1(slave1.RVALID),
      .RREADY_S1(slave1.RREADY),
      // Slave 2
      .RID_S2(slave2.RID),
      .RDATA_S2(slave2.RDATA),
      .RRESP_S2(slave2.RRESP),
      .RLAST_S2(slave2.RLAST),
      .RVALID_S2(slave2.RVALID),
      .RREADY_S2(slave2.RREADY),
      // Slave 3
      .RID_S3(slave3.RID),
      .RDATA_S3(slave3.RDATA),
      .RRESP_S3(slave3.RRESP),
      .RLAST_S3(slave3.RLAST),
      .RVALID_S3(slave3.RVALID),
      .RREADY_S3(slave3.RREADY),
      // Slave 4
      .RID_S4(slave4.RID),
      .RDATA_S4(slave4.RDATA),
      .RRESP_S4(slave4.RRESP),
      .RLAST_S4(slave4.RLAST),
      .RVALID_S4(slave4.RVALID),
      .RREADY_S4(slave4.RREADY),
      // Slave 5
      .RID_S5(slave5.RID),
      .RDATA_S5(slave5.RDATA),
      .RRESP_S5(slave5.RRESP),
      .RLAST_S5(slave5.RLAST),
      .RVALID_S5(slave5.RVALID),
      .RREADY_S5(slave5.RREADY),
      // Slave 6
      .RID_S6(slave6.RID),
      .RDATA_S6(slave6.RDATA),
      .RRESP_S6(slave6.RRESP),
      .RLAST_S6(slave6.RLAST),
      .RVALID_S6(slave6.RVALID),
      .RREADY_S6(slave6.RREADY)
  );

  // AWx
  AWx AWx (
      .clk(ACLK),
      .rstn(ARESETn),
      // Master 0
      .AWID_M0(master0.AWID),
      .AWADDR_M0(master0.AWADDR),
      .AWLEN_M0(master0.AWLEN),
      .AWSIZE_M0(master0.AWSIZE),
      .AWBURST_M0(master0.AWBURST),
      .AWVALID_M0(master0.AWVALID),
      .AWREADY_M0(master0.AWREADY),
      .BREADY_M0(master0.BREADY),
      .BVALID_M0(master0.BVALID),
      // Master 1
      .AWID_M1(master1.AWID),
      .AWADDR_M1(master1.AWADDR),
      .AWLEN_M1(master1.AWLEN),
      .AWSIZE_M1(master1.AWSIZE),
      .AWBURST_M1(master1.AWBURST),
      .AWVALID_M1(master1.AWVALID),
      .AWREADY_M1(master1.AWREADY),
      .BREADY_M1(master1.BREADY),
      .BVALID_M1(master1.BVALID),
      // Master 2
      .AWID_M2(master2.AWID),
      .AWADDR_M2(master2.AWADDR),
      .AWLEN_M2(master2.AWLEN),
      .AWSIZE_M2(master2.AWSIZE),
      .AWBURST_M2(master2.AWBURST),
      .AWVALID_M2(master2.AWVALID),
      .AWREADY_M2(master2.AWREADY),
      .BREADY_M2(master2.BREADY),
      .BVALID_M2(master2.BVALID),
      // Slave resp
      .AWREADY_S0(slave0.AWREADY),
      .AWREADY_S1(slave1.AWREADY),
      .AWREADY_S2(slave2.AWREADY),
      .AWREADY_S3(slave3.AWREADY),
      .AWREADY_S4(slave4.AWREADY),
      .AWREADY_S5(slave5.AWREADY),
      .AWREADY_S6(slave6.AWREADY),
      // Slave 0
      .AWID_S0(slave0.AWID),
      .AWADDR_S0(slave0.AWADDR),
      .AWLEN_S0(slave0.AWLEN),
      .AWSIZE_S0(slave0.AWSIZE),
      .AWBURST_S0(slave0.AWBURST),
      .AWVALID_S0(slave0.AWVALID),
      // Slave 1
      .AWID_S1(slave1.AWID),
      .AWADDR_S1(slave1.AWADDR),
      .AWLEN_S1(slave1.AWLEN),
      .AWSIZE_S1(slave1.AWSIZE),
      .AWBURST_S1(slave1.AWBURST),
      .AWVALID_S1(slave1.AWVALID),
      // slave 2
      .AWID_S2(slave2.AWID),
      .AWADDR_S2(slave2.AWADDR),
      .AWLEN_S2(slave2.AWLEN),
      .AWSIZE_S2(slave2.AWSIZE),
      .AWBURST_S2(slave2.AWBURST),
      .AWVALID_S2(slave2.AWVALID),
      // slave 3
      .AWID_S3(slave3.AWID),
      .AWADDR_S3(slave3.AWADDR),
      .AWLEN_S3(slave3.AWLEN),
      .AWSIZE_S3(slave3.AWSIZE),
      .AWBURST_S3(slave3.AWBURST),
      .AWVALID_S3(slave3.AWVALID),
      // slave 4
      .AWID_S4(slave4.AWID),
      .AWADDR_S4(slave4.AWADDR),
      .AWLEN_S4(slave4.AWLEN),
      .AWSIZE_S4(slave4.AWSIZE),
      .AWBURST_S4(slave4.AWBURST),
      .AWVALID_S4(slave4.AWVALID),
      // slave 5
      .AWID_S5(slave5.AWID),
      .AWADDR_S5(slave5.AWADDR),
      .AWLEN_S5(slave5.AWLEN),
      .AWSIZE_S5(slave5.AWSIZE),
      .AWBURST_S5(slave5.AWBURST),
      .AWVALID_S5(slave5.AWVALID),
      // slave 6
      .AWID_S6(slave6.AWID),
      .AWADDR_S6(slave6.AWADDR),
      .AWLEN_S6(slave6.AWLEN),
      .AWSIZE_S6(slave6.AWSIZE),
      .AWBURST_S6(slave6.AWBURST),
      .AWVALID_S6(slave6.AWVALID)
  );

  Wx Wx (
      .clk(ACLK),
      .rstn(ARESETn),
      // Master 0
      .WDATA_M0(master0.WDATA),
      .WSTRB_M0(master0.WSTRB),
      .WLAST_M0(master0.WLAST),
      .WVALID_M0(master0.WVALID),
      .WREADY_M0(master0.WREADY),
      .AWVALID_M0(master0.AWVALID),
      // Master 1
      .WDATA_M1(master1.WDATA),
      .WSTRB_M1(master1.WSTRB),
      .WLAST_M1(master1.WLAST),
      .WVALID_M1(master1.WVALID),
      .WREADY_M1(master1.WREADY),
      .AWVALID_M1(master1.AWVALID),
      // Master 2
      .WDATA_M2(master2.WDATA),
      .WSTRB_M2(master2.WSTRB),
      .WLAST_M2(master2.WLAST),
      .WVALID_M2(master2.WVALID),
      .WREADY_M2(master2.WREADY),
      .AWVALID_M2(master2.AWVALID),
      // Slave 0
      .WDATA_S0(slave0.WDATA),
      .WSTRB_S0(slave0.WSTRB),
      .WLAST_S0(slave0.WLAST),
      .WVALID_S0(slave0.WVALID),
      .WREADY_S0(slave0.WREADY),
      .AWVALID_S0(slave0.AWVALID),
      .AWREADY_S0(slave0.AWREADY),
      // Slave 1
      .WDATA_S1(slave1.WDATA),
      .WSTRB_S1(slave1.WSTRB),
      .WLAST_S1(slave1.WLAST),
      .WVALID_S1(slave1.WVALID),
      .WREADY_S1(slave1.WREADY),
      .AWVALID_S1(slave1.AWVALID),
      .AWREADY_S1(slave1.AWREADY),
      // Slave 2
      .WDATA_S2(slave2.WDATA),
      .WSTRB_S2(slave2.WSTRB),
      .WLAST_S2(slave2.WLAST),
      .WVALID_S2(slave2.WVALID),
      .WREADY_S2(slave2.WREADY),
      .AWVALID_S2(slave2.AWVALID),
      .AWREADY_S2(slave2.AWREADY),
      // Slave 3
      .WDATA_S3(slave3.WDATA),
      .WSTRB_S3(slave3.WSTRB),
      .WLAST_S3(slave3.WLAST),
      .WVALID_S3(slave3.WVALID),
      .WREADY_S3(slave3.WREADY),
      .AWVALID_S3(slave3.AWVALID),
      .AWREADY_S3(slave3.AWREADY),
      // Slave 4
      .WDATA_S4(slave4.WDATA),
      .WSTRB_S4(slave4.WSTRB),
      .WLAST_S4(slave4.WLAST),
      .WVALID_S4(slave4.WVALID),
      .WREADY_S4(slave4.WREADY),
      .AWVALID_S4(slave4.AWVALID),
      .AWREADY_S4(slave4.AWREADY),
      // Slave 5
      .WDATA_S5(slave5.WDATA),
      .WSTRB_S5(slave5.WSTRB),
      .WLAST_S5(slave5.WLAST),
      .WVALID_S5(slave5.WVALID),
      .WREADY_S5(slave5.WREADY),
      .AWVALID_S5(slave5.AWVALID),
      .AWREADY_S5(slave5.AWREADY),
      // Slave 6
      .WDATA_S6(slave6.WDATA),
      .WSTRB_S6(slave6.WSTRB),
      .WLAST_S6(slave6.WLAST),
      .WVALID_S6(slave6.WVALID),
      .WREADY_S6(slave6.WREADY),
      .AWVALID_S6(slave6.AWVALID),
      .AWREADY_S6(slave6.AWREADY)
  );

  Bx Bx (
      .clk(ACLK),
      .rstn(ARESETn),
      // Master 0
      .BID_M0(master0.BID),
      .BRESP_M0(master0.BRESP),
      .BVALID_M0(master0.BVALID),
      .BREADY_M0(master0.BREADY),
      .WVALID_M0(master0.WVALID),
      .WREADY_M0(master0.WREADY),
      .WLAST_M0(master0.WLAST),
      // Master 1
      .BID_M1(master1.BID),
      .BRESP_M1(master1.BRESP),
      .BVALID_M1(master1.BVALID),
      .BREADY_M1(master1.BREADY),
      .WVALID_M1(master1.WVALID),
      .WREADY_M1(master1.WREADY),
      .WLAST_M1(master1.WLAST),
      // Master 2
      .BID_M2(master2.BID),
      .BRESP_M2(master2.BRESP),
      .BVALID_M2(master2.BVALID),
      .BREADY_M2(master2.BREADY),
      .WVALID_M2(master2.WVALID),
      .WREADY_M2(master2.WREADY),
      .WLAST_M2(master2.WLAST),
      // Slave 0
      .BID_S0(slave0.BID),
      .BRESP_S0(slave0.BRESP),
      .BVALID_S0(slave0.BVALID),
      .BREADY_S0(slave0.BREADY),
      // Slave 1
      .BID_S1(slave1.BID),
      .BRESP_S1(slave1.BRESP),
      .BVALID_S1(slave1.BVALID),
      .BREADY_S1(slave1.BREADY),
      // Slave 2
      .BID_S2(slave2.BID),
      .BRESP_S2(slave2.BRESP),
      .BVALID_S2(slave2.BVALID),
      .BREADY_S2(slave2.BREADY),
      // Slave 3
      .BID_S3(slave3.BID),
      .BRESP_S3(slave3.BRESP),
      .BVALID_S3(slave3.BVALID),
      .BREADY_S3(slave3.BREADY),
      // Slave 4
      .BID_S4(slave4.BID),
      .BRESP_S4(slave4.BRESP),
      .BVALID_S4(slave4.BVALID),
      .BREADY_S4(slave4.BREADY),
      // Slave 5
      .BID_S5(slave5.BID),
      .BRESP_S5(slave5.BRESP),
      .BVALID_S5(slave5.BVALID),
      .BREADY_S5(slave5.BREADY),
      // Slave 6
      .BID_S6(slave6.BID),
      .BRESP_S6(slave6.BRESP),
      .BVALID_S6(slave6.BVALID),
      .BREADY_S6(slave6.BREADY)
  );

endmodule
