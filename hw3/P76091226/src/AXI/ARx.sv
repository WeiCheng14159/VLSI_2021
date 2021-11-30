`include "pkg_include.sv"

module ARx
  import axi_pkg::*;
(
    input  logic                       clk,
    input  logic                       rstn,
    // Master0
    input  logic [   `AXI_ID_BITS-1:0] ARID_M0,
    input  logic [ `AXI_ADDR_BITS-1:0] ARADDR_M0,
    input  logic [  `AXI_LEN_BITS-1:0] ARLEN_M0,
    input  logic [ `AXI_SIZE_BITS-1:0] ARSIZE_M0,
    input  logic [`AXI_BURST_BITS-1:0] ARBURST_M0,
    input  logic                       ARVALID_M0,
    output logic                       ARREADY_M0,
    input  logic                       RREADY_M0,
    input  logic                       RLAST_M0,
    // Master1
    input  logic [   `AXI_ID_BITS-1:0] ARID_M1,
    input  logic [ `AXI_ADDR_BITS-1:0] ARADDR_M1,
    input  logic [  `AXI_LEN_BITS-1:0] ARLEN_M1,
    input  logic [ `AXI_SIZE_BITS-1:0] ARSIZE_M1,
    input  logic [`AXI_BURST_BITS-1:0] ARBURST_M1,
    input  logic                       ARVALID_M1,
    output logic                       ARREADY_M1,
    input  logic                       RREADY_M1,
    input  logic                       RLAST_M1,
    // Master2
    input  logic [   `AXI_ID_BITS-1:0] ARID_M2,
    input  logic [ `AXI_ADDR_BITS-1:0] ARADDR_M2,
    input  logic [  `AXI_LEN_BITS-1:0] ARLEN_M2,
    input  logic [ `AXI_SIZE_BITS-1:0] ARSIZE_M2,
    input  logic [`AXI_BURST_BITS-1:0] ARBURST_M2,
    input  logic                       ARVALID_M2,
    output logic                       ARREADY_M2,
    input  logic                       RREADY_M2,
    input  logic                       RLAST_M2,
    // Slave0 resp
    input  logic                       ARREADY_S0,
    input  logic                       ARREADY_S1,
    input  logic                       ARREADY_S2,
    input  logic                       ARREADY_S3,
    input  logic                       ARREADY_S4,
    input  logic                       ARREADY_S5,
    input  logic                       ARREADY_S6,
    // Slave0
    output logic [  `AXI_IDS_BITS-1:0] ARID_S0,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S0,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S0,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S0,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S0,
    output logic                       ARVALID_S0,
    input  logic                       RLAST_S0,
    input  logic                       RREADY_S0,
    // Slave1
    output logic [  `AXI_IDS_BITS-1:0] ARID_S1,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S1,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S1,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S1,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S1,
    output logic                       ARVALID_S1,
    input  logic                       RLAST_S1,
    input  logic                       RREADY_S1,
    // Slave2
    output logic [  `AXI_IDS_BITS-1:0] ARID_S2,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S2,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S2,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S2,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S2,
    output logic                       ARVALID_S2,
    input  logic                       RLAST_S2,
    input  logic                       RREADY_S2,
    // Slave3
    output logic [  `AXI_IDS_BITS-1:0] ARID_S3,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S3,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S3,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S3,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S3,
    output logic                       ARVALID_S3,
    input  logic                       RLAST_S3,
    input  logic                       RREADY_S3,
    // Slave4
    output logic [  `AXI_IDS_BITS-1:0] ARID_S4,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S4,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S4,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S4,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S4,
    output logic                       ARVALID_S4,
    input  logic                       RLAST_S4,
    input  logic                       RREADY_S4,
    // Slave5
    output logic [  `AXI_IDS_BITS-1:0] ARID_S5,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S5,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S5,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S5,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S5,
    output logic                       ARVALID_S5,
    input  logic                       RLAST_S5,
    input  logic                       RREADY_S5,
    // Slave6
    output logic [  `AXI_IDS_BITS-1:0] ARID_S6,
    output logic [ `AXI_ADDR_BITS-1:0] ARADDR_S6,
    output logic [  `AXI_LEN_BITS-1:0] ARLEN_S6,
    output logic [ `AXI_SIZE_BITS-1:0] ARSIZE_S6,
    output logic [`AXI_BURST_BITS-1:0] ARBURST_S6,
    output logic                       ARVALID_S6,
    input  logic                       RLAST_S6,
    input  logic                       RREADY_S6
);

  logic [  `AXI_IDS_BITS-1:0] ARID_M;
  logic [ `AXI_ADDR_BITS-1:0] ARADDR_M;
  logic [  `AXI_LEN_BITS-1:0] ARLEN_M;
  logic [ `AXI_SIZE_BITS-1:0] ARSIZE_M;
  logic [`AXI_BURST_BITS-1:0] ARBURST_M;
  logic                       ARVALID_M;
  logic                       ARREADY_from_slave;

  logic
      lock_ARVALID_S0,
      lock_ARVALID_S1,
      lock_ARVALID_S2,
      lock_ARVALID_S3,
      lock_ARVALID_S4,
      lock_ARVALID_S5,
      lock_ARVALID_S6;
  logic lock_ARREADY_M0, lock_ARREADY_M1;
  addr_dec_result_t decode_result;
  addr_arb_lock_t addr_arb_lock, addr_arb_lock_next;

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
      addr_arb_lock[LOCK_M0_BIT]:
      addr_arb_lock_next = (ARREADY_from_slave) ? LOCK_FREE : LOCK_M0;
      addr_arb_lock[LOCK_M1_BIT]:
      addr_arb_lock_next = (ARREADY_from_slave) ? LOCK_FREE : LOCK_M1;
      addr_arb_lock[LOCK_FREE_BIT]: begin
        case ({
          ARVALID_M0, ARVALID_M1
        })
          2'b11:   addr_arb_lock_next = LOCK_M0;  // M0 has higher priority
          2'b01:   addr_arb_lock_next = LOCK_M1;
          2'b10:   addr_arb_lock_next = LOCK_M0;
          default: addr_arb_lock_next = LOCK_FREE;
        endcase
      end
    endcase
  end  // Next state (C)

  // Lock ARVALID (slave) if there are outstanding requests
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      {lock_ARVALID_S0, lock_ARVALID_S1, lock_ARVALID_S2, lock_ARVALID_S3, lock_ARVALID_S4, lock_ARVALID_S5, lock_ARVALID_S6} <= 7'b0;
    end else begin
      lock_ARVALID_S0 <= (lock_ARVALID_S0) ? (RREADY_S0 & RLAST_S0) ? 1'b0 : 1'b1 : (ARVALID_S0 & ARREADY_S0) ? 1'b1 : 1'b0;
      lock_ARVALID_S1 <= (lock_ARVALID_S1) ? (RREADY_S1 & RLAST_S1) ? 1'b0 : 1'b1 : (ARVALID_S1 & ARREADY_S1) ? 1'b1 : 1'b0;
      lock_ARVALID_S2 <= (lock_ARVALID_S2) ? (RREADY_S2 & RLAST_S2) ? 1'b0 : 1'b1 : (ARVALID_S2 & ARREADY_S2) ? 1'b1 : 1'b0;
      lock_ARVALID_S3 <= (lock_ARVALID_S3) ? (RREADY_S3 & RLAST_S3) ? 1'b0 : 1'b1 : (ARVALID_S3 & ARREADY_S3) ? 1'b1 : 1'b0;
      lock_ARVALID_S4 <= (lock_ARVALID_S4) ? (RREADY_S4 & RLAST_S4) ? 1'b0 : 1'b1 : (ARVALID_S4 & ARREADY_S4) ? 1'b1 : 1'b0;
      lock_ARVALID_S5 <= (lock_ARVALID_S5) ? (RREADY_S5 & RLAST_S5) ? 1'b0 : 1'b1 : (ARVALID_S5 & ARREADY_S5) ? 1'b1 : 1'b0;
      lock_ARVALID_S6 <= (lock_ARVALID_S6) ? (RREADY_S6 & RLAST_S6) ? 1'b0 : 1'b1 : (ARVALID_S6 & ARREADY_S6) ? 1'b1 : 1'b0;
    end
  end

  // Lock ARREADY (master) if there are outstanding requests
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      {lock_ARREADY_M0, lock_ARREADY_M1} <= 2'b0;
    end else begin
      lock_ARREADY_M0 <= (lock_ARREADY_M0) ? (RREADY_M0 & RLAST_M0) ? 1'b0 : 1'b1 : (ARVALID_M0 & ARREADY_M0) ? 1'b1 : 1'b0;
      lock_ARREADY_M1 <= (lock_ARREADY_M1) ? (RREADY_M1 & RLAST_M1) ? 1'b0 : 1'b1 : (ARVALID_M1 & ARREADY_M1) ? 1'b1 : 1'b0;
    end
  end

  // Arbiter
  always_comb begin
    // Default
    ARID_M = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
    ARADDR_M = `AXI_ADDR_BITS'b0;
    ARLEN_M = `AXI_LEN_BITS'b0;
    ARSIZE_M = `AXI_SIZE_BITS'b0;
    ARBURST_M = 2'b0;
    ARVALID_M = 1'b0;
    {ARREADY_M0, ARREADY_M1} = {1'b0, 1'b0};
    unique case (1'b1)
      addr_arb_lock[LOCK_M0_BIT]: begin
        ARID_M = {AXI_MASTER_0_ID, ARID_M0};
        ARADDR_M = ARADDR_M0;
        ARLEN_M = ARLEN_M0;
        ARSIZE_M = ARSIZE_M0;
        ARBURST_M = ARBURST_M0;
        ARVALID_M = ARVALID_M0;
        ARREADY_M0 = ARREADY_from_slave & ~lock_ARREADY_M0;
      end
      addr_arb_lock[LOCK_M1_BIT]: begin
        ARID_M = {AXI_MASTER_1_ID, ARID_M1};
        ARADDR_M = ARADDR_M1;
        ARLEN_M = ARLEN_M1;
        ARSIZE_M = ARSIZE_M1;
        ARBURST_M = ARBURST_M1;
        ARVALID_M = ARVALID_M1;
        ARREADY_M1 = ARREADY_from_slave & ~lock_ARREADY_M1;
      end
      addr_arb_lock[LOCK_FREE_BIT]: begin
        case ({
          ARVALID_M0, ARVALID_M1
        })
          2'b11: begin  // M0 has higher priority
            ARID_M = {AXI_MASTER_0_ID, ARID_M0};
            ARADDR_M = ARADDR_M0;
            ARLEN_M = ARLEN_M0;
            ARSIZE_M = ARSIZE_M0;
            ARBURST_M = ARBURST_M0;
            ARVALID_M = ARVALID_M0;
            ARREADY_M0 = ARREADY_from_slave & ~lock_ARREADY_M0;
          end
          2'b01: begin  // M1
            ARID_M = {AXI_MASTER_1_ID, ARID_M1};
            ARADDR_M = ARADDR_M1;
            ARLEN_M = ARLEN_M1;
            ARSIZE_M = ARSIZE_M1;
            ARBURST_M = ARBURST_M1;
            ARVALID_M = ARVALID_M1;
            ARREADY_M1 = ARREADY_from_slave & ~lock_ARREADY_M1;
          end
          2'b10: begin  // M0
            ARID_M = {AXI_MASTER_0_ID, ARID_M0};
            ARADDR_M = ARADDR_M0;
            ARLEN_M = ARLEN_M0;
            ARSIZE_M = ARSIZE_M0;
            ARBURST_M = ARBURST_M0;
            ARVALID_M = ARVALID_M0;
            ARREADY_M0 = ARREADY_from_slave & ~lock_ARREADY_M0;
          end
          default: ;
        endcase
      end
    endcase
  end

  // Decoder
  assign decode_result = ADDR_DECODER(ARADDR_M);
  always_comb begin
    // Default 
    {ARID_S0, ARID_S1, ARID_S2, ARID_S3, ARID_S4, ARID_S5, ARID_S6} = {
      `AXI_IDS_BITS'b0,
      `AXI_IDS_BITS'b0,
      `AXI_IDS_BITS'b0,
      `AXI_IDS_BITS'b0,
      `AXI_IDS_BITS'b0,
      `AXI_IDS_BITS'b0,
      `AXI_IDS_BITS'b0
    };
    {ARADDR_S0, ARADDR_S1, ARADDR_S2, ARADDR_S3, ARADDR_S4, ARADDR_S5, ARADDR_S6} = {
      `AXI_ADDR_BITS'b0,
      `AXI_ADDR_BITS'b0,
      `AXI_ADDR_BITS'b0,
      `AXI_ADDR_BITS'b0,
      `AXI_ADDR_BITS'b0,
      `AXI_ADDR_BITS'b0,
      `AXI_ADDR_BITS'b0
    };
    {ARLEN_S0, ARLEN_S1, ARLEN_S2, ARLEN_S3, ARLEN_S4, ARLEN_S5, ARLEN_S6} = {
      `AXI_LEN_BITS'b0,
      `AXI_LEN_BITS'b0,
      `AXI_LEN_BITS'b0,
      `AXI_LEN_BITS'b0,
      `AXI_LEN_BITS'b0,
      `AXI_LEN_BITS'b0,
      `AXI_LEN_BITS'b0
    };
    {ARSIZE_S0, ARSIZE_S1, ARSIZE_S2, ARSIZE_S3, ARSIZE_S4, ARSIZE_S5, ARSIZE_S6} = {
      `AXI_SIZE_BITS'b0,
      `AXI_SIZE_BITS'b0,
      `AXI_SIZE_BITS'b0,
      `AXI_SIZE_BITS'b0,
      `AXI_SIZE_BITS'b0,
      `AXI_SIZE_BITS'b0,
      `AXI_SIZE_BITS'b0
    };
    {ARBURST_S0, ARBURST_S1, ARBURST_S2, ARBURST_S3, ARBURST_S4, ARBURST_S5, ARBURST_S6} = {
      2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0, 2'b0
    };
    {ARVALID_S0, ARVALID_S1, ARVALID_S2, ARVALID_S3, ARVALID_S4, ARVALID_S5, ARVALID_S6} = {
      1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    };
    unique case (1'b1)
      decode_result[SLAVE_0_BIT]: begin
        ARID_S0 = ARID_M;
        ARADDR_S0 = ARADDR_M;
        ARLEN_S0 = ARLEN_M;
        ARSIZE_S0 = ARSIZE_M;
        ARBURST_S0 = ARBURST_M;
        ARVALID_S0 = ARVALID_M & ~lock_ARVALID_S0;
      end
      decode_result[SLAVE_1_BIT]: begin
        ARID_S1 = ARID_M;
        ARADDR_S1 = ARADDR_M;
        ARLEN_S1 = ARLEN_M;
        ARSIZE_S1 = ARSIZE_M;
        ARBURST_S1 = ARBURST_M;
        ARVALID_S1 = ARVALID_M & ~lock_ARVALID_S1;
      end
      decode_result[SLAVE_2_BIT]: begin
        ARID_S2 = ARID_M;
        ARADDR_S2 = ARADDR_M;
        ARLEN_S2 = ARLEN_M;
        ARSIZE_S2 = ARSIZE_M;
        ARBURST_S2 = ARBURST_M;
        ARVALID_S2 = ARVALID_M & ~lock_ARVALID_S2;
      end
      decode_result[SLAVE_3_BIT]: begin
        ARID_S3 = ARID_M;
        ARADDR_S3 = ARADDR_M;
        ARLEN_S3 = ARLEN_M;
        ARSIZE_S3 = ARSIZE_M;
        ARBURST_S3 = ARBURST_M;
        ARVALID_S3 = ARVALID_M & ~lock_ARVALID_S3;
      end
      decode_result[SLAVE_4_BIT]: begin
        ARID_S4 = ARID_M;
        ARADDR_S4 = ARADDR_M;
        ARLEN_S4 = ARLEN_M;
        ARSIZE_S4 = ARSIZE_M;
        ARBURST_S4 = ARBURST_M;
        ARVALID_S4 = ARVALID_M & ~lock_ARVALID_S4;
      end
      decode_result[SLAVE_5_BIT]: begin
        ARID_S5 = ARID_M;
        ARADDR_S5 = ARADDR_M;
        ARLEN_S5 = ARLEN_M;
        ARSIZE_S5 = ARSIZE_M;
        ARBURST_S5 = ARBURST_M;
        ARVALID_S5 = ARVALID_M & ~lock_ARVALID_S5;
      end
      decode_result[SLAVE_6_BIT]: begin
        ARID_S6 = ARID_M;
        ARADDR_S6 = ARADDR_M;
        ARLEN_S6 = ARLEN_M;
        ARSIZE_S6 = ARSIZE_M;
        ARBURST_S6 = ARBURST_M;
        ARVALID_S6 = ARVALID_M & ~lock_ARVALID_S6;
      end
    endcase
  end  // always_comb

  // Decoder
  always_comb begin
    ARREADY_from_slave = 1'b0;
    unique case (1'b1)
      decode_result[SLAVE_0_BIT]: ARREADY_from_slave = ARREADY_S0;
      decode_result[SLAVE_1_BIT]: ARREADY_from_slave = ARREADY_S1;
      decode_result[SLAVE_2_BIT]: ARREADY_from_slave = ARREADY_S2;
      decode_result[SLAVE_3_BIT]: ARREADY_from_slave = ARREADY_S3;
      decode_result[SLAVE_4_BIT]: ARREADY_from_slave = ARREADY_S4;
      decode_result[SLAVE_5_BIT]: ARREADY_from_slave = ARREADY_S5;
      decode_result[SLAVE_6_BIT]: ARREADY_from_slave = ARREADY_S6;
    endcase
  end  // always_comb

endmodule
