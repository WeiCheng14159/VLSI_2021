`include "def.v"
module mem(
  input logic                           memrd_i,
  input logic                           memwr_i,
  input logic                 [`RegBus] wreg_data_i,
  input logic                 [`RegBus] wdata_i,
  input logic                           wb_mem2reg_i,
  input logic               [`Func3Bus] func3_i,

  output logic                          data_read_o,
  output logic                  [ 3: 0] data_write_o,
  output logic                [`RegBus] data_addr_o,
  output logic               [`DataBus] data_in_o
);

  logic                       [`RegBus] memaddr_i;
  logic                                 prev_is_read;

  assign prev_is_read = wb_mem2reg_i;
  assign memaddr_i = wreg_data_i;

  always_comb begin
    data_read_o = `ReadDisable | prev_is_read;
    data_write_o = {`WriteDisable, `WriteDisable, `WriteDisable, `WriteDisable};
    data_addr_o = `ZeroWord;
    data_in_o = `ZeroWord;

    if(memrd_i == `ReadEnable && memwr_i == `WriteDisable) begin // Load
      data_read_o = `ReadEnable;
      data_addr_o = memaddr_i;
    end else if(memrd_i == `ReadDisable && memwr_i == `WriteEnable) begin // Store
      data_read_o = `ReadEnable;
      data_addr_o = memaddr_i;
      case(func3_i)
        `OP_SW : begin 
          data_write_o = {`WriteEnable, `WriteEnable, `WriteEnable, `WriteEnable};
          data_in_o = wdata_i;
        end
        `OP_SH : begin
          case(memaddr_i[1])
            1'b1: begin
              data_write_o = {`WriteEnable, `WriteEnable, `WriteDisable, `WriteDisable};
              data_in_o = {wdata_i[15:0], 16'b0};
            end
            1'b0: begin
              data_write_o = {`WriteDisable, `WriteDisable, `WriteEnable, `WriteEnable};
              data_in_o = {16'b0, wdata_i[15:0]};
            end
          endcase
        end
        `OP_SB : begin 
          case(memaddr_i[1:0])
            2'b00: begin 
              data_write_o = {`WriteDisable, `WriteDisable, `WriteDisable, `WriteEnable};
              data_in_o = {24'b0, wdata_i[7:0]};
            end
            2'b01: begin 
              data_write_o = {`WriteDisable, `WriteDisable, `WriteEnable, `WriteDisable};
              data_in_o = {16'b0, wdata_i[7:0], 8'b0};
            end
            2'b10: begin
              data_write_o = {`WriteDisable, `WriteEnable, `WriteDisable, `WriteDisable};
              data_in_o = {8'b0, wdata_i[7:0], 16'b0};
            end
            2'b11: begin
              data_write_o = {`WriteEnable, `WriteDisable, `WriteDisable, `WriteDisable};
              data_in_o = {wdata_i[7:0], 24'b0};
            end
          endcase
        end
        default: begin
          data_write_o = {`WriteDisable, `WriteDisable, `WriteDisable, `WriteDisable};
          data_in_o = wdata_i;
        end
      endcase
    end
  end

endmodule
