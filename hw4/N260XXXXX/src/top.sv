module top(
  input         clk,
  input         rst,
  input [31:0]  ROM_out,
  input         sensor_ready,
  input [31:0]  sensor_out,
  input         DRAM_valid,
  input [31:0]  DRAM_Q,
  output        ROM_read,
  output        ROM_enable,
  output [11:0] ROM_address,
  output        sensor_en,
  output        DRAM_CSn,
  output [3:0]  DRAM_WEn,
  output        DRAM_RASn,
  output        DRAM_CASn,
  output [10:0] DRAM_A,
  output [31:0] DRAM_D
);


endmodule
