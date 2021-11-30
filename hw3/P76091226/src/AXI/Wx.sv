`include "pkg_include.sv"

module Wx
  import axi_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    // Master 0
    input  logic [`AXI_DATA_BITS-1:0] WDATA_M0,
    input  logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
    input  logic                      WLAST_M0,
    input  logic                      WVALID_M0,
    output logic                      WREADY_M0,
    input  logic                      AWVALID_M0,
    // Master 1
    input  logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    input  logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    input  logic                      WLAST_M1,
    input  logic                      WVALID_M1,
    output logic                      WREADY_M1,
    input  logic                      AWVALID_M1,
    // Master 2
    input  logic [`AXI_DATA_BITS-1:0] WDATA_M2,
    input  logic [`AXI_STRB_BITS-1:0] WSTRB_M2,
    input  logic                      WLAST_M2,
    input  logic                      WVALID_M2,
    output logic                      WREADY_M2,
    input  logic                      AWVALID_M2,
    // Slave 0
    output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
    output logic                      WLAST_S0,
    output logic                      WVALID_S0,
    input  logic                      WREADY_S0,
    input  logic                      AWVALID_S0,
    input  logic                      AWREADY_S0,
    // Slave 1
    output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
    output logic                      WLAST_S1,
    output logic                      WVALID_S1,
    input  logic                      WREADY_S1,
    input  logic                      AWVALID_S1,
    input  logic                      AWREADY_S1,
    // Slave 2
    output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
    output logic                      WLAST_S2,
    output logic                      WVALID_S2,
    input  logic                      WREADY_S2,
    input  logic                      AWVALID_S2,
    input  logic                      AWREADY_S2,
    // Slave 3
    output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
    output logic                      WLAST_S3,
    output logic                      WVALID_S3,
    input  logic                      WREADY_S3,
    input  logic                      AWVALID_S3,
    input  logic                      AWREADY_S3,
    // Slave 4
    output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
    output logic                      WLAST_S4,
    output logic                      WVALID_S4,
    input  logic                      WREADY_S4,
    input  logic                      AWVALID_S4,
    input  logic                      AWREADY_S4,
    // Slave 5
    output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
    output logic                      WLAST_S5,
    output logic                      WVALID_S5,
    input  logic                      WREADY_S5,
    input  logic                      AWVALID_S5,
    input  logic                      AWREADY_S5,
    // Slave 6
    output logic [`AXI_DATA_BITS-1:0] WDATA_S6,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S6,
    output logic                      WLAST_S6,
    output logic                      WVALID_S6,
    input  logic                      WREADY_S6,
    input  logic                      AWVALID_S6,
    input  logic                      AWREADY_S6
);

  logic [`AXI_DATA_BITS-1:0] WDATA_M;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M;
  logic                      WLAST_M;
  logic                      WVALID_M;

  logic                      WREADY_from_slave;

  logic slow_transaction, fast_transaction;

  addr_arb_lock_t addr_arb_lock, addr_arb_lock_next;
  data_arb_lock_t AWx_slave_lock, AWx_slave_lock_r;
  data_arb_lock_t Wx_slave_lock;

  // AWx channel lock to which slave
  always_comb begin
    if (AWVALID_S0) AWx_slave_lock = LOCK_S0;
    else if (AWVALID_S1) AWx_slave_lock = LOCK_S1;
    else if (AWVALID_S2) AWx_slave_lock = LOCK_S2;
    else if (AWVALID_S3) AWx_slave_lock = LOCK_S3;
    else if (AWVALID_S4) AWx_slave_lock = LOCK_S4;
    else if (AWVALID_S5) AWx_slave_lock = LOCK_S5;
    else if (AWVALID_S6) AWx_slave_lock = LOCK_S6;
    else AWx_slave_lock = LOCK_NO;
  end

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      addr_arb_lock <= LOCK_FREE;
    end else begin
      addr_arb_lock <= addr_arb_lock_next;
    end
  end  // State

  always_comb begin
    addr_arb_lock_next = LOCK_FREE;
    unique case (1'b1)
      addr_arb_lock[LOCK_M0_BIT]: ;
      addr_arb_lock[LOCK_M1_BIT]:
      addr_arb_lock_next = (WREADY_from_slave && WLAST_M1) ? LOCK_FREE : LOCK_M1;
      addr_arb_lock[LOCK_FREE_BIT]:
      addr_arb_lock_next = (WVALID_M1) ? (WREADY_from_slave && WLAST_M1) ? LOCK_FREE : LOCK_M1 : LOCK_FREE;
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    WDATA_M   = `AXI_DATA_BITS'b0;
    WSTRB_M   = `AXI_STRB_BITS'b0;
    WLAST_M   = 1'b0;
    WVALID_M  = 1'b0;
    WREADY_M1 = 1'b0;

    unique case (1'b1)
      addr_arb_lock[LOCK_M0_BIT]: ;
      addr_arb_lock[LOCK_M1_BIT]: begin
        WDATA_M   = WDATA_M1;
        WSTRB_M   = WSTRB_M1;
        WLAST_M   = WLAST_M1;
        WVALID_M  = WVALID_M1;
        WREADY_M1 = WREADY_from_slave;
      end
      addr_arb_lock[LOCK_FREE_BIT]: begin
        if (WVALID_M1) begin
          WDATA_M   = WDATA_M1;
          WSTRB_M   = WSTRB_M1;
          WLAST_M   = WLAST_M1;
          WVALID_M  = WVALID_M1;
          WREADY_M1 = WREADY_from_slave;
        end
      end
    endcase
  end

  // Latch data at the first rising edge after VALID_Mx is asserted
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      AWx_slave_lock_r <= LOCK_NO;
    end else if (~addr_arb_lock[LOCK_M1_BIT] && addr_arb_lock_next[LOCK_M1_BIT]) begin
      AWx_slave_lock_r <= AWx_slave_lock;
    end
  end

  // Decoder
  assign fast_transaction = WVALID_M1 & AWVALID_M1;
  assign slow_transaction = addr_arb_lock[LOCK_M1_BIT];
  assign Wx_slave_lock = (fast_transaction) ? AWx_slave_lock : (slow_transaction) ? AWx_slave_lock_r : LOCK_NO;
  always_comb begin
    // Default
    {WDATA_S0, WDATA_S1, WDATA_S2, WDATA_S3, WDATA_S4, WDATA_S5, WDATA_S6} = {
      WDATA_M, WDATA_M, WDATA_M, WDATA_M, WDATA_M, WDATA_M, WDATA_M
    };
    {WSTRB_S0, WSTRB_S1, WSTRB_S2, WSTRB_S3, WSTRB_S4, WSTRB_S5, WSTRB_S6} = {
      WSTRB_M, WSTRB_M, WSTRB_M, WSTRB_M, WSTRB_M, WSTRB_M, WSTRB_M
    };
    {WLAST_S0, WLAST_S1, WLAST_S2, WLAST_S3, WLAST_S4, WLAST_S5, WLAST_S6} = {
      WLAST_M, WLAST_M, WLAST_M, WLAST_M, WLAST_M, WLAST_M, WLAST_M
    };
    {WVALID_S0, WVALID_S1, WVALID_S2, WVALID_S3, WVALID_S4, WVALID_S5, WVALID_S6} = {
      1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    };

    unique case (1'b1)
      Wx_slave_lock[LOCK_S0_BIT]: begin
        WVALID_S0 = WVALID_M;
      end
      Wx_slave_lock[LOCK_S1_BIT]: begin
        WVALID_S1 = WVALID_M;
      end
      Wx_slave_lock[LOCK_S2_BIT]: begin
        WVALID_S2 = WVALID_M;
      end
      Wx_slave_lock[LOCK_S3_BIT]: begin
        WVALID_S3 = WVALID_M;
      end
      Wx_slave_lock[LOCK_S4_BIT]: begin
        WVALID_S4 = WVALID_M;
      end
      Wx_slave_lock[LOCK_S5_BIT]: begin
        WVALID_S5 = WVALID_M;
      end
      Wx_slave_lock[LOCK_S6_BIT]: begin
        WVALID_S6 = WVALID_M;
      end
      Wx_slave_lock[LOCK_NO_BIT]: ;
    endcase
  end

  // Decoder
  always_comb begin
    WREADY_from_slave = 1'b0;
    unique case (1'b1)
      Wx_slave_lock[LOCK_S0_BIT]: WREADY_from_slave = WREADY_S0;
      Wx_slave_lock[LOCK_S1_BIT]: WREADY_from_slave = WREADY_S1;
      Wx_slave_lock[LOCK_S2_BIT]: WREADY_from_slave = WREADY_S2;
      Wx_slave_lock[LOCK_S3_BIT]: WREADY_from_slave = WREADY_S3;
      Wx_slave_lock[LOCK_S4_BIT]: WREADY_from_slave = WREADY_S4;
      Wx_slave_lock[LOCK_S5_BIT]: WREADY_from_slave = WREADY_S5;
      Wx_slave_lock[LOCK_S6_BIT]: WREADY_from_slave = WREADY_S6;
      Wx_slave_lock[LOCK_NO_BIT]: ;
    endcase
  end

endmodule
