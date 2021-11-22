`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "AXI/AXI.sv"
`include "util.sv"

module top (
    input logic clk,
    input logic rst
);

  logic rst_sync, rstn_sync;
  reset_sync i_reset_sync (
      .clk(clk),
      .rst_async(rst),
      .rst_sync(rst_sync)
  );
  assign rstn_sync = ~rst_sync;

  // Master 0 (IF-stage)
  // ARx
  logic [`AXI_ID_BITS-1:0] ARID_M0;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M0;
  logic [`AXI_LEN_BITS-1:0] ARLEN_M0;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0;
  logic [1:0] ARBURST_M0;
  logic ARVALID_M0;
  logic ARREADY_M0;
  // Rx
  logic [`AXI_ID_BITS-1:0] RID_M0;
  logic [`AXI_DATA_BITS-1:0] RDATA_M0;
  logic [1:0] RRESP_M0;
  logic RLAST_M0;
  logic RVALID_M0;
  logic RREADY_M0;
  // AWx
  logic [`AXI_ID_BITS-1:0] AWID_M0;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_M0;
  logic [`AXI_LEN_BITS-1:0] AWLEN_M0;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0;
  logic [1:0] AWBURST_M0;
  logic AWVALID_M0;
  logic AWREADY_M0;
  // Wx
  logic [`AXI_DATA_BITS-1:0] WDATA_M0;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M0;
  logic WLAST_M0;
  logic WVALID_M0;
  logic WREADY_M0;
  // Bx
  logic [`AXI_ID_BITS-1:0] BID_M0;
  logic [1:0] BRESP_M0;
  logic BVALID_M0;
  logic BREADY_M0;
  // Master 1 (MEM-stage)
  // ARx
  logic [`AXI_ID_BITS-1:0] ARID_M1;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M1;
  logic [`AXI_LEN_BITS-1:0] ARLEN_M1;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1;
  logic [1:0] ARBURST_M1;
  logic ARVALID_M1;
  logic ARREADY_M1;
  // Rx
  logic [`AXI_ID_BITS-1:0] RID_M1;
  logic [`AXI_DATA_BITS-1:0] RDATA_M1;
  logic [1:0] RRESP_M1;
  logic RLAST_M1;
  logic RVALID_M1;
  logic RREADY_M1;
  // Wx
  logic [`AXI_ID_BITS-1:0] AWID_M1;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_M1;
  logic [`AXI_LEN_BITS-1:0] AWLEN_M1;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1;
  logic [1:0] AWBURST_M1;
  logic AWVALID_M1;
  logic AWREADY_M1;
  // Wx
  logic [`AXI_DATA_BITS-1:0] WDATA_M1;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M1;
  logic WLAST_M1;
  logic WVALID_M1;
  logic WREADY_M1;
  // Bx
  logic [`AXI_ID_BITS-1:0] BID_M1;
  logic [1:0] BRESP_M1;
  logic BVALID_M1;
  logic BREADY_M1;

  // Slave 0 (IF-stage)
  // AWx
  logic [`AXI_IDS_BITS-1:0] AWID_S0;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_S0;
  logic [`AXI_LEN_BITS-1:0] AWLEN_S0;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0;
  logic [1:0] AWBURST_S0;
  logic AWVALID_S0;
  logic AWREADY_S0;
  // Wx
  logic [`AXI_DATA_BITS-1:0] WDATA_S0;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S0;
  logic WLAST_S0;
  logic WVALID_S0;
  logic WREADY_S0;
  // Bx
  logic [`AXI_IDS_BITS-1:0] BID_S0;
  logic [1:0] BRESP_S0;
  logic BVALID_S0;
  logic BREADY_S0;
  // ARx
  logic [`AXI_IDS_BITS-1:0] ARID_S0;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_S0;
  logic [`AXI_LEN_BITS-1:0] ARLEN_S0;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0;
  logic [1:0] ARBURST_S0;
  logic ARVALID_S0;
  logic ARREADY_S0;
  // Rx
  logic [`AXI_IDS_BITS-1:0] RID_S0;
  logic [`AXI_DATA_BITS-1:0] RDATA_S0;
  logic [1:0] RRESP_S0;
  logic RLAST_S0;
  logic RVALID_S0;
  logic RREADY_S0;
  // Slave 1 (MEM-stage)
  // AWx
  logic [`AXI_IDS_BITS-1:0] AWID_S1;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_S1;
  logic [`AXI_LEN_BITS-1:0] AWLEN_S1;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1;
  logic [1:0] AWBURST_S1;
  logic AWVALID_S1;
  logic AWREADY_S1;
  // Wx
  logic [`AXI_DATA_BITS-1:0] WDATA_S1;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S1;
  logic WLAST_S1;
  logic WVALID_S1;
  logic WREADY_S1;
  // Bx
  logic [`AXI_IDS_BITS-1:0] BID_S1;
  logic [1:0] BRESP_S1;
  logic BVALID_S1;
  logic BREADY_S1;
  // ARx
  logic [`AXI_IDS_BITS-1:0] ARID_S1;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_S1;
  logic [`AXI_LEN_BITS-1:0] ARLEN_S1;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1;
  logic [1:0] ARBURST_S1;
  logic ARVALID_S1;
  logic ARREADY_S1;
  // Rx
  logic [`AXI_IDS_BITS-1:0] RID_S1;
  logic [`AXI_DATA_BITS-1:0] RDATA_S1;
  logic [1:0] RRESP_S1;
  logic RLAST_S1;
  logic RVALID_S1;
  logic RREADY_S1;

  // Master 0 AW, W, B channel
  assign AWREADY_M0 = 1'b0;
  assign WREADY_M0 = 1'b0;
  assign BID_M0 = `AXI_ID_BITS'b0;
  assign BRESP_M0 = `AXI_RESP_OKAY;
  assign BVALID_M0 = 1'b0;

  CPU_wrapper cpu_wrapper0 (
      .clk(clk),
      .rstn(rstn_sync),
      // Master 1
      // AWx
      .AWID_M1(AWID_M1),
      .AWADDR_M1(AWADDR_M1),
      .AWLEN_M1(AWLEN_M1),
      .AWSIZE_M1(AWSIZE_M1),
      .AWBURST_M1(AWBURST_M1),
      .AWVALID_M1(AWVALID_M1),
      .AWREADY_M1(AWREADY_M1),
      // Wx
      .WDATA_M1(WDATA_M1),
      .WSTRB_M1(WSTRB_M1),
      .WLAST_M1(WLAST_M1),
      .WVALID_M1(WVALID_M1),
      .WREADY_M1(WREADY_M1),
      // Bx
      .BID_M1(BID_M1),
      .BRESP_M1(BRESP_M1),
      .BVALID_M1(BVALID_M1),
      .BREADY_M1(BREADY_M1),
      // ARx
      .ARID_M1(ARID_M1),
      .ARADDR_M1(ARADDR_M1),
      .ARLEN_M1(ARLEN_M1),
      .ARSIZE_M1(ARSIZE_M1),
      .ARBURST_M1(ARBURST_M1),
      .ARVALID_M1(ARVALID_M1),
      .ARREADY_M1(ARREADY_M1),
      // Rx
      .RID_M1(RID_M1),
      .RDATA_M1(RDATA_M1),
      .RRESP_M1(RRESP_M1),
      .RLAST_M1(RLAST_M1),
      .RVALID_M1(RVALID_M1),
      .RREADY_M1(RREADY_M1),

      // Master 0
      // AWx
      .AWID_M0(AWID_M0),
      .AWADDR_M0(AWADDR_M0),
      .AWLEN_M0(AWLEN_M0),
      .AWSIZE_M0(AWSIZE_M0),
      .AWBURST_M0(AWBURST_M0),
      .AWVALID_M0(AWVALID_M0),
      .AWREADY_M0(AWREADY_M0),
      // Wx
      .WDATA_M0(WDATA_M0),
      .WSTRB_M0(WSTRB_M0),
      .WLAST_M0(WLAST_M0),
      .WVALID_M0(WVALID_M0),
      .WREADY_M0(WREADY_M0),
      // Bx
      .BID_M0(BID_M0),
      .BRESP_M0(BRESP_M0),
      .BVALID_M0(BVALID_M0),
      .BREADY_M0(BREADY_M0),
      // ARx
      .ARID_M0(ARID_M0),
      .ARADDR_M0(ARADDR_M0),
      .ARLEN_M0(ARLEN_M0),
      .ARSIZE_M0(ARSIZE_M0),
      .ARBURST_M0(ARBURST_M0),
      .ARVALID_M0(ARVALID_M0),
      .ARREADY_M0(ARREADY_M0),
      // Rx
      .RID_M0(RID_M0),
      .RDATA_M0(RDATA_M0),
      .RRESP_M0(RRESP_M0),
      .RLAST_M0(RLAST_M0),
      .RVALID_M0(RVALID_M0),
      .RREADY_M0(RREADY_M0)
  );

  AXI axi (
      .ACLK(clk),
      .ARESETn(rstn_sync),
      // AXI to master 0 (IF-stage)
      // ARx
      .ARID_M0   (ARID_M0),
      .ARADDR_M0 (ARADDR_M0),
      .ARLEN_M0  (ARLEN_M0),
      .ARSIZE_M0 (ARSIZE_M0),
      .ARBURST_M0(ARBURST_M0),
      .ARVALID_M0(ARVALID_M0),
      .ARREADY_M0(ARREADY_M0),
      // Rx
      .RID_M0   (RID_M0),
      .RDATA_M0 (RDATA_M0),
      .RRESP_M0 (RRESP_M0),
      .RLAST_M0 (RLAST_M0),
      .RVALID_M0(RVALID_M0),
      .RREADY_M0(RREADY_M0),

      // AXI to master 1 (MEM-stage)
      // AWx
      .AWID_M1   (AWID_M1),
      .AWADDR_M1 (AWADDR_M1),
      .AWLEN_M1  (AWLEN_M1),
      .AWSIZE_M1 (AWSIZE_M1),
      .AWBURST_M1(AWBURST_M1),
      .AWVALID_M1(AWVALID_M1),
      .AWREADY_M1(AWREADY_M1),
      // Wx
      .WDATA_M1 (WDATA_M1),
      .WSTRB_M1 (WSTRB_M1),
      .WLAST_M1 (WLAST_M1),
      .WVALID_M1(WVALID_M1),
      .WREADY_M1(WREADY_M1),
      // Bx
      .BID_M1   (BID_M1),
      .BRESP_M1 (BRESP_M1),
      .BVALID_M1(BVALID_M1),
      .BREADY_M1(BREADY_M1),
      // ARx
      .ARID_M1   (ARID_M1),
      .ARADDR_M1 (ARADDR_M1),
      .ARLEN_M1  (ARLEN_M1),
      .ARSIZE_M1 (ARSIZE_M1),
      .ARBURST_M1(ARBURST_M1),
      .ARVALID_M1(ARVALID_M1),
      .ARREADY_M1(ARREADY_M1),
      // Rx
      .RID_M1   (RID_M1),
      .RDATA_M1 (RDATA_M1),
      .RRESP_M1 (RRESP_M1),
      .RLAST_M1 (RLAST_M1),
      .RVALID_M1(RVALID_M1),
      .RREADY_M1(RREADY_M1),
      // AXI to slave 0 (IM)
      // AWx
      .AWID_S0   (AWID_S0),
      .AWADDR_S0 (AWADDR_S0),
      .AWLEN_S0  (AWLEN_S0),
      .AWSIZE_S0 (AWSIZE_S0),
      .AWBURST_S0(AWBURST_S0),
      .AWVALID_S0(AWVALID_S0),
      .AWREADY_S0(AWREADY_S0),
      // Wx
      .WDATA_S0 (WDATA_S0),
      .WSTRB_S0 (WSTRB_S0),
      .WLAST_S0 (WLAST_S0),
      .WVALID_S0(WVALID_S0),
      .WREADY_S0(WREADY_S0),
      // Bx
      .BID_S0   (BID_S0),
      .BRESP_S0 (BRESP_S0),
      .BVALID_S0(BVALID_S0),
      .BREADY_S0(BREADY_S0),
      // ARx
      .ARID_S0   (ARID_S0),
      .ARADDR_S0 (ARADDR_S0),
      .ARLEN_S0  (ARLEN_S0),
      .ARSIZE_S0 (ARSIZE_S0),
      .ARBURST_S0(ARBURST_S0),
      .ARVALID_S0(ARVALID_S0),
      .ARREADY_S0(ARREADY_S0),
      // Rx
      .RID_S0   (RID_S0),
      .RDATA_S0 (RDATA_S0),
      .RRESP_S0 (RRESP_S0),
      .RLAST_S0 (RLAST_S0),
      .RVALID_S0(RVALID_S0),
      .RREADY_S0(RREADY_S0),

      // AXI to slave 1 (DM)
      // AWx
      .AWID_S1   (AWID_S1),
      .AWADDR_S1 (AWADDR_S1),
      .AWLEN_S1  (AWLEN_S1),
      .AWSIZE_S1 (AWSIZE_S1),
      .AWBURST_S1(AWBURST_S1),
      .AWVALID_S1(AWVALID_S1),
      .AWREADY_S1(AWREADY_S1),
      // Wx
      .WDATA_S1 (WDATA_S1),
      .WSTRB_S1 (WSTRB_S1),
      .WLAST_S1 (WLAST_S1),
      .WVALID_S1(WVALID_S1),
      .WREADY_S1(WREADY_S1),
      // Bx
      .BID_S1   (BID_S1),
      .BRESP_S1 (BRESP_S1),
      .BVALID_S1(BVALID_S1),
      .BREADY_S1(BREADY_S1),
      // ARx
      .ARID_S1   (ARID_S1),
      .ARADDR_S1 (ARADDR_S1),
      .ARLEN_S1  (ARLEN_S1),
      .ARSIZE_S1 (ARSIZE_S1),
      .ARBURST_S1(ARBURST_S1),
      .ARVALID_S1(ARVALID_S1),
      .ARREADY_S1(ARREADY_S1),
      // Rx
      .RID_S1   (RID_S1),
      .RDATA_S1 (RDATA_S1),
      .RRESP_S1 (RRESP_S1),
      .RLAST_S1 (RLAST_S1),
      .RVALID_S1(RVALID_S1),
      .RREADY_S1(RREADY_S1)
  );

  SRAM_wrapper IM1 (
      .clk(clk),
      .rstn(rstn_sync),
      // AWx
      .AWID_S(AWID_S0),
      .AWADDR_S(AWADDR_S0),
      .AWLEN_S(AWLEN_S0),
      .AWSIZE_S(AWSIZE_S0),
      .AWBURST_S(AWBURST_S0),
      .AWVALID_S(AWVALID_S0),
      .AWREADY_S(AWREADY_S0),
      // Wx
      .WDATA_S(WDATA_S0),
      .WSTRB_S(WSTRB_S0),
      .WLAST_S(WLAST_S0),
      .WVALID_S(WVALID_S0),
      .WREADY_S(WREADY_S0),
      // Bx
      .BID_S(BID_S0),
      .BRESP_S(BRESP_S0),
      .BVALID_S(BVALID_S0),
      .BREADY_S(BREADY_S0),
      // ARx
      .ARID_S(ARID_S0),
      .ARADDR_S(ARADDR_S0),
      .ARLEN_S(ARLEN_S0),
      .ARSIZE_S(ARSIZE_S0),
      .ARBURST_S(ARBURST_S0),
      .ARVALID_S(ARVALID_S0),
      .ARREADY_S(ARREADY_S0),
      // Rx
      .RID_S(RID_S0),
      .RDATA_S(RDATA_S0),
      .RRESP_S(RRESP_S0),
      .RLAST_S(RLAST_S0),
      .RVALID_S(RVALID_S0),
      .RREADY_S(RREADY_S0)
  );

  SRAM_wrapper DM1 (
      .clk(clk),
      .rstn(rstn_sync),
      // AWx
      .AWID_S(AWID_S1),
      .AWADDR_S(AWADDR_S1),
      .AWLEN_S(AWLEN_S1),
      .AWSIZE_S(AWSIZE_S1),
      .AWBURST_S(AWBURST_S1),
      .AWVALID_S(AWVALID_S1),
      .AWREADY_S(AWREADY_S1),
      // Wx
      .WDATA_S(WDATA_S1),
      .WSTRB_S(WSTRB_S1),
      .WLAST_S(WLAST_S1),
      .WVALID_S(WVALID_S1),
      .WREADY_S(WREADY_S1),
      // Bx
      .BID_S(BID_S1),
      .BRESP_S(BRESP_S1),
      .BVALID_S(BVALID_S1),
      .BREADY_S(BREADY_S1),
      // ARx
      .ARID_S(ARID_S1),
      .ARADDR_S(ARADDR_S1),
      .ARLEN_S(ARLEN_S1),
      .ARSIZE_S(ARSIZE_S1),
      .ARBURST_S(ARBURST_S1),
      .ARVALID_S(ARVALID_S1),
      .ARREADY_S(ARREADY_S1),
      // Rx
      .RID_S(RID_S1),
      .RDATA_S(RDATA_S1),
      .RRESP_S(RRESP_S1),
      .RLAST_S(RLAST_S1),
      .RVALID_S(RVALID_S1),
      .RREADY_S(RREADY_S1)
  );

endmodule
