package axi_pkg;

  typedef struct ARx_bus {
    logic            [`AXI_ID_BITS-1:0] ARID;
    logic          [`AXI_ADDR_BITS-1:0] ARADDR;
    logic           [`AXI_LEN_BITS-1:0] ARLEN;
    logic          [`AXI_SIZE_BITS-1:0] ARSIZE;
    logic                         [1:0] ARBURST;
    logic                               ARVALID;
    logic                               ARREADY;
  } ARx_bus_t;

  typedef struct Rx_bus {
    logic            [`AXI_ID_BITS-1:0] RID;
    logic          [`AXI_DATA_BITS-1:0] RDATA;
    logic                         [1:0] RRESP;
    logic                               RLAST;
    logic                               RVALID;
    logic                               RREADY;
  } Rx_bus_t;

  typedef struct AWx_bus {
    logic            [`AXI_ID_BITS-1:0] AWID;
    logic          [`AXI_ADDR_BITS-1:0] AWADDR;
    logic           [`AXI_LEN_BITS-1:0] AWLEN;
    logic          [`AXI_SIZE_BITS-1:0] AWSIZE;
    logic                         [1:0] AWBURST;
    logic                               AWVALID;
    logic                               AWREADY;
  } AWx_bus_t;

  typedef struct Wx_bus {
    logic          [`AXI_DATA_BITS-1:0] WDATA;
    logic          [`AXI_STRB_BITS-1:0] WSTRB;
    logic                               WLAST;
    logic                               WVALID;
    logic                               WREADY;
  } Wx_bus_t;

  typedef struct Bx_bus {
    logic            [`AXI_ID_BITS-1:0] BID;
    logic                         [1:0] BRESP;
    logic                               BVALID;
    logic                               BREADY;
  } Bx_bus_t;

endpackage
