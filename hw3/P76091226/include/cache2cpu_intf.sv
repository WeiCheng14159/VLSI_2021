`ifndef CACHE2CPU_INTF_SV
`define CACHE2CPU_INTF_SV

`include "cache.svh"

interface cache2cpu_intf;

  logic [      `DATA_BITS-1:0] core_addr;
  logic                        core_req;
  logic                        core_write;
  logic [      `DATA_BITS-1:0] core_in;
  logic [`CACHE_TYPE_BITS-1:0] core_type;
  logic [      `DATA_BITS-1:0] core_out;
  logic                        core_wait;

  modport cpu(
      input core_addr, core_req, core_write, core_in, core_type,
      output core_out, core_wait
  );

  modport cache(
      output core_addr, core_req, core_write, core_in, core_type,
      input core_out, core_wait
  );

endinterface : cache2cpu_intf

`endif
