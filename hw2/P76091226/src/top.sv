`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "AXI.sv"
`include "util.sv"
`include "AXI2CPU.sv"

module top(
    input logic clk, 
    input logic rst
);

logic                rst_sync;

reset_sync i_reset_sync(
  .clk(clk), 
  .rst_async(rst), 
  .rst_sync(rst_sync)
);

AXI2CPU_interface axi2cpu ();

CPU_wrapper cpu0 (
  .clk, .rst, 
  .cpu2axi_interface(axi2cpu.cpu_ports)
);

AXI axi (
  .ACLK(clk), .ARESETn(rst),
  .axi2cpu_interface(axi2cpu.axi_ports)
);

//SRAM_wrapper IM1(
//    .CK         ( clk              ),
//    .CS         ( 1'b1             ),
//    .A          ( imem_addr[15:2]  ),
//    .OE         ( imem_enb         ),
//    .WEB        ( 4'hF             ),
//    .DI         ( 32'b0            ),
//    .DO         ( imem_rdata       )
//);
//
//SRAM_wrapper DM1(
//    .CK         ( clk              ),
//    .CS         ( 1'b1             ),
//    .A          ( dmem_addr[15:2]  ),
//    .OE         ( dmem_enb         ),
//    .WEB        ( ~dmem_web        ),
//    .DI         ( dmem_wdata       ),
//    .DO         ( dmem_rdata       )
//);

endmodule
