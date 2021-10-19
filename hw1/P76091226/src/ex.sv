`include "def.v"
module ex(
  input logic                 [`RegBus] pc_i,
  input logic               [`AluOpBus] aluop_i,
  input logic                           alusrc1_i,
  input logic                           alusrc2_i,
  input logic                 [`RegBus] rs1_i,
  input logic                 [`RegBus] rs2_i,
  input logic                 [`RegBus] imm_i,
  input logic                           is_in_delayslot_i,
  input logic                 [`RegBus] link_addr_i,

  output logic                [`RegBus] wdata_o,
  output logic signed         [`RegBus] wreg_data_o,
  output logic                          stallreq
);

  logic                       [`RegBus] alu_in1, alu_in2;
  logic signed                [`MulBus] result_mul;
  logic                       [`MulBus] result_mulu;
  logic signed                [`MulBus] result_mulsu;

  /* MUL-related */
  assign result_mul[`MulBus]   = $signed  ({{ 32{alu_in1[31]} }, alu_in1[`RegBus]}) *
                                 $signed  ({{ 32{alu_in2[31]} }, alu_in2[`RegBus]});
  assign result_mulu[`MulBus]  = $unsigned({{ 32{1'b0} },         alu_in1[`RegBus]}) *
                                 $unsigned({{ 32{1'b0} },         alu_in2[`RegBus]});
  assign result_mulsu[`MulBus] = $signed  ({{ 32{alu_in1[31]} }, alu_in1[`RegBus]}) *
                                 $unsigned({{ 32{1'b0} },         alu_in2[`RegBus]});

  always_comb begin
    // stallreq = 1'b0;
    wdata_o  = rs2_i;
  end

  // alu_in1
  always_comb begin
    if(alusrc1_i == `SRC1_FROM_REG)
      alu_in1 = rs1_i;
    else // `SRC1_FROM_PC
      alu_in1 = pc_i;
  end

  // alu_in2
  always_comb begin
    if(alusrc2_i == `SRC2_FROM_REG)
      alu_in2 = rs2_i;
    else // `SRC2_FROM_IMM
      alu_in2 = imm_i;
  end

  // wreg_data_o
  always_comb begin
    stallreq = 1'b0;
    case (1'b1)
      aluop_i[`ALUOP_ADD]: begin
        wreg_data_o = $signed(alu_in1) + $signed(alu_in2);
      end
      aluop_i[`ALUOP_SUB]: begin
        wreg_data_o = $signed(alu_in1) - $signed(alu_in2);
      end
      aluop_i[`ALUOP_SLL]: begin
        wreg_data_o = alu_in1 << alu_in2[4:0];
      end
      aluop_i[`ALUOP_SRL]: begin
        wreg_data_o = alu_in1 >> alu_in2[4:0];
      end
      aluop_i[`ALUOP_SRA]: begin
        wreg_data_o = $signed(alu_in1) >>> alu_in2[4:0];
      end
      aluop_i[`ALUOP_SLT]: begin
        wreg_data_o = ($signed(alu_in1) < $signed(alu_in2)) ? 32'b1 : 32'b0;
      end
      aluop_i[`ALUOP_SLTU]: begin
        wreg_data_o = (alu_in1 < alu_in2) ? 32'b1 : 32'b0;
      end
      aluop_i[`ALUOP_OR]: begin
        wreg_data_o = alu_in1 | alu_in2;
      end
      aluop_i[`ALUOP_XOR]: begin
        wreg_data_o = alu_in1 ^ alu_in2;
      end
      aluop_i[`ALUOP_AND]: begin
        wreg_data_o = alu_in1 & alu_in2;
      end
      aluop_i[`ALUOP_MUL]: begin
        stallreq = 1'b1;
        wreg_data_o = result_mul[31:0];
      end
      aluop_i[`ALUOP_MULH]: begin
        stallreq = 1'b1;
        wreg_data_o = result_mul[63:32];
      end
      aluop_i[`ALUOP_MULU]: begin
        stallreq = 1'b1;
        wreg_data_o = result_mulu[63:32];
      end
      aluop_i[`ALUOP_MULSU]: begin
        stallreq = 1'b1;
        wreg_data_o = result_mulsu[63:32];
      end
      aluop_i[`ALUOP_LINK]: begin
        wreg_data_o = link_addr_i;
      end
      default: wreg_data_o = `ZeroWord;
    endcase
  end

endmodule
