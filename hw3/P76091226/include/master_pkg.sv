`ifndef MASTER_PKG_SV
`define MASTER_PKG_SV

package master_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam IDLE_BIT = 0, READ_BIT = 1, WRITE_BIT = 2;

  typedef enum logic [2:0] {
    IDLE  = 1 << IDLE_BIT,
    READ  = 1 << READ_BIT,
    WRITE = 1 << WRITE_BIT
  } master_state_t;

endpackage : master_pkg

`endif
