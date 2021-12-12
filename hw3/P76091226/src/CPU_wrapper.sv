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
          AXI_master_intf.master master0,
          AXI_master_intf.master master1
);

  // CPU - Instruction
  logic [      InstrWidth-1:0] inst_from_mem;
  logic                        inst_read;
  logic [  InstrAddrWidth-1:0] inst_addr;
  logic                        inst_rw_request;

  // CPU - Data
  logic [       DataWidth-1:0] data_from_mem;
  logic                        data_read;
  logic [   Func3BusWidth-1:0] data_read_type;
  logic                        data_write;
  logic [   Func3BusWidth-1:0] data_write_type;
  logic [   DataAddrWidth-1:0] data_write_addr;
  logic [       DataWidth-1:0] data_to_mem;
  logic                        data_rw_request;

  logic                        stallreq_from_imem;
  logic                        stallreq_from_dmem;

  // Cache 
  logic [`CACHE_TYPE_BITS-1:0] core_type;
  logic [`CACHE_TYPE_BITS-1:0] read_type;
  // L1-D$ 
  logic [      `DATA_BITS-1:0] D_out;
  logic                        D_req;
  logic [      `DATA_BITS-1:0] D_addr;
  logic                        D_write;
  logic [      `DATA_BITS-1:0] D_in;
  logic [`CACHE_TYPE_BITS-1:0] D_type;
  logic                        D_wait;
  // L1-I$
  logic [      `DATA_BITS-1:0] I_out;
  logic                        I_req;
  logic [      `DATA_BITS-1:0] I_addr;
  logic                        I_write;
  logic [      `DATA_BITS-1:0] I_in;
  logic [`CACHE_TYPE_BITS-1:0] I_type;
  logic                        I_wait;

  // Cache signals
  assign inst_rw_request = inst_read;
  assign data_rw_request = data_read | data_write;

  CPU cpu0 (
      .clk(clk),
      .rstn(rstn),
      // Instruction access
      .inst_in_i(inst_from_mem),
      .inst_read_o(inst_read),
      .inst_addr_o(inst_addr),
      // Data access
      .data_in_i(data_from_mem),
      .data_read_o(data_read),
      .data_read_type_o(data_read_type),
      .data_write_o(data_write),
      .data_write_type_o(data_write_type),
      .data_write_addr_o(data_write_addr),
      .data_out_o(data_to_mem),
      // Stall request from cache
      .stallreq_from_imem(stallreq_from_imem),
      .stallreq_from_dmem(stallreq_from_dmem)
  );

  wire [3:0] NoWrite = 4'hf;

  L1C_inst I_cache (
      .clk(clk),
      .rstn(rstn),
      // CPU -> cache
      .core_addr(inst_addr),
      .core_req(inst_rw_request),
      .core_write(1'b0),
      .core_in(`DATA_BITS'b0),
      .core_type(`CACHE_WORD),
      // Cache -> Master
      .I_out(I_out),
      .I_wait(I_wait),
      // Master -> CPU
      .core_out(inst_from_mem),
      .core_wait(stallreq_from_imem),
      // Master -> cache 
      .I_req(I_req),
      .I_addr(I_addr),
      .I_write(I_write),
      .I_in(I_in),
      .I_type(I_type)
  );

  master #(
      .master_ID(`AXI_ID_BITS'b0),
      .READ_BLOCK_SIZE(`AXI_LEN_FOUR)
  ) M0 (
      .clk(clk),
      .rstn(rstn),
      .master(master0),

      // Cache
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
      .rstn(rstn),
      // CPU -> cache
      .core_addr(data_write_addr),
      .core_req(data_rw_request),
      .core_write(data_write),
      .core_in(data_to_mem),
      .core_type(data_write_type),
      // Cache -> Master
      .D_out(D_out),
      .D_wait(D_wait),
      // Master -> CPU
      .core_out(data_from_mem),
      .core_wait(stallreq_from_dmem),
      // Master -> cache 
      .D_req(D_req),
      .D_addr(D_addr),
      .D_write(D_write),
      .D_in(D_in),
      .D_type(D_type)
  );

  master #(
      .master_ID(`AXI_ID_BITS'b01),
      .READ_BLOCK_SIZE(`AXI_LEN_FOUR)
  ) M1 (
      .clk(clk),
      .rstn(rstn),
      .master(master1),
      // Cache
      .access_request(D_req),
      .write(D_write),
      .w_type(D_type),
      .data_in(D_in),
      .addr(D_addr),
      .data_out(D_out),
      .stall(D_wait)
  );

endmodule
