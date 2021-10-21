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
  else           rst_async_tmp <= 1'b0;
end

always @(posedge clk or posedge rst_async) begin
  if (rst_async) rst_async_tmp2 <= 1'b1;
  else           rst_async_tmp2 <= rst_async_tmp;
end

assign rst_sync = rst_async_tmp2;

endmodule
