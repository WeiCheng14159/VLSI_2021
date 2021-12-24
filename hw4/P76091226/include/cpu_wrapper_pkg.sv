`ifndef CPU_WRAPPER_PKG_SV
`define CPU_WRAPPER_PKG_SV

package cpu_wrapper_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam IDLEE_BIT = 0, SADDR_BIT = 1, SWAIT_BIT = 2, STEPP_BIT = 3;

  typedef enum logic [STEPP_BIT:0] {
    IDLEE = 1 << IDLEE_BIT,
    SADDR = 1 << SADDR_BIT,
    SWAIT = 1 << SWAIT_BIT,
    STEPP = 1 << STEPP_BIT
  } cpu_wrapper_state_t;

endpackage : cpu_wrapper_pkg

`endif
