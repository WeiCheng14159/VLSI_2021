module ex_mem
  import cpu_pkg::*;
(
    input logic clk,
    input logic rstn,

    input logic      [  RegBusWidth-1:0] ex_pc,
    input reg_addr_t                     ex_rd,
    input logic                          ex_wreg,
    input logic      [  RegBusWidth-1:0] ex_wdata,
    input logic      [  RegBusWidth-1:0] ex_wreg_data,
    input logic                          ex_memrd,
    input logic                          ex_memwr,
    input logic                          ex_mem2reg,
    input logic      [Func3BusWidth-1:0] ex_func3,
    input logic      [    STAGE_NUM-1:0] stall,
    input logic                          flush,

    output logic      [  RegBusWidth-1:0] mem_pc,
    output logic      [Func3BusWidth-1:0] mem_func3,
    output reg_addr_t                     mem_rd,
    output logic                          mem_wreg,
    output logic      [  RegBusWidth-1:0] mem_wdata,
    output logic      [  RegBusWidth-1:0] mem_wreg_data,
    output logic                          mem_memrd,
    output logic                          mem_memwr,
    output logic                          mem_mem2reg
);

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      mem_pc        <= ZeroWord;
      mem_func3     <= {Func3BusWidth{1'b0}};
      mem_rd        <= ZERO_REG;
      mem_wreg      <= WriteDisable;
      mem_wdata     <= ZeroWord;
      mem_memrd     <= ReadDisable;
      mem_memwr     <= WriteDisable;
      mem_mem2reg   <= NotMem2Reg;
      mem_wreg_data <= ZeroWord;
    end else if (flush == True | (stall[EX_STAGE] == Stop && stall[ME_STAGE] == NoStop)) begin
      mem_pc        <= ZeroWord;
      mem_func3     <= {Func3BusWidth{1'b0}};
      mem_rd        <= ZERO_REG;
      mem_wreg      <= WriteDisable;
      mem_wdata     <= ZeroWord;
      mem_memrd     <= ReadDisable;
      mem_memwr     <= WriteDisable;
      mem_mem2reg   <= NotMem2Reg;
      mem_wreg_data <= ZeroWord;
    end else if (stall[ME_STAGE] == NoStop) begin
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
