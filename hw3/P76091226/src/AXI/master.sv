`include "pkg_include.sv"

module master
  import master_pkg::*;
  import axi_pkg::*;
  import cpu_pkg::Func3BusWidth;
  import cpu_pkg::OP_SB;
  import cpu_pkg::OP_SH;
  import cpu_pkg::OP_SW;
  import cpu_pkg::WriteEnable;
  import cpu_pkg::WriteDisable;
#(
    parameter [`AXI_ID_BITS-1:0] master_ID = {`AXI_ID_BITS{1'b0}},
    parameter [`AXI_LEN_BITS-1:0] READ_BLOCK_SIZE = `AXI_LEN_ONE
) (
    input logic                  clk,
    input logic                  rstn,
          AXI_master_intf.master master,
          cache2mem_intf.memory  mem
);

  logic [`AXI_ADDR_BITS-1:0] ARADDR_r, AWADDR_r;
  logic [`AXI_DATA_BITS-1:0] RDATA_r, WDATA_r;
  logic [`AXI_STRB_BITS-1:0] WSTRB_r, WSTRB_c;
  logic read_req, write_req;
  master_state_t m_curr_state, m_next_state;
  logic ARx_hs_done, Rx_hs_done, AWx_hs_done, Wx_hs_done, Bx_hs_done;

  assign read_req = mem.m_req & ~mem.m_write;
  assign write_req = mem.m_req & mem.m_write;

  assign AWx_hs_done = master.AWVALID & master.AWREADY;
  assign Wx_hs_done = master.WVALID & master.WREADY;
  assign Bx_hs_done = master.BVALID & master.BREADY;
  assign ARx_hs_done = master.ARVALID & master.ARREADY;
  assign Rx_hs_done = master.RVALID & master.RREADY;

  // RDATA_r, ARADDR_r, AWADDR_r, WDATA_r, WSTRB_r
  assign mem.m_out = Rx_hs_done ? master.RDATA : RDATA_r;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      RDATA_r  <= `AXI_DATA_BITS'b0;
      ARADDR_r <= `AXI_ADDR_BITS'b0;
      AWADDR_r <= `AXI_ADDR_BITS'b0;
      WDATA_r  <= `AXI_ADDR_BITS'b0;
      WSTRB_r  <= {WriteDisable, WriteDisable, WriteDisable, WriteDisable};
    end else begin
      RDATA_r  <= (Rx_hs_done) ? master.RDATA : RDATA_r;
      ARADDR_r <= (ARx_hs_done) ? mem.m_addr : ARADDR_r;
      AWADDR_r <= (AWx_hs_done) ? mem.m_addr : AWADDR_r;
      WDATA_r  <= (Wx_hs_done) ? mem.m_in : WDATA_r;
      WSTRB_r  <= (Wx_hs_done) ? WSTRB_c : WSTRB_r;
    end
  end

  // WSTRB_c
  always_comb begin
    WSTRB_c = {WriteDisable, WriteDisable, WriteDisable, WriteDisable};
    case (mem.m_type)
      OP_SW: WSTRB_c = {WriteEnable, WriteEnable, WriteEnable, WriteEnable};
      OP_SH: begin
        case (mem.m_addr[1])
          1'b1:
          WSTRB_c = {WriteEnable, WriteEnable, WriteDisable, WriteDisable};
          1'b0:
          WSTRB_c = {WriteDisable, WriteDisable, WriteEnable, WriteEnable};
        endcase
      end
      OP_SB: begin
        case (mem.m_addr[1:0])
          2'b00:
          WSTRB_c = {WriteDisable, WriteDisable, WriteDisable, WriteEnable};
          2'b01:
          WSTRB_c = {WriteDisable, WriteDisable, WriteEnable, WriteDisable};
          2'b10:
          WSTRB_c = {WriteDisable, WriteEnable, WriteDisable, WriteDisable};
          2'b11:
          WSTRB_c = {WriteEnable, WriteDisable, WriteDisable, WriteDisable};
        endcase
      end
    endcase
  end

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      m_curr_state <= IDLE;
    end else begin
      m_curr_state <= m_next_state;
    end
  end  // State

  always_comb begin
    m_next_state = IDLE;
    unique case (1'b1)
      m_curr_state[IDLE_BIT]:
      m_next_state = (AWx_hs_done) ? WRITE : (ARx_hs_done) ? READ : IDLE;
      m_curr_state[READ_BIT]:
      m_next_state = (Rx_hs_done && master.RLAST) ? (write_req ? WRITE : read_req ? READ : IDLE) : READ;
      m_curr_state[WRITE_BIT]: m_next_state = (Bx_hs_done) ? IDLE : WRITE;
    endcase
  end  // Next state (C)

  always_comb begin
    // AWx
    master.AWID = master_ID;
    master.AWADDR = AWADDR_r;
    master.AWLEN = `AXI_LEN_BITS'b0;
    master.AWSIZE = `AXI_SIZE_BITS'b0;
    master.AWBURST = `AXI_BURST_INC;
    master.AWVALID = 1'b0;
    // Wx
    master.WDATA = WDATA_r;
    master.WSTRB = `AXI_STRB_BITS'b0;
    master.WLAST = 1'b1;
    master.WVALID = 1'b0;
    // Bx
    master.BREADY = 1'b0;
    // ARx
    master.ARID = master_ID;
    master.ARADDR = ARADDR_r;
    master.ARLEN = READ_BLOCK_SIZE;
    master.ARSIZE = `AXI_SIZE_BITS'b0;
    master.ARBURST = `AXI_BURST_INC;
    master.ARVALID = 1'b0;
    // Rx
    master.RREADY = 1'b0;
    // valid
    mem.m_wait = 1'b0;
    unique case (1'b1)
      m_curr_state[IDLE_BIT]: begin
        // ARx
        master.ARVALID = read_req;
        master.ARADDR  = mem.m_addr;
        // Rx
        master.RREADY  = read_req & ~write_req;
        // AWx
        master.AWVALID = write_req & ~read_req;
        master.AWADDR  = mem.m_addr;
        // Wx
        master.WVALID  = write_req;
        master.WDATA   = mem.m_in;
        master.WSTRB   = WSTRB_c;
      end
      m_curr_state[READ_BIT]: begin
        // ARx
        master.ARADDR = ARADDR_r;
        // Rx
        master.RREADY = 1'b1;
        // valid
        mem.m_wait = master.RVALID;
      end
      m_curr_state[WRITE_BIT]: begin
        // Wx
        master.WDATA = WDATA_r;
        master.WSTRB = WSTRB_r;
        // Bx
        master.BREADY = 1'b1;
        // valid
        mem.m_wait = master.BVALID;
      end
    endcase
  end

endmodule
