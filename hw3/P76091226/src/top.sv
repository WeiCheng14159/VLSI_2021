`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "AXI/AXI.sv"
`include "util.sv"
`include "AXI_master_intf.sv"
`include "AXI_slave_intf.sv"
`include "rom_wrapper.sv"
`include "DRAM_wrapper.sv"

module top (
    input logic clk,
    input logic rst,
    // ROM
    input logic [31:0] ROM_out,
    output logic ROM_read,
    output logic ROM_enable,
    output logic [11:0] ROM_address,
    // DRAM
    input logic DRAM_valid,
    output logic DRAM_CSn,
    output logic [3:0] DRAM_WEn,
    output logic DRAM_RASn,
    output logic DRAM_CASn,
    output logic [10:0] DRAM_A,
    output logic [31:0] DRAM_D,
    input logic [31:0] DRAM_Q
);

  logic rst_sync, rstn_sync;
  reset_sync i_reset_sync (
      .clk(clk),
      .rst_async(rst),
      .rst_sync(rst_sync)
  );
  assign rstn_sync = ~rst_sync;

  AXI_master_intf master0 ();
  AXI_master_intf master1 ();
  AXI_master_intf master2 ();
  AXI_slave_intf slave0 ();
  AXI_slave_intf slave1 ();
  AXI_slave_intf slave2 ();
  AXI_slave_intf slave3 ();
  AXI_slave_intf slave4 ();
  AXI_slave_intf slave5 ();

  CPU_wrapper cpu_wrapper (
      .clk(clk),
      .rstn(rstn_sync),
      .master0(master0),
      .master1(master1)
  );

  AXI axi (
      .ACLK(clk),
      .ARESETn(rstn_sync),
      .master0(master0),
      .master1(master1),
      .master2(master2),
      .slave0(slave0),
      .slave1(slave1),
      .slave2(slave2),
      .slave3(slave3),
      .slave4(slave4),
      .slave5(slave5)
  );

  // slave 0 => ROM
  rom_wrapper rom_wrapper (
      .clk(clk),
      .rstn(rstn_sync),
      .slave(slave0),
      .ROM_out(ROM_out),
      .ROM_read(ROM_read),
      .ROM_enable(ROM_enable),
      .ROM_address(ROM_address)
  );

  // slave 1 => IM
  SRAM_wrapper IM1 (
      .clk  (clk),
      .rstn (rstn_sync),
      .slave(slave1)
  );

  // slave 2 => DM
  SRAM_wrapper DM1 (
      .clk  (clk),
      .rstn (rstn_sync),
      .slave(slave2)
  );

  logic DRAM_CSn_r;
  logic [3:0] DRAM_WEn_r;
  logic DRAM_RASn_r;
  logic DRAM_CASn_r;
  logic [10:0] DRAM_A_r;
  logic [31:0] DRAM_D_r;

  always_ff @(posedge clk or posedge rst_sync) begin
    if (rst_sync) begin
      DRAM_CSn <= 1'b1;
      DRAM_WEn <= 4'hf;
      DRAM_RASn <= 1'b1;
      DRAM_CASn <= 1'b1;
      DRAM_A <= 11'b0;
      DRAM_D <= 32'b0;
    end else begin
      DRAM_CSn  <= DRAM_CSn_r;
      DRAM_WEn  <= DRAM_WEn_r;
      DRAM_RASn <= DRAM_RASn_r;
      DRAM_CASn <= DRAM_CASn_r;
      DRAM_A    <= DRAM_A_r;
      DRAM_D    <= DRAM_D_r;
    end
  end

  // slave 4 => DRAM
  DRAM_wrapper dram_wrapper (
      .clk(clk),
      .rstn(rstn_sync),
      .slave(slave4),
      .DRAM_Q(DRAM_Q),
      .DRAM_valid(DRAM_valid),
      .DRAM_CSn(DRAM_CSn_r),
      .DRAM_WEn(DRAM_WEn_r),
      .DRAM_RASn(DRAM_RASn_r),
      .DRAM_CASn(DRAM_CASn_r),
      .DRAM_A(DRAM_A_r),
      .DRAM_D(DRAM_D_r)
  );


endmodule
