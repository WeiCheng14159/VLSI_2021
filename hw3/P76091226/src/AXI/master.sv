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

  logic [`AXI_ADDR_BITS-1:0] ARADDR_r, AWADDR_r;
  logic [`AXI_DATA_BITS-1:0] RDATA_r, WDATA_r;
  logic [`AXI_STRB_BITS-1:0] WSTRB_r;
  logic read;
  master_state_t m_curr_state, m_next_state;
  logic ARx_hs_done, Rx_hs_done, AWx_hs_done, Wx_hs_done, Bx_hs_done;

  assign read = access_request & ~write;

  assign AWx_hs_done = master.AWVALID & master.AWREADY;
  assign Wx_hs_done = master.WVALID & master.WREADY;
  assign Bx_hs_done = master.BVALID & master.BREADY;
  assign ARx_hs_done = master.ARVALID & master.ARREADY;
  assign Rx_hs_done = master.RVALID & master.RREADY;

  assign data_out = Rx_hs_done ? master.RDATA : RDATA_r;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) RDATA_r <= `AXI_DATA_BITS'b0;
    else RDATA_r <= (Rx_hs_done) ? master.RDATA : RDATA_r;
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ARADDR_r <= `AXI_ADDR_BITS'b0;
      AWADDR_r <= `AXI_ADDR_BITS'b0;
    end else if (m_curr_state != AR & m_next_state == AR) begin
      ARADDR_r <= addr;
    end else if (m_curr_state != AW & m_next_state == AW) begin
      AWADDR_r <= addr;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      WDATA_r <= `AXI_ADDR_BITS'b0;
      WSTRB_r <= `AXI_STRB_BITS'b1111;
    end else if (m_curr_state != AW & m_next_state == AW) begin
      WDATA_r <= data_in;
      WSTRB_r <= `AXI_STRB_WORD;
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
    case (m_curr_state)
      IDLE: m_next_state = (write) ? AW : (read) ? AR : IDLE;
      AR: m_next_state = (master.ARREADY) ? R : AR;
      R: m_next_state = (Rx_hs_done) ? (write ? AW : read ? AR : IDLE) : R;
      AW: m_next_state = (AWx_hs_done) ? (Wx_hs_done) ? B : W : AW;
      W: m_next_state = (Wx_hs_done) ? (Bx_hs_done) ? IDLE : B : W;
      B: m_next_state = (Bx_hs_done) ? IDLE : B;
      default: m_next_state = IDLE;
    endcase
  end  // Next state (C)

  always_comb begin
    // AWx
    master.AWID = `AXI_IDS_BITS'b0;
    master.AWADDR = AWADDR_r;
    master.AWLEN = `AXI_LEN_BITS'b0;
    master.AWSIZE = `AXI_SIZE_BITS'b0;
    master.AWBURST = `AXI_BURST_INC;
    master.AWVALID = 1'b0;
    // Wx
    master.WDATA = WDATA_r;
    master.WSTRB = WSTRB_r;
    master.WLAST = 1'b1;
    master.WVALID = 1'b0;
    // Bx
    master.BREADY = 1'b0;
    // ARx
    master.ARID = `AXI_IDS_BITS'b0;
    master.ARADDR = ARADDR_r;
    master.ARLEN = `AXI_LEN_BITS'b0;
    master.ARSIZE = `AXI_SIZE_BITS'b0;
    master.ARBURST = `AXI_BURST_INC;
    master.ARVALID = 1'b0;
    // Rx
    master.RREADY = 1'b0;
    // stall
    stall = 1'b0;

    case (m_curr_state)
      AR: begin
        // ARx
        master.ARBURST = `AXI_BURST_INC;
        master.ARVALID = 1'b1;
        stall = 1'b1;
      end
      R: begin
        // Rx
        master.RREADY = 1'b1;
      end
      AW: begin
        // AWx
        master.AWVALID = 1'b1;
        stall = 1'b1;
        master.WVALID = AWx_hs_done;
      end
      W: begin
        // Wx
        master.WVALID = 1'b1;
        // Bx
        master.BREADY = 1'b1;
        stall = 1'b1;
      end
      B: begin
        // Bx
        master.BREADY = 1'b1;
        stall = 1'b1;
      end
    endcase
  end



endmodule
