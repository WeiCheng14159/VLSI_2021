`ifndef AXI_MASTER_INTF_SV
`define AXI_MASTER_INTF_SV

`include "AXI_define.svh"

interface AXI_master_intf;
  // AWx
  logic [  `AXI_ID_BITS-1:0] AWID;
  logic [`AXI_ADDR_BITS-1:0] AWADDR;
  logic [ `AXI_LEN_BITS-1:0] AWLEN;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE;
  logic [               1:0] AWBURST;
  logic                      AWVALID;
  logic                      AWREADY;
  // Wx
  logic [`AXI_DATA_BITS-1:0] WDATA;
  logic [`AXI_STRB_BITS-1:0] WSTRB;
  logic                      WLAST;
  logic                      WVALID;
  logic                      WREADY;
  // Bx
  logic [  `AXI_ID_BITS-1:0] BID;
  logic [               1:0] BRESP;
  logic                      BVALID;
  logic                      BREADY;
  // ARx
  logic [  `AXI_ID_BITS-1:0] ARID;
  logic [`AXI_ADDR_BITS-1:0] ARADDR;
  logic [ `AXI_LEN_BITS-1:0] ARLEN;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE;
  logic [               1:0] ARBURST;
  logic                      ARVALID;
  logic                      ARREADY;
  // Rx
  logic [  `AXI_ID_BITS-1:0] RID;
  logic [`AXI_DATA_BITS-1:0] RDATA;
  logic [               1:0] RRESP;
  logic                      RLAST;
  logic                      RVALID;
  logic                      RREADY;

  modport master(
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
      output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID,
      // Rx
      input RID, RDATA, RRESP, RLAST, RVALID,
      output RREADY
  );

  modport bridge(
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
      input ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID,
      // Rx
      output RID, RDATA, RRESP, RLAST, RVALID,
      input RREADY
  );

endinterface

`endif
