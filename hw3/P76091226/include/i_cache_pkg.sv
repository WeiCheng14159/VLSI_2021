`ifndef I_CACHE_PKG_SV
`define I_CACHE_PKG_SV

package i_cache_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam VALID = 1'b1, INVALID = 1'b0;
  localparam CACHE_HIT = 1'b1, CACHE_MISS = 1'b0;

  localparam IDLE_BIT = 0, CHK_BIT = 1, RHIT_BIT = 2, RMISS_BIT = 3,  FIN_BIT = 4;
  typedef enum logic [4:0] {
    IDLE  = 1 << IDLE_BIT,
    CHK   = 1 << CHK_BIT,
    RHIT  = 1 << RHIT_BIT,
    RMISS = 1 << RMISS_BIT,
    FIN   = 1 << FIN_BIT
  } icache_state_t;

endpackage : i_cache_pkg

`endif
