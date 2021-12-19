`ifndef CPU_PKG_SV
`define CPU_PKG_SV

package cpu_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  // Bus
  localparam InstrWidth = 32, InstrAddrWidth = 32, DataWidth = 32, DataAddrWidth = 32;
  localparam RegBusWidth = 32, RegAddrWidth = 5, Func3BusWidth = 3;
  // Address
  localparam ZeroWord = {InstrAddrWidth{1'b0}}, StartAddr = {InstrAddrWidth{1'b0}};
  // Signal alias
  localparam WriteEnable = 1'b1, WriteDisable = 1'b0;
  localparam ReadEnable = 1'b1, ReadDisable = 1'b0;
  localparam InstInvalid = 1'b1, InstValid = 1'b0;
  localparam ChipEnable = 1'b1, ChipDisable = 1'b0;
  localparam Stop = 1'b1, NoStop = 1'b0;
  localparam Mem2Reg = 1'b1, NotMem2Reg = 1'b0;
  localparam BranchTaken = 1'b1, BranchNotTaken = 1'b0;
  localparam InDelaySlot = 1'b1, NotInDelaySlot = 1'b0;
  localparam True = 1'b1, False = 1'b0;
  // Register
  localparam RegNum = 32, RegNumLog2 = 5;
  // Pipeline stages
  localparam STAGE_NUM = 5;
  localparam IF_STAGE = 0, ID_STAGE = 1, EX_STAGE = 2, ME_STAGE = 3, WB_STAGE = 4;
  // Multiply
  // `define MulEnable
  localparam MulBusWidth = 64;
  // NOP
  localparam NOP = 32'h0000_0013;

  /* Instruction field */
  `define OPCODE 6:0
  `define FUNC3 14:12
  `define FUNC7 31:25
  `define RD 11:7
  `define RS1 19:15
  `define RS2 24:20
  `define IMM12 31:20

  // OPCODE, INST[6:0]
  localparam OP_AUIPC = 7'b0010111;  // U-type
  localparam OP_LUI = 7'b0110111;  // U-type
  localparam OP_JAL = 7'b1101111;  // J-type
  localparam OP_JALR = 7'b1100111;  // I-type
  localparam OP_BRANCH = 7'b1100011;  // B-type
  localparam OP_LOAD = 7'b0000011;  // I-type
  localparam OP_STORE = 7'b0100011;  // S-type
  localparam OP_ARITHI = 7'b0010011;  // I-type
  localparam OP_ARITHR = 7'b0110011;  // R-type
  localparam OP_FENCE = 7'b0001111;
  localparam OP_SYSTEM = 7'b1110011;

  // FUNC3, INST[14:12], INST[6:0] = OP_BRANCH
  localparam OP_BEQ = 3'b000;
  localparam OP_BNE = 3'b001;
  localparam OP_BLT = 3'b100;
  localparam OP_BGE = 3'b101;
  localparam OP_BLTU = 3'b110;
  localparam OP_BGEU = 3'b111;

  // FUNC3, INST[14:12], INST[6:0] = OP_LOAD
  localparam OP_LB = 3'b000;
  localparam OP_LH = 3'b001;
  localparam OP_LW = 3'b010;
  localparam OP_LBU = 3'b100;
  localparam OP_LHU = 3'b101;

  // FUNC3, INST[14:12], INST[6:0] = OP_STORE
  localparam OP_SB = 3'b000;
  localparam OP_SH = 3'b001;
  localparam OP_SW = 3'b010;

  // FUNC3, INST[14:12], INST[6:0] = OP_ARTHI, OP_ARTHR
  localparam OP_ADD = 3'b000;  // SUB: inst[30] == 1
  localparam OP_SLL = 3'b001;
  localparam OP_SLT = 3'b010;
  localparam OP_SLTU = 3'b011;
  localparam OP_XOR = 3'b100;
  localparam OP_OR = 3'b110;
  localparam OP_SR = 3'b101;  // SRA: inst[30] == 1
  localparam OP_AND = 3'b111;

  // FUNC3, INST[14:12], INST[6:0] = OP_ARTHR, FUNC7 INST[31:25] == 0x01
  localparam OP_MUL = 3'b000;
  localparam OP_MULH = 3'b001;
  localparam OP_MULHSU = 3'b010;
  localparam OP_MULHU = 3'b011;
  localparam OP_DIV = 3'b100;
  localparam OP_DIVU = 3'b101;
  localparam OP_REM = 3'b110;
  localparam OP_REMU = 3'b111;

  // ALUop
  localparam AluOpBusWidth = 15;
  localparam ALUOP_ADD_BIT = 0, ALUOP_SUB_BIT = 1, ALUOP_SLL_BIT = 2, 
             ALUOP_SRL_BIT = 3, ALUOP_SRA_BIT = 4,ALUOP_SLT_BIT = 5, 
             ALUOP_SLTU_BIT = 6, ALUOP_OR_BIT = 7, ALUOP_XOR_BIT = 8, 
             ALUOP_AND_BIT = 9, ALUOP_MUL_BIT = 10, ALUOP_MULH_BIT = 11, 
             ALUOP_MULHU_BIT = 12, ALUOP_MULSU_BIT = 13, ALUOP_LINK_BIT = 14;

  typedef enum logic [AluOpBusWidth-1:0] {
    ALUOP_ADD = 1 << ALUOP_ADD_BIT,
    ALUOP_SUB = 1 << ALUOP_SUB_BIT,
    ALUOP_SLL = 1 << ALUOP_SLL_BIT,
    ALUOP_SRL = 1 << ALUOP_SRL_BIT,
    ALUOP_SRA = 1 << ALUOP_SRA_BIT,
    ALUOP_SLT = 1 << ALUOP_SLT_BIT,
    ALUOP_SLTU = 1 << ALUOP_SLTU_BIT,
    ALUOP_OR = 1 << ALUOP_OR_BIT,
    ALUOP_XOR = 1 << ALUOP_XOR_BIT,
    ALUOP_AND = 1 << ALUOP_AND_BIT,
    ALUOP_MUL = 1 << ALUOP_MUL_BIT,
    ALUOP_MULH = 1 << ALUOP_MULH_BIT,
    ALUOP_MULHU = 1 << ALUOP_MULHU_BIT,
    ALUOP_MULSU = 1 << ALUOP_MULSU_BIT,
    ALUOP_LINK = 1 << ALUOP_LINK_BIT
  } aluop_t;

  // ALU source
  localparam SRC1_FROM_REG = 1'b0;
  localparam SRC1_FROM_PC = 1'b1;
  localparam SRC2_FROM_REG = 1'b0;
  localparam SRC2_FROM_IMM = 1'b1;

  typedef enum logic [RegAddrWidth-1:0] {
    ZERO_REG = 5'd0,
    RA_REG   = 5'd1,
    SP_REG   = 5'd2,
    GP_REG   = 5'd3,
    TP_REG   = 5'd4,
    T0_REG   = 5'd5,
    T1_REG   = 5'd6,
    T2_REG   = 5'd7,
    S0_REG   = 5'd8,
    S1_REG   = 5'd9,
    A0_REG   = 5'd10,
    A1_REG   = 5'd11,
    A2_REG   = 5'd12,
    A3_REG   = 5'd13,
    A4_REG   = 5'd14,
    A5_REG   = 5'd15,
    A6_REG   = 5'd16,
    A7_REG   = 5'd17,
    S2_REG   = 5'd18,
    S3_REG   = 5'd19,
    S4_REG   = 5'd20,
    S5_REG   = 5'd21,
    S6_REG   = 5'd22,
    S7_REG   = 5'd23,
    S8_REG   = 5'd24,
    S9_REG   = 5'd25,
    S10_REG  = 5'd26,
    S11_REG  = 5'd27,
    T3_REG   = 5'd28,
    T4_REG   = 5'd29,
    T5_REG   = 5'd30,
    T6_REG   = 5'd31
  } reg_addr_t;

  function automatic reg_addr_t REG_CONVERT(
      logic [RegAddrWidth-1:0] reg_num_in);
    unique case (reg_num_in)
      5'd0:  REG_CONVERT = ZERO_REG;
      5'd1:  REG_CONVERT = RA_REG;
      5'd2:  REG_CONVERT = SP_REG;
      5'd3:  REG_CONVERT = GP_REG;
      5'd4:  REG_CONVERT = TP_REG;
      5'd5:  REG_CONVERT = T0_REG;
      5'd6:  REG_CONVERT = T1_REG;
      5'd7:  REG_CONVERT = T2_REG;
      5'd8:  REG_CONVERT = S0_REG;
      5'd9:  REG_CONVERT = S1_REG;
      5'd10: REG_CONVERT = A0_REG;
      5'd11: REG_CONVERT = A1_REG;
      5'd12: REG_CONVERT = A2_REG;
      5'd13: REG_CONVERT = A3_REG;
      5'd14: REG_CONVERT = A4_REG;
      5'd15: REG_CONVERT = A5_REG;
      5'd16: REG_CONVERT = A6_REG;
      5'd17: REG_CONVERT = A7_REG;
      5'd18: REG_CONVERT = S2_REG;
      5'd19: REG_CONVERT = S3_REG;
      5'd20: REG_CONVERT = S4_REG;
      5'd21: REG_CONVERT = S5_REG;
      5'd22: REG_CONVERT = S6_REG;
      5'd23: REG_CONVERT = S7_REG;
      5'd24: REG_CONVERT = S8_REG;
      5'd25: REG_CONVERT = S9_REG;
      5'd26: REG_CONVERT = S10_REG;
      5'd27: REG_CONVERT = S11_REG;
      5'd28: REG_CONVERT = T3_REG;
      5'd29: REG_CONVERT = T4_REG;
      5'd30: REG_CONVERT = T5_REG;
      5'd31: REG_CONVERT = T6_REG;
    endcase
  endfunction

endpackage : cpu_pkg

`endif
