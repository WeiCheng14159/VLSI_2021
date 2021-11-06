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

  typedef enum logic [3:0] {
    AXI_MASTER_0_ID  = 4'b0001, 
    AXI_MASTER_1_ID  = 4'b0010, 
    AXI_MASTER_2_ID  = 4'b0100  
  } axi_master_id_t;

  typedef enum logic [2:0] {
    LOCK_M0, LOCK_M1, LOCK_M2, LOCK_FREE
  } addr_arb_lock_t;
  
  typedef enum logic [3:0] {
    LOCK_S0, LOCK_S1, LOCK_S2, LOCK_NO
  } data_arb_lock_t;

  // Address Decoder
  typedef enum logic [2:0] {
    SLAVE_0, SLAVE_1, SLAVE_2
  } addr_dec_result_t;

  function automatic addr_dec_result_t ADDR_DECODER (logic [`AXI_ADDR_BITS-1:0] address);
    if(address >= 32'h0000_0000 && address < 32'h0001_0000)
      ADDR_DECODER = SLAVE_0;
    else if (address >= 32'h0001_0000 && address < 32'h0010_0000)
      ADDR_DECODER = SLAVE_1;
    else
      ADDR_DECODER = SLAVE_2;
  endfunction

  // Data Decoder
  typedef enum logic [2:0] {
    MASTER_0, MASTER_1, MASTER_2, MASTER_U
  } data_dec_result_t;

  function automatic data_dec_result_t DATA_DECODER (logic [`AXI_IDS_BITS-1:0] IDS);
    logic IDS_UPPER = IDS[`AXI_IDS_BITS-1:`AXI_ID_BITS];
    if (IDS_UPPER == AXI_MASTER_0_ID)
      DATA_DECODER = MASTER_0;
    else if (IDS_UPPER == AXI_MASTER_1_ID)
      DATA_DECODER = MASTER_1;
    else if (IDS_UPPER == AXI_MASTER_2_ID)
      DATA_DECODER = MASTER_2;
    else
      DATA_DECODER = MASTER_U;
  endfunction

endpackage : axi_pkg

`endif
