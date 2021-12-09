module ifetch
  import cpu_pkg::*;
(
    input logic clk,
    input logic rstn,

    input logic [  STAGE_NUM-1:0] stall,
    input logic                   flush,
    input logic [RegBusWidth-1:0] branch_target_addr_i,
    input logic                   branch_taken_i,
    input logic                   is_id_branch_inst,
    input logic [RegBusWidth-1:0] new_pc_i,

    output logic [RegBusWidth-1:0] if_pc_o,
    output logic                   inst_read_o,
    output logic [RegBusWidth-1:0] inst_addr_o,
    output logic                   if_is_in_delay_slot_o
);

  logic branch_taken_i_r, is_id_branch_inst_r;
  logic [RegBusWidth-1:0]
      branch_not_taken_addr_r, fetch_pc, fetch_pc_next, next_pc;
  logic if_stall, is_taken;

  assign if_stall = (stall[IF_STAGE] == Stop);
  assign is_taken = (branch_taken_i == BranchTaken);
  assign inst_addr_o = fetch_pc;
  assign next_pc = fetch_pc + 4'h4;

  // inst_read_o
  assign inst_read_o = (if_stall | is_id_branch_inst) ? ReadDisable : ReadEnable;

  // if_pc_o
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      if_pc_o <= StartAddr;
    end else begin
      if_pc_o <= (if_stall) ? if_pc_o : fetch_pc;
    end
  end

  // fetch_pc
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      fetch_pc <= StartAddr;
    end else begin
      fetch_pc <= (is_id_branch_inst & ~is_taken) ? branch_not_taken_addr_r :
                  (is_id_branch_inst & is_taken) ? branch_target_addr_i :
                  (if_stall) ? fetch_pc : next_pc;
    end
  end

  // branch_not_taken_addr_r
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      branch_not_taken_addr_r <= StartAddr;
    end else begin
      branch_not_taken_addr_r <= (~is_id_branch_inst) ? next_pc : branch_not_taken_addr_r;
    end
  end

  // is_id_branch_inst_r, branch_taken_i_r
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      is_id_branch_inst_r <= False;
      branch_taken_i_r <= BranchNotTaken;
    end else begin
      is_id_branch_inst_r <= is_id_branch_inst;
      branch_taken_i_r <= (~if_stall | (is_id_branch_inst & ~is_taken)) ? BranchNotTaken : 
                          (is_id_branch_inst & is_taken) ? BranchTaken : branch_taken_i_r;
    end
  end

  assign if_is_in_delay_slot_o = (is_taken | branch_taken_i_r);

endmodule
