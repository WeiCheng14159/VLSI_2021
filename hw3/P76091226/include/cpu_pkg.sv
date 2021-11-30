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
  localparam NOP = 32'h0000_0013, NopRegAddr = 5'b0;

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
  localparam ALUOP_ADD_BIT = 0, ALUOP_SUB_BIT = 1, ALUOP_SLL_BIT = 2, ALUOP_SRL_BIT = 3,
  ALUOP_SRA_BIT = 4,ALUOP_SLT_BIT = 5, ALUOP_SLTU_BIT = 6, ALUOP_OR_BIT = 7, 
  ALUOP_XOR_BIT = 8, ALUOP_AND_BIT = 9, ALUOP_MUL_BIT = 10, ALUOP_MULH_BIT = 11, 
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
  localparam AluSrcBusWidth = 2;
  typedef enum logic [AluSrcBusWidth-1:0] {
    SRC_FROM_REG = 2'b01,
    SRC_FROM_PC  = 2'b10,
    SRC_FROM_IMM = 2'b11
  } alusrc_t;

  typedef enum logic [4:0] {
    REG_ZERO = 5'd0,
    REG_RA   = 5'd1,
    REG_SP   = 5'd2,
    REG_GP   = 5'd3,
    REG_TP   = 5'd4,
    REG_T0   = 5'd5,
    REG_T1   = 5'd6,
    REG_T2   = 5'd7,
    REG_S0   = 5'd8,
    REG_S1   = 5'd9,
    REG_A0   = 5'd10,
    REG_A1   = 5'd11,
    REG_A2   = 5'd12,
    REG_A3   = 5'd13,
    REG_A4   = 5'd14,
    REG_A5   = 5'd15,
    REG_A6   = 5'd16,
    REG_A7   = 5'd17,
    REG_S2   = 5'd18,
    REG_S3   = 5'd19,
    REG_S4   = 5'd20,
    REG_S5   = 5'd21,
    REG_S6   = 5'd22,
    REG_S7   = 5'd23,
    REG_S8   = 5'd24,
    REG_S9   = 5'd25,
    REG_S10  = 5'd26,
    REG_S11  = 5'd27,
    REG_T3   = 5'd28,
    REG_T4   = 5'd29,
    REG_T5   = 5'd30,
    REG_T6   = 5'd31
  } register_t;

  function automatic register_t REG_CONVERT(logic [4:0] reg_num_in);
    unique case (reg_num_in)
      5'd0:  REG_CONVERT = REG_ZERO;
      5'd1:  REG_CONVERT = REG_RA;
      5'd2:  REG_CONVERT = REG_SP;
      5'd3:  REG_CONVERT = REG_GP;
      5'd4:  REG_CONVERT = REG_TP;
      5'd5:  REG_CONVERT = REG_T0;
      5'd6:  REG_CONVERT = REG_T1;
      5'd7:  REG_CONVERT = REG_T2;
      5'd8:  REG_CONVERT = REG_S0;
      5'd9:  REG_CONVERT = REG_S1;
      5'd10: REG_CONVERT = REG_A0;
      5'd11: REG_CONVERT = REG_A1;
      5'd12: REG_CONVERT = REG_A2;
      5'd13: REG_CONVERT = REG_A3;
      5'd14: REG_CONVERT = REG_A4;
      5'd15: REG_CONVERT = REG_A5;
      5'd16: REG_CONVERT = REG_A6;
      5'd17: REG_CONVERT = REG_A7;
      5'd18: REG_CONVERT = REG_S2;
      5'd19: REG_CONVERT = REG_S3;
      5'd20: REG_CONVERT = REG_S4;
      5'd21: REG_CONVERT = REG_S5;
      5'd22: REG_CONVERT = REG_S6;
      5'd23: REG_CONVERT = REG_S7;
      5'd24: REG_CONVERT = REG_S8;
      5'd25: REG_CONVERT = REG_S9;
      5'd26: REG_CONVERT = REG_S10;
      5'd27: REG_CONVERT = REG_S11;
      5'd28: REG_CONVERT = REG_T3;
      5'd29: REG_CONVERT = REG_T4;
      5'd30: REG_CONVERT = REG_T5;
      5'd31: REG_CONVERT = REG_T6;
    endcase
  endfunction

endpackage : cpu_pkg

`endif
