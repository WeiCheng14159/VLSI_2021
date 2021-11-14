`include "def.v"
module ifetch (
    input logic clk,
    input logic rstn,

    input logic                  stallreq_from_if,
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

  logic [       `RegBus]  fetch_pc;
  logic [`STAGE_NUM-1:0 ] stall_prev;
  logic [       `RegBus]  next_pc;

  assign inst_read_o = `ReadEnable;
  assign inst_addr_o = fetch_pc;
  assign next_pc = fetch_pc + 4;

  // fetch_pc
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      fetch_pc <= `StartAddr;
    end else begin
      fetch_pc <= (branch_taken_i == `BranchTaken) ? branch_target_addr_i :
                  (stallreq_from_if) ? fetch_pc :
                  (flush == `True) ? new_pc_i :
                  (stall[`IF_STAGE] == `Stop) ? id_pc_i + 4 :
                  next_pc;
    end
  end

  // if_pc_o
  always_comb begin
    if(flush == `True)
      if_pc_o = new_pc_i;
    else if(stall[`IF_STAGE] == `Stop)
      if_pc_o = `ZeroWord;
    else
      if_pc_o = fetch_pc - 4;
  end

  // inst_o
  assign inst_o = (stall[`IF_STAGE] == `Stop) ? `NOP : inst_i;

endmodule
