`include "def.v"

module id_ex(
    input logic                         clk,
    input logic                         rstn,
    
    input logic               [`RegBus] id_pc,
    input logic             [`Func3Bus] id_func3,
    input logic             [`AluOpBus] id_aluop,
    input logic                         id_alusrc1,
    input logic                         id_alusrc2,
    input logic               [`RegBus] id_imm,
    input logic               [`RegBus] id_rs1,
    input logic               [`RegBus] id_rs2,
    input logic           [`RegAddrBus] id_rd,
    input logic                         id_wreg,
    input logic                         id_memrd,
    input logic                         id_memwr,
    input logic                         id_mem2reg,
    input logic               [`RegBus] id_link_addr,
    input logic                         id_is_in_delayslot,
    input logic                         id_next_inst_in_delayslot,
    input logic        [`STAGE_NUM-1:0] stall,
    input logic                         flush,

    output logic              [`RegBus] ex_pc,
    output logic            [`Func3Bus] ex_func3,
    output logic            [`AluOpBus] ex_aluop,
    output logic                        ex_alusrc1,
    output logic                        ex_alusrc2,
    output logic              [`RegBus] ex_imm,
    output logic              [`RegBus] ex_rs1,
    output logic              [`RegBus] ex_rs2,
    output logic          [`RegAddrBus] ex_rd,
    output logic                        ex_wreg,
    output logic                        ex_memrd,
    output logic                        ex_memwr,
    output logic                        ex_mem2reg,
    output logic              [`RegBus] ex_link_addr,
    // output logic                        ex_is_in_delayslot,
    output logic                        ex_is_id_in_delayslot
);

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      ex_pc                 <= `ZeroWord;
      ex_func3              <= 3'b000;
      ex_aluop              <= (1'b1 << `ALUOP_ADD);
      ex_alusrc1            <= `SRC1_FROM_REG;
      ex_alusrc2            <= `SRC2_FROM_REG;
      ex_imm                <= `ZeroWord;
      ex_rs1                <= `ZeroWord;
      ex_rs2                <= `ZeroWord;
      ex_rd                 <= `NopRegAddr;
      ex_wreg               <= `WriteDisable;
      ex_memrd              <= `ReadDisable;
      ex_memwr              <= `WriteDisable;
      ex_mem2reg            <= `NotMem2Reg;
      ex_link_addr          <= `ZeroWord;
      ex_is_id_in_delayslot <= `NotInDelaySlot;
    end else if (flush == `True | 
      (stall[`ID_STAGE] == `Stop && stall[`EX_STAGE] == `NoStop) ) begin
      ex_pc                 <= `ZeroWord;
      ex_func3              <= 3'b000;
      ex_aluop              <= (1'b1 << `ALUOP_ADD);
      ex_alusrc1            <= `SRC1_FROM_REG;
      ex_alusrc2            <= `SRC2_FROM_REG;
      ex_imm                <= `ZeroWord;
      ex_rs1                <= `ZeroWord;
      ex_rs2                <= `ZeroWord;
      ex_rd                 <= `NopRegAddr;
      ex_wreg               <= `WriteDisable;
      ex_memrd              <= `ReadDisable;
      ex_memwr              <= `WriteDisable;
      ex_mem2reg            <= `NotMem2Reg;
      ex_link_addr          <= `ZeroWord;
      ex_is_id_in_delayslot <= `NotInDelaySlot;
    end else if (stall[`ID_STAGE] == `NoStop) begin
      ex_pc                 <= id_pc;
      ex_func3              <= id_func3;
      ex_aluop              <= id_aluop;
      ex_alusrc1            <= id_alusrc1;
      ex_alusrc2            <= id_alusrc2;
      ex_imm                <= id_imm;
      ex_rs1                <= id_rs1;
      ex_rs2                <= id_rs2;
      ex_rd                 <= id_rd;
      ex_wreg               <= id_wreg;
      ex_memrd              <= id_memrd;
      ex_memwr              <= id_memwr;
      ex_mem2reg            <= id_mem2reg;
      ex_link_addr          <= id_link_addr;
      ex_is_id_in_delayslot <= id_next_inst_in_delayslot;
    end
  end

endmodule

