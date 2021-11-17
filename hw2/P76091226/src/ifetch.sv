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
    input logic [       `RegBus] id_pc_i,

    output logic [ `RegBus] if_pc_o,
    output logic            inst_read_o,
    output logic [ `RegBus] inst_addr_o,
    output logic [`InstBus] inst_o
);

  logic [       `RegBus] fetch_pc, fetch_pc_next, next_pc;
  logic [       `RegBus] branch_target_addr_r, branch_not_taken_addr_r;
  logic                  if_stall, branch_taken;

  assign if_stall = stall[`IF_STAGE] == `Stop;
  assign branch_taken = (branch_taken_i == `BranchTaken);
  assign inst_addr_o = fetch_pc;
  assign next_pc = fetch_pc + 4;

  // inst_read_o
  assign inst_read_o = (if_stall | branch_taken | is_id_branch_inst) ? `ReadDisable : `ReadEnable;

  // if_pc_o
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      if_pc_o <= `StartAddr;
      fetch_pc_next <= `StartAddr;
    end else begin
      if_pc_o <= (if_stall) ? if_pc_o : fetch_pc_next;
      fetch_pc_next <= (if_stall) ? fetch_pc_next : fetch_pc;
    end
  end

  // fetch_pc
  always_ff @(posedge clk, negedge rstn) begin
    if(~rstn) begin
      fetch_pc <= `StartAddr;
    end else begin
      if(if_stall) begin
        if(is_id_branch_inst & branch_taken) begin
          fetch_pc <= branch_target_addr_i;
        end else if(is_id_branch_inst & ~branch_taken) begin
          fetch_pc <= fetch_pc;
        end else begin
          fetch_pc <= fetch_pc;
        end
      end else begin
        // no if_stall
        if(is_id_branch_inst & branch_taken) begin
          fetch_pc <= branch_target_addr_r;
        end else if(is_id_branch_inst & ~branch_taken) begin
          fetch_pc <= branch_not_taken_addr_r;
        end else begin
          fetch_pc <= next_pc;
        end
      end

    end
  end

  // branch_target_addr_r
  always_ff @(posedge clk, negedge rstn) begin
    if(~rstn) begin
      branch_target_addr_r <= `StartAddr;
      branch_not_taken_addr_r <= `StartAddr;
    end else begin
      branch_target_addr_r <= (is_id_branch_inst) ? branch_target_addr_i : branch_target_addr_r;
      branch_not_taken_addr_r <= (~is_id_branch_inst) ? next_pc : branch_not_taken_addr_r;
    end
  end

  // inst_o
  always_ff @(posedge clk, negedge rstn) begin
    if(~rstn) begin
      inst_o <= `StartAddr;
    end else begin
      inst_o <= (if_stall) ? inst_o : inst_i;
    end
  end

endmodule
