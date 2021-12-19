`ifndef SRAM_WRAPPER_PKG_SV
`define SRAM_WRAPPER_PKG_SV

package sram_wrapper_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam WEB_SIZE = 4;
  localparam ADDR_SIZE = 14;
  localparam DATA_SIZE = 32;

  localparam EMPTY_ADDR = {ADDR_SIZE{1'b0}};
  localparam EMPTY_DATA = {DATA_SIZE{1'b0}};

  localparam CS_ENB = 1'b1, CS_DIS = 1'b0;
  localparam OE_ENB = 1'b1, OE_DIS = 1'b0;
  localparam WEB_ENB = 1'b0, WEB_DIS = 1'b1;

  localparam IDLE_BIT = 0, READ_BIT = 1, WRITE_BIT = 2;

  typedef enum logic [3:0] {
    IDLE  = 1 << IDLE_BIT,
    READ  = 1 << READ_BIT,
    WRITE = 1 << WRITE_BIT
  } sram_wrapper_state_t;

endpackage : sram_wrapper_pkg

`endif
