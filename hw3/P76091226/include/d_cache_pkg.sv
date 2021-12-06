`ifndef D_CACHE_PKG_SV
`define D_CACHE_PKG_SV

package d_cache_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam VALID = 1'b1, INVALID = 1'b0;
  localparam CACHE_HIT = 1'b1, CACHE_MISS = 1'b0;

  localparam IDLE_BIT = 0, CHK_BIT = 1, WHIT_BIT = 2, WMISS_BIT = 3, 
  RMISS_BIT = 4, FIN_BIT = 5;

  typedef enum logic [5:0] {
    IDLE  = 1 << IDLE_BIT,
    CHK   = 1 << CHK_BIT,
    WHIT  = 1 << WHIT_BIT,
    WMISS = 1 << WMISS_BIT,
    RMISS = 1 << RMISS_BIT,
    FIN   = 1 << FIN_BIT
  } dcache_state_t;

endpackage : d_cache_pkg

`endif
