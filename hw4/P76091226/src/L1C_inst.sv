//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "pkg_include.sv"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"

module L1C_inst
  import i_cache_pkg::*;
(
    input logic                clk,
    input logic                rstn,
          cache2mem_intf.cache mem,
          cache2cpu_intf.cache cpu
);

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write, TA_read;
  logic [`CACHE_LINE_BITS-1:0] valid;


  logic [`DATA_BITS      -1:0] core_addr_r, core_in_r;
  logic [`CACHE_TYPE_BITS-1:0] core_type_r;
  logic                        core_write_r;
  logic [`DATA_BITS      -1:0] read_data;
  logic [`CACHE_DATA_BITS-1:0] read_block_data;
  logic                        hit;
  logic                        read_miss_done;
  logic [                 2:0] cnt;
  logic                        I_out_valid;

  icache_state_t curr_state, next_state;

  assign I_out_valid = mem.m_wait;
  assign read_miss_done = (cnt == 3'h4);

  // Registers for inputs
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      core_addr_r  <= `DATA_BITS'h0;
      core_in_r    <= `DATA_BITS'h0;
      core_type_r  <= `CACHE_TYPE_BITS'h0;
      core_write_r <= 1'b0;
    end else if (curr_state == IDLE) begin
      core_addr_r  <= cpu.core_addr;
      core_in_r    <= cpu.core_in;
      core_type_r  <= cpu.core_type;
      core_write_r <= cpu.core_write;
    end
  end

  // cnt
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cnt <= 3'h0;
    else if (~I_out_valid) cnt <= 3'h0;
    else if (I_out_valid) cnt <= cnt + 3'h1;
    else cnt <= cnt;
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end  // State (S)

  always_comb begin
    next_state = IDLE;
    case (curr_state)
      IDLE: begin
        if (~cpu.core_req) next_state = IDLE;
        else if (cpu.core_req & ~cpu.core_write & ~valid[index])
          next_state = RMISS;
        else next_state = CHK;
      end
      CHK:     next_state = ~core_write_r & hit ? IDLE : RMISS;
      RMISS:   next_state = (read_miss_done) ? IDLE : RMISS;
      default: next_state = IDLE;
    endcase
  end  // Next state (N)

  // index, offset, hit, valid
  assign index = (curr_state == IDLE) ? cpu.core_addr[`INDEX_FIELD] : core_addr_r[`INDEX_FIELD];
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) valid <= `CACHE_LINE_BITS'h0;
    else if (curr_state == RMISS) valid[index] <= 1'b1;
  end

  always_comb begin
    hit = 1'b0;
    case (curr_state)
      CHK: hit = (TA_out == core_addr_r[`TAG_FIELD]);
      default: hit = 1'b0;
    endcase
  end

  // TAx
  assign TA_in = (curr_state == IDLE) ? cpu.core_addr[`TAG_FIELD] : core_addr_r[`TAG_FIELD];
  always_comb begin
    case (curr_state)
      IDLE:
      {TA_write, TA_read} = {
        TA_WRITE_DIS, (cpu.core_req) ? TA_READ_ENB : TA_READ_DIS
      };
      CHK: {TA_write, TA_read} = {TA_WRITE_DIS, TA_READ_ENB};
      RMISS: {TA_write, TA_read} = {TA_WRITE_ENB, TA_READ_DIS};
      default: {TA_write, TA_read} = {TA_WRITE_DIS, TA_READ_DIS};
    endcase
  end

  // DAx
  assign DA_read = (curr_state == CHK) ? (hit & ~core_write_r) ? DA_READ_ENB : DA_READ_DIS : DA_READ_DIS;
  assign DA_write = (read_miss_done) ? {`CACHE_WRITE_BITS{DA_WRITE_ENB}} : {`CACHE_WRITE_BITS{DA_WRITE_DIS}};
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      DA_in <= `CACHE_DATA_BITS'h0;
    end else if (curr_state == RMISS && I_out_valid) begin
      DA_in[127-:32] <= mem.m_out;
      DA_in[95-:32]  <= DA_in[127-:32];
      DA_in[63-:32]  <= DA_in[95-:32];
      DA_in[31-:32]  <= DA_in[63-:32];
    end else begin
      DA_in <= `CACHE_DATA_BITS'h0;
    end
  end

  // read_block_data, read_data
  assign read_block_data = (DA_read) ? DA_out : DA_in;
  assign read_data = read_block_data[{core_addr_r[`WORD_FIELD], 5'b0}+:32];

  // cpu.core_out
  assign cpu.core_wait = (curr_state == IDLE) ? 1'b0 : 1'b1;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cpu.core_out <= `DATA_BITS'h0;
    else begin
      case (curr_state)
        CHK:   cpu.core_out <= read_data;
        RMISS: cpu.core_out <= (read_miss_done) ? read_data : cpu.core_out;
      endcase
    end
  end

  // From Cache to  CPU wrapper
  assign mem.m_req = (curr_state == RMISS && ~I_out_valid && ~|cnt);
  assign mem.m_write = 1'b0;
  assign mem.m_in = `DATA_BITS'h0;
  assign mem.m_type = `CACHE_WORD;
  assign mem.m_addr = {core_addr_r[`DATA_BITS-1:4], 4'h0};
  assign mem.m_blk_size = `AXI_LEN_FOUR;

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
  logic [`DATA_BITS-1:0] L1CI_cnt;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      L1CI_rhits <= `DATA_BITS'h0;
      L1CI_rmiss <= `DATA_BITS'h0;
      L1CI_cnt   <= `DATA_BITS'h0;
    end else begin
      L1CI_rhits <= (curr_state == CHK) & ~core_write_r &hit ? L1CI_rhits + 'h1 : L1CI_rhits;
      L1CI_rmiss <= (curr_state == RMISS) & read_miss_done ? L1CI_rmiss + 'h1 : L1CI_rmiss;
      L1CI_cnt <= (curr_state == IDLE) & cpu.core_req ? L1CI_cnt + 'h1 : L1CI_cnt;
    end
  end

endmodule

