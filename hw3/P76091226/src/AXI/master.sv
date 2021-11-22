`include "AXI_define.svh"
`include "master_pkg.sv"

module master
  import master_pkg::*;
(
    input logic clk,
    input logic rstn,
    // AXI master interface
    AXI_master_intf.master master,
    //interface for cpu
    input logic access_request,
    input logic write,
    input logic [`AXI_STRB_BITS-1:0] w_type,
    input logic [`AXI_DATA_BITS-1:0] data_in,
    input logic [`AXI_ADDR_BITS-1:0] addr,
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall
);

  logic [`AXI_ADDR_BITS-1:0] ARADDR_M_r, AWADDR_M_r;
  logic [`AXI_DATA_BITS-1:0] RDATA_M_r, WDATA_M_r;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M_r;
  logic read;
  master_state_t m_curr_state, m_next_state;
  logic ARx_hs_done, Rx_hs_done, AWx_hs_done, Wx_hs_done, Bx_hs_done;

  assign read = access_request & ~write;

  assign AWx_hs_done = master.AWVALID_M & master.AWREADY_M;
  assign Wx_hs_done = master.WVALID_M & master.WREADY_M;
  assign Bx_hs_done = master.BVALID_M & master.BREADY_M;
  assign ARx_hs_done = master.ARVALID_M & master.ARREADY_M;
  assign Rx_hs_done = master.RVALID_M & master.RREADY_M;

  assign data_out = Rx_hs_done ? master.RDATA_M : RDATA_M_r;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) RDATA_M_r <= `AXI_DATA_BITS'b0;
    else RDATA_M_r <= (Rx_hs_done) ? master.RDATA_M : RDATA_M_r;
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ARADDR_M_r <= `AXI_ADDR_BITS'b0;
      AWADDR_M_r <= `AXI_ADDR_BITS'b0;
    end else if (~m_curr_state[AR_BIT] & m_next_state[AR_BIT]) begin
      ARADDR_M_r <= addr;
    end else if (~m_curr_state[AW_BIT] & m_next_state[AW_BIT]) begin
      AWADDR_M_r <= addr;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      WDATA_M_r <= `AXI_ADDR_BITS'b0;
      WSTRB_M_r <= `AXI_STRB_BITS'b1111;
    end else if (~m_curr_state[AW_BIT] & m_next_state[AW_BIT]) begin
      WDATA_M_r <= data_in;
      case (w_type)
        `CACHE_BYTE: WSTRB_M_r <= `AXI_STRB_BYTE;
        `CACHE_HWORD: WSTRB_M_r <= `AXI_STRB_HWORD;
        default: WSTRB_M_r <= `AXI_STRB_WORD;
      endcase
    end
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
      m_curr_state[IDLE_BIT]: m_next_state = (write) ? AW : (read) ? AR : IDLE;
      m_curr_state[AR_BIT]: m_next_state = (master.ARREADY_M) ? R : AR;
      m_curr_state[R_BIT]:
      m_next_state = (Rx_hs_done) ? (write ? AW : read ? AR : IDLE) : R;
      m_curr_state[AW_BIT]:
      m_next_state = (AWx_hs_done) ? (Wx_hs_done) ? B : W : AW;
      m_curr_state[W_BIT]:
      m_next_state = (Wx_hs_done) ? (Bx_hs_done) ? IDLE : B : W;
      m_curr_state[B_BIT]: m_next_state = (Bx_hs_done) ? IDLE : B;
    endcase
  end  // Next state (C)

  always_comb begin
    // AWx
    master.AWID_M = `AXI_IDS_BITS'b0;
    master.AWADDR_M = AWADDR_M_r;
    master.AWLEN_M = `AXI_LEN_BITS'b0;
    master.AWSIZE_M = `AXI_SIZE_BITS'b0;
    master.AWBURST_M = `AXI_BURST_INC;
    master.AWVALID_M = 1'b0;
    // Wx
    master.WDATA_M = WDATA_M_r;
    master.WSTRB_M = WSTRB_M_r;
    master.WLAST_M = 1'b1;
    master.WVALID_M = 1'b0;
    // Bx
    master.BREADY_M = 1'b0;
    // ARx
    master.ARID_M = `AXI_IDS_BITS'b0;
    master.ARADDR_M = ARADDR_M_r;
    master.ARLEN_M = `AXI_LEN_BITS'b0;
    master.ARSIZE_M = `AXI_SIZE_BITS'b0;
    master.ARBURST_M = `AXI_BURST_INC;
    master.ARVALID_M = 1'b0;
    // Rx
    master.RREADY_M = 1'b0;
    // stall
    stall = 1'b0;

    case (1'b1)
      m_curr_state[AR_BIT]: begin
        // ARx
        master.ARBURST_M = `AXI_BURST_INC;
        master.ARVALID_M = 1'b1;
        stall = 1'b1;
      end
      m_curr_state[R_BIT]: begin
        // Rx
        master.RREADY_M = 1'b1;
      end
      m_curr_state[AW_BIT]: begin
        // AWx
        master.AWVALID_M = 1'b1;
        stall = 1'b1;
        master.WVALID_M = AWx_hs_done;
      end
      m_curr_state[W_BIT]: begin
        // Wx
        master.WVALID_M = 1'b1;
        // Bx
        master.BREADY_M = 1'b1;
        stall = 1'b1;
      end
      m_curr_state[B_BIT]: begin
        // Bx
        master.BREADY_M = 1'b1;
        stall = 1'b1;
      end
    endcase
  end



endmodule
