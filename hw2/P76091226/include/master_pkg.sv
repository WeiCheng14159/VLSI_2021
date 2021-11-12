`ifndef MASTER_PKG_SV
`define MASTER_PKG_SV

`include "AXI_define.svh"

package master_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam LOCK_BIT = 0, UNLOCK_BIT = 1;

  typedef enum logic {
    LOCK   = 1'b1,
    UNLOCK = 1'b0
  } lock_state_t;

endpackage : master_pkg

`endif
