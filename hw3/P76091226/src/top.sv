`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "AXI/AXI.sv"
`include "util.sv"

module top (
    input logic clk,
    input logic rst
);

  logic rst_sync, rstn_sync;
  reset_sync i_reset_sync (
      .clk(clk),
      .rst_async(rst),
      .rst_sync(rst_sync)
  );
  assign rstn_sync = ~rst_sync;

  // Master 0 AW, W, B channel
  assign AWREADY_M0 = 1'b0;
  assign WREADY_M0 = 1'b0;
  assign BID_M0 = `AXI_ID_BITS'b0;
  assign BRESP_M0 = `AXI_RESP_OKAY;
  assign BVALID_M0 = 1'b0;

  AXI_master_intf master0 ();
  AXI_master_intf master1 ();
  AXI_slave_intf slave0 ();
  AXI_slave_intf slave1 ();

  CPU_wrapper cpu_wrapper0 (
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
      .slave0(slave0),
      .slave1(slave1)
  );

  SRAM_wrapper IM1 (
      .clk  (clk),
      .rstn (rstn_sync),
      .slave(slave0)
  );

  SRAM_wrapper DM1 (
      .clk  (clk),
      .rstn (rstn_sync),
      .slave(slave1)
  );

endmodule
