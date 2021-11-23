`include "def.v"
module ex_mem (
    input logic clk,
    input logic rst,

    input logic [       `RegBus] ex_pc,
    input logic [   `RegAddrBus] ex_rd,
    input logic                  ex_wreg,
    input logic [       `RegBus] ex_wdata,
    input logic [       `RegBus] ex_wreg_data,
    input logic                  ex_memrd,
    input logic                  ex_memwr,
    input logic                  ex_mem2reg,
    input logic [     `Func3Bus] ex_func3,
    input logic [`STAGE_NUM-1:0] stall,
    input logic                  flush,

    output logic [    `RegBus] mem_pc,
    output logic [  `Func3Bus] mem_func3,
    output logic [`RegAddrBus] mem_rd,
    output logic               mem_wreg,
    output logic [    `RegBus] mem_wdata,
    output logic [    `RegBus] mem_wreg_data,
    output logic               mem_memrd,
    output logic               mem_memwr,
    output logic               mem_mem2reg
);

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      mem_pc        <= `ZeroWord;
      mem_func3     <= 3'b0;
      mem_rd        <= `NopRegAddr;
      mem_wreg      <= `WriteDisable;
      mem_wdata     <= `ZeroWord;
      mem_memrd     <= `ReadDisable;
      mem_memwr     <= `WriteDisable;
      mem_mem2reg   <= `NotMem2Reg;
      mem_wreg_data <= `ZeroWord;
    end else if (flush == `True | 
      (stall[`EX_STAGE] == `Stop && stall[`ME_STAGE] == `NoStop) ) begin
      mem_pc        <= `ZeroWord;
      mem_func3     <= 3'b0;
      mem_rd        <= `NopRegAddr;
      mem_wreg      <= `WriteDisable;
      mem_wdata     <= `ZeroWord;
      mem_memrd     <= `ReadDisable;
      mem_memwr     <= `WriteDisable;
      mem_mem2reg   <= `NotMem2Reg;
      mem_wreg_data <= `ZeroWord;
    end else if (stall[`ME_STAGE] == `NoStop) begin
      mem_pc        <= ex_pc;
      mem_func3     <= ex_func3;
      mem_rd        <= ex_rd;
      mem_wreg      <= ex_wreg;
      mem_wdata     <= ex_wdata;
      mem_memrd     <= ex_memrd;
      mem_memwr     <= ex_memwr;
      mem_mem2reg   <= ex_mem2reg;
      mem_wreg_data <= ex_wreg_data;
    end
  end

endmodule
