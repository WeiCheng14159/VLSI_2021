//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "pkg_include.sv"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"

module L1C_data
  import d_cache_pkg::*;
(
    input  logic                                       clk,
    input  logic                                       rstn,
           cache2mem_intf.cache                        mem,
    // From CPU to cache
    input  logic                [      `DATA_BITS-1:0] core_addr,
    input  logic                                       core_req,
    input  logic                                       core_write,
    input  logic                [      `DATA_BITS-1:0] core_in,
    input  logic                [`CACHE_TYPE_BITS-1:0] core_type,
    // From cache to CPU
    output logic                [      `DATA_BITS-1:0] core_out,
    output logic                                       core_wait
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
  logic [`CACHE_LINE_BITS-1:0] valid;

  // Sample
  logic [`DATA_BITS      -1:0] core_addr_r, core_in_r;
  logic [ `CACHE_TYPE_BITS-1:0] core_type_r;
  logic                         core_write_r;
  logic [`CACHE_WRITE_BITS-1:0] da_write;
  logic [ `DATA_BITS      -1:0] read_data;
  logic [ `CACHE_DATA_BITS-1:0] read_block_data;
  // Other
  logic [1:0] blk_off, byte_offset;
  logic [2:0] cnt;
  logic       hit;
  logic [3:0] web, bweb, hweb;
  logic read_miss_done, write_miss_done, write_hit_done;
  logic D_out_valid;

  dcache_state_t curr_state, next_state;

  assign read_miss_done = (cnt == 3'h4);
  assign write_miss_done = (cnt == 3'h1);
  assign write_hit_done = (cnt == 3'h1);
  assign D_out_valid = mem.m_wait;

  // Registers for inputs
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      core_addr_r  <= `DATA_BITS'h0;
      core_in_r    <= `DATA_BITS'h0;
      core_type_r  <= `CACHE_TYPE_BITS'h0;
      core_write_r <= 1'b0;
    end else if (curr_state == IDLE) begin
      core_addr_r  <= core_addr;
      core_in_r    <= core_in;
      core_type_r  <= core_type;
      core_write_r <= core_write;
    end
  end

  // cnt
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cnt <= 3'h0;
    else begin
      case (curr_state)
        RMISS: cnt <= (D_out_valid) ? (cnt + 1) : cnt;
        WMISS: cnt <= (D_out_valid) ? (cnt + 1) : cnt;
        WHIT:  cnt <= (D_out_valid) ? (cnt + 1) : cnt;
        IDLE:  cnt <= 3'h0;
      endcase
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end  // State (S)

  always_comb begin
    case (curr_state)
      IDLE: begin
        if (~core_req) next_state = IDLE;
        else if (core_req & core_write & ~valid[index]) next_state = WMISS;
        else if (core_req & ~core_write & ~valid[index]) next_state = RMISS;
        else next_state = CHK;
      end
      CHK: begin
        next_state = (core_write_r) ? (hit ? WHIT : WMISS) : (hit ? IDLE : RMISS);
      end
      WHIT: next_state = (write_hit_done) ? IDLE : WHIT;
      WMISS: next_state = (write_miss_done) ? IDLE : WMISS;
      RMISS: next_state = (read_miss_done) ? IDLE : RMISS;
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
      CHK: hit = (TA_out == core_addr_r[`TAG_FIELD]);
      WHIT: hit = 1'b1;
      default: hit = 1'b0;  // WMISS, RMISS
    endcase
  end

  // web
  assign byte_offset = core_addr_r[1:0];
  always_comb begin
    case (byte_offset)
      2'h0:
      {bweb, hweb} = {
        {DA_WRITE_DIS, DA_WRITE_DIS, DA_WRITE_DIS, DA_WRITE_ENB},
        {DA_WRITE_DIS, DA_WRITE_DIS, DA_WRITE_ENB, DA_WRITE_ENB}
      };
      2'h1:
      {bweb, hweb} = {
        {DA_WRITE_DIS, DA_WRITE_DIS, DA_WRITE_ENB, DA_WRITE_DIS},
        {DA_WRITE_DIS, DA_WRITE_DIS, DA_WRITE_ENB, DA_WRITE_ENB}
      };
      2'h2:
      {bweb, hweb} = {
        {DA_WRITE_DIS, DA_WRITE_ENB, DA_WRITE_DIS, DA_WRITE_DIS},
        {DA_WRITE_ENB, DA_WRITE_ENB, DA_WRITE_DIS, DA_WRITE_DIS}
      };
      2'h3:
      {bweb, hweb} = {
        {DA_WRITE_ENB, DA_WRITE_DIS, DA_WRITE_DIS, DA_WRITE_DIS},
        {DA_WRITE_ENB, DA_WRITE_ENB, DA_WRITE_DIS, DA_WRITE_DIS}
      };
    endcase
  end

  always_comb begin
    case (core_type_r[1:0])
      `BYTE:   web = bweb;
      `HWORD:  web = hweb;
      default: web = {DA_WRITE_ENB, DA_WRITE_ENB, DA_WRITE_ENB, DA_WRITE_ENB};
    endcase
  end

  assign blk_off = core_addr_r[`WORD_FIELD];
  always_comb begin
    case (blk_off)
      2'h0: da_write = {{12{DA_WRITE_DIS}}, web};
      2'h1: da_write = {{8{DA_WRITE_DIS}}, web, {4{DA_WRITE_DIS}}};
      2'h2: da_write = {{4{DA_WRITE_DIS}}, web, {8{DA_WRITE_DIS}}};
      2'h3: da_write = {web, {12{DA_WRITE_DIS}}};
    endcase
  end

  // TAx
  assign TA_in = (curr_state == IDLE) ? core_addr[`TAG_FIELD] : core_addr_r[`TAG_FIELD];
  always_comb begin
    case (curr_state)
      IDLE:
      {TA_write, TA_read} = {
        TA_WRITE_DIS, (core_req) ? TA_READ_ENB : TA_READ_DIS
      };
      CHK: {TA_write, TA_read} = {TA_WRITE_DIS, TA_READ_ENB};
      WHIT: {TA_write, TA_read} = {TA_WRITE_ENB, TA_READ_DIS};
      RMISS: {TA_write, TA_read} = {TA_WRITE_ENB, TA_READ_DIS};
      default: {TA_write, TA_read} = {TA_WRITE_DIS, TA_READ_DIS};
    endcase
  end

  // DAx
  assign DA_read = (curr_state == CHK) ? (hit & ~core_write_r) ? DA_READ_ENB : DA_READ_DIS : DA_READ_DIS;
  always_comb begin
    case (curr_state)
      RMISS:
      DA_write = (read_miss_done) ? {`CACHE_WRITE_BITS{DA_WRITE_ENB}} :{`CACHE_WRITE_BITS{DA_WRITE_DIS}};
      WHIT:
      DA_write = (write_hit_done) ? da_write : {`CACHE_WRITE_BITS{DA_WRITE_DIS}};
      default: DA_write = {`CACHE_WRITE_BITS{DA_WRITE_DIS}};
    endcase
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      DA_in <= `CACHE_DATA_BITS'h0;
    end else begin
      case (curr_state)
        WHIT: DA_in <= {core_in_r, core_in_r, core_in_r, core_in_r};
        RMISS: begin
          if (D_out_valid) begin
            DA_in[127-:32] <= mem.m_out;
            DA_in[95-:32]  <= DA_in[127-:32];
            DA_in[63-:32]  <= DA_in[95-:32];
            DA_in[31-:32]  <= DA_in[63-:32];
          end
        end
        default: DA_in <= `CACHE_DATA_BITS'h0;
      endcase
    end
  end

  // read_block_data, read_data
  assign read_block_data = (DA_read) ? DA_out : DA_in;
  assign read_data = read_block_data[{core_addr_r[`WORD_FIELD], 5'b0}+:32];

  // core_out
  assign core_wait = (curr_state == IDLE) ? 1'b0 : 1'b1;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) core_out <= `DATA_BITS'h0;
    else begin
      case (curr_state)
        CHK:   core_out <= read_data;
        RMISS: core_out <= (read_miss_done) ? read_data : core_out;
      endcase
    end
  end

  // From Cache to CPU wrapper
  always_comb begin
    case (curr_state)
      WMISS: begin
        mem.m_req   = ~|cnt & ~D_out_valid;
        mem.m_write = ~|cnt & ~D_out_valid;
        mem.m_addr  = core_addr_r;
        mem.m_in    = core_in_r;
        mem.m_type  = core_type_r;
      end
      WHIT: begin
        mem.m_req   = ~|cnt & ~D_out_valid;
        mem.m_write = ~|cnt & ~D_out_valid;
        mem.m_addr  = core_addr_r;
        mem.m_in    = core_in_r;
        mem.m_type  = core_type_r;
      end
      RMISS: begin
        mem.m_req   = ~|cnt & ~D_out_valid;
        mem.m_write = 1'b0;
        mem.m_addr  = {core_addr_r[`DATA_BITS-1:4], 4'h0};
        mem.m_in    = `DATA_BITS'h0;
        mem.m_type  = `CACHE_WORD;
      end
      default: begin
        mem.m_req   = 1'b0;
        mem.m_write = 1'b0;
        mem.m_addr  = `DATA_BITS'h0;
        mem.m_in    = `DATA_BITS'h0;
        mem.m_type  = core_type_r;
      end
    endcase
  end

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

  logic [`DATA_BITS-1:0] L1CD_rhits, L1CD_whits;
  logic [`DATA_BITS-1:0] L1CD_rmiss, L1CD_wmiss;
  logic [`DATA_BITS-1:0] L1CD_hits, L1CD_miss;
  logic [`DATA_BITS-1:0] L1CD_rcnt, L1CD_wcnt, L1CD_rwcnt;
  assign L1CD_hits  = L1CD_rhits + L1CD_whits;
  assign L1CD_miss  = L1CD_rmiss + L1CD_wmiss;
  assign L1CD_rwcnt = L1CD_rcnt + L1CD_wcnt;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      L1CD_rhits <= `DATA_BITS'h0;
      L1CD_whits <= `DATA_BITS'h0;
      L1CD_rmiss <= `DATA_BITS'h0;
      L1CD_wmiss <= `DATA_BITS'h0;
      L1CD_rcnt  <= `DATA_BITS'h0;
      L1CD_wcnt  <= `DATA_BITS'h0;
    end else begin
      L1CD_rhits <= (curr_state == CHK) & hit & ~core_write_r ? L1CD_rhits + 'h1 : L1CD_rhits;
      L1CD_whits <= (curr_state == WHIT) & (write_hit_done) ? L1CD_whits + 'h1 : L1CD_whits;
      L1CD_rmiss <= (curr_state == RMISS) & (read_miss_done) ? L1CD_rmiss + 'h1 : L1CD_rmiss;
      L1CD_wmiss <= (curr_state == WMISS) & (write_miss_done) ? L1CD_wmiss + 'h1 : L1CD_wmiss;
      L1CD_rcnt  <= (curr_state == IDLE) & (core_req & ~core_write) ? L1CD_rcnt + 'h1 : L1CD_rcnt;
      L1CD_wcnt  <= (curr_state == IDLE) & (core_req & core_write) ? L1CD_wcnt + 'h1 : L1CD_wcnt;
    end
  end

endmodule

