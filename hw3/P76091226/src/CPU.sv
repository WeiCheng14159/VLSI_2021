`include "pkg_include.sv"
`include "ex_mem.sv"
`include "id_ex.sv"
`include "if_id.sv"
`include "mem_wb.sv"
`include "regfile.sv"
`include "ctrl.sv"
`include "ex.sv"
`include "id.sv"
`include "mem.sv"
`include "ifetch.sv"
`include "wb.sv"

module CPU
  import cpu_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    // Instruction access
    input  logic [    InstrWidth-1:0] inst_in_i,
    output logic                      inst_read_o,
    output logic [InstrAddrWidth-1:0] inst_addr_o,
    // Data access
    input  logic [     DataWidth-1:0] data_in_i,
    output logic                      data_read_o,
    output logic [ Func3BusWidth-1:0] data_read_type_o,
    output logic                      data_write_o,
    output logic [ Func3BusWidth-1:0] data_write_type_o,
    output logic [ DataAddrWidth-1:0] data_write_addr_o,
    output logic [     DataWidth-1:0] data_out_o,
    // Stall request from cache
    input  logic                      stallreq_from_imem,
    input  logic                      stallreq_from_dmem
);

  /* Instruction Fetch (IF) */
  logic      [  RegBusWidth-1:0] if_pc;
  logic      [   InstrWidth-1:0] if_inst;
  logic                          if_is_in_delay_slot;

  /* Instruction Decode (ID) */
  logic      [  RegBusWidth-1:0] id_pc;
  logic      [   InstrWidth-1:0] id_inst;
  aluop_t                        id_aluop;
  logic                          id_alusrc1;
  logic                          id_alusrc2;
  logic      [  RegBusWidth-1:0] id_imm;
  logic      [  RegBusWidth-1:0] id_rs1;
  logic      [  RegBusWidth-1:0] id_rs2;
  logic                          id_wreg;
  reg_addr_t                     id_rd;
  logic                          id_memrd;
  logic                          id_memwr;
  logic                          id_mem2reg;
  logic                          id_is_branch;
  logic                          id_branch_taken;
  logic      [  RegBusWidth-1:0] id_branch_target_addr;
  logic      [  RegBusWidth-1:0] id_link_addr;
  logic      [Func3BusWidth-1:0] id_func3;

  /* Execution (EX) */
  logic      [  RegBusWidth-1:0] ex_pc;
  aluop_t                        ex_aluop;
  logic                          ex_alusrc1;
  logic                          ex_alusrc2;
  logic      [  RegBusWidth-1:0] ex_imm;
  logic      [  RegBusWidth-1:0] ex_rs1;
  logic      [  RegBusWidth-1:0] ex_rs2;
  logic                          ex_wreg;
  reg_addr_t                     ex_rd;
  logic      [  RegBusWidth-1:0] ex_wdata;
  logic      [  RegBusWidth-1:0] ex_wreg_data;
  logic                          ex_memrd;
  logic                          ex_memwr;
  logic                          ex_mem2reg;
  logic      [  RegBusWidth-1:0] ex_link_addr;
  logic      [Func3BusWidth-1:0] ex_func3;

  /* Memory Read Write (MEM) */
  logic      [  RegBusWidth-1:0] mem_pc;
  logic                          mem_wreg;
  reg_addr_t                     mem_rd;
  logic      [  RegBusWidth-1:0] mem_wdata;
  logic      [  RegBusWidth-1:0] mem_wreg_data;
  logic                          mem_memrd;
  logic                          mem_memwr;
  logic                          mem_mem2reg;
  logic      [Func3BusWidth-1:0] mem_func3;

  /* Write Back (WB) */
  logic      [  RegBusWidth-1:0] wb_pc;
  logic                          wb_wreg;
  reg_addr_t                     wb_rd;
  logic      [  RegBusWidth-1:0] wb_wdata;
  logic                          wb_mem2reg;
  logic      [  RegBusWidth-1:0] wb_from_alu;
  logic      [Func3BusWidth-1:0] wb_func3;

  /* Register file */
  logic                          rs1_read;
  logic                          rs2_read;
  logic      [  RegBusWidth-1:0] rs1_data;
  logic      [  RegBusWidth-1:0] rs2_data;
  reg_addr_t                     rs1_addr;
  reg_addr_t                     rs2_addr;

  /* Stall signal */
  logic                          stallreq_from_id;
  logic                          stallreq_from_ex;
  logic      [    STAGE_NUM-1:0] stallreq;

  /* Flush */
  logic                          flush;
  logic      [  RegBusWidth-1:0] new_pc;

  logic                          booting;
  assign booting = (inst_addr_o >= 32'h128 && inst_addr_o <= 32'h27c);

  /* Register file */
  regfile regfile0 (
      .clk (clk),
      .rstn(rstn),

      .we_i(wb_wreg),
      .waddr_i(wb_rd),
      .wdata_i(wb_wdata),
      .re1_i(rs1_read),
      .raddr1_i(rs1_addr),
      .re2_i(rs2_read),
      .raddr2_i(rs2_addr),

      .rdata1_o(rs1_data),
      .rdata2_o(rs2_data)
  );

  /* Contrller */
  ctrl ctrl0 (
      .stallreq_from_imem(stallreq_from_imem),
      .stallreq_from_id  (stallreq_from_id),
      .stallreq_from_ex  (stallreq_from_ex),
      .stallreq_from_dmem(stallreq_from_dmem),
      .is_id_branch_inst (id_is_branch),

      .stall(stallreq),
      .new_pc_o(new_pc)
  );

  // IF
  ifetch ifetch0 (
      .clk (clk),
      .rstn(rstn),

      .stall(stallreq),
      .flush(flush),
      .branch_target_addr_i(id_branch_target_addr),
      .branch_taken_i(id_branch_taken),
      .is_id_branch_inst(id_is_branch),
      .new_pc_i(new_pc),

      .if_pc_o(if_pc),
      .inst_read_o(inst_read_o),
      .inst_addr_o(inst_addr_o),
      .if_is_in_delay_slot_o(if_is_in_delay_slot)
  );

  // IF-ID
  if_id if_id0 (
      .clk (clk),
      .rstn(rstn),

      .if_pc(if_pc),
      .if_inst(inst_in_i),
      .stall(stallreq),
      .flush(flush),
      .if_is_in_delay_slot(if_is_in_delay_slot),

      .id_pc  (id_pc),
      .id_inst(id_inst)
  );

  // ID
  id id0 (
      .pc_i(id_pc),
      .inst_i(id_inst),
      .rs1_data_i(rs1_data),
      .rs2_data_i(rs2_data),
      .ex_wreg_i(ex_wreg),
      .ex_wreg_data_i(ex_wreg_data),
      .ex_rd_i(ex_rd),
      .ex_memrd_i(ex_memrd),
      .mem_wreg_i(mem_wreg),
      .mem_wreg_data_i(mem_wreg_data),
      .mem_rd_i(mem_rd),
      .mem_memrd_i(mem_memrd),
      .func3_o(id_func3),
      .rs1_read_o(rs1_read),
      .rs2_read_o(rs2_read),
      .rs1_addr_o(rs1_addr),
      .rs2_addr_o(rs2_addr),
      .aluop_o(id_aluop),
      .alusrc1_o(id_alusrc1),
      .alusrc2_o(id_alusrc2),
      .imm_o(id_imm),
      .rs1_data_o(id_rs1),
      .rs2_data_o(id_rs2),
      .rd_o(id_rd),
      .wreg_o(id_wreg),
      .memrd_o(id_memrd),
      .memwr_o(id_memwr),
      .mem2reg_o(id_mem2reg),
      .is_branch_o(id_is_branch),
      .branch_taken_o(id_branch_taken),
      .branch_target_addr_o(id_branch_target_addr),
      .link_addr_o(id_link_addr),
      .stallreq(stallreq_from_id),
      .flush_o(flush)
  );

  // ID-EX
  id_ex id_ex0 (
      .clk (clk),
      .rstn(rstn),

      .id_pc(id_pc),
      .id_func3(id_func3),
      .id_aluop(id_aluop),
      .id_alusrc1(id_alusrc1),
      .id_alusrc2(id_alusrc2),
      .id_imm(id_imm),
      .id_rs1(id_rs1),
      .id_rs2(id_rs2),
      .id_rd(id_rd),
      .id_wreg(id_wreg),
      .id_memrd(id_memrd),
      .id_memwr(id_memwr),
      .id_mem2reg(id_mem2reg),
      .id_link_addr(id_link_addr),
      .stall(stallreq),
      .flush(flush),

      .ex_pc(ex_pc),
      .ex_func3(ex_func3),
      .ex_aluop(ex_aluop),
      .ex_alusrc1(ex_alusrc1),
      .ex_alusrc2(ex_alusrc2),
      .ex_imm(ex_imm),
      .ex_rs1(ex_rs1),
      .ex_rs2(ex_rs2),
      .ex_rd(ex_rd),
      .ex_wreg(ex_wreg),
      .ex_memrd(ex_memrd),
      .ex_memwr(ex_memwr),
      .ex_mem2reg(ex_mem2reg),
      .ex_link_addr(ex_link_addr)
  );

  // EX
  ex ex0 (
      .pc_i(ex_pc),
      .aluop_i(ex_aluop),
      .alusrc1_i(ex_alusrc1),
      .alusrc2_i(ex_alusrc2),
      .rs1_i(ex_rs1),
      .rs2_i(ex_rs2),
      .imm_i(ex_imm),

      .link_addr_i(ex_link_addr),
      .wdata_o(ex_wdata),
      .wreg_data_o(ex_wreg_data),
      .stallreq(stallreq_from_ex)
  );

  // EX-MEM
  ex_mem ex_mem0 (
      .clk (clk),
      .rstn(rstn),

      .ex_pc(ex_pc),
      .ex_func3(ex_func3),
      .ex_rd(ex_rd),
      .ex_wreg(ex_wreg),
      .ex_wdata(ex_wdata),
      .ex_wreg_data(ex_wreg_data),
      .ex_memrd(ex_memrd),
      .ex_memwr(ex_memwr),
      .ex_mem2reg(ex_mem2reg),
      .stall(stallreq),
      .flush(flush),

      .mem_pc(mem_pc),
      .mem_func3(mem_func3),
      .mem_rd(mem_rd),
      .mem_wreg(mem_wreg),
      .mem_wdata(mem_wdata),
      .mem_wreg_data(mem_wreg_data),
      .mem_memrd(mem_memrd),
      .mem_memwr(mem_memwr),
      .mem_mem2reg(mem_mem2reg)
  );

  // MEM
  mem mem0 (
      .memrd_i(mem_memrd),
      .memwr_i(mem_memwr),
      .wreg_data_i(mem_wreg_data),
      .wdata_i(mem_wdata),
      .wb_mem2reg_i(wb_mem2reg),
      .func3_i(mem_func3),

      .data_read_o(data_read_o),
      .data_write_o(data_write_o),
      .data_write_type_o(data_write_type_o),
      .data_write_addr_o(data_write_addr_o),
      .data_out_o(data_out_o)
  );

  // MEM-WB
  mem_wb mem_wb0 (
      .clk (clk),
      .rstn(rstn),

      .mem_rd(mem_rd),
      .mem_wreg(mem_wreg),
      .mem_mem2reg(mem_mem2reg),
      .mem_wreg_data(mem_wreg_data),
      .mem_func3(mem_func3),
      .mem_pc(mem_pc),
      .stall(stallreq),
      .flush(flush),

      .wb_rd(wb_rd),
      .wb_wreg(wb_wreg),
      .wb_mem2reg(wb_mem2reg),
      .wb_from_alu(wb_from_alu),
      .wb_func3(wb_func3),
      .wb_pc(wb_pc)
  );

  // WB
  wb wb0 (
      .mem2reg_i(wb_mem2reg),
      .from_reg_i(wb_from_alu),
      .from_mem_i(data_in_i),
      .func3_i(wb_func3),

      .wdata_o(wb_wdata)
  );

endmodule
