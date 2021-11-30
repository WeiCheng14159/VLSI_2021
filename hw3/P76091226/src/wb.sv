module wb
  import cpu_pkg::*;
(
    input logic                     mem2reg_i,
    input logic [  RegBusWidth-1:0] from_reg_i,
    input logic [    DataWidth-1:0] from_mem_i,
    input logic [Func3BusWidth-1:0] func3_i,

    output logic [RegBusWidth-1:0] wdata_o
);
  logic [RegBusWidth-1:0] load_addr_i;
  assign load_addr_i = from_reg_i;

  // wdata_o
  always_comb begin
    if (mem2reg_i == Mem2Reg) begin
      case (func3_i)  // LW, LH, LB, LBU, LHU
        OP_LB: begin
          case (load_addr_i[1:0])
            2'b00: wdata_o = $signed(from_mem_i[7:0]);
            2'b01: wdata_o = $signed(from_mem_i[15:8]);
            2'b10: wdata_o = $signed(from_mem_i[23:16]);
            2'b11: wdata_o = $signed(from_mem_i[31:24]);
          endcase
        end
        OP_LH: begin
          case (load_addr_i[1])
            1'b1: wdata_o = $signed(from_mem_i[31:16]);
            1'b0: wdata_o = $signed(from_mem_i[15:0]);
          endcase
        end
        OP_LW:   wdata_o = from_mem_i;
        OP_LBU: begin
          case (load_addr_i[1:0])
            2'b00: wdata_o = {24'b0, from_mem_i[7:0]};
            2'b01: wdata_o = {24'b0, from_mem_i[15:8]};
            2'b10: wdata_o = {24'b0, from_mem_i[23:16]};
            2'b11: wdata_o = {24'b0, from_mem_i[31:24]};
          endcase
        end
        OP_LHU: begin
          case (load_addr_i[1])
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
