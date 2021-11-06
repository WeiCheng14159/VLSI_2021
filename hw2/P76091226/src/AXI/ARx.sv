`include "AXI_define.svh"

module ARx
  import axi_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    // Master0 interface
    input  logic [  `AXI_ID_BITS-1:0] ID_M0,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR_M0,
    input  logic [ `AXI_LEN_BITS-1:0] LEN_M0,
    input  logic [`AXI_SIZE_BITS-1:0] SIZE_M0,
    input  logic [               1:0] BURST_M0,
    input  logic                      VALID_M0,
    output logic                      READY_M0,
    // Master1_interface
    input  logic [  `AXI_ID_BITS-1:0] ID_M1,
    input  logic [`AXI_ADDR_BITS-1:0] ADDR_M1,
    input  logic [ `AXI_LEN_BITS-1:0] LEN_M1,
    input  logic [`AXI_SIZE_BITS-1:0] SIZE_M1,
    input  logic [               1:0] BURST_M1,
    input  logic                      VALID_M1,
    output logic                      READY_M1,
    // Slave0 resp
    input  logic                      READY_S0,
    input  logic                      READY_S1,
    input  logic                      READY_S2,
    // Slave0
    output logic [ `AXI_IDS_BITS-1:0] ID_S0,
    output logic [`AXI_ADDR_BITS-1:0] ADDR_S0,
    output logic [ `AXI_LEN_BITS-1:0] LEN_S0,
    output logic [`AXI_SIZE_BITS-1:0] SIZE_S0,
    output logic [               1:0] BURST_S0,
    output logic                      VALID_S0,
    // Slave1
    output logic [ `AXI_IDS_BITS-1:0] ID_S1,
    output logic [`AXI_ADDR_BITS-1:0] ADDR_S1,
    output logic [ `AXI_LEN_BITS-1:0] LEN_S1,
    output logic [`AXI_SIZE_BITS-1:0] SIZE_S1,
    output logic [               1:0] BURST_S1,
    output logic                      VALID_S1,
    // Default Slave
    output logic [ `AXI_IDS_BITS-1:0] ID_S2,
    output logic [`AXI_ADDR_BITS-1:0] ADDR_S2,
    output logic [ `AXI_LEN_BITS-1:0] LEN_S2,
    output logic [`AXI_SIZE_BITS-1:0] SIZE_S2,
    output logic [               1:0] BURST_S2,
    output logic                      VALID_S2
);

  logic [ `AXI_IDS_BITS-1:0] ID_M;
  logic [`AXI_ADDR_BITS-1:0] ADDR_M;
  logic [ `AXI_LEN_BITS-1:0] LEN_M;
  logic [`AXI_SIZE_BITS-1:0] SIZE_M;
  logic [               1:0] BURST_M;
  logic                      VALID_M;
  logic                      READY_from_slave;

  logic [ `AXI_IDS_BITS-1:0] ID_M_r;
  logic [`AXI_ADDR_BITS-1:0] ADDR_M_r;
  logic [ `AXI_LEN_BITS-1:0] LEN_M_r;
  logic [`AXI_SIZE_BITS-1:0] SIZE_M_r;
  logic [               1:0] BURST_M_r;

  logic                      fast_transaction;
  logic                      slow_transaction;

  addr_arb_lock_t addr_arb_lock, addr_arb_lock_next;

  always_ff @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      addr_arb_lock <= LOCK_FREE;
    end else begin
      addr_arb_lock <= addr_arb_lock_next;
    end
  end  // State

  // Next state logic
  always_comb begin
    addr_arb_lock_next = LOCK_FREE;
    unique case (addr_arb_lock)
      LOCK_M0:
      addr_arb_lock_next = (READY_from_slave) ? (VALID_M1) ? LOCK_M1 : LOCK_FREE : LOCK_M0;
      LOCK_M1:
      addr_arb_lock_next = (READY_from_slave) ? (VALID_M0) ? LOCK_M0 : LOCK_FREE : LOCK_M1;
      LOCK_M2: ;
      LOCK_FREE: begin
        case ({
          VALID_M0, VALID_M1
        })
          2'b11:
          addr_arb_lock_next = (READY_from_slave) ? LOCK_FREE : LOCK_M0;  // M0 has higher priority
          2'b01: addr_arb_lock_next = (READY_from_slave) ? LOCK_FREE : LOCK_M1;
          2'b10: addr_arb_lock_next = (READY_from_slave) ? LOCK_FREE : LOCK_M0;
          default: addr_arb_lock_next = LOCK_FREE;
        endcase
      end
      default: ;
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    // Default
    ID_M = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
    ADDR_M = 0;
    LEN_M = 0;
    SIZE_M = 0;
    BURST_M = 0;
    VALID_M = 0;
    {READY_M0, READY_M1} = {1'b0, 1'b0};

    unique case (addr_arb_lock)
      LOCK_M0: begin
        ID_M = {AXI_MASTER_0_ID, ID_M0};
        ADDR_M = ADDR_M0;
        LEN_M = LEN_M0;
        SIZE_M = SIZE_M0;
        BURST_M = BURST_M0;
        VALID_M = 1'b1;  // Valid should hold
        {READY_M0, READY_M1} = {READY_from_slave, 1'b0};
      end
      LOCK_M1: begin
        ID_M = {AXI_MASTER_1_ID, ID_M1};
        ADDR_M = ADDR_M1;
        LEN_M = LEN_M1;
        SIZE_M = SIZE_M1;
        BURST_M = BURST_M1;
        VALID_M = 1'b1;  // Valid should hold
        {READY_M0, READY_M1} = {1'b0, READY_from_slave};
      end
      LOCK_M2: begin
        ID_M = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
        ADDR_M = 0;
        LEN_M = 0;
        SIZE_M = 0;
        BURST_M = 0;
        VALID_M = 1'b1;  // Valid should hold
        {READY_M0, READY_M1} = {1'b0, 1'b0};
      end
      LOCK_FREE: begin
        case ({
          VALID_M0, VALID_M1
        })
          2'b11: begin  // M0 has higher priority
            ID_M = {AXI_MASTER_0_ID, ID_M0};
            ADDR_M = ADDR_M0;
            LEN_M = LEN_M0;
            SIZE_M = SIZE_M0;
            BURST_M = BURST_M0;
            VALID_M = VALID_M0;
            {READY_M0, READY_M1} = {READY_from_slave, 1'b0};
          end
          2'b01: begin  // M1
            ID_M = {AXI_MASTER_1_ID, ID_M1};
            ADDR_M = ADDR_M1;
            LEN_M = LEN_M1;
            SIZE_M = SIZE_M1;
            BURST_M = BURST_M1;
            VALID_M = VALID_M1;
            {READY_M0, READY_M1} = {1'b0, READY_from_slave};
          end
          2'b10: begin  // M0
            ID_M = {AXI_MASTER_0_ID, ID_M0};
            ADDR_M = ADDR_M0;
            LEN_M = LEN_M0;
            SIZE_M = SIZE_M0;
            BURST_M = BURST_M0;
            VALID_M = VALID_M0;
            {READY_M0, READY_M1} = {READY_from_slave, 1'b0};
          end
          default: ;
        endcase
      end
    endcase
  end

  // Latch data at the first rising edge after VALID_Mx is asserted
  always_ff @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      ID_M_r <= {`AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0};
      ADDR_M_r <= 0;
      LEN_M_r <= 0;
      SIZE_M_r <= 0;
      BURST_M_r <= 0;
    end else if (addr_arb_lock == LOCK_FREE && addr_arb_lock_next == LOCK_M0) begin
      ID_M_r <= {AXI_MASTER_0_ID, ID_M0};
      ADDR_M_r <= ADDR_M0;
      LEN_M_r <= LEN_M0;
      SIZE_M_r <= SIZE_M0;
      BURST_M_r <= BURST_M0;
    end else if (addr_arb_lock == LOCK_FREE && addr_arb_lock_next == LOCK_M1) begin
      ID_M_r <= {AXI_MASTER_1_ID, ID_M1};
      ADDR_M_r <= ADDR_M1;
      LEN_M_r <= LEN_M1;
      SIZE_M_r <= SIZE_M1;
      BURST_M_r <= BURST_M1;
    end
  end

  // Decoder
  assign fast_transaction = (addr_arb_lock == LOCK_FREE && (VALID_M0 || VALID_M1));
  assign slow_transaction = (addr_arb_lock == LOCK_M0 || addr_arb_lock == LOCK_M1);

  always_comb begin
    // Default 
    {ID_S0, ID_S1, ID_S2} = {
      `AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0
    };
    {ADDR_S0, ADDR_S1, ADDR_S2} = {
      `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0
    };
    {LEN_S0, LEN_S1, LEN_S2} = {
      `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0
    };
    {SIZE_S0, SIZE_S1, SIZE_S2} = {
      `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0
    };
    {BURST_S0, BURST_S1, BURST_S2} = {2'b0, 2'b0, 2'b0};
    {VALID_S0, VALID_S1, VALID_S2} = {1'b0, 1'b0, 1'b0};
    READY_from_slave = 1'b0;

    if (fast_transaction) begin
      unique case (ADDR_DECODER(
          ADDR_M
      ))
        SLAVE_0: begin
          {ID_S0, ID_S1, ID_S2} = {ID_M, `AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0};
          {ADDR_S0, ADDR_S1, ADDR_S2} = {
            ADDR_M, `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0
          };
          {LEN_S0, LEN_S1, LEN_S2} = {
            LEN_M, `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0
          };
          {SIZE_S0, SIZE_S1, SIZE_S2} = {
            SIZE_M, `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0
          };
          {BURST_S0, BURST_S1, BURST_S2} = {BURST_M, 2'b0, 2'b0};
          {VALID_S0, VALID_S1, VALID_S2} = {VALID_M, 1'b0, 1'b0};
          READY_from_slave = READY_S0;
        end
        SLAVE_1: begin
          {ID_S0, ID_S1, ID_S2} = {`AXI_IDS_BITS'b0, ID_M, `AXI_IDS_BITS'b0};
          {ADDR_S0, ADDR_S1, ADDR_S2} = {
            `AXI_ADDR_BITS'b0, ADDR_M, `AXI_ADDR_BITS'b0
          };
          {LEN_S0, LEN_S1, LEN_S2} = {
            `AXI_LEN_BITS'b0, LEN_M, `AXI_LEN_BITS'b0
          };
          {SIZE_S0, SIZE_S1, SIZE_S2} = {
            `AXI_SIZE_BITS'b0, SIZE_M, `AXI_SIZE_BITS'b0
          };
          {BURST_S0, BURST_S1, BURST_S2} = {2'b0, BURST_M, 2'b0};
          {VALID_S0, VALID_S1, VALID_S2} = {1'b0, VALID_M, 1'b0};
          READY_from_slave = READY_S1;
        end
        SLAVE_2: begin
          {ID_S0, ID_S1, ID_S2} = {`AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0, ID_M};
          {ADDR_S0, ADDR_S1, ADDR_S2} = {
            `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0, ADDR_M
          };
          {LEN_S0, LEN_S1, LEN_S2} = {
            `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0, LEN_M
          };
          {SIZE_S0, SIZE_S1, SIZE_S2} = {
            `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0, SIZE_M
          };
          {BURST_S0, BURST_S1, BURST_S2} = {2'b0, 2'b0, BURST_M};
          {VALID_S0, VALID_S1, VALID_S2} = {1'b0, 1'b0, VALID_M};
          READY_from_slave = READY_S2;
        end
        LOCK_NO: ;
      endcase
    end else if (slow_transaction) begin  // Use latched value
      unique case (ADDR_DECODER(
          ADDR_M_r
      ))
        SLAVE_0: begin
          {ID_S0, ID_S1, ID_S2} = {ID_M_r, `AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0};
          {ADDR_S0, ADDR_S1, ADDR_S2} = {
            ADDR_M_r, `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0
          };
          {LEN_S0, LEN_S1, LEN_S2} = {
            LEN_M_r, `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0
          };
          {SIZE_S0, SIZE_S1, SIZE_S2} = {
            SIZE_M_r, `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0
          };
          {BURST_S0, BURST_S1, BURST_S2} = {BURST_M_r, 2'b0, 2'b0};
          {VALID_S0, VALID_S1, VALID_S2} = {1'b1, 1'b0, 1'b0};
          READY_from_slave = READY_S0;
        end
        SLAVE_1: begin
          {ID_S0, ID_S1, ID_S2} = {`AXI_IDS_BITS'b0, ID_M_r, `AXI_IDS_BITS'b0};
          {ADDR_S0, ADDR_S1, ADDR_S2} = {
            `AXI_ADDR_BITS'b0, ADDR_M_r, `AXI_ADDR_BITS'b0
          };
          {LEN_S0, LEN_S1, LEN_S2} = {
            `AXI_LEN_BITS'b0, LEN_M_r, `AXI_LEN_BITS'b0
          };
          {SIZE_S0, SIZE_S1, SIZE_S2} = {
            `AXI_SIZE_BITS'b0, SIZE_M_r, `AXI_SIZE_BITS'b0
          };
          {BURST_S0, BURST_S1, BURST_S2} = {2'b0, BURST_M_r, 2'b0};
          {VALID_S0, VALID_S1, VALID_S2} = {1'b0, 1'b1, 1'b0};
          READY_from_slave = READY_S1;
        end
        SLAVE_2: begin
          {ID_S0, ID_S1, ID_S2} = {`AXI_IDS_BITS'b0, `AXI_IDS_BITS'b0, ID_M_r};
          {ADDR_S0, ADDR_S1, ADDR_S2} = {
            `AXI_ADDR_BITS'b0, `AXI_ADDR_BITS'b0, ADDR_M_r
          };
          {LEN_S0, LEN_S1, LEN_S2} = {
            `AXI_LEN_BITS'b0, `AXI_LEN_BITS'b0, LEN_M_r
          };
          {SIZE_S0, SIZE_S1, SIZE_S2} = {
            `AXI_SIZE_BITS'b0, `AXI_SIZE_BITS'b0, SIZE_M_r
          };
          {BURST_S0, BURST_S1, BURST_S2} = {2'b0, 2'b0, BURST_M_r};
          {VALID_S0, VALID_S1, VALID_S2} = {1'b0, 1'b0, 1'b1};
          READY_from_slave = READY_S2;
        end
        LOCK_NO: ;
      endcase
    end
  end  // always_comb

endmodule
