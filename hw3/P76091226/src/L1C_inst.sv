//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
module L1C_inst (
    input logic clk,
    input logic rst,
    // Core to CPU wrapper
    input logic [`DATA_BITS-1:0] core_addr,
    input logic core_req,
    input logic core_write,
    input logic [`DATA_BITS-1:0] core_in,
    input logic [`CACHE_TYPE_BITS-1:0] core_type,
    // Mem to CPU wrapper
    input logic [`DATA_BITS-1:0] I_out,
    input logic I_wait,
    // CPU wrapper to core
    output logic [`DATA_BITS-1:0] core_out,
    output logic core_wait,
    // CPU wrapper to Mem
    output logic I_req,
    output logic [`DATA_BITS-1:0] I_addr,
    output logic I_write,
    output logic [`DATA_BITS-1:0] I_in,
    output logic [`CACHE_TYPE_BITS-1:0] I_type
);

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;

  //--------------- complete this part by yourself -----------------//

  data_array_wrapper DA (
      .A  (index),
      .DO (DA_out),
      .DI (DA_in),
      .CK (clk),
      .WEB(DA_write),
      .OE (DA_read),
      .CS (1'b1)
  );

  tag_array_wrapper TA (
      .A  (index),
      .DO (TA_out),
      .DI (TA_in),
      .CK (clk),
      .WEB(TA_write),
      .OE (TA_read),
      .CS (1'b1)
  );

endmodule

