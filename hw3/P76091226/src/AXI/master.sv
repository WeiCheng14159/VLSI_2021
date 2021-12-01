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
    input  logic                                       clk,
    input  logic                                       rstn,
    // AXI master interface
           AXI_master_intf.master                      master,
    //interface for cpu
    input  logic                                       access_request,
    input  logic                                       write,
    input  logic                  [ Func3BusWidth-1:0] w_type,
    input  logic                  [`AXI_DATA_BITS-1:0] data_in,
    input  logic                  [`AXI_ADDR_BITS-1:0] addr,
    output logic                  [`AXI_DATA_BITS-1:0] data_out,
    output logic                                       stall
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

  // RDATA_r
  assign data_out = Rx_hs_done ? master.RDATA : RDATA_r;
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) RDATA_r <= `AXI_DATA_BITS'b0;
    else RDATA_r <= (Rx_hs_done) ? master.RDATA : RDATA_r;
  end

  // ARADDR_r, AWADDR_r
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

  // WDATA_r
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      WDATA_r <= `AXI_ADDR_BITS'b0;
    end else if (m_curr_state != AW & m_next_state == AW) begin
      WDATA_r <= data_in;
    end
  end

  // WSTRB_r
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      WSTRB_r <= {WriteDisable, WriteDisable, WriteDisable, WriteDisable};
    end else if (m_curr_state != AW & m_next_state == AW) begin
      case (w_type)
        OP_SW: WSTRB_r <= {WriteEnable, WriteEnable, WriteEnable, WriteEnable};
        OP_SH: begin
          case (addr[1])
            1'b1:
            WSTRB_r <= {WriteEnable, WriteEnable, WriteDisable, WriteDisable};
            1'b0:
            WSTRB_r <= {WriteDisable, WriteDisable, WriteEnable, WriteEnable};
          endcase
        end
        OP_SB: begin
          case (addr[1:0])
            2'b00:
            WSTRB_r <= {WriteDisable, WriteDisable, WriteDisable, WriteEnable};
            2'b01:
            WSTRB_r <= {WriteDisable, WriteDisable, WriteEnable, WriteDisable};
            2'b10:
            WSTRB_r <= {WriteDisable, WriteEnable, WriteDisable, WriteDisable};
            2'b11:
            WSTRB_r <= {WriteEnable, WriteDisable, WriteDisable, WriteDisable};
          endcase
        end
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
      m_curr_state[AR_BIT]: m_next_state = (master.ARREADY) ? R : AR;
      m_curr_state[R_BIT]:
      m_next_state = (Rx_hs_done) ? (write ? AW : read ? AR : IDLE) : R;
      m_curr_state[AW_BIT]:
      m_next_state = (AWx_hs_done) ? (Wx_hs_done) ? B : W : AW;
      m_curr_state[W_BIT]:
      m_next_state = (Wx_hs_done) ? (Bx_hs_done) ? IDLE : B : W;
      m_curr_state[B_BIT]:
      m_next_state = (Bx_hs_done) ? (write ? AW : read ? AR : IDLE) : B;
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
    master.WSTRB = WSTRB_r;
    master.WLAST = 1'b1;
    master.WVALID = 1'b0;
    // Bx
    master.BREADY = 1'b0;
    // ARx
    master.ARID = master_ID;
    master.ARADDR = ARADDR_r;
    master.ARLEN = `AXI_LEN_BITS'b0;
    master.ARSIZE = `AXI_SIZE_BITS'b0;
    master.ARBURST = `AXI_BURST_INC;
    master.ARVALID = 1'b0;
    // Rx
    master.RREADY = 1'b0;
    // stall
    stall = 1'b0;

    unique case (1'b1)
      m_curr_state[IDLE_BIT]: ;
      m_curr_state[AR_BIT]: begin
        // ARx
        master.ARBURST = `AXI_BURST_INC;
        master.ARVALID = 1'b1;
        stall = 1'b1;
      end
      m_curr_state[R_BIT]: begin
        // Rx
        master.RREADY = 1'b1;
        stall = ~master.RLAST;
      end
      m_curr_state[AW_BIT]: begin
        // AWx
        master.AWVALID = 1'b1;
        stall = 1'b1;
        master.WVALID = AWx_hs_done;
      end
      m_curr_state[W_BIT]: begin
        // Wx
        master.WVALID = 1'b1;
        // Bx
        master.BREADY = 1'b1;
        stall = 1'b1;
      end
      m_curr_state[B_BIT]: begin
        // Bx
        master.BREADY = 1'b1;
        stall = ~master.BVALID;
      end
    endcase
  end

endmodule
