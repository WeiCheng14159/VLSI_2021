`ifndef ROM_WRAPPER_PKG_SV
`define ROM_WRAPPER_PKG_SV

package rom_wrapper_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  localparam ADDR_SIZE = 12;
  localparam DATA_SIZE = 32;

  localparam EMPTY_ADDR = {ADDR_SIZE{1'b0}};
  localparam EMPTY_DATA = {DATA_SIZE{1'b0}};

  localparam ROM_ENB = 1'b1, ROM_DIS = 1'b0;
  localparam ROM_READ_ENB = 1'b1, ROM_READ_DIS = 1'b0;

  localparam IDLE_BIT = 0, READ_BIT = 1;

  typedef enum logic [3:0] {
    IDLE = 1 << IDLE_BIT,
    READ = 1 << READ_BIT
  } rom_wrapper_state_t;

endpackage : rom_wrapper_pkg

`endif
