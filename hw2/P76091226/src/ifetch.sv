`include "def.v"
module ifetch (
    input logic clk,
    input logic rstn,

    input logic [`STAGE_NUM-1:0] stall,
    input logic                  flush,
    input logic [       `RegBus] branch_target_addr_i,
    input logic                  branch_taken_i,
    input logic                  is_id_branch_inst,
    input logic [       `RegBus] new_pc_i,
    input logic [      `InstBus] inst_i,

    output logic [ `RegBus] if_pc_o,
    output logic            inst_read_o,
    output logic [ `RegBus] inst_addr_o,
    output logic [`InstBus] inst_o
);

  logic [`RegBus] fetch_pc, fetch_pc_next, next_pc;
  logic [`RegBus] branch_not_taken_addr_r;
  logic if_stall, branch_taken;

  assign if_stall = (stall[`IF_STAGE] == `Stop);
  assign branch_taken = (branch_taken_i == `BranchTaken);
  assign inst_addr_o = fetch_pc;
  assign next_pc = fetch_pc + 4'h4;

  // inst_read_o
  assign inst_read_o = (if_stall) ? `ReadDisable : `ReadEnable;

  // fetch_pc_next, if_pc_o
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      fetch_pc_next <= `StartAddr;
      if_pc_o <= `StartAddr;
    end else begin
      fetch_pc_next <= (if_stall) ? fetch_pc_next : fetch_pc;
      if_pc_o <= (if_stall) ? if_pc_o : fetch_pc_next;
    end
  end

  // fetch_pc
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      fetch_pc <= `StartAddr;
    end else begin
      fetch_pc <= (branch_taken) ? (branch_target_addr_i) : (is_id_branch_inst) ?  branch_not_taken_addr_r : (if_stall) ? fetch_pc : next_pc;
    end
  end

  // branch_not_taken_addr_r
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      branch_not_taken_addr_r <= `StartAddr;
    end else begin
      branch_not_taken_addr_r <= (~is_id_branch_inst) ? next_pc : branch_not_taken_addr_r;
    end
  end

  // inst_o
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      inst_o <= `StartAddr;
    end else begin
      inst_o <= (if_stall) ? inst_o : inst_i;
    end
  end

endmodule
