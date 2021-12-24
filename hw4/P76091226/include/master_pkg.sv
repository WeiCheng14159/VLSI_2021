`ifndef MASTER_PKG_SV
`define MASTER_PKG_SV

package master_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam IDLE_BIT = 0, AR_BIT = 1, R_BIT = 2, AW_BIT = 3, W_BIT = 4, B_BIT = 5;

  typedef enum logic [B_BIT:0] {
    IDLE = 1 << IDLE_BIT,
    AR = 1 << AR_BIT,
    R = 1 << R_BIT,
    AW = 1 << AW_BIT,
    W = 1 << W_BIT,
    B = 1 << B_BIT
  } master_state_t;

endpackage : master_pkg

`endif
