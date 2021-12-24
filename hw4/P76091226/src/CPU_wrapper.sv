`include "pkg_include.sv"
`include "CPU.sv"
`include "AXI/master.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"

module CPU_wrapper
  import cpu_wrapper_pkg::*;
  import cpu_pkg::*;
(
    input logic                  clk,
    input logic                  rstn,
    input logic                  interrupt,
          AXI_master_intf.master master0,
          AXI_master_intf.master master1
);

  // L1-I$
  cache2cpu_intf icache2cpu ();
  cache2mem_intf icache2mem ();
  // L1-D$
  cache2cpu_intf dcache2cpu ();
  cache2mem_intf dcache2mem ();

  CPU cpu0 (
      .clk(clk),
      .rstn(rstn),
      .interrupt(interrupt),
      .icache(icache2cpu),
      .dcache(dcache2cpu)
  );

  L1C_inst I_cache (
      .clk (clk),
      .rstn(rstn),
      .mem (icache2mem),
      .cpu (icache2cpu)
  );

  master #(
      .master_ID(`AXI_ID_BITS'b0)
  ) M0 (
      .clk(clk),
      .rstn(rstn),
      .master(master0),
      .mem(icache2mem)
  );

  L1C_data D_cache (
      .clk (clk),
      .rstn(rstn),
      .mem (dcache2mem),
      .cpu (dcache2cpu)
  );

  master #(
      .master_ID(`AXI_ID_BITS'b01)
  ) M1 (
      .clk(clk),
      .rstn(rstn),
      .master(master1),
      .mem(dcache2mem)
  );

endmodule
