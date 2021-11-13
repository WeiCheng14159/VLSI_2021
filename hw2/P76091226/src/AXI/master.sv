`include "AXI_define.svh"
`include "master_pkg.sv"

module master
  import master_pkg::*;
(
    input logic clk,
    input logic rstn,
    // AWx
    output logic [`AXI_ID_BITS-1:0] AWID_M,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
    output logic [1:0] AWBURST_M,
    output logic AWVALID_M,
    input logic AWREADY_M,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_M,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
    output logic WLAST_M,
    output logic WVALID_M,
    input logic WREADY_M,
    // Bx
    input logic [`AXI_ID_BITS-1:0] BID_M,
    input logic [1:0] BRESP_M,
    input logic BVALID_M,
    output logic BREADY_M,
    // ARx
    output logic [`AXI_ID_BITS-1:0] ARID_M,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
    output logic [1:0] ARBURST_M,
    output logic ARVALID_M,
    input logic ARREADY_M,
    // Rx
    input logic [`AXI_ID_BITS-1:0] RID_M,
    input logic [`AXI_DATA_BITS-1:0] RDATA_M,
    input logic [1:0] RRESP_M,
    input logic RLAST_M,
    input logic RVALID_M,
    output logic RREADY_M,
    //interface for cpu
    input logic read,
    input logic write,
    input logic [`AXI_STRB_BITS-1:0] w_type,
    input logic [`AXI_DATA_BITS-1:0] data_in,
    input logic [`AXI_ADDR_BITS-1:0] addr,
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall
);


  logic [`AXI_DATA_BITS-1:0] RDATA_M_r;
  master_state_t m_curr_state, m_next_state;
  logic ARx_hs_done, Rx_hs_done, AW_hs_done, Wx_hs_done, Bx_hs_done;

  assign AW_hs_done = AWVALID_M & AWREADY_M;
  assign Wx_hs_done = WVALID_M & WREADY_M;
  assign Bx_hs_done = BVALID_M & BREADY_M;
  assign ARx_hs_done = ARVALID_M & ARREADY_M;
  assign Rx_hs_done = RVALID_M & RREADY_M;

  assign data_out = Rx_hs_done ? RDATA_M : RDATA_M_r;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) RDATA_M_r <= `AXI_DATA_BITS'b0;
    else RDATA_M_r <= (Rx_hs_done) ? RDATA_M : RDATA_M_r;
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
      AR: m_next_state = (ARREADY_M) ? R : AR;
      R: m_next_state = (RREADY_M) ? (write ? AW : read ? AR : IDLE) : R;
      AW: m_next_state = (AWREADY_M) ? W : AW;
      W: m_next_state = (WREADY_M) ? B : W;
      B: m_next_state = (BREADY_M) ? (write ? AW : read ? AR : IDLE) : B;
      default: ;
    endcase
  end  // Next state (C)

  always_comb begin
    // AWx
    AWID_M = `AXI_IDS_BITS'b0;
    AWADDR_M = addr;
    AWLEN_M = `AXI_LEN_BITS'b0;
    AWSIZE_M = `AXI_SIZE_BITS'b0;
    AWBURST_M = `AXI_BURST_INC;
    AWVALID_M = 1'b0;
    // Wx
    WDATA_M = data_in;
    WSTRB_M = w_type;
    WLAST_M = 1'b1;
    WVALID_M = 1'b0;
    // Bx
    BREADY_M = 1'b0;
    // ARx
    ARID_M = `AXI_IDS_BITS'b0;
    ARADDR_M = addr;
    ARLEN_M = `AXI_LEN_BITS'b0;
    ARSIZE_M = `AXI_SIZE_BITS'b0;
    ARBURST_M = `AXI_BURST_INC;
    ARVALID_M = 1'b0;
    // Rx
    RREADY_M = 1'b0;

    case (m_curr_state)
      IDLE: begin

      end
      AR: begin
        // ARx
        ARBURST_M = `AXI_BURST_INC;
        ARVALID_M = 1'b1;
        // Rx
        RREADY_M  = 1'b1;
      end
      R: begin
        // Rx
        RREADY_M = 1'b1;
      end
      AW: begin
        // AWx
        AWVALID_M = 1'b1;
        // Wx
        WVALID_M  = 1'b1;
      end
      W: begin
        // Wx
        WVALID_M = 1'b1;
        // Bx
        BREADY_M = 1'b1;
      end
      B: begin
        // Bx
        BREADY_M = 1'b1;
      end
      default: ;
    endcase
  end

endmodule
