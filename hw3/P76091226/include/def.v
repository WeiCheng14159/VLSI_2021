`ifndef __CPU_DEF_V__
`define __CPU_DEF_V__

// `define MulEnable

/* Signal alias */
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h0000_0000
`define StartAddr 32'h0000_0000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define Stop 1'b1
`define NoStop 1'b0
`define Mem2Reg 1'b1
`define NotMem2Reg 1'b0
`define BranchTaken 1'b1
`define BranchNotTaken 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define True 1'b1
`define False 1'b0

/* Pipeline stages */
`define IF_STAGE 0
`define ID_STAGE 1
`define EX_STAGE 2
`define ME_STAGE 3
`define WB_STAGE 4
`define STAGE_NUM 5

/* Bus width */
`define RegNum 32
`define RegNumLog2 5

`define InstBus 31:0
`define InstAddrBus 31:0
`define DataBus 31:0
`define DataAddrBus 31:0
`define Func3Bus 2:0
`define RegBus 31:0
`define MulBus 63:0
`define RegAddrBus `RegNumLog2 - 1:0
`define AluOpBus 14:0

/* Instruction field */
`define OPCODE 6:0
`define FUNC3 14:12
`define FUNC7 31:25
`define RD 11:7
`define RS1 19:15
`define RS2 24:20
`define IMM12 31:20

/* NOP (bubble) */
`define NOP 32'h0000_0013  // addi x0, x0, 0
`define NopRegAddr 5'b00000

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

// ALUop
`define ALUOP_ADD 0
`define ALUOP_SUB 1
`define ALUOP_SLL 2
`define ALUOP_SRL 3
`define ALUOP_SRA 4
`define ALUOP_SLT 5
`define ALUOP_SLTU 6
`define ALUOP_OR 7
`define ALUOP_XOR 8
`define ALUOP_AND 9
`define ALUOP_MUL 10
`define ALUOP_MULH 11
`define ALUOP_MULU 12
`define ALUOP_MULSU 13
`define ALUOP_LINK 14

// ALU source
`define SRC1_FROM_REG 1'b0
`define SRC1_FROM_PC 1'b1
`define SRC2_FROM_REG 1'b0
`define SRC2_FROM_IMM 1'b1

// Register/ABI mapping
`define REG_ZERO 0
`define REG_RA 1
`define REG_SP 2
`define REG_GP 3
`define REG_TP 4
`define REG_T0 5
`define REG_T1 6
`define REG_T2 7
`define REG_S0 8
`define REG_S1 9
`define REG_A0 10
`define REG_A1 11
`define REG_A2 12
`define REG_A3 13
`define REG_A4 14
`define REG_A5 15
`define REG_A6 16
`define REG_A7 17
`define REG_S2 18
`define REG_S3 19
`define REG_S4 20
`define REG_S5 21
`define REG_S6 22
`define REG_S7 23
`define REG_S8 24
`define REG_S9 25
`define REG_S10 26
`define REG_S11 27
`define REG_T3 28
`define REG_T4 29
`define REG_T5 30
`define REG_T6 31

`endif
