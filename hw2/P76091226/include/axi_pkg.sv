`ifndef AXI_PKG_SV
`define AXI_PKG_SV

`include "AXI_define.svh"

package axi_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  // typedef struct packed {
  //   logic            [`AXI_ID_BITS-1:0] ARID;
  //   logic          [`AXI_ADDR_BITS-1:0] ARADDR;
  //   logic           [`AXI_LEN_BITS-1:0] ARLEN;
  //   logic          [`AXI_SIZE_BITS-1:0] ARSIZE;
  //   logic                         [1:0] ARBURST;
  //   logic                               ARVALID;
  //   logic                               ARREADY;
  // } ARx_bus_t;

  // typedef struct packed{
  //   logic            [`AXI_ID_BITS-1:0] RID;
  //   logic          [`AXI_DATA_BITS-1:0] RDATA;
  //   logic                         [1:0] RRESP;
  //   logic                               RLAST;
  //   logic                               RVALID;
  //   logic                               RREADY;
  // } Rx_bus_t;

  // typedef struct packed {
  //   logic            [`AXI_ID_BITS-1:0] AWID;
  //   logic          [`AXI_ADDR_BITS-1:0] AWADDR;
  //   logic           [`AXI_LEN_BITS-1:0] AWLEN;
  //   logic          [`AXI_SIZE_BITS-1:0] AWSIZE;
  //   logic                         [1:0] AWBURST;
  //   logic                               AWVALID;
  //   logic                               AWREADY;
  // } AWx_bus_t;

  // typedef struct packed {
  //   logic          [`AXI_DATA_BITS-1:0] WDATA;
  //   logic          [`AXI_STRB_BITS-1:0] WSTRB;
  //   logic                               WLAST;
  //   logic                               WVALID;
  //   logic                               WREADY;
  // } Wx_bus_t;

  // typedef struct packed{
  //   logic            [`AXI_ID_BITS-1:0] BID;
  //   logic                         [1:0] BRESP;
  //   logic                               BVALID;
  //   logic                               BREADY;
  // } Bx_bus_t;

  localparam AXI_M0_BIT = 0, AXI_M1_BIT = 1, AXI_M2_BIT = 2;  
  typedef enum logic [`AXI_ID_BITS-1:0] {
    AXI_MASTER_0_ID = 1 << AXI_M0_BIT,
    AXI_MASTER_1_ID = 1 << AXI_M1_BIT,
    AXI_MASTER_2_ID = 1 << AXI_M2_BIT
  } axi_master_id_t;

  localparam LOCK_M0_BIT = 0, LOCK_M1_BIT = 1, LOCK_FREE_BIT = 2;
  typedef enum logic [2:0] {
    LOCK_M0   = 1 << LOCK_M0_BIT,
    LOCK_M1   = 1 << LOCK_M1_BIT,
    LOCK_FREE = 1 << LOCK_FREE_BIT
  } addr_arb_lock_t;

  localparam LOCK_S0_BIT = 0, LOCK_S1_BIT = 1, LOCK_S2_BIT = 2, LOCK_NO_BIT = 3;
  typedef enum logic [3:0] {
    LOCK_S0 = 1 << LOCK_S0_BIT,
    LOCK_S1 = 1 << LOCK_S1_BIT,
    LOCK_S2 = 1 << LOCK_S2_BIT,
    LOCK_NO = 1 << LOCK_NO_BIT
  } data_arb_lock_t;

  // Address Decoder
  localparam SLAVE_0_BIT = 0, SLAVE_1_BIT = 1, SLAVE_2_BIT = 2;
  typedef enum logic [2:0] {
    SLAVE_0 = 1 << SLAVE_0_BIT,
    SLAVE_1 = 1 << SLAVE_1_BIT,
    SLAVE_2 = 1 << SLAVE_2_BIT
  } addr_dec_result_t;

  function automatic addr_dec_result_t ADDR_DECODER(
      logic [`AXI_ADDR_BITS-1:0] address);
    logic [`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2] address_upper = address[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2];
    if (address_upper < 16'h0001)
      ADDR_DECODER = SLAVE_0;
    else if (address_upper >= 16'h0001 && address_upper < 16'h0010)
      ADDR_DECODER = SLAVE_1;
    else ADDR_DECODER = SLAVE_2;
  endfunction

  function automatic axi_master_id_t DATA_DECODER(
      logic [`AXI_IDS_BITS-1:0] IDS);
    logic [`AXI_ID_BITS-1:0] IDS_UPPER = IDS[`AXI_IDS_BITS-1:`AXI_ID_BITS];
    
    // Use one bit encoding IDs for smaller area
    if (IDS_UPPER[0]) DATA_DECODER = AXI_MASTER_0_ID;
    else if (IDS_UPPER[1]) DATA_DECODER = AXI_MASTER_1_ID;
    else DATA_DECODER = AXI_MASTER_2_ID;
  endfunction

endpackage : axi_pkg

`endif
