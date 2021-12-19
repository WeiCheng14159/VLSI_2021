module mem_wb
  import cpu_pkg::*;
(
    input logic clk,
    input logic rstn,

    input reg_addr_t                     mem_rd,
    input logic                          mem_wreg,
    input logic                          mem_mem2reg,
    input logic      [  RegBusWidth-1:0] mem_wreg_data,
    input logic      [Func3BusWidth-1:0] mem_func3,
    input logic      [  RegBusWidth-1:0] mem_pc,
    input logic      [    STAGE_NUM-1:0] stall,
    input logic                          flush,

    output reg_addr_t                     wb_rd,
    output logic                          wb_wreg,
    output logic                          wb_mem2reg,
    output logic      [  RegBusWidth-1:0] wb_from_alu,
    output logic      [Func3BusWidth-1:0] wb_func3,
    output logic      [  RegBusWidth-1:0] wb_pc
);

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      wb_rd       <= ZERO_REG;
      wb_wreg     <= WriteDisable;
      wb_mem2reg  <= NotMem2Reg;
      wb_from_alu <= ZeroWord;
      wb_func3    <= {Func3BusWidth{1'b0}};
      wb_pc       <= ZeroWord;
    end else if (flush == True |
       (stall[ME_STAGE] == Stop && stall[WB_STAGE] == NoStop) ) begin
      wb_rd       <= ZERO_REG;
      wb_wreg     <= WriteDisable;
      wb_mem2reg  <= NotMem2Reg;
      wb_from_alu <= ZeroWord;
      wb_func3    <= {Func3BusWidth{1'b0}};
      wb_pc       <= ZeroWord;
    end else if (stall[ME_STAGE] == NoStop) begin
      wb_rd       <= mem_rd;
      wb_wreg     <= mem_wreg;
      wb_mem2reg  <= mem_mem2reg;
      wb_from_alu <= mem_wreg_data;
      wb_func3    <= mem_func3;
      wb_pc       <= mem_pc;
    end
  end

endmodule

