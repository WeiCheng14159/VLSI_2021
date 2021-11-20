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
  logic                       [`RegBus] alu_in1_mult, alu_in2_mult;
  logic                       [`MulBus] hilo_temp;
  logic                       [`MulBus] mulres;

  `ifdef MulEnable
  assign alu_in1_mult = ( (aluop_i[`ALUOP_MUL] || aluop_i[`ALUOP_MULH]) && (rs1_i[31] == 1'b1) ) ? 
                          (~rs1_i + 1'b1) : rs1_i;
  assign alu_in2_mult = ( (aluop_i[`ALUOP_MUL] || aluop_i[`ALUOP_MULH]) && (rs2_i[31] == 1'b1) ) ? 
                          (~rs2_i + 1'b1) : rs2_i;
  assign hilo_temp = alu_in1_mult * alu_in2_mult;

  always_comb begin
    if(aluop_i[`ALUOP_MUL] || aluop_i[`ALUOP_MULH]) begin
      mulres = (rs1_i[31] ^ rs2_i[31]) ? (~hilo_temp + 1'b1) : hilo_temp;
    end else begin
      mulres = hilo_temp;
    end
  end
  `endif

  // alu_in1
  assign alu_in1 = (alusrc1_i == `SRC1_FROM_REG) ? rs1_i : pc_i;

  // alu_in2
  assign alu_in2 = (alusrc2_i == `SRC2_FROM_REG) ? rs2_i : imm_i;

  // wreg_data_o
  always_comb begin
    stallreq = 1'b0;
    wreg_data_o = `ZeroWord;

    unique case (1'b1)
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
      `ifdef MulEnable
      aluop_i[`ALUOP_MUL]: begin
        wreg_data_o = mulres[31:0];
      end
      aluop_i[`ALUOP_MULH]: begin
        wreg_data_o = mulres[63:32];
      end
      aluop_i[`ALUOP_MULU]: begin
        wreg_data_o = mulres[63:32];
      end
      aluop_i[`ALUOP_MULSU]: begin
        wreg_data_o = mulres[63:32];
      end
      `endif
      aluop_i[`ALUOP_LINK]: begin
        wreg_data_o = link_addr_i;
      end
    endcase
  end

  assign wdata_o  = rs2_i;

endmodule
