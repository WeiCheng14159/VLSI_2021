`ifndef CACHE2MEM_INTF_SV
`define CACHE2MEM_INTF_SV

`include "cache.svh"

interface cache2mem_intf;

  logic [      `DATA_BITS-1:0] m_out;
  logic                        m_wait;
  logic                        m_req;
  logic [      `DATA_BITS-1:0] m_addr;
  logic                        m_write;
  logic [      `DATA_BITS-1:0] m_in;
  logic [`CACHE_TYPE_BITS-1:0] m_type;

  modport memory(
      output m_out, m_wait,
      input m_req, m_addr, m_write, m_in, m_type
  );

  modport cache(
      input m_out, m_wait,
      output m_req, m_addr, m_write, m_in, m_type
  );

endinterface : cache2mem_intf

`endif
