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
    parameter [`AXI_ID_BITS-1:0] master_ID = {`AXI_ID_BITS{1'b0}}
) (
    input logic                  clk,
    input logic                  rstn,
          AXI_master_intf.master master,
          cache2mem_intf.memory  mem
);

  logic [`AXI_STRB_BITS-1:0] WSTRB_c;
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

  assign mem.m_out = master.RDATA;

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
      m_next_state = (write_req) ? AW : (read_req) ? AR : IDLE;
      m_curr_state[AR_BIT]: m_next_state = (ARx_hs_done) ? R : AR;
      m_curr_state[R_BIT]:
      m_next_state = (Rx_hs_done & master.RLAST) ? (write_req ? AW : read_req ? AR : IDLE) : R;
      m_curr_state[AW_BIT]:
      m_next_state = (AWx_hs_done) ? (Wx_hs_done) ? B : W : AW;
      m_curr_state[W_BIT]:
      m_next_state = (Wx_hs_done) ? (Bx_hs_done) ? IDLE : B : W;
      m_curr_state[B_BIT]:
      m_next_state = (Bx_hs_done) ? (write_req ? AW : read_req ? AR : IDLE) : B;
    endcase
  end  // Next state (C)

  always_comb begin
    // AWx
    master.AWID = master_ID;
    master.AWADDR = mem.m_addr;
    master.AWLEN = `AXI_LEN_BITS'b0;
    master.AWSIZE = `AXI_SIZE_BITS'b0;
    master.AWBURST = `AXI_BURST_INC;
    master.AWVALID = 1'b0;
    // Wx
    master.WDATA = mem.m_in;
    master.WSTRB = WSTRB_c;
    master.WLAST = 1'b1;
    master.WVALID = 1'b0;
    // Bx
    master.BREADY = 1'b0;
    // ARx
    master.ARID = master_ID;
    master.ARADDR = mem.m_addr;
    master.ARLEN = mem.m_blk_size;
    ;
    master.ARSIZE = `AXI_SIZE_BITS'b0;
    master.ARBURST = `AXI_BURST_INC;
    master.ARVALID = 1'b0;
    // Rx
    master.RREADY = 1'b0;
    // valid
    mem.m_wait = 1'b0;

    unique case (1'b1)
      m_curr_state[IDLE_BIT]: ;
      m_curr_state[AR_BIT]: begin
        // ARx
        master.ARBURST = `AXI_BURST_INC;
        master.ARVALID = 1'b1;
      end
      m_curr_state[R_BIT]: begin
        // Rx
        master.RREADY = 1'b1;
        mem.m_wait = master.RVALID;
      end
      m_curr_state[AW_BIT]: begin
        // AWx
        master.AWVALID = 1'b1;
        master.WVALID  = AWx_hs_done;
      end
      m_curr_state[W_BIT]: begin
        // Wx
        master.WVALID = 1'b1;
        // Bx
        master.BREADY = 1'b1;
      end
      m_curr_state[B_BIT]: begin
        // Bx
        master.BREADY = 1'b1;
        mem.m_wait = master.BVALID;
      end
    endcase
  end

endmodule
