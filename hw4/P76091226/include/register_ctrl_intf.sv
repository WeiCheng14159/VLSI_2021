`ifndef REGISTER_FILE_INTF_SV
`define REGISTER_FILE_INTF_SV

import cpu_pkg::*;

interface register_ctrl_intf;

  reg_addr_t                   raddr1;
  logic                        re1;
  logic      [RegBusWidth-1:0] rdata1;
  reg_addr_t                   raddr2;
  logic                        re2;
  logic      [RegBusWidth-1:0] rdata2;
  reg_addr_t                   waddr;
  logic                        we;
  logic      [RegBusWidth-1:0] wdata;

  modport regfile(
      input raddr1, re1, raddr2, re2, waddr, we, wdata,
      output rdata1, rdata2
  );

  modport cpu(
      output raddr1, re1, raddr2, re2, waddr, we, wdata,
      input rdata1, rdata2
  );

endinterface : register_ctrl_intf

`endif
