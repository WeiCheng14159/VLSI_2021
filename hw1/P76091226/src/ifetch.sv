`include "def.v"
module ifetch (
    input logic clk,
    input logic rst,

    input logic [`STAGE_NUM-1:0] stall,
    input logic                  flush,
    input logic [       `RegBus] branch_target_addr_i,
    input logic                  branch_taken_i,
    input logic [       `RegBus] new_pc_i,
    input logic [      `InstBus] inst_i,
    input logic [       `RegBus] id_pc_i,

    output logic [ `RegBus] if_pc_o,
    output logic            inst_read_o,
    output logic [ `RegBus] inst_addr_o,
    output logic [`InstBus] inst_o
);

  logic                   ce;
  logic [       `RegBus]  fetch_pc;
  logic [`STAGE_NUM-1:0 ] stall_prev;
  logic [       `RegBus]  next_pc;

  assign ce = `ChipEnable;
  assign inst_read_o = `ReadEnable;
  assign inst_addr_o = fetch_pc;
  assign next_pc = fetch_pc + 4;

  // stall_prev
  always_ff @(posedge clk, posedge rst) begin
    if (rst) stall_prev <= `STAGE_NUM'b0;
    else stall_prev <= stall;
  end

  // fetch_pc
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      fetch_pc <= `StartAddr;
    end else begin
      fetch_pc <= (ce == `ChipDisable) ? `ZeroWord :
                  (flush == `True) ? new_pc_i :
                  (stall[`IF_STAGE] == `Stop) ? id_pc_i + 4 :
                  (branch_taken_i == `BranchTaken) ? branch_target_addr_i :
                  next_pc;
    end
  end

  // if_pc_o
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      if_pc_o <= `ZeroWord;
    end else begin
      if_pc_o <= (flush == `True) ? new_pc_i : 
                 (stall[`IF_STAGE] == `Stop) ? `ZeroWord : fetch_pc;
    end
  end

  // inst_o
  assign inst_o = (stall_prev[`IF_STAGE] == `Stop) ? `NOP : inst_i;

endmodule
