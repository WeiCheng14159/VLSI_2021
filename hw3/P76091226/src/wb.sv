`include "def.v"
module wb(
  input logic                           mem2reg_i,
  input logic                 [`RegBus] from_reg_i,
  input logic                [`DataBus] from_mem_i,
  input logic               [`Func3Bus] func3_i,

  output logic                [`RegBus] wdata_o
);
  logic                 [`RegBus] load_addr_i;
  assign load_addr_i = from_reg_i;

  // wdata_o
  always_comb begin
    if (mem2reg_i == `Mem2Reg) begin
      case(func3_i) // LW, LH, LB, LBU, LHU
        `OP_LB:  wdata_o = $signed(from_mem_i[7:0]);
        `OP_LH:  begin
          case(load_addr_i[1])
            1'b1: wdata_o = $signed(from_mem_i[31:16]);
            1'b0: wdata_o = $signed(from_mem_i[15:0]);
          endcase
        end
        `OP_LW:  wdata_o = from_mem_i;
        `OP_LBU: wdata_o = {24'h0, from_mem_i[7:0]};
        `OP_LHU: begin  
          case(load_addr_i[1])
            1'b1: wdata_o = {16'h0, from_mem_i[31:16]};
            1'b0: wdata_o = {16'h0, from_mem_i[15:0]};
          endcase
        end
        default: wdata_o = from_mem_i;
      endcase
    end else begin
      wdata_o = from_reg_i;
    end
  end

endmodule
