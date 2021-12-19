`include "pkg_include.sv"

module AWx
  import axi_pkg::*;
(
    input  logic                       clk,
    input  logic                       rstn,
    // Master 0
    input  logic [   `AXI_ID_BITS-1:0] AWID_M0,
    input  logic [ `AXI_ADDR_BITS-1:0] AWADDR_M0,
    input  logic [  `AXI_LEN_BITS-1:0] AWLEN_M0,
    input  logic [ `AXI_SIZE_BITS-1:0] AWSIZE_M0,
    input  logic [`AXI_BURST_BITS-1:0] AWBURST_M0,
    input  logic                       AWVALID_M0,
    output logic                       AWREADY_M0,
    input  logic                       BREADY_M0,
    input  logic                       BVALID_M0,
    // Master 1 
    input  logic [   `AXI_ID_BITS-1:0] AWID_M1,
    input  logic [ `AXI_ADDR_BITS-1:0] AWADDR_M1,
    input  logic [  `AXI_LEN_BITS-1:0] AWLEN_M1,
    input  logic [ `AXI_SIZE_BITS-1:0] AWSIZE_M1,
    input  logic [`AXI_BURST_BITS-1:0] AWBURST_M1,
    input  logic                       AWVALID_M1,
    output logic                       AWREADY_M1,
    input  logic                       BREADY_M1,
    input  logic                       BVALID_M1,
    // Master 2
    input  logic [   `AXI_ID_BITS-1:0] AWID_M2,
    input  logic [ `AXI_ADDR_BITS-1:0] AWADDR_M2,
    input  logic [  `AXI_LEN_BITS-1:0] AWLEN_M2,
    input  logic [ `AXI_SIZE_BITS-1:0] AWSIZE_M2,
    input  logic [`AXI_BURST_BITS-1:0] AWBURST_M2,
    input  logic                       AWVALID_M2,
    output logic                       AWREADY_M2,
    input  logic                       BREADY_M2,
    input  logic                       BVALID_M2,
    // Slave resp
    input  logic                       AWREADY_S0,
    input  logic                       AWREADY_S1,
    input  logic                       AWREADY_S2,
    input  logic                       AWREADY_S3,
    input  logic                       AWREADY_S4,
    input  logic                       AWREADY_S5,
    input  logic                       AWREADY_S6,
    // Slave 0
    output logic [  `AXI_IDS_BITS-1:0] AWID_S0,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S0,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S0,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S0,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S0,
    output logic                       AWVALID_S0,
    // Slave 1
    output logic [  `AXI_IDS_BITS-1:0] AWID_S1,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S1,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S1,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S1,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S1,
    output logic                       AWVALID_S1,
    // Slave 2
    output logic [  `AXI_IDS_BITS-1:0] AWID_S2,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S2,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S2,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S2,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S2,
    output logic                       AWVALID_S2,
    // Slave 3
    output logic [  `AXI_IDS_BITS-1:0] AWID_S3,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S3,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S3,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S3,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S3,
    output logic                       AWVALID_S3,
    // Slave 4
    output logic [  `AXI_IDS_BITS-1:0] AWID_S4,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S4,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S4,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S4,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S4,
    output logic                       AWVALID_S4,
    // Slave 5
    output logic [  `AXI_IDS_BITS-1:0] AWID_S5,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S5,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S5,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S5,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S5,
    output logic                       AWVALID_S5,
    // Slave 6
    output logic [  `AXI_IDS_BITS-1:0] AWID_S6,
    output logic [ `AXI_ADDR_BITS-1:0] AWADDR_S6,
    output logic [  `AXI_LEN_BITS-1:0] AWLEN_S6,
    output logic [ `AXI_SIZE_BITS-1:0] AWSIZE_S6,
    output logic [`AXI_BURST_BITS-1:0] AWBURST_S6,
    output logic                       AWVALID_S6
);

  logic [  `AXI_IDS_BITS-1:0] AWID_M;
  logic [ `AXI_ADDR_BITS-1:0] AWADDR_M;
  logic [  `AXI_LEN_BITS-1:0] AWLEN_M;
  logic [ `AXI_SIZE_BITS-1:0] AWSIZE_M;
  logic [`AXI_BURST_BITS-1:0] AWBURST_M;
  logic                       AWVALID_M;
  logic                       AWREADY_from_slave;

  logic                       lock_AWREADY_M1;

  addr_arb_lock_t addr_arb_lock, addr_arb_lock_next;
  addr_dec_result_t decode_result;

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
      addr_arb_lock_next = (AWREADY_from_slave) ? LOCK_FREE : LOCK_M1;
      addr_arb_lock[LOCK_FREE_BIT]:
      addr_arb_lock_next = (AWVALID_M1) ? LOCK_M1 : LOCK_FREE;
    endcase
  end  // Next state (C)

  // Lock AWREADY (master) if there are outstanding requests
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      lock_AWREADY_M1 <= 1'b0;
    end else begin
      lock_AWREADY_M1 <= (lock_AWREADY_M1) ? (BREADY_M1 & BVALID_M1) ? 1'b0 : 1'b1 : (AWVALID_M1 & AWREADY_M1) ? 1'b1 : 1'b0;
    end
  end

  // Arbiter
  always_comb begin
    AWID_M = {AXI_MASTER_1_ID, AWID_M1};
    AWADDR_M = AWADDR_M1;
    AWLEN_M = AWLEN_M1;
    AWSIZE_M = AWSIZE_M1;
    AWBURST_M = AWBURST_M1;
    AWVALID_M = AWVALID_M1;
    AWREADY_M1 = AWREADY_from_slave & ~lock_AWREADY_M1;
  end

  // Decoder
  assign decode_result = ADDR_DECODER(AWADDR_M);
  always_comb begin
    // Default
    {AWID_S0, AWID_S1, AWID_S2, AWID_S3, AWID_S4, AWID_S5, AWID_S6} = {
      AWID_M, AWID_M, AWID_M, AWID_M, AWID_M, AWID_M, AWID_M
    };
    {AWADDR_S0, AWADDR_S1, AWADDR_S2, AWADDR_S3, AWADDR_S4, AWADDR_S5, AWADDR_S6} = {
      AWADDR_M, AWADDR_M, AWADDR_M, AWADDR_M, AWADDR_M, AWADDR_M, AWADDR_M
    };
    {AWLEN_S0, AWLEN_S1, AWLEN_S2, AWLEN_S3, AWLEN_S4, AWLEN_S5, AWLEN_S6} = {
      AWLEN_M, AWLEN_M, AWLEN_M, AWLEN_M, AWLEN_M, AWLEN_M, AWLEN_M
    };
    {AWSIZE_S0, AWSIZE_S1, AWSIZE_S2, AWSIZE_S3, AWSIZE_S4, AWSIZE_S5, AWSIZE_S6} = {
      AWSIZE_M, AWSIZE_M, AWSIZE_M, AWSIZE_M, AWSIZE_M, AWSIZE_M, AWSIZE_M
    };
    {AWBURST_S0, AWBURST_S1, AWBURST_S2, AWBURST_S3, AWBURST_S4, AWBURST_S5, AWBURST_S6} = {
      AWBURST_M,
      AWBURST_M,
      AWBURST_M,
      AWBURST_M,
      AWBURST_M,
      AWBURST_M,
      AWBURST_M
    };
    {AWVALID_S0, AWVALID_S1, AWVALID_S2, AWVALID_S3, AWVALID_S4, AWVALID_S5, AWVALID_S6} = {
      1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    };

    unique case (1'b1)
      decode_result[SLAVE_0_BIT]: begin
        AWVALID_S0 = AWVALID_M;
      end
      decode_result[SLAVE_1_BIT]: begin
        AWVALID_S1 = AWVALID_M;
      end
      decode_result[SLAVE_2_BIT]: begin
        AWVALID_S2 = AWVALID_M;
      end
      decode_result[SLAVE_3_BIT]: begin
        AWVALID_S3 = AWVALID_M;
      end
      decode_result[SLAVE_4_BIT]: begin
        AWVALID_S4 = AWVALID_M;
      end
      decode_result[SLAVE_5_BIT]: begin
        AWVALID_S5 = AWVALID_M;
      end
      decode_result[SLAVE_6_BIT]: begin
        AWVALID_S6 = AWVALID_M;
      end
    endcase
  end

  // Decoder
  always_comb begin
    AWREADY_from_slave = 1'b0;
    unique case (1'b1)
      decode_result[SLAVE_0_BIT]: AWREADY_from_slave = AWREADY_S0;
      decode_result[SLAVE_1_BIT]: AWREADY_from_slave = AWREADY_S1;
      decode_result[SLAVE_2_BIT]: AWREADY_from_slave = AWREADY_S2;
      decode_result[SLAVE_3_BIT]: AWREADY_from_slave = AWREADY_S3;
      decode_result[SLAVE_4_BIT]: AWREADY_from_slave = AWREADY_S4;
      decode_result[SLAVE_5_BIT]: AWREADY_from_slave = AWREADY_S5;
      decode_result[SLAVE_6_BIT]: AWREADY_from_slave = AWREADY_S6;
    endcase
  end

endmodule
