`include "def.v"
`include "CPU.sv"
`include "AXI_define.svh"
`include "cpu_wrapper_pkg.sv"
`include "AXI/master.sv"

module CPU_wrapper
  import cpu_wrapper_pkg::*;
(
    input logic clk,
    input logic rstn,
    AXI_master_intf.master master0,
    AXI_master_intf.master master1
);

  // CPU - Instruction
  logic [            `InstBus]  inst_from_mem;
  logic                         inst_read;
  logic [        `InstAddrBus]  inst_addr;
  logic                         inst_rw_request;

  // CPU - Data
  logic [            `DataBus]  data_from_mem;
  logic                         data_read;
  logic [`CACHE_TYPE_BITS-1:0 ] data_read_type;
  logic                         data_write;
  logic [`CACHE_TYPE_BITS-1:0 ] data_write_type;
  logic [        `DataAddrBus]  data_addr;
  logic [            `DataBus]  data_to_mem;
  logic                         data_rw_request;

  logic                         stallreq_from_imem;
  logic                         stallreq_from_dmem;

  // Cache 
  logic [`CACHE_TYPE_BITS-1:0 ] core_type;
  logic [`CACHE_TYPE_BITS-1:0 ] read_type;
  // L1-D$ 
  logic [      `DATA_BITS-1:0 ] D_out;
  logic                         D_req;
  logic [      `DATA_BITS-1:0 ] D_addr;
  logic                         D_write;
  logic [      `DATA_BITS-1:0 ] D_in;
  logic [`CACHE_TYPE_BITS-1:0 ] D_type;
  logic                         D_wait;
  // L1-I$
  logic [      `DATA_BITS-1:0 ] I_out;
  logic                         I_req;
  logic [      `DATA_BITS-1:0 ] I_addr;
  logic                         I_write;
  logic [      `DATA_BITS-1:0 ] I_in;
  logic [`CACHE_TYPE_BITS-1:0 ] I_type;
  logic                         I_wait;

  CPU cpu0 (
      .clk(clk),
      .rstn(rstn),
      // Instruction access
      .inst_in_i(inst_from_mem),
      .inst_read_o(inst_read),
      .inst_addr_o(inst_addr),
      .inst_rw_request_o(inst_addr),
      // Data access
      .data_in_i(data_from_mem),
      .data_read_o(data_read),
      .data_read_type_o(data_read_type),
      .data_write_o(data_write),
      .data_write_type_o(data_write_type),
      .data_addr_o(data_addr),
      .data_out_o(data_to_mem),
      // Stall request from cache
      .stallreq_from_imem(stallreq_from_imem),
      .stallreq_from_dmem(stallreq_from_dmem)
  );
  // Cache signals
  assign inst_rw_request = inst_read;
  assign I_req = inst_read;
  assign I_write = 1'b0;
  assign I_type = `CACHE_TYPE_BITS'b0;

  assign data_rw_request = data_read | data_write;
  assign D_req = ;
  wire [3:0] NoWrite = 4'hf;
  
  L1C_inst I_cache (
      .clk(clk),
      .rst(~rstn),
      .core_addr(inst_addr), // address from CPU
      .core_req(inst_rw_request),// memory access request from CPU
      .core_write(1'b0), // write signal from CPU
      .core_in(`DATA_BITS'b0), // data from CPU
      .core_type(`CACHE_WORD), // write/read byte, half word, or word from CPU
      .I_out(I_out), // data from CPU wrapper
      .I_wait(I_wait), // wait signal from CPU wrapper
      .core_out(inst_from_mem), // data to CPU
      .core_wait(stallreq_from_imem), // wait signal to CPU
      .I_req(I_req), // request to CPU wrapper
      .I_addr(I_addr), // address to CPU wrapper
      .I_write(I_write), // write signal to CPU wrapper
      .I_in(I_in), // write data to CPU wrapper
      .I_type(I_type) // write/read byte, half word, or word to CPU wrapper
  );

  master M0 (
      .clk(clk),
      .rstn(rstn),
      .master(master0),
      // CPU interface
      .access_request(I_req),
      .write(I_write),
      .w_type(I_type),
      .data_in(I_in),
      .addr(I_addr),
      .data_out(I_out),
      .stall(I_wait)
  );

  L1C_data D_cache (
      .clk(clk),
      .rst(~rstn),
      .core_addr(data_addr), // address from CPU
      .core_req(data_rw_request), // memory access request from CPU
      .core_write(data_write), // write signal from CPU
      .core_in(data_to_mem), // data from CPU
      .core_type(data_write_type),// write/read byte, half word, or word from CPU
      .D_out(D_out), // data from CPU wrapper
      .D_wait(D_wait), // wait signal from CPU wrapper
      .core_out(data_from_mem),// data to CPU
      .core_wait(stallreq_from_dmem),// wait signal to CPU
      .D_req(D_req),// request to CPU wrapper
      .D_addr(D_addr),// address to CPU wrapper
      .D_write(D_write), // write signal to CPU wrapper
      .D_in(D_in),// write data to CPU wrapper
      .D_type(D_type)// write/read byte, half word, or word to CPU wrapper
  );

  master M1 (
      .clk(clk),
      .rstn(rstn),
      .master(master1),
      // CPU interface
      .access_request(D_req),
      .write(D_write),
      .w_type(D_type)),
      .data_in(D_in),
      .addr(D_addr),
      .data_out(D_out),
      .stall(D_wait)
  );

endmodule
