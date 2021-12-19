`ifndef D_CACHE_PKG_SV
`define D_CACHE_PKG_SV

package d_cache_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam DA_WRITE_ENB = 1'b0, DA_WRITE_DIS = 1'b1;
  localparam DA_READ_ENB = 1'b1, DA_READ_DIS = 1'b0;
  localparam TA_WRITE_ENB = 1'b0, TA_WRITE_DIS = 1'b1;
  localparam TA_READ_ENB = 1'b1, TA_READ_DIS = 1'b0;

  localparam IDLE_BIT = 0, CHK_BIT = 1, WHIT_BIT = 2, WMISS_BIT = 3, 
  RMISS_BIT = 4;

  typedef enum logic [4:0] {
    IDLE  = 1 << IDLE_BIT,
    CHK   = 1 << CHK_BIT,
    WHIT  = 1 << WHIT_BIT,
    WMISS = 1 << WMISS_BIT,
    RMISS = 1 << RMISS_BIT
  } dcache_state_t;

endpackage : d_cache_pkg

`endif
