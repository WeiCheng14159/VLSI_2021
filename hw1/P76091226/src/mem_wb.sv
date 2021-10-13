`include "def.v"

module mem_wb(
  input logic                           clk,
  input logic                           rst,

  input logic             [`RegAddrBus] mem_rd,
  input logic                           mem_wreg,
  input logic                           mem_mem2reg,
  input logic                 [`RegBus] mem_wreg_data,
  input logic               [`Func3Bus] mem_func3,
  input logic          [`STAGE_NUM-1:0] stall,
  input logic                           flush,

  output logic            [`RegAddrBus] wb_rd,
  output logic                          wb_wreg,
  output logic                          wb_mem2reg,
  output logic                [`RegBus] wb_from_alu,
  output logic              [`Func3Bus] wb_func3 
);

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      wb_rd          <= `NopRegAddr;
      wb_wreg        <= `WriteDisable;
      wb_mem2reg     <= `NotMem2Reg;
      wb_from_alu    <= `ZeroWord;
      wb_func3       <= 3'b0;
    end else if (flush == `True |
       (stall[`ME_STAGE] == `Stop && stall[`WB_STAGE] == `NoStop) ) begin
      wb_rd          <= `NopRegAddr;
      wb_wreg        <= `WriteDisable;
      wb_mem2reg     <= `NotMem2Reg;
      wb_from_alu    <= `ZeroWord;
      wb_func3       <= 3'b0;
    end else if (stall[`ME_STAGE] == `NoStop) begin
      wb_rd          <= mem_rd;
      wb_wreg        <= mem_wreg;
      wb_mem2reg     <= mem_mem2reg;
      wb_from_alu    <= mem_wreg_data;
      wb_func3       <= mem_func3;
    end
  end

endmodule

