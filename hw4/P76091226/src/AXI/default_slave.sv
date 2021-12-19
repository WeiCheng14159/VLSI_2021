`include "pkg_include.sv"

module default_slave
  import axi_pkg::*;
(
    input logic                clk,
    input logic                rstn,
          AXI_slave_intf.slave slave
);

  logic lockAR, lockAW, lockW;
  logic ARx_hs_done, AWx_hs_done, Wx_hs_done;

  logic [`AXI_LEN_BITS-1:0] ARLEN_cnt;

  assign ARx_hs_done = slave.ARREADY & slave.ARVALID;

  assign slave.RRESP = `AXI_RESP_DECERR;
  assign slave.RDATA = `AXI_DATA_BITS'b0;
  assign slave.RLAST = (slave.RVALID && ARLEN_cnt == `AXI_LEN_BITS'b0) ? 1'b1 : 1'b0;

  // Read channel  
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ARLEN_cnt <= `AXI_LEN_BITS'b0;
    end else begin
      ARLEN_cnt <= (slave.ARREADY & slave.ARVALID) ? slave.ARLEN : (slave.RREADY) ? (ARLEN_cnt - 1) : ARLEN_cnt;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      slave.RVALID <= 1'b0;
      slave.RID <= {AXI_MASTER_2_ID, `AXI_ID_BITS'b0};
      slave.ARREADY <= 1'b1;
      lockAR <= 1'b0;
    end else begin
      slave.RVALID <= (slave.RVALID & slave.RREADY) ? 1'b0 : (ARx_hs_done) ? 1'b1 : slave.RVALID;
      slave.RID <= (ARx_hs_done) ? slave.ARID : slave.RID;
      slave.ARREADY <= ((lockAR & ~slave.RREADY) | ARx_hs_done) ? 1'b0 : 1'b1;
      lockAR <= (lockAR & slave.RREADY) ? 1'b0 : (ARx_hs_done) ? 1'b1 : lockAR;
    end
  end

  assign AWx_hs_done = slave.AWREADY & slave.AWVALID;
  assign Wx_hs_done  = slave.WREADY & slave.WVALID;
  assign slave.BRESP = `AXI_RESP_DECERR;

  // Write channel
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      slave.BVALID <= 1'b0;
      slave.BID <= {AXI_MASTER_2_ID, `AXI_ID_BITS'b0};
      slave.AWREADY <= 1'b0;
      slave.WREADY <= 1'b0;
      lockAW <= 1'b0;
      lockW <= 1'b0;
    end else begin
      slave.BVALID <= (slave.BVALID & slave.BREADY) ? 1'b0 : ((AWx_hs_done & Wx_hs_done) | (lockAW & Wx_hs_done) | (lockW & AWx_hs_done)) ? 1'b1: slave.BVALID;
      slave.BID <= (AWx_hs_done) ? slave.AWID : slave.BID;
      slave.AWREADY <= ((lockAW & ~slave.BREADY) | AWx_hs_done) ? 1'b0 : 1'b1;
      slave.WREADY <= ((lockW & ~slave.BREADY) | Wx_hs_done) ? 1'b0 : 1'b1;
      lockAW <= (lockAW & slave.BREADY) ? 1'b0 : (AWx_hs_done) ? 1'b1 : lockAW;
      lockW <= (lockW & slave.BREADY) ? 1'b0 : (Wx_hs_done) ? 1'b1 : lockW;
    end
  end

endmodule
