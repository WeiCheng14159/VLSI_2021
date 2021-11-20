`include "SRAM_wrapper.sv"
`include "CPU.sv"
`include "util.sv"

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

  logic                 imem_enb;
  logic [`InstAddrBus]  imem_addr;
  logic [    `InstBus]  imem_rdata;
  logic                 dmem_enb;
  logic [         3:0 ] dmem_web;
  logic [`DataAddrBus]  dmem_addr;
  logic [    `DataBus]  dmem_wdata;
  logic [    `DataBus]  dmem_rdata;

  CPU i_CPU (
      .clk         (clk),
      .rst         (rst_sync),
      .inst_read_o (imem_enb),
      .inst_addr_o (imem_addr),
      .inst_out_i  (imem_rdata),
      .data_read_o (dmem_enb),
      .data_write_o(dmem_web),
      .data_addr_o (dmem_addr),
      .data_in_o   (dmem_wdata),
      .data_out_i  (dmem_rdata)
  );

  //logic imem_gated_clk, dmem_gated_clk;
  //CG u_imem_cg (
  //    .CK   ( clk            ),
  //    .EN   ( imem_enb       ),
  //    .CKEN ( imem_gated_clk )
  //);
  //
  //CG u_dmem_cg (
  //    .CK   ( clk            ),
  //    .EN   ( dmem_enb       ),
  //    .CKEN ( dmem_gated_clk )
  //);

  SRAM_wrapper IM1 (
      .CK (clk),
      .CS (1'b1),
      .A  (imem_addr[15:2]),
      .OE (imem_enb),
      .WEB(4'hF),
      .DI (32'b0),
      .DO (imem_rdata)
  );

  SRAM_wrapper DM1 (
      .CK (clk),
      .CS (1'b1),
      .A  (dmem_addr[15:2]),
      .OE (dmem_enb),
      .WEB(~dmem_web),
      .DI (dmem_wdata),
      .DO (dmem_rdata)
  );

endmodule
