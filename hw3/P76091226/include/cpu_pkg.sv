`ifndef CPU_PKG_SV
`define CPU_PKG_SV

package cpu_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  // `define MulEnable

  // Bus
  localparam AddressWidth = 32, DataWidth = 32, RegBusWidth = 32, Func3BusWidth = 3;
  // Address
  localparam ZeroWord = {AddressWidth{1'b0}}, StartAddr = {AddressWidth{1'b0}};
  // Instruction
  localparam NOP = 32'h0000_0013;

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
  localparam MulBusWidth = 32;

  /* Instruction field */
  `define OPCODE 6:0
  `define FUNC3 14:12
  `define FUNC7 31:25
  `define RD 11:7
  `define RS1 19:15
  `define RS2 24:20
  `define IMM12 31:20

  // OPCODE, INST[6:0]
  `define OP_AUIPC 7'b0010111 // U-type
  `define OP_LUI 7'b0110111 // U-type
  `define OP_JAL 7'b1101111 // J-type
  `define OP_JALR 7'b1100111 // I-type
  `define OP_BRANCH 7'b1100011 // B-type
  `define OP_LOAD 7'b0000011 // I-type
  `define OP_STORE 7'b0100011 // S-type
  `define OP_ARITHI 7'b0010011 // I-type
  `define OP_ARITHR 7'b0110011 // R-type
  `define OP_FENCE 7'b0001111
  `define OP_SYSTEM 7'b1110011

  // FUNC3, INST[14:12], INST[6:0] = OP_BRANCH
  `define OP_BEQ 3'b000
  `define OP_BNE 3'b001
  `define OP_BLT 3'b100
  `define OP_BGE 3'b101
  `define OP_BLTU 3'b110
  `define OP_BGEU 3'b111

  // FUNC3, INST[14:12], INST[6:0] = OP_LOAD
  `define OP_LB 3'b000
  `define OP_LH 3'b001
  `define OP_LW 3'b010
  `define OP_LBU 3'b100
  `define OP_LHU 3'b101

  // FUNC3, INST[14:12], INST[6:0] = OP_STORE
  `define OP_SB 3'b000
  `define OP_SH 3'b001
  `define OP_SW 3'b010

  // FUNC3, INST[14:12], INST[6:0] = OP_ARTHI, OP_ARTHR
  `define OP_ADD 3'b000    // SUB: inst[30] == 1
  `define OP_SLL 3'b001
  `define OP_SLT 3'b010
  `define OP_SLTU 3'b011
  `define OP_XOR 3'b100
  `define OP_OR 3'b110
  `define OP_SR 3'b101    // SRA: inst[30] == 1
  `define OP_AND 3'b111

  // FUNC3, INST[14:12], INST[6:0] = OP_ARTHR, FUNC7 INST[31:25] == 0x01
  `define OP_MUL 3'b000
  `define OP_MULH 3'b001
  `define OP_MULHSU 3'b010
  `define OP_MULHU 3'b011
  `define OP_DIV 3'b100
  `define OP_DIVU 3'b101
  `define OP_REM 3'b110
  `define OP_REMU 3'b111

  localparam AluOpBusWidth = 15;
  // ALUop
  typedef enum logic [AluOpBusWidth-1:0] {
    ALUOP_ADD = 1 << 0,
    ALUOP_SUB = 1 << 1,
    ALUOP_SLL = 1 << 2,
    ALUOP_SRL = 1 << 3,
    ALUOP_SRA = 1 << 4,
    ALUOP_SLT = 1 << 5,
    ALUOP_SLTU = 1 << 6,
    ALUOP_OR = 1 << 7,
    ALUOP_XOR = 1 << 8,
    ALUOP_AND = 1 << 9,
    ALUOP_MUL = 1 << 10,
    ALUOP_MULH = 1 << 11,
    ALUOP_MULU = 1 << 12,
    ALUOP_MULSU = 1 << 13,
    ALUOP_LINK = 1 << 14
  } aluop_t;

  // ALU source
  localparam AluSrcBusWidth = 2;
  typedef enum logic [AluSrcBusWidth-1:0] {
    SRC1_FROM_REG = 2'b000,
    SRC1_FROM_PC  = 2'b001,
    SRC2_FROM_REG = 2'b010,
    SRC2_FROM_IMM = 2'b011
  } alusrc_t;

  typedef enum logic [4:0] {
    REG_ZERO = 5'h0,
    REG_RA   = 5'h1,
    REG_SP   = 5'h2,
    REG_GP   = 5'h3,
    REG_TP   = 5'h4,
    REG_T0   = 5'h5,
    REG_T1   = 5'h6,
    REG_T2   = 5'h7,
    REG_S0   = 5'h8,
    REG_S1   = 5'h9,
    REG_A0   = 5'h10,
    REG_A1   = 5'h11,
    REG_A2   = 5'h12,
    REG_A3   = 5'h13,
    REG_A4   = 5'h14,
    REG_A5   = 5'h15,
    REG_A6   = 5'h16,
    REG_A7   = 5'h17,
    REG_S2   = 5'h18,
    REG_S3   = 5'h19,
    REG_S4   = 5'h20,
    REG_S5   = 5'h21,
    REG_S6   = 5'h22,
    REG_S7   = 5'h23,
    REG_S8   = 5'h24,
    REG_S9   = 5'h25,
    REG_S10  = 5'h26,
    REG_S11  = 5'h27,
    REG_T3   = 5'h28,
    REG_T4   = 5'h29,
    REG_T5   = 5'h30,
    REG_T6   = 5'h31
  } register_t;

  function automatic register_t REG_CONVERT(logic [4:0] reg_num_in);
    unique case (reg_num_in)
      5'h0:  REG_CONVERT = REG_ZERO;
      5'h1:  REG_CONVERT = REG_RA;
      5'h2:  REG_CONVERT = REG_SP;
      5'h3:  REG_CONVERT = REG_GP;
      5'h4:  REG_CONVERT = REG_TP;
      5'h5:  REG_CONVERT = REG_T0;
      5'h6:  REG_CONVERT = REG_T1;
      5'h7:  REG_CONVERT = REG_T2;
      5'h8:  REG_CONVERT = REG_S0;
      5'h9:  REG_CONVERT = REG_S1;
      5'h10: REG_CONVERT = REG_A0;
      5'h11: REG_CONVERT = REG_A1;
      5'h12: REG_CONVERT = REG_A2;
      5'h13: REG_CONVERT = REG_A3;
      5'h14: REG_CONVERT = REG_A4;
      5'h15: REG_CONVERT = REG_A5;
      5'h16: REG_CONVERT = REG_A6;
      5'h17: REG_CONVERT = REG_A7;
      5'h18: REG_CONVERT = REG_S2;
      5'h19: REG_CONVERT = REG_S3;
      5'h20: REG_CONVERT = REG_S4;
      5'h21: REG_CONVERT = REG_S5;
      5'h22: REG_CONVERT = REG_S6;
      5'h23: REG_CONVERT = REG_S7;
      5'h24: REG_CONVERT = REG_S8;
      5'h25: REG_CONVERT = REG_S9;
      5'h26: REG_CONVERT = REG_S10;
      5'h27: REG_CONVERT = REG_S11;
      5'h28: REG_CONVERT = REG_T3;
      5'h29: REG_CONVERT = REG_T4;
      5'h30: REG_CONVERT = REG_T5;
      5'h31: REG_CONVERT = REG_T6;
    endcase
  endfunction

endpackage : cpu_pkg

`endif
