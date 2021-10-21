`include "def.v"

module ctrl(
  input logic                           stallreq_from_if,
  input logic                           stallreq_from_id,
  input logic                           stallreq_from_ex,
  input logic                           stallreq_from_mem,

  output logic         [`STAGE_NUM-1:0] stall,
  output logic                [`RegBus] new_pc_o
);

  always_comb begin
    stall = {`STAGE_NUM'b000_00};
    if (stallreq_from_if == `Stop) begin
      stall = {`STAGE_NUM'b000_11};
    end else if (stallreq_from_id == `Stop) begin
      stall = {`STAGE_NUM'b000_11};
    end else if (stallreq_from_ex == `Stop) begin
      stall = {`STAGE_NUM'b001_11};
    end else if (stallreq_from_mem == `Stop) begin
      stall = {`STAGE_NUM'b011_11};
    end else begin
      stall = {`STAGE_NUM'b000_00};
    end
  end

  assign new_pc_o = `ZeroWord;

endmodule
