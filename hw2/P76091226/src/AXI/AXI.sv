//================================================
// Auther:      Chen Tsung-Chi (Michael)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "AXI_define.svh"
`include "axi_pkg.sv"
`include "ARx.sv"
`include "Rx.sv"
`include "AWx.sv"
`include "Wx.sv"
`include "Bx.sv"

module AXI
  import axi_pkg::*;
(
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

// SASD architecture
// Master 0 : CPU IF stage
// Master 1 : CPU MEM stage
// Slave 0 : SRAM IM
// Slave 1 : SRAM DM

// Default Slave
logic              [`AXI_IDS_BITS-1:0 ] ARID_DEFAULT;
logic              [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT;
logic              [`AXI_LEN_BITS-1:0 ] ARLEN_DEFAULT;
logic              [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT;
logic              [1:0               ] ARBURST_DEFAULT;
logic                                   ARVALID_DEFAULT;
logic                                   ARREADY_DEFAULT;

logic              [`AXI_IDS_BITS-1:0 ] AWID_DEFAULT;
logic              [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT;
logic              [`AXI_LEN_BITS-1:0 ] AWLEN_DEFAULT;
logic              [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT;
logic              [1:0               ] AWBURST_DEFAULT;
logic                                   AWVALID_DEFAULT;
logic                                   AWREADY_DEFAULT;

logic              [`AXI_DATA_BITS-1:0] WDATA_DEFAULT;
logic              [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT;
logic                                   WLAST_DEFAULT;
logic                                   WVALID_DEFAULT;
logic                                   WREADY_DEFAULT;

logic               [`AXI_IDS_BITS-1:0] BID_DEFAULT;
logic               [1:0] BRESP_DEFAULT;
logic                                   BVALID_DEFAULT;
logic                                   BREADY_DEFAULT;

logic               [`AXI_IDS_BITS-1:0] RID_DEFAULT;
logic              [`AXI_DATA_BITS-1:0] RDATA_DEFAULT;
logic                             [1:0] RRESP_DEFAULT;
logic                                   RLAST_DEFAULT;
logic                                   RVALID_DEFAULT;
logic                                   RREADY_DEFAULT;

// localparam EMPTY_ADDR = 32'h0, EMPTY_DATA = 32'h0;

// ARx
ARx ARx(
  .clk(ACLK),
  .rstn(ARESETn),
    // Master 0
  .ID_M0(ARID_M0),
  .ADDR_M0(ARADDR_M0),
  .LEN_M0(ARLEN_M0),
  .SIZE_M0(ARSIZE_M0),
  .BURST_M0(ARBURST_M0),
  .VALID_M0(ARVALID_M0),
  .READY_M0(ARREADY_M0),
    // Master 1
  .ID_M1(ARID_M1),
  .ADDR_M1(ARADDR_M1),
  .LEN_M1(ARLEN_M1),
  .SIZE_M1(ARSIZE_M1),
  .BURST_M1(ARBURST_M1),
  .VALID_M1(ARVALID_M1),
  .READY_M1(ARREADY_M1),
    // Slave resp
  .READY_S0(ARREADY_S0),
  .READY_S1(ARREADY_S1),
  .READY_S2(ARREADY_DEFAULT),
    // Slave 0
  .ID_S0(ARID_S0),
  .ADDR_S0(ARADDR_S0),
  .LEN_S0(ARLEN_S0),
  .SIZE_S0(ARSIZE_S0),
  .BURST_S0(ARBURST_S0),
  .VALID_S0(ARVALID_S0),
    // Slave 1
  .ID_S1(ARID_S1),
  .ADDR_S1(ARADDR_S1),
  .LEN_S1(ARLEN_S1),
  .SIZE_S1(ARSIZE_S1),
  .BURST_S1(ARBURST_S1),
  .VALID_S1(ARVALID_S1),
    // Default Slave 
  .ID_S2(ARID_DEFAULT),
  .ADDR_S2(ARADDR_DEFAULT),
  .LEN_S2(ARLEN_DEFAULT),
  .SIZE_S2(ARSIZE_DEFAULT),
  .BURST_S2(ARBURST_DEFAULT),
  .VALID_S2(ARVALID_DEFAULT)
);

// Rx
Rx Rx(
  .clk(ACLK),
  .rstn(ARESETn),
    // Master 0 
  .RID_M0(RID_M0),
  .RDATA_M0(RDATA_M0),
  .RLAST_M0(RLAST_M0),
  .RRESP_M0(RRESP_M0),
  .RVALID_M0(RVALID_M0),
  .RREADY_M0(RREADY_M0),
    // Master 1
  .RID_M1(RID_M1),
  .RDATA_M1(RDATA_M1),
  .RRESP_M1(RRESP_M1),
  .RLAST_M1(RLAST_M1),
  .RVALID_M1(RVALID_M1),
  .RREADY_M1(RREADY_M1),
    // Slave 0
  .RID_S0(RID_S0),
  .RDATA_S0(RDATA_S0),
  .RRESP_S0(RRESP_S0),
  .RLAST_S0(RLAST_S0),
  .RVALID_S0(RVALID_S0),
  .RREADY_S0(RREADY_S0),
    // Slave 1
  .RID_S1(RID_S1),
  .RDATA_S1(RDATA_S1),
  .RRESP_S1(RRESP_S1),
  .RLAST_S1(RLAST_S1),
  .RVALID_S1(RVALID_S1),
  .RREADY_S1(RREADY_S1),
    // Slave 2
  .RID_S2(RID_DEFAULT),
  .RDATA_S2 (RDATA_DEFAULT),
  .RRESP_S2 (RRESP_DEFAULT),
  .RLAST_S2 (RLAST_DEFAULT),
  .RVALID_S2(RVALID_DEFAULT),
  .RREADY_S2(RREADY_DEFAULT)
);

// AWx
AWx AWx(
  .clk(ACLK),
  .rstn(ARESETn),
    // Master1
  .ID_M1(AWID_M1),
  .ADDR_M1(AWADDR_M1),
  .LEN_M1(AWLEN_M1),
  .SIZE_M1(AWSIZE_M1),
  .BURST_M1(AWBURST_M1),
  .VALID_M1(AWVALID_M1),
  .READY_M1(AWREADY_M1),
    // Slave resp
  .READY_S0(AWREADY_S0),
  .READY_S1(AWREADY_S1),
  .READY_S2(AWREADY_DEFAULT),
    // Slave 0
  .ID_S0(AWID_S0),
  .ADDR_S0(AWADDR_S0),
  .LEN_S0(AWLEN_S0),
  .SIZE_S0(AWSIZE_S0),
  .BURST_S0(AWBURST_S0),
  .VALID_S0(AWVALID_S0),
    // Slave 1
  .ID_S1(AWID_S1),
  .ADDR_S1(AWADDR_S1),
  .LEN_S1(AWLEN_S1),
  .SIZE_S1(AWSIZE_S1),
  .BURST_S1(AWBURST_S1),
  .VALID_S1(AWVALID_S1),
    // Default Slave
  .ID_S2(AWID_DEFAULT),
  .ADDR_S2(AWADDR_DEFAULT),
  .LEN_S2(AWLEN_DEFAULT),
  .SIZE_S2(AWSIZE_DEFAULT),
  .BURST_S2(AWBURST_DEFAULT),
  .VALID_S2(AWVALID_DEFAULT)
);

Wx Wx(
  .clk(ACLK),
  .rstn(ARESETn),
    // Master 1
  .WDATA_M1(WDATA_M1),
  .WSTRB_M1(WSTRB_M1),
  .WLAST_M1(WLAST_M1),
  .WVALID_M1(WVALID_M1),
  .WREADY_M1(WREADY_M1),
    // Slave 0
  .WDATA_S0(WDATA_S0),
  .WSTRB_S0(WSTRB_S0),
  .WLAST_S0(WLAST_S0),
  .WVALID_S0(WVALID_S0),
  .WREADY_S0(WREADY_S0),
  .AWVALID_S0(AWVALID_S0),
  .AWREADY_S0(AWREADY_S0),
    // Slave 1
  .WDATA_S1(WDATA_S1),
  .WSTRB_S1(WSTRB_S1),
  .WLAST_S1(WLAST_S1),
  .WVALID_S1(WVALID_S1),
  .WREADY_S1(WREADY_S1),
  .AWVALID_S1(AWVALID_S1),
  .AWREADY_S1(AWREADY_S1),
    // Slave 2
  .WDATA_S2(WDATA_DEFAULT),
  .WSTRB_S2(WSTRB_DEFAULT),
  .WLAST_S2(WLAST_DEFAULT),
  .WVALID_S2(WVALID_DEFAULT),
  .WREADY_S2(WREADY_DEFAULT),
  .AWVALID_S2(AWVALID_DEFAULT),
  .AWREADY_S2(AWREADY_DEFAULT)
);

Bx Bx(
  .clk(ACLK),
  .rstn(ARESETn),
    // Master 1
  .BID_M1(BID_M1),
  .BRESP_M1(BRESP_M1),
  .BVALID_M1(BVALID_M1),
  .BREADY_M1(BREADY_M1),
    // Slave 0
  .BID_S0(BID_S0),
  .BRESP_S0(BRESP_S0),
  .BVALID_S0(BVALID_S0),
  .BREADY_S0(BREADY_S0),
    // Slave 1
  .BID_S1(BID_S1),
  .BRESP_S1(BRESP_S1),
  .BVALID_S1(BVALID_S1),
  .BREADY_S1(BREADY_S1),
    // Slave 2
  .BID_S2(BID_DEFAULT),
  .BRESP_S2(BRESP_DEFAULT),
  .BVALID_S2(BVALID_DEFAULT),
  .BREADY_S2(BREADY_DEFAULT)
);

endmodule
