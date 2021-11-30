`ifndef AXI_PKG_SV
`define AXI_PKG_SV

`include "AXI_define.svh"

package axi_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

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

  localparam LOCK_S0_BIT = 0, LOCK_S1_BIT = 1, LOCK_S2_BIT = 2, 
             LOCK_S3_BIT = 3, LOCK_S4_BIT = 4, LOCK_S5_BIT = 5, 
             LOCK_S6_BIT = 6, LOCK_NO_BIT = 7;
  typedef enum logic [7:0] {
    LOCK_S0 = 1 << LOCK_S0_BIT,
    LOCK_S1 = 1 << LOCK_S1_BIT,
    LOCK_S2 = 1 << LOCK_S2_BIT,
    LOCK_S3 = 1 << LOCK_S3_BIT,
    LOCK_S4 = 1 << LOCK_S4_BIT,
    LOCK_S5 = 1 << LOCK_S5_BIT,
    LOCK_S6 = 1 << LOCK_S6_BIT,
    LOCK_NO = 1 << LOCK_NO_BIT
  } data_arb_lock_t;

  // Address Decoder
  localparam SLAVE_0_BIT = 0, SLAVE_1_BIT = 1, SLAVE_2_BIT = 2, 
             SLAVE_3_BIT = 3, SLAVE_4_BIT = 4, SLAVE_5_BIT = 5,
             SLAVE_6_BIT = 6, SLAVE_D_BIT = 7;
  typedef enum logic [7:0] {
    SLAVE_0 = 1 << SLAVE_0_BIT,
    SLAVE_1 = 1 << SLAVE_1_BIT,
    SLAVE_2 = 1 << SLAVE_2_BIT,
    SLAVE_3 = 1 << SLAVE_3_BIT,
    SLAVE_4 = 1 << SLAVE_4_BIT,
    SLAVE_5 = 1 << SLAVE_5_BIT,
    SLAVE_6 = 1 << SLAVE_6_BIT,
    SLAVE_D = 1 << SLAVE_D_BIT
  } addr_dec_result_t;

  function automatic addr_dec_result_t ADDR_DECODER(
      logic [`AXI_ADDR_BITS-1:0] address);
    if (address <= 32'h0000_1FFF) ADDR_DECODER = SLAVE_0;
    else if (address >= 32'h0001_0000 && address <= 32'h0001_FFFF)
      ADDR_DECODER = SLAVE_1;
    else if (address >= 32'h0002_0000 && address <= 32'h0002_FFFF)
      ADDR_DECODER = SLAVE_2;
    else if (address >= 32'h1000_0000 && address <= 32'h1000_03FF)
      ADDR_DECODER = SLAVE_3;
    else if (address >= 32'h2000_0000 && address <= 32'h201F_FFFF)
      ADDR_DECODER = SLAVE_4;
    else ADDR_DECODER = SLAVE_D;
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
