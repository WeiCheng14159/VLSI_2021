`ifndef SENSOR_WRAPPER_PKG_SV
`define SENSOR_WRAPPER_PKG_SV

package sensor_wrapper_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam ADDR_SIZE = 6;
  localparam DATA_SIZE = 32;

  localparam EMPTY_ADDR = {ADDR_SIZE{1'b0}};
  localparam EMPTY_DATA = {DATA_SIZE{1'b0}};

  localparam SCTRL_ENB = 1'b1, SCTRL_DIS = 1'b0;
  localparam SCTRL_CLEAR_ENB = 1'b1, SCTRL_CLEAR_DIS = 1'b0;

  localparam SCTRL_ENB_ADDR = 10'h40;
  localparam SCTRL_CLEAR_ADDR = 10'h80;

  localparam IDLE_BIT = 0, READ_BIT = 1, WRITE_BIT = 2;

  typedef enum logic [WRITE_BIT:0] {
    IDLE  = 1 << IDLE_BIT,
    READ  = 1 << READ_BIT,
    WRITE = 1 << WRITE_BIT
  } sensor_wrapper_state_t;

endpackage : sensor_wrapper_pkg

`endif
