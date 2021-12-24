module ctrl
  import cpu_pkg::*;
(
    input logic stallreq_from_imem,
    input logic stallreq_from_id,
    input logic stallreq_from_csr,
    input logic stallreq_from_ex,
    input logic stallreq_from_dmem,
    input logic is_id_branch_inst,

    output logic [  STAGE_NUM-1:0] stall,
    output logic [RegBusWidth-1:0] new_pc_o
);

  always_comb begin
    stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b0_0000};
    if (stallreq_from_csr) begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b1_1111};
    end else if (stallreq_from_dmem == Stop) begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b1_1111};
    end else if (stallreq_from_ex == Stop) begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b0_0111};
    end else if (stallreq_from_id == Stop) begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b0_0011};
    end else if (stallreq_from_imem == Stop) begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b0_0001};
    end else if (is_id_branch_inst) begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b0_0001};
    end else begin
      stall = {{(STAGE_NUM - 5) {1'b0}}, 5'b0_0000};
    end
  end

  assign new_pc_o = ZeroWord;

endmodule
