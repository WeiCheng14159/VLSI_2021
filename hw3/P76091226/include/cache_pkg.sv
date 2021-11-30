`ifndef CACHE_PKG_SV
`define CACHE_PKG_SV

package cache_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam IDLE_BIT = 0, CHECK_BIT = 1, MISS_BIT = 2, WRITE_BIT = 3;
  typedef enum logic [`AXI_ID_BITS-1:0] {
    IDLE  = 1 << IDLE_BIT,
    CHECK = 1 << CHECK_BIT,
    MISS  = 1 << MISS_BIT,
    WRITE = 1 << WRITE_BIT
  } cache_state_t;

endpackage : cache_pkg

`endif
