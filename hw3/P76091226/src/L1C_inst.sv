//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "cache.svh"
`include "cache_pkg.sv"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"
module L1C_inst
  import cache_pkg::*;
(
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

  //   cache_state_t curr_state, next_state;

  // always_ff @(posedge clk, posedge rst) begin
  //   if (rst) begin
  //     curr_state <= IDLE;
  //   end else begin
  //     curr_state <= next_state;
  //   end
  // end  // State

  // always_comb begin
  //   next_state = IDLE;
  //   case (curr_state)
  //     IDLE: begin
  //       if(core_req)
  //         if(core_write)
  //           next_state = CHECK;
  //         else
  //           next_state = (valid[index]) ? (hit) ? STATE_IDLE : CHECK : CHECK;
  //       else 
  //         next_state = IDLE;
  //     end

  //     CHECK: begin
  //       if(core_write)
  //         next_state = (I_wait) ? CHECK : WRITE;
  //       else
  //         next_state = (hit) ? IDLE : MISS;
  //     end
  //     MISS: begin
  //       next_state = (~I_wait) ? IDLE : MISS;
  //     end
  //     WRITE: begin
  //       next_state = I_wait ? WRITE : IDLE;
  //     end

  //   endcase
  // end  // Next state (C)

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

