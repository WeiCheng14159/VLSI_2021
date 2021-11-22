`include "AXI_define.svh"
interface AXI_slave_intf;
	// AWx
  logic [`AXI_IDS_BITS-1:0] AWID;
  logic [`AXI_ADDR_BITS-1:0] AWADDR;
  logic [`AXI_LEN_BITS-1:0] AWLEN;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE;
  logic [1:0] AWBURST;
  logic AWVALID;
  logic AWREADY;
  // Wx
	logic [`AXI_DATA_BITS-1:0] WDATA;
  logic [`AXI_STRB_BITS-1:0] WSTRB;
  logic WLAST;
  logic WVALID;
  logic WREADY;
  // Bx
	logic [`AXI_IDS_BITS-1:0] BID;
  logic [1:0] BRESP;
  logic BVALID;
  logic BREADY;
  // ARx
	logic [`AXI_IDS_BITS-1:0] ARID;
  logic [`AXI_ADDR_BITS-1:0] ARADDR;
  logic [`AXI_LEN_BITS-1:0] ARLEN;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE;
  logic [1:0] ARBURST;
  logic ARVALID;
  logic ARREADY;
  // Rx
	logic [`AXI_IDS_BITS-1:0] RID;
  logic [`AXI_DATA_BITS-1:0] RDATA;
  logic [1:0] RRESP;
  logic RLAST;
  logic RVALID;
  logic RREADY;

  modport slave(
      input AWID,
      input AWADDR,
      input AWLEN,
      input AWSIZE,
      input AWBURST,
      input AWVALID,
      input WDATA,
      input WSTRB,
      input WLAST,
      input WVALID,
      input BREADY,
      input ARID,
      input ARADDR,
      input ARLEN,
      input ARSIZE,
      input ARBURST,
      input ARVALID,
      input RREADY,
      output AWREADY,
      output WREADY,
      output BID,
      output BRESP,
      output BVALID,
      output ARREADY,
      output RID,
      output RDATA,
      output RRESP,
      output RLAST,
      output RVALID
  );
  modport bridge(
      output AWID,
      output AWADDR,
      output AWLEN,
      output AWSIZE,
      output AWBURST,
      output AWVALID,
      output WDATA,
      output WSTRB,
      output WLAST,
      output WVALID,
      output BREADY,
      output ARID,
      output ARADDR,
      output ARLEN,
      output ARSIZE,
      output ARBURST,
      output ARVALID,
      output RREADY,
      input AWREADY,
      input WREADY,
      input BID,
      input BRESP,
      input BVALID,
      input ARREADY,
      input RID,
      input RDATA,
      input RRESP,
      input RLAST,
      input RVALID
  );
endinterface
