module ex
  import cpu_pkg::*;
(
    input logic      [RegBusWidth-1:0] pc_i,
    input aluop_t                      aluop_i,
    input alu_src1_t                   alusrc1_i,
    input alu_src2_t                   alusrc2_i,
    input logic      [RegBusWidth-1:0] rs1_i,
    input logic      [RegBusWidth-1:0] rs2_i,
    input logic      [RegBusWidth-1:0] imm_i,
    input logic      [RegBusWidth-1:0] csr_rdata_i,
    input logic      [RegBusWidth-1:0] link_addr_i,

    output logic        [RegBusWidth-1:0] wdata_o,
    output logic signed [RegBusWidth-1:0] wreg_data_o,
    output logic                          stallreq
);

  logic [RegBusWidth-1:0] alu_in1, alu_in2;
  logic [RegBusWidth-1:0] alu_in1_mult, alu_in2_mult;
  logic [MulBusWidth-1:0] hilo_temp, mulres;

`ifdef MulEnable
  assign alu_in1_mult = ( (aluop_i == ALUOP_MUL || aluop_i == ALUOP_MULH) && (rs1_i[31] == 1'b1) ) ? 
                          (~rs1_i + 1'b1) : rs1_i;
  assign alu_in2_mult = ( (aluop_i== ALUOP_MUL || aluop_i== ALUOP_MULH) && (rs2_i[31] == 1'b1) ) ? 
                          (~rs2_i + 1'b1) : rs2_i;
  assign hilo_temp = alu_in1_mult * alu_in2_mult;

  always_comb begin
    if (aluop_i == ALUOP_MUL || aluop_i == ALUOP_MULH) begin
      mulres = (rs1_i[31] ^ rs2_i[31]) ? (~hilo_temp + 1'b1) : hilo_temp;
    end else begin
      mulres = hilo_temp;
    end
  end
`else
  assign mulres = {MulBusWidth{1'b0}};
`endif

  // alu_in1
  always_comb begin
    unique case (1'b1)
      alusrc1_i[SRC1_FROM_REG_BIT]: alu_in1 = rs1_i;
      alusrc1_i[SRC1_FROM_PC_BIT]:  alu_in1 = pc_i;
      alusrc1_i[SRC1_FROM_CSR_BIT]: alu_in1 = csr_rdata_i;
    endcase
  end

  // alu_in2
  always_comb begin
    unique case (1'b1)
      alusrc2_i[SRC2_FROM_REG_BIT]: alu_in2 = rs2_i;
      alusrc2_i[SRC2_FROM_IMM_BIT]: alu_in2 = imm_i;
    endcase
  end

  // wreg_data_o
  always_comb begin
    stallreq = NoStop;
    wreg_data_o = ZeroWord;

    unique case (1'b1)
      aluop_i[ALUOP_ADD_BIT]: begin
        wreg_data_o = $signed(alu_in1) + $signed(alu_in2);
      end
      aluop_i[ALUOP_SUB_BIT]: begin
        wreg_data_o = $signed(alu_in1) - $signed(alu_in2);
      end
      aluop_i[ALUOP_SLL_BIT]: begin
        wreg_data_o = alu_in1 << alu_in2[4:0];
      end
      aluop_i[ALUOP_SRL_BIT]: begin
        wreg_data_o = alu_in1 >> alu_in2[4:0];
      end
      aluop_i[ALUOP_SRA_BIT]: begin
        wreg_data_o = $signed(alu_in1) >>> alu_in2[4:0];
      end
      aluop_i[ALUOP_SLT_BIT]: begin
        wreg_data_o = ($signed(alu_in1) < $signed(alu_in2)) ? 32'b1 : 32'b0;
      end
      aluop_i[ALUOP_SLTU_BIT]: begin
        wreg_data_o = (alu_in1 < alu_in2) ? 32'b1 : 32'b0;
      end
      aluop_i[ALUOP_OR_BIT]: begin
        wreg_data_o = alu_in1 | alu_in2;
      end
      aluop_i[ALUOP_XOR_BIT]: begin
        wreg_data_o = alu_in1 ^ alu_in2;
      end
      aluop_i[ALUOP_AND_BIT]: begin
        wreg_data_o = alu_in1 & alu_in2;
      end
      aluop_i[ALUOP_MUL_BIT]: begin
        wreg_data_o = mulres[31:0];
      end
      aluop_i[ALUOP_MULH_BIT]: begin
        wreg_data_o = mulres[63:32];
      end
      aluop_i[ALUOP_MULHU_BIT]: begin
        wreg_data_o = mulres[63:32];
      end
      aluop_i[ALUOP_MULSU_BIT]: begin
        wreg_data_o = mulres[63:32];
      end
      aluop_i[ALUOP_LINK_BIT]: begin
        wreg_data_o = link_addr_i;
      end
    endcase
  end

  assign wdata_o = rs2_i;

endmodule
