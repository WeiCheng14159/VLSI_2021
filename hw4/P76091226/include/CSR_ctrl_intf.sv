`ifndef CSR_CTRL_INTF_SV
`define CSR_CTRL_INTF_SV

import CSR_pkg::*;

interface CSR_ctrl_intf;

  logic [CSR_DATA_WIDTH-1:0] CSR_wdata;
  logic [CSR_ADDR_WIDTH-1:0] CSR_addr;
  logic [CSR_DATA_WIDTH-1:0] CSR_rdata;
  logic [CSR_DATA_WIDTH-1:0] curr_pc;
  logic CSR_wait;
  logic CSR_ret;
  logic CSR_write;

  modport register(
    input CSR_wdata, CSR_addr, CSR_wait, CSR_ret, CSR_write, curr_pc,
    output CSR_rdata
  );

  modport cpu(
    output CSR_wdata, CSR_addr, CSR_wait, CSR_ret, CSR_write, curr_pc,
    input CSR_rdata
  );

endinterface : CSR_ctrl_intf

`endif
