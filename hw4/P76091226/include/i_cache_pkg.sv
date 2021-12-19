`ifndef I_CACHE_PKG_SV
`define I_CACHE_PKG_SV

package i_cache_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam DA_WRITE_ENB = 1'b0, DA_WRITE_DIS = 1'b1;
  localparam DA_READ_ENB = 1'b1, DA_READ_DIS = 1'b0;
  localparam TA_WRITE_ENB = 1'b0, TA_WRITE_DIS = 1'b1;
  localparam TA_READ_ENB = 1'b1, TA_READ_DIS = 1'b0;

  localparam IDLE_BIT = 0, CHK_BIT = 1, RMISS_BIT = 2;
  typedef enum logic [2:0] {
    IDLE  = 1 << IDLE_BIT,
    CHK   = 1 << CHK_BIT,
    RMISS = 1 << RMISS_BIT
  } icache_state_t;

endpackage : i_cache_pkg

`endif
