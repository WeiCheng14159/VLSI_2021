`include "AXI_define.svh"

module AWx
  import axi_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    // Master 1 
    input  logic [  `AXI_ID_BITS-1:0] AWID_M1,
    input  logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    input  logic [ `AXI_LEN_BITS-1:0] AWLEN_M1,
    input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    input  logic [               1:0] AWBURST_M1,
    input  logic                      AWVALID_M1,
    output logic                      AWREADY_M1,
    input  logic                      BREADY_M1,
    input  logic                      BVALID_M1,
    // Slave resp
    input  logic                      AWREADY_S0,
    input  logic                      AWREADY_S1,
    input  logic                      AWREADY_S2,
    // Slave 0
    output logic [ `AXI_IDS_BITS-1:0] AWID_S0,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
    output logic [ `AXI_LEN_BITS-1:0] AWLEN_S0,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
    output logic [               1:0] AWBURST_S0,
    output logic                      AWVALID_S0,
    // Slave 1
    output logic [ `AXI_IDS_BITS-1:0] AWID_S1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
    output logic [ `AXI_LEN_BITS-1:0] AWLEN_S1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
    output logic [               1:0] AWBURST_S1,
    output logic                      AWVALID_S1,
    // Default Slave
    output logic [ `AXI_IDS_BITS-1:0] AWID_S2,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
    output logic [ `AXI_LEN_BITS-1:0] AWLEN_S2,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
    output logic [               1:0] AWBURST_S2,
    output logic                      AWVALID_S2
);

  logic [ `AXI_IDS_BITS-1:0] AWID_M;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_M;
  logic [ `AXI_LEN_BITS-1:0] AWLEN_M;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M;
  logic [               1:0] AWBURST_M;
  logic                      AWVALID_M;
  logic                      AWREADY_from_slave;

  logic                      lock_AWREADY_M1;

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
    {AWID_S0, AWID_S1, AWID_S2} = {
      `AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0
    };
    {AWADDR_S0, AWADDR_S1, AWADDR_S2} = {
      `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0
    };
    {AWLEN_S0, AWLEN_S1, AWLEN_S2} = {
      `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0
    };
    {AWSIZE_S0, AWSIZE_S1, AWSIZE_S2} = {
      `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0
    };
    {AWBURST_S0, AWBURST_S1, AWBURST_S2} = {2'b0, 2'b0, 2'b0};
    {AWVALID_S0, AWVALID_S1, AWVALID_S2} = {1'b0, 1'b0, 1'b0};

    unique case (1'b1)
      decode_result[SLAVE_0_BIT]: begin
        AWID_S0 = AWID_M;
        AWADDR_S0 = AWADDR_M;
        AWLEN_S0 = AWLEN_M;
        AWSIZE_S0 = AWSIZE_M;
        AWBURST_S0 = AWBURST_M;
        AWVALID_S0 = AWVALID_M;
      end
      decode_result[SLAVE_1_BIT]: begin
        AWID_S1 = AWID_M;
        AWADDR_S1 = AWADDR_M;
        AWLEN_S1 = AWLEN_M;
        AWSIZE_S1 = AWSIZE_M;
        AWBURST_S1 = AWBURST_M;
        AWVALID_S1 = AWVALID_M;
      end
      decode_result[SLAVE_2_BIT]: begin
        AWID_S2 = AWID_M;
        AWADDR_S2 = AWADDR_M;
        AWLEN_S2 = AWLEN_M;
        AWSIZE_S2 = AWSIZE_M;
        AWBURST_S2 = AWBURST_M;
        AWVALID_S2 = AWVALID_M;
      end
    endcase
  end

  // Decoder
  always_comb begin
    AWREADY_from_slave = 1'b0;
    unique case (1'b1)
      decode_result[SLAVE_0_BIT]: begin
        AWREADY_from_slave = AWREADY_S0;
      end
      decode_result[SLAVE_1_BIT]: begin
        AWREADY_from_slave = AWREADY_S1;
      end
      decode_result[SLAVE_2_BIT]: begin
        AWREADY_from_slave = AWREADY_S2;
      end
    endcase
  end

endmodule
