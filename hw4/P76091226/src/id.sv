`include "pkg_include.sv"

module id
  import cpu_pkg::*;
(
    input logic [RegBusWidth-1:0] pc_i,
    input logic [ InstrWidth-1:0] inst_i,

    // From reg file
    input logic [RegBusWidth-1:0] rs1_data_i,
    input logic [RegBusWidth-1:0] rs2_data_i,

    // From ex stage
    input logic                        ex_wreg_i,
    input logic      [RegBusWidth-1:0] ex_wreg_data_i,
    input reg_addr_t                   ex_rd_i,
    input logic                        ex_memrd_i,

    // From mem stage
    input logic                        mem_wreg_i,
    input logic      [RegBusWidth-1:0] mem_wreg_data_i,
    input reg_addr_t                   mem_rd_i,
    input logic                        mem_memrd_i,

    // Register file control
    output logic      rs1_read_o,
    output logic      rs2_read_o,
    output reg_addr_t rs1_addr_o,
    output reg_addr_t rs2_addr_o,

    // Control signals
    output aluop_t                          aluop_o,
    output logic                            alusrc1_o,
    output logic                            alusrc2_o,
    output logic signed [  RegBusWidth-1:0] imm_o,
    output logic        [  RegBusWidth-1:0] rs1_data_o,
    output logic        [  RegBusWidth-1:0] rs2_data_o,
    output reg_addr_t                       rd_o,
    output logic                            wreg_o,
    output logic                            memrd_o,
    output logic                            memwr_o,
    output logic                            mem2reg_o,
    output logic        [Func3BusWidth-1:0] func3_o,

    // Branch
    output logic                   is_branch_o,
    output logic                   branch_taken_o,
    output logic [RegBusWidth-1:0] branch_target_addr_o,
    output logic [RegBusWidth-1:0] link_addr_o,

    // Stall
    output logic stallreq,
    output logic flush_o
);

  logic inst_valid;
  logic branch_taken;
  logic load_use_for_rs1, load_use_for_rs2;

  logic [RegBusWidth-1:0] pc_next;
  logic [            6:0] opcode;
  logic [            6:0] func7;
  logic signed [RegBusWidth-1:0] rs1_data_sign, rs2_data_sign;
  logic load_inst_in_ex, load_inst_in_mem;

  assign pc_next = pc_i + 4;
  assign opcode = inst_i[`OPCODE];
  assign func3_o = inst_i[`FUNC3];
  assign func7 = inst_i[`FUNC7];
  assign rs1_data_sign = $signed(rs1_data_o);
  assign rs2_data_sign = $signed(rs2_data_o);
  assign stallreq = load_use_for_rs1 | load_use_for_rs2;
  assign load_inst_in_ex = (ex_memrd_i == True) ? True : False;
  assign load_inst_in_mem = (mem_memrd_i == True) ? True : False;

  always_comb begin
    aluop_o              = ALUOP_ADD;
    alusrc1_o            = SRC1_FROM_REG;
    alusrc2_o            = SRC2_FROM_REG;
    rd_o                 = ZERO_REG;
    wreg_o               = WriteDisable;
    inst_valid           = InstInvalid;
    rs1_read_o           = ReadDisable;
    rs2_read_o           = ReadDisable;
    rs1_addr_o           = ZERO_REG;
    rs2_addr_o           = ZERO_REG;
    imm_o                = ZeroWord;
    memrd_o              = ReadDisable;
    memwr_o              = WriteDisable;
    mem2reg_o            = NotMem2Reg;
    link_addr_o          = ZeroWord;
    branch_target_addr_o = ZeroWord;
    branch_taken         = BranchNotTaken;
    is_branch_o          = False;
    branch_taken_o       = BranchNotTaken;
    flush_o              = False;
    case (opcode)
      OP_AUIPC: begin
        rd_o       = REG_CONVERT(inst_i[`RD]);
        alusrc1_o  = SRC1_FROM_PC;
        alusrc2_o  = SRC2_FROM_IMM;
        wreg_o     = WriteEnable;
        inst_valid = InstValid;
        imm_o      = {inst_i[31:12], 12'b0};
      end
      OP_LUI: begin
        rd_o       = REG_CONVERT(inst_i[`RD]);
        wreg_o     = WriteEnable;
        alusrc1_o  = SRC1_FROM_REG;
        alusrc2_o  = SRC2_FROM_IMM;
        inst_valid = InstValid;
        imm_o      = {inst_i[31:12], 12'b0};
      end
      OP_JAL: begin
        aluop_o = ALUOP_LINK;
        rd_o = REG_CONVERT(inst_i[`RD]);
        wreg_o = WriteEnable;
        inst_valid = InstValid;
        imm_o = $signed({inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21],
                         1'b0});
        link_addr_o = pc_next;
        branch_target_addr_o = pc_i + imm_o;
        is_branch_o = True;
        branch_taken_o = BranchTaken;
        // next_inst_in_delayslot_o = InDelaySlot;
      end
      OP_JALR: begin
        aluop_o              = ALUOP_LINK;
        rd_o                 = REG_CONVERT(inst_i[`RD]);
        wreg_o               = WriteEnable;
        inst_valid           = InstValid;
        rs1_read_o           = ReadEnable;
        rs1_addr_o           = REG_CONVERT(inst_i[`RS1]);
        imm_o                = $signed({inst_i[31:20]});
        link_addr_o          = pc_next;
        is_branch_o          = True;
        branch_target_addr_o = rs1_data_o + imm_o;
        branch_taken_o       = BranchTaken;
        // next_inst_in_delayslot_o = InDelaySlot;
      end
      OP_BRANCH: begin
        inst_valid = InstValid;
        rs1_read_o = ReadEnable;
        rs2_read_o = ReadEnable;
        rs1_addr_o = REG_CONVERT(inst_i[`RS1]);
        rs2_addr_o = REG_CONVERT(inst_i[`RS2]);
        imm_o =
            $signed({inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0});
        is_branch_o = True;
        case (func3_o)
          OP_BEQ: begin
            if (rs1_data_o == rs2_data_o) branch_taken = BranchTaken;
          end
          OP_BNE: begin
            if (rs1_data_o != rs2_data_o) branch_taken = BranchTaken;
          end
          OP_BLT: begin
            if (rs1_data_sign < rs2_data_sign) branch_taken = BranchTaken;
          end
          OP_BGE: begin
            if (rs1_data_sign >= rs2_data_sign) branch_taken = BranchTaken;
          end
          OP_BLTU: begin
            if (rs1_data_o < rs2_data_o) branch_taken = BranchTaken;
          end
          OP_BGEU: begin
            if (rs1_data_o >= rs2_data_o) branch_taken = BranchTaken;
          end
          default: branch_taken = BranchNotTaken;
        endcase

        branch_target_addr_o = pc_i + imm_o;
        if (branch_taken == BranchTaken) begin
          branch_taken_o = BranchTaken;
          // next_inst_in_delayslot_o = InDelaySlot;
        end
      end
      OP_LOAD: begin
        rd_o       = REG_CONVERT(inst_i[`RD]);  // rd
        alusrc1_o  = SRC1_FROM_REG;
        alusrc2_o  = SRC2_FROM_IMM;
        wreg_o     = WriteEnable;
        inst_valid = InstValid;
        rs1_read_o = ReadEnable;
        rs1_addr_o = REG_CONVERT(inst_i[`RS1]);  // rs
        imm_o      = $signed({inst_i[31:20]});
        memrd_o    = ReadEnable;
        mem2reg_o  = Mem2Reg;
      end
      OP_STORE: begin
        inst_valid = InstValid;
        alusrc1_o  = SRC1_FROM_REG;
        alusrc2_o  = SRC2_FROM_IMM;
        rs1_read_o = ReadEnable;
        rs2_read_o = ReadEnable;
        rs1_addr_o = REG_CONVERT(inst_i[`RS1]);
        rs2_addr_o = REG_CONVERT(inst_i[`RS2]);
        imm_o      = $signed({inst_i[31:25], inst_i[11:7]});
        memwr_o    = WriteEnable;
      end
      OP_ARITHI: begin
        case (func3_o)
          OP_ADD:  aluop_o = ALUOP_ADD;
          OP_SLL:  aluop_o = ALUOP_SLL;
          OP_SLT:  aluop_o = ALUOP_SLT;
          OP_SLTU: aluop_o = ALUOP_SLTU;
          OP_XOR:  aluop_o = ALUOP_XOR;
          OP_SR:   aluop_o = (inst_i[30]) ? ALUOP_SRA : ALUOP_SRL;
          OP_OR:   aluop_o = ALUOP_OR;
          OP_AND:  aluop_o = ALUOP_AND;
        endcase
        rd_o       = REG_CONVERT(inst_i[`RD]);
        alusrc1_o  = SRC1_FROM_REG;
        alusrc2_o  = SRC2_FROM_IMM;
        wreg_o     = WriteEnable;
        inst_valid = InstValid;
        rs1_read_o = ReadEnable;
        rs1_addr_o = REG_CONVERT(inst_i[`RS1]);
        imm_o      = $signed({inst_i[31:20]});
      end
      OP_ARITHR: begin
        if (func7[0] == 1'b1) begin  // Multiply instruction
`ifdef MulEnable
          case (func3_o)
            OP_MUL:    aluop_o = ALUOP_MUL;
            OP_MULH:   aluop_o = ALUOP_MULH;
            OP_MULHSU: aluop_o = ALUOP_MULSU;
            OP_MULHU:  aluop_o = ALUOP_MULHU;
          endcase
`endif
        end else begin  // Other instruction
          case (func3_o)
            OP_ADD:  aluop_o = (inst_i[30]) ? ALUOP_SUB : ALUOP_ADD;
            OP_SLL:  aluop_o = ALUOP_SLL;
            OP_SLT:  aluop_o = ALUOP_SLT;
            OP_SLTU: aluop_o = ALUOP_SLTU;
            OP_XOR:  aluop_o = ALUOP_XOR;
            OP_SR:   aluop_o = (inst_i[30]) ? ALUOP_SRA : ALUOP_SRL;
            OP_OR:   aluop_o = ALUOP_OR;
            OP_AND:  aluop_o = ALUOP_AND;
          endcase
        end
        rd_o       = REG_CONVERT(inst_i[`RD]);
        wreg_o     = WriteEnable;
        inst_valid = InstValid;
        rs1_read_o = ReadEnable;
        rs2_read_o = ReadEnable;
        rs1_addr_o = REG_CONVERT(inst_i[`RS1]);
        rs2_addr_o = REG_CONVERT(inst_i[`RS2]);
      end
      OP_FENCE: begin
        inst_valid = InstValid;
      end
      OP_SYSTEM: begin
        inst_valid = InstValid;
      end

      default: ;
    endcase  //case opcode
  end  //always

  // load_use_for_rs1
  always_comb begin
    if ((rs1_read_o == ReadEnable) && (ex_wreg_i == WriteEnable) && 
        (ex_rd_i == rs1_addr_o) && (load_inst_in_ex == True)) begin
      load_use_for_rs1 = True;
    end else if ((rs1_read_o == ReadEnable) && (mem_wreg_i == WriteEnable) &&
                 (mem_rd_i == rs1_addr_o) && (load_inst_in_mem == True)) begin
      load_use_for_rs1 = True;
    end else begin
      load_use_for_rs1 = False;
    end
  end

  // load_use_for_rs2
  always_comb begin
    if((rs2_read_o == ReadEnable) && (ex_wreg_i == WriteEnable) && 
       (ex_rd_i == rs2_addr_o) && (load_inst_in_ex == True)) begin
      load_use_for_rs2 = True;
    end else if ((rs2_read_o == ReadEnable) && (mem_wreg_i == WriteEnable) && 
                 (mem_rd_i == rs2_addr_o) && (load_inst_in_mem == True)) begin
      load_use_for_rs2 = True;
    end else begin
      load_use_for_rs2 = False;
    end
  end

  // rs1_data_o
  always_comb begin
    if ((rs1_read_o == ReadEnable) && (ex_wreg_i == WriteEnable) && 
        (ex_rd_i != {RegNumLog2{1'b0}}) && (ex_rd_i == rs1_addr_o)) begin
      rs1_data_o = ex_wreg_data_i;
    end else if ((rs1_read_o == ReadEnable) && (mem_wreg_i == WriteEnable) &&
                 (mem_rd_i != {RegNumLog2{1'b0}}) && (mem_rd_i == rs1_addr_o)) begin
      rs1_data_o = mem_wreg_data_i;
    end else if (rs1_read_o == ReadEnable) begin
      rs1_data_o = rs1_data_i;
    end else begin
      rs1_data_o = ZeroWord;
    end
  end

  // rs2_data_o
  always_comb begin
    if ((rs2_read_o == ReadEnable) && (ex_wreg_i == WriteEnable) &&
                 (ex_rd_i != {RegNumLog2{1'b0}}) && (ex_rd_i == rs2_addr_o)) begin
      rs2_data_o = ex_wreg_data_i;
    end else if ((rs2_read_o == ReadEnable) && (mem_wreg_i == WriteEnable) && 
                 (mem_rd_i != {RegNumLog2{1'b0}}) && (mem_rd_i == rs2_addr_o)) begin
      rs2_data_o = mem_wreg_data_i;
    end else if (rs2_read_o == ReadEnable) begin
      rs2_data_o = rs2_data_i;
    end else begin
      rs2_data_o = ZeroWord;
    end
  end

endmodule
