module mem
  import cpu_pkg::*;
(
    input logic                     memrd_i,
    input logic                     memwr_i,
    input logic [  RegBusWidth-1:0] wreg_data_i,
    input logic [  RegBusWidth-1:0] wdata_i,
    input logic                     wb_mem2reg_i,
    input logic [Func3BusWidth-1:0] func3_i,

    output logic                     data_read_o,
    output logic                     data_write_o,
    output logic [Func3BusWidth-1:0] data_write_type_o,
    output logic [  RegBusWidth-1:0] data_write_addr_o,
    output logic [    DataWidth-1:0] data_out_o
);

  logic [RegBusWidth-1:0] memaddr_i;

  assign memaddr_i = wreg_data_i;

  always_comb begin
    data_read_o = ReadDisable;
    data_write_o = WriteDisable;
    data_write_addr_o = ZeroWord;
    data_out_o = ZeroWord;

    if (memrd_i == ReadEnable && memwr_i == WriteDisable) begin  // Load
      data_read_o = ReadEnable;
      data_write_addr_o = memaddr_i;
    end else if(memrd_i == ReadDisable && memwr_i == WriteEnable) begin // Store
      data_write_o = WriteEnable;
      data_write_addr_o = memaddr_i;
      case (func3_i)
        OP_SW:   data_out_o = wdata_i;
        OP_SH: begin
          case (memaddr_i[1])
            1'b1: data_out_o = {wdata_i[15:0], 16'b0};
            1'b0: data_out_o = {16'b0, wdata_i[15:0]};
          endcase
        end
        OP_SB: begin
          case (memaddr_i[1:0])
            2'b00: data_out_o = {24'b0, wdata_i[7:0]};
            2'b01: data_out_o = {16'b0, wdata_i[7:0], 8'b0};
            2'b10: data_out_o = {8'b0, wdata_i[7:0], 16'b0};
            2'b11: data_out_o = {wdata_i[7:0], 24'b0};
          endcase
        end
        default: data_out_o = wdata_i;
      endcase
    end
  end

  always_comb begin
    if (memrd_i == ReadDisable && memwr_i == WriteEnable)  // Store
      data_write_type_o = func3_i;
    else data_write_type_o = {Func3BusWidth{1'b0}};
  end

endmodule
