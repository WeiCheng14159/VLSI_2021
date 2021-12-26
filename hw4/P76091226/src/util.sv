module CG (
    input  CK,
    input  EN,
    output CKEN
);

  logic en_latch;

  always_latch begin
    if (~CK) en_latch <= EN;
  end

  assign CKEN = CK & en_latch;

endmodule

module reset_sync (
    input  clk,
    input  rst_async,
    output rst_sync
);

  logic rst_async_tmp;
  logic rst_async_tmp2;

  always @(posedge clk or posedge rst_async) begin
    if (rst_async) rst_async_tmp <= 1'b1;
    else rst_async_tmp <= 1'b0;
  end

  always @(posedge clk or posedge rst_async) begin
    if (rst_async) rst_async_tmp2 <= 1'b1;
    else rst_async_tmp2 <= rst_async_tmp;
  end

  assign rst_sync = rst_async_tmp2;

endmodule

module bus_syncer #(
    parameter BUS_WIDTH = 32
) (
    input logic clk,
    input logic rstn,
    input logic [BUS_WIDTH-1:0] data_in,
    output logic [BUS_WIDTH-1:0] data_out
);

  logic [BUS_WIDTH-1:0] data_tmp;

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      data_tmp <= {BUS_WIDTH{1'b0}};
      data_out <= {BUS_WIDTH{1'b0}};
    end else begin
      data_tmp <= data_in;
      data_out <= data_tmp;
    end
  end

endmodule
