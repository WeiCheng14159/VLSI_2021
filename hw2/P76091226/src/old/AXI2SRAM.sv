`include "AXI_define.svh"
`include "axi_pkg.sv"

interface AXI2SRAM_interface;

  //WRITE ADDRESS
  logic             [`AXI_IDS_BITS-1:0] AWID;
  logic            [`AXI_ADDR_BITS-1:0] AWADDR;
  logic             [`AXI_LEN_BITS-1:0] AWLEN;
  logic            [`AXI_SIZE_BITS-1:0] AWSIZE;
  logic                           [1:0] AWBURST;
  logic                                 AWVALID;
  logic                                 AWREADY;
  //WRITE DATA
  logic            [`AXI_DATA_BITS-1:0] WDATA;
  logic            [`AXI_STRB_BITS-1:0] WSTRB;
  logic                                 WLAST;
  logic                                 WVALID;
  logic                                WREADY;
  //WRITE RESPONSE
  logic             [`AXI_IDS_BITS-1:0] BID;
  logic                           [1:0] BRESP;
  logic                                 BVALID;
  logic                                 BREADY;
  //READ ADDRESM
  logic              [`AXI_ID_BITS-1:0] ARID;
  logic            [`AXI_ADDR_BITS-1:0] ARADDR;
  logic             [`AXI_LEN_BITS-1:0] ARLEN;
  logic            [`AXI_SIZE_BITS-1:0] ARSIZE;
  logic                           [1:0] ARBURST
  logic                                 ARVALID;
  logic                                 ARREADY;
  //READ DATA
  logic              [`AXI_ID_BITS-1:0] RID;
  logic            [`AXI_DATA_BITS-1:0] RDATA;
  logic                           [1:0] RRESP;
  logic                                 RLAST;
  logic                                 RVALID;
  logic                                 RREADY;

  modport axi_ports (
    // AWx
    input AWREADY,
    output AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID,
    // Wx
    input WREADY,
    output WDATA, WSTRB, WLAST, WVALID,
    // Bx
    input BID, BRESP, BVALID,
    output BREADY,
    // ARx
    input ARREADY,
    output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID
  );

  modport sram_ports (
    // AWx
    output AWREADY,
    input AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID,
    // Wx
    output WREADY,
    input WDATA, WSTRB, WLAST, WVALID,
    // Bx
    output BID, BRESP, BVALID,
    input BREADY,
    // ARx
    output ARREADY,
    input ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID
  );

endinterface : AXI2SRAM_interface
