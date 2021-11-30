`ifndef AXI_SLAVE_INTF_SV
`define AXI_SLAVE_INTF_SV

`include "AXI_define.svh"

interface AXI_slave_intf;
  // AWx
  logic [  `AXI_IDS_BITS-1:0] AWID;
  logic [ `AXI_ADDR_BITS-1:0] AWADDR;
  logic [  `AXI_LEN_BITS-1:0] AWLEN;
  logic [ `AXI_SIZE_BITS-1:0] AWSIZE;
  logic [`AXI_BURST_BITS-1:0] AWBURST;
  logic                       AWVALID;
  logic                       AWREADY;
  // Wx
  logic [ `AXI_DATA_BITS-1:0] WDATA;
  logic [ `AXI_STRB_BITS-1:0] WSTRB;
  logic                       WLAST;
  logic                       WVALID;
  logic                       WREADY;
  // Bx
  logic [  `AXI_IDS_BITS-1:0] BID;
  logic [ `AXI_RESP_BITS-1:0] BRESP;
  logic                       BVALID;
  logic                       BREADY;
  // ARx
  logic [  `AXI_IDS_BITS-1:0] ARID;
  logic [ `AXI_ADDR_BITS-1:0] ARADDR;
  logic [  `AXI_LEN_BITS-1:0] ARLEN;
  logic [ `AXI_SIZE_BITS-1:0] ARSIZE;
  logic [`AXI_BURST_BITS-1:0] ARBURST;
  logic                       ARVALID;
  logic                       ARREADY;
  // Rx
  logic [  `AXI_IDS_BITS-1:0] RID;
  logic [ `AXI_DATA_BITS-1:0] RDATA;
  logic [ `AXI_RESP_BITS-1:0] RRESP;
  logic                       RLAST;
  logic                       RVALID;
  logic                       RREADY;

  modport slave(
      // AWx
      input AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID,
      output AWREADY,
      // Wx
      input WDATA, WSTRB, WLAST, WVALID,
      output WREADY,
      // Bx
      input BREADY,
      output BID, BRESP, BVALID,
      // ARx
      input ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID,
      output ARREADY,
      // Rx
      input RREADY,
      output RID, RDATA, RRESP, RLAST, RVALID
  );

  modport bridge(
      // AWx
      output AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID,
      input AWREADY,
      // Wx
      output WDATA, WSTRB, WLAST, WVALID,
      input WREADY,
      // Bx
      output BREADY,
      input BID, BRESP, BVALID,
      // ARx
      output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID,
      input ARREADY,
      // Rx
      output RREADY,
      input RID, RDATA, RRESP, RLAST, RVALID
  );

endinterface

`endif
