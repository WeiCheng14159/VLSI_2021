`ifndef SRAM_PKG_SV
`define SRAM_PKG_SV
package sram_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";
  
  localparam WEB_SIZE = 4;
  localparam ADDR_SIZE = 14;
  localparam DATA_SIZE = 32;

  localparam EMPTY_ADDR = 14'b0;
  localparam EMPTY_DATA = 32'b0;
  localparam EMPTY_WEB = 4'hf;
  
  localparam CS_ENB = 1'b1, CS_DIS = 1'b0;
  localparam OE_ENB = 1'b1, OE_DIS = 1'b0;
  localparam WEB_ENB = 1'b0, WEB_DIS = 1'b1;

endpackage : sram_pkg
`endif
