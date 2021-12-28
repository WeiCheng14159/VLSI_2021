`include "pkg_include.sv"
`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "AXI/AXI.sv"
`include "util.sv"
`include "ROM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "sctrl_wrapper.sv"

module top (
    input  logic        clk,
    input  logic        rst,
    // ROM
    input  logic [31:0] ROM_out,
    output logic        ROM_read,
    output logic        ROM_enable,
    output logic [11:0] ROM_address,
    // DRAM
    input  logic        DRAM_valid,
    output logic        DRAM_CSn,
    output logic [ 3:0] DRAM_WEn,
    output logic        DRAM_RASn,
    output logic        DRAM_CASn,
    output logic [10:0] DRAM_A,
    output logic [31:0] DRAM_D,
    input  logic [31:0] DRAM_Q,
    // Sensor
    input  logic        sensor_ready,
    input  logic [31:0] sensor_out,
    output logic        sensor_en
);

  logic rst_sync, rstn_sync;
  logic sensor_interrupt;

  reset_sync i_reset_sync (
      .clk(clk),
      .rst_async(rst),
      .rst_sync(rst_sync)
  );
  assign rstn_sync = ~rst_sync;

  // Masters
  AXI_master_intf master0 ();  // IM master
  AXI_master_intf master1 ();  // DM master
  AXI_master_intf master2 ();  // 
  // Slaves
  AXI_slave_intf slave0 ();  // ROM wrapper     (0x0000_0000 ~ 0x0000_1FFF)
  AXI_slave_intf slave1 ();  // IM SRAM wrapper (0x0001_0000 ~ 0x0001_FFFF)
  AXI_slave_intf slave2 ();  // DM SRAM wrapper (0x0002_0000 ~ 0x0002_FFFF)
  AXI_slave_intf slave3 ();  // Sensor          (0x1000_0000 ~ 0x1000_03FF)
  AXI_slave_intf slave4 ();  // DRAM wrapper    (0x2000_0000 ~ 0x201F_FFFF)
  AXI_slave_intf slave5 ();  // 
  AXI_slave_intf slave6 ();  // Default slave

  CPU_wrapper cpu_wrapper (
      .clk(clk),
      .rstn(rstn_sync),
      .interrupt(sensor_interrupt),
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
      .slave5(slave5),
      .slave6(slave6)
  );

  logic        ROM_read_r;
  logic        ROM_enable_r;
  logic [11:0] ROM_address_r;

  always_ff @(posedge clk or posedge rst_sync) begin
    if (rst_sync) begin
      ROM_read <= 1'b0;
      ROM_enable <= 1'b0;
      ROM_address <= 12'h0;
    end else begin
      ROM_read <= ROM_read_r;
      ROM_enable <= ROM_enable_r;
      ROM_address <= ROM_address_r;
    end
  end

  // slave 0 => ROM
  ROM_wrapper rom_wrapper (
      .clk(clk),
      .rstn(rstn_sync),
      .slave(slave0),
      .ROM_out(ROM_out),
      .ROM_read(ROM_read_r),
      .ROM_enable(ROM_enable_r),
      .ROM_address(ROM_address_r)
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

  // Slave 3
  sctrl_wrapper sctrl_wrapper (
      .clk(clk),
      .rstn(rstn_sync),
      .sensor_ready(sensor_ready),
      .sensor_out(sensor_out),
      .sensor_en(sensor_en),
      .sensor_interrupt(sensor_interrupt),
      .slave(slave3)
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

  // Slave 5
  default_slave default_slave5 (
      .clk  (clk),
      .rstn (rstn_sync),
      .slave(slave5)
  );

  // Slave 6
  default_slave default_slave6 (
      .clk  (clk),
      .rstn (rstn_sync),
      .slave(slave6)
  );

endmodule
