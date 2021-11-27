`ifndef DRAM_WRAPPER_PKG_SV
`define DRAM_WRAPPER_PKG_SV

package dram_wrapper_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam WEB_SIZE = 4;
  localparam ADDR_SIZE = 11;
  localparam DATA_SIZE = 32;

  localparam EMPTY_ADDR = 11'b0;
  localparam EMPTY_DATA = 32'b0;

  localparam CS_ENB = 1'b0, CS_DIS = 1'b1;
  localparam RAS_ENB = 1'b0, RAS_DIS = 1'b1;
  localparam CAS_ENB = 1'b0, CAS_DIS = 1'b1;
  localparam WEB_ENB = 1'b0, WEB_DIS = 1'b1;

  localparam ROW_ADDR_SIZE = 11;
  localparam COL_ADDR_SIZE = 10;
  
  localparam IDLE_BIT = 0, ACT_BIT = 1, READ_BIT = 2, WRITE_BIT = 3, 
  WRITE_RESP_BIT = 4, PRE_BIT = 5, ERROR_BIT = 6;

  typedef enum logic [6:0] {
    IDLE  = 1 << IDLE_BIT,
    ACT   = 1 << ACT_BIT,
    READ  = 1 << READ_BIT,
    WRITE = 1 << WRITE_BIT,
    WRITE_RESP = 1 << WRITE_RESP_BIT,
    PRE = 1 << PRE_BIT,
    ERROR = 1 << ERROR_BIT
  } dram_wrapper_state_t;

  typedef enum logic [1:0] {
    DRAM_NO = 2'b00,
    DRAM_READ = 2'b01,
    DRAM_WRITE = 2'b10
  } dram_op_t;

endpackage : dram_wrapper_pkg

`endif