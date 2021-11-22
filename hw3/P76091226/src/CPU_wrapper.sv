`include "def.v"
`include "CPU.sv"
`include "AXI_define.svh"
`include "cpu_wrapper_pkg.sv"
`include "AXI/master.sv"

module CPU_wrapper
  import cpu_wrapper_pkg::*;
(
    input logic clk,
    input logic rstn,
    // Master 1 (MEM-stage)
    // AWx
    output logic [`AXI_ID_BITS-1:0] AWID_M1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    output logic [1:0] AWBURST_M1,
    output logic AWVALID_M1,
    input logic AWREADY_M1,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    output logic WLAST_M1,
    output logic WVALID_M1,
    input logic WREADY_M1,
    // Bx
    input logic [`AXI_ID_BITS-1:0] BID_M1,
    input logic [1:0] BRESP_M1,
    input logic BVALID_M1,
    output logic BREADY_M1,
    // ARx
    output logic [`AXI_ID_BITS-1:0] ARID_M1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    output logic [1:0] ARBURST_M1,
    output logic ARVALID_M1,
    input logic ARREADY_M1,
    // Rx
    input logic [`AXI_ID_BITS-1:0] RID_M1,
    input logic [`AXI_DATA_BITS-1:0] RDATA_M1,
    input logic [1:0] RRESP_M1,
    input logic RLAST_M1,
    input logic RVALID_M1,
    output logic RREADY_M1,
    // Master 0 (IF-stage)
    // AWx
    output logic [`AXI_ID_BITS-1:0] AWID_M0,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
    output logic [1:0] AWBURST_M0,
    output logic AWVALID_M0,
    input logic AWREADY_M0,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
    output logic WLAST_M0,
    output logic WVALID_M0,
    input logic WREADY_M0,
    // Bx
    input logic [`AXI_ID_BITS-1:0] BID_M0,
    input logic [1:0] BRESP_M0,
    input logic BVALID_M0,
    output logic BREADY_M0,
    // ARx
    output logic [`AXI_ID_BITS-1:0] ARID_M0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    output logic [1:0] ARBURST_M0,
    output logic ARVALID_M0,
    input logic ARREADY_M0,
    // Rx
    input logic [`AXI_ID_BITS-1:0] RID_M0,
    input logic [`AXI_DATA_BITS-1:0] RDATA_M0,
    input logic [1:0] RRESP_M0,
    input logic RLAST_M0,
    input logic RVALID_M0,
    output logic RREADY_M0
);

  logic [    `InstBus]  inst_from_mem;
  logic                 inst_read;
  logic [`InstAddrBus]  inst_addr;

  logic [    `DataBus]  data_from_mem;
  logic                 data_read;
  logic                 data_write;
  logic [         3:0 ] data_write_web;
  logic [`DataAddrBus]  data_addr;
  logic [    `DataBus]  data_to_mem;

  logic                 stallreq_from_if;
  logic                 stallreq_from_mem;

  CPU cpu0 (
      .clk (clk),
      .rstn(rstn),

      .inst_out_i(inst_from_mem),
      .inst_read_o(inst_read),
      .inst_addr_o(inst_addr),
      .data_out_i(data_from_mem),
      .data_read_o(data_read),
      .data_write_o(data_write),
      .data_write_web_o(data_write_web),
      .data_addr_o(data_addr),
      .data_in_o(data_to_mem),

      .stallreq_from_if (stallreq_from_if),
      .stallreq_from_mem(stallreq_from_mem)
  );

  wire [3:0] NoWrite = 4'hf;

  master M0 (
      .clk(clk),
      .rstn(rstn),
      .AWID_M(AWID_M0),
      .AWADDR_M(AWADDR_M0),
      .AWLEN_M(AWLEN_M0),
      .AWSIZE_M(AWSIZE_M0),
      .AWBURST_M(AWBURST_M0),
      .AWVALID_M(AWVALID_M0),
      .AWREADY_M(AWREADY_M0),
      .WDATA_M(WDATA_M0),
      .WSTRB_M(WSTRB_M0),
      .WLAST_M(WLAST_M0),
      .WVALID_M(WVALID_M0),
      .WREADY_M(WREADY_M0),
      .BID_M(BID_M0),
      .BRESP_M(BRESP_M0),
      .BVALID_M(BVALID_M0),
      .BREADY_M(BREADY_M0),
      .ARID_M(ARID_M0),
      .ARADDR_M(ARADDR_M0),
      .ARLEN_M(ARLEN_M0),
      .ARSIZE_M(ARSIZE_M0),
      .ARBURST_M(ARBURST_M0),
      .ARVALID_M(ARVALID_M0),
      .ARREADY_M(ARREADY_M0),
      .RID_M(RID_M0),
      .RDATA_M(RDATA_M0),
      .RRESP_M(RRESP_M0),
      .RLAST_M(RLAST_M0),
      .RVALID_M(RVALID_M0),
      .RREADY_M(RREADY_M0),
      // CPU interface
      .read(inst_read),
      .write(1'b0),
      .w_type(NoWrite),
      .data_in(32'b0),
      .addr(inst_addr),
      .data_out(inst_from_mem),
      .stall(stallreq_from_if)
  );

  master M1 (
      .clk(clk),
      .rstn(rstn),
      .AWID_M(AWID_M1),
      .AWADDR_M(AWADDR_M1),
      .AWLEN_M(AWLEN_M1),
      .AWSIZE_M(AWSIZE_M1),
      .AWBURST_M(AWBURST_M1),
      .AWVALID_M(AWVALID_M1),
      .AWREADY_M(AWREADY_M1),
      .WDATA_M(WDATA_M1),
      .WSTRB_M(WSTRB_M1),
      .WLAST_M(WLAST_M1),
      .WVALID_M(WVALID_M1),
      .WREADY_M(WREADY_M1),
      .BID_M(BID_M1),
      .BRESP_M(BRESP_M1),
      .BVALID_M(BVALID_M1),
      .BREADY_M(BREADY_M1),
      .ARID_M(ARID_M1),
      .ARADDR_M(ARADDR_M1),
      .ARLEN_M(ARLEN_M1),
      .ARSIZE_M(ARSIZE_M1),
      .ARBURST_M(ARBURST_M1),
      .ARVALID_M(ARVALID_M1),
      .ARREADY_M(ARREADY_M1),
      .RID_M(RID_M1),
      .RDATA_M(RDATA_M1),
      .RRESP_M(RRESP_M1),
      .RLAST_M(RLAST_M1),
      .RVALID_M(RVALID_M1),
      .RREADY_M(RREADY_M1),
      // CPU interface
      .read(data_read),
      .write(data_write),
      .w_type(~data_write_web),
      .data_in(data_to_mem),
      .addr(data_addr),
      .data_out(data_from_mem),
      .stall(stallreq_from_mem)
  );

endmodule
