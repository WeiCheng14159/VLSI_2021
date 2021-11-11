`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "./AXI/AXI_wrapper.sv"
`include "util.sv"
`include "./AXI/AXI2CPU.sv"
`include "./AXI/AXI2SRAM.sv"

module top (
    input logic clk,
    input logic rst
);

  logic rst_sync;

  reset_sync i_reset_sync (
      .clk(clk),
      .rst_async(rst),
      .rst_sync(rst_sync)
  );

  AXI2CPU_interface axi2cpu ();
  AXI2SRAM_interface axi2sram0 ();
  AXI2SRAM_interface axi2sram1 ();

  CPU_wrapper cpu0 (
      .clk,
      .rst,
      .cpu2axi_interface(axi2cpu.cpu_ports)
  );

  AXI_wrapper axi_wrapper0 (
      .ACLK(clk),
      .ARESETn(~rst),
      .axi2cpu_interface(axi2cpu.axi_ports),
      .axi2sram0_interface(axi2sram0.axi_ports),
      .axi2sram1_interface(axi2sram1.axi_ports)
  );

  SRAM_wrapper IM1 (
      .clk,
      .rst,
      .sram2axi_interface(axi2sram0.sram_ports)
  );

  SRAM_wrapper DM1 (
      .clk,
      .rst,
      .sram2axi_interface(axi2sram1.sram_ports)
  );

endmodule
