`include "def.v"
module if_id(
  input logic                           clk,
  input logic                           rst,

  input logic                 [`RegBus] if_pc,
  input logic                [`InstBus] if_inst,
  input logic                           flush,
  input logic          [`STAGE_NUM-1:0] stall,
  
  output logic                [`RegBus] id_pc,
  output logic               [`InstBus] id_inst
);

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      id_pc   <= `ZeroWord;
      id_inst <= `NOP;
    end else if (flush == `True | 
      (stall[`IF_STAGE] == `Stop && stall[`ID_STAGE] == `NoStop) ) begin
      id_pc   <= `ZeroWord;
      id_inst <= `NOP;
    end else if(stall[`IF_STAGE] == `NoStop) begin
      id_pc   <= if_pc;
      id_inst <= if_inst;
    end 
  end

endmodule

