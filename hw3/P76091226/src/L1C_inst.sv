//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "pkg_include.sv"

module L1C_inst
  import i_cache_pkg::*;
(
    input  logic                        clk,
    input  logic                        rstn,
    // From CPU to cache
    input  logic [      `DATA_BITS-1:0] core_addr,
    input  logic                        core_req,
    input  logic                        core_write,
    input  logic [      `DATA_BITS-1:0] core_in,
    input  logic [`CACHE_TYPE_BITS-1:0] core_type,
    // From CPU wrapper to cache
    input  logic [      `DATA_BITS-1:0] I_out,
    input  logic                        I_wait,
    // From cache to CPU
    output logic [      `DATA_BITS-1:0] core_out,
    output logic                        core_wait,
    // From Cache to  CPU wrapper
    output logic                        I_req,
    output logic [      `DATA_BITS-1:0] I_addr,
    output logic                        I_write,
    output logic [      `DATA_BITS-1:0] I_in,
    output logic [`CACHE_TYPE_BITS-1:0] I_type
);

  logic [`CACHE_INDEX_BITS -1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINE_BITS-1:0] valid;


  logic [`DATA_BITS      -1:0] core_addr_r, core_in_r;
  logic [`CACHE_TYPE_BITS-1:0] core_type_r;
  logic                        core_write_r;
  logic [                 1:0] I_wait_r;
  logic [`DATA_BITS      -1:0] read_data;
  logic [`CACHE_DATA_BITS-1:0] read_block_data;
  logic                        hit;
  logic                        write_block_done;

  icache_state_t curr_state, next_state;

  // Registers for inputs
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      core_addr_r  <= `DATA_BITS'h0;
      core_in_r    <= `DATA_BITS'h0;
      core_type_r  <= `CACHE_TYPE_BITS'h0;
      core_write_r <= 1'b0;
      I_wait_r[0] <= 1'b0;
      I_wait_r[1] <= 1'b0;
    end else if (curr_state == IDLE) begin
      core_addr_r  <= core_addr;
      core_in_r    <= core_in;
      core_type_r  <= core_type;
      core_write_r <= core_write;
    end else if (curr_state == RMISS) begin
      I_wait_r[0] <= I_wait;
      I_wait_r[1] <= I_wait_r[0];
    end
  end

  assign write_block_done = ~I_wait & ~I_wait_r[0] & I_wait_r[1];

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end  // State (S)

  always_comb begin
    next_state = IDLE;
    case (curr_state)
      IDLE: begin
        if (~core_req) next_state = IDLE;
        else if (core_req & ~core_write & ~valid[index]) next_state = RMISS;
        else next_state = CHK;
      end
      CHK:     next_state = ~core_write_r & hit ? IDLE : RMISS;
      RHIT:    next_state = FIN;
      RMISS:   next_state = write_block_done ? IDLE : RMISS;
      FIN:     next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end  // Next state (N)

  // index, offset, hit, valid
  assign index = (curr_state == IDLE) ? core_addr[`INDEX_FIELD] : core_addr_r[`INDEX_FIELD];
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) valid <= `CACHE_LINE_BITS'h0;
    else if (curr_state == RMISS) valid[index] <= 1'b1;
  end

  always_comb begin
    hit = 1'b0;
    case (curr_state)
      IDLE:
      hit = valid[core_addr[`INDEX_FIELD]] & (TA_out == core_addr[`TAG_FIELD]);
      CHK: hit = (TA_out == core_addr_r[`TAG_FIELD]);
      RHIT: hit = 1'b1;
      FIN: ;
      default: hit = 1'b0;  // WMISS, RMISS, FIN
    endcase
  end

  // TAx
  assign TA_in = (curr_state == IDLE) ? core_addr[`TAG_FIELD] : core_addr_r[`TAG_FIELD];
  always_comb begin
    {TA_write, TA_read} = 2'b00;
    case (curr_state)
      IDLE: {TA_write, TA_read} = 2'b11;
      CHK: {TA_write, TA_read} = 2'b11;
      RMISS:
      {TA_write, TA_read} = {(curr_state == IDLE & next_state == RMISS), 1'b0};
      default: {TA_write, TA_read} = 2'b10;  // WHIT, WMISS, RHIT, FIN
    endcase
  end

  // DAx
  always_comb begin
    case (curr_state)
      CHK:     DA_read = hit & ~core_write_r;
      RHIT:    DA_read = 1'b1;
      default: DA_read = 1'b0;
    endcase
  end

  assign DA_write = (write_block_done) ? `CACHE_WRITE_BITS'h0 : `CACHE_WRITE_BITS'hffff;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      DA_in <= `CACHE_DATA_BITS'h0;
    end else if (curr_state == RMISS) begin
      DA_in[127-:32] <= I_out;
      DA_in[95-:32]  <= DA_in[127-:32];
      DA_in[63-:32]  <= DA_in[95-:32];
      DA_in[31-:32]  <= DA_in[63-:32];
    end else begin
      DA_in <= `CACHE_DATA_BITS'h0;
    end
  end

  // read_block_data, read_data
  assign read_block_data = (write_block_done) ? DA_in : DA_out;
  assign read_data = read_block_data[{core_addr_r[`WORD_FIELD], 5'b0}+:32];

  // core_out
  assign core_wait = (curr_state == IDLE) ? 1'b0 : 1'b1;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) core_out <= `DATA_BITS'h0;
    else begin
      case (curr_state)
        CHK:   core_out <= read_data;
        RMISS: core_out <= (write_block_done) ? read_data : core_out;
      endcase
    end
  end

  // From Cache to  CPU wrapper
  assign I_req = (curr_state == RMISS && ~I_wait && ~I_wait_r[0] && ~I_wait_r[1]);
  assign I_write = 1'b0;
  assign I_in = `DATA_BITS'h0;
  assign I_type = `CACHE_WORD;
  assign I_addr = {core_addr_r[`DATA_BITS-1:4], 4'h0};

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

  logic [`DATA_BITS-1:0] L1CI_rhits;
  logic [`DATA_BITS-1:0] L1CI_rmiss;
  logic [`DATA_BITS-1:0] insts;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      L1CI_rhits <= `DATA_BITS'h0;
      L1CI_rmiss <= `DATA_BITS'h0;
      insts      <= `DATA_BITS'h0;
    end else begin
      L1CI_rhits <= (curr_state == CHK) & ~core_write_r &hit ? L1CI_rhits + 'h1 : L1CI_rhits;
      L1CI_rmiss <= (curr_state == RMISS) & write_block_done ? L1CI_rmiss + 'h1 : L1CI_rmiss;
      insts <= (curr_state == IDLE) & core_req ? insts + 'h1 : insts;
    end
  end


endmodule

