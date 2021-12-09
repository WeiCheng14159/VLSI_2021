module if_id
  import cpu_pkg::*;
(
    input logic clk,
    input logic rstn,

    input logic [RegBusWidth-1:0] if_pc,
    input logic [ InstrWidth-1:0] if_inst,
    input logic                   flush,
    input logic [  STAGE_NUM-1:0] stall,
    input logic                   if_is_in_delay_slot,

    output logic [RegBusWidth-1:0] id_pc,
    output logic [ InstrWidth-1:0] id_inst
);

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      id_pc   <= ZeroWord;
      id_inst <= NOP;
    end else if (flush == True | (if_is_in_delay_slot & stall[IF_STAGE] == NoStop) |
      (stall[IF_STAGE] == Stop && stall[ID_STAGE] == NoStop) ) begin
      id_pc   <= ZeroWord;
      id_inst <= NOP;
    end else if (stall[IF_STAGE] == NoStop) begin
      id_pc   <= if_pc;
      id_inst <= if_inst;
    end
  end

endmodule

