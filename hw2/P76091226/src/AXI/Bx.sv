`include "AXI_define.svh"

module Bx
  import axi_pkg::*;
(
    input  logic                     clk,
    input  logic                     rstn,
    // Master 0
    output logic [ `AXI_ID_BITS-1:0] BID_M1,
    output logic [              1:0] BRESP_M1,
    output logic                     BVALID_M1,
    input  logic                     BREADY_M1,
    // Slave 0
    input  logic [`AXI_IDS_BITS-1:0] BID_S0,
    input  logic [              1:0] BRESP_S0,
    input  logic                     BVALID_S0,
    output logic                     BREADY_S0,
    // Slave 1
    input  logic [`AXI_IDS_BITS-1:0] BID_S1,
    input  logic [              1:0] BRESP_S1,
    input  logic                     BVALID_S1,
    output logic                     BREADY_S1,
    // Slave 2
    input  logic [`AXI_IDS_BITS-1:0] BID_S2,
    input  logic [              1:0] BRESP_S2,
    input  logic                     BVALID_S2,
    output logic                     BREADY_S2
);

  logic [`AXI_IDS_BITS-1:0] BID_S;
  logic [              1:0] BRESP_S;
  logic                     BVALID_S;

  logic [`AXI_IDS_BITS-2:0] BID_S_r;
  logic [              0:0] BRESP_S_r;

  logic                     BREADY_from_master;

  logic                     fast_transaction;
  logic                     slow_transaction;

  data_arb_lock_t data_arb_lock, data_arb_lock_next;

  always_ff @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      data_arb_lock <= LOCK_NO;
    end else begin
      data_arb_lock <= data_arb_lock_next;
    end
  end  // State

  always_comb begin
    data_arb_lock_next = LOCK_NO;
    unique case (data_arb_lock)
      LOCK_S0:
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : LOCK_NO : LOCK_S0;
      LOCK_S1:
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S2) ? LOCK_S2 : (BVALID_S0) ? LOCK_S0 : LOCK_NO : LOCK_S1;
      LOCK_S2:
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : LOCK_NO : LOCK_S2;
      LOCK_NO: begin
        if (BVALID_S0) data_arb_lock_next = LOCK_S0;
        else if (BVALID_S1) data_arb_lock_next = LOCK_S1;
        else if (BVALID_S2) data_arb_lock_next = LOCK_S2;
        else data_arb_lock_next = LOCK_NO;
      end
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    // Default
    BVALID_S = 1'b0;
    {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, 1'b0};

    unique case (data_arb_lock)
      LOCK_S0: begin
        BVALID_S = 1'b1; // Value should hold
        {BREADY_S0, BREADY_S1, BREADY_S2} = {BREADY_from_master, 1'b0, 1'b0};
      end
      LOCK_S1: begin
        BVALID_S = 1'b1; // Value should hold
        {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, BREADY_from_master, 1'b0};
      end
      LOCK_S2: begin
        BVALID_S = 1'b1; // Value should hold
        {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, BREADY_from_master};
      end
      LOCK_NO: begin
        if (BVALID_S0) begin
          BVALID_S = BVALID_S0;
          {BREADY_S0, BREADY_S1, BREADY_S2} = {BREADY_from_master, 1'b0, 1'b0};
        end else if (BVALID_S1) begin
          BVALID_S = BVALID_S1;
          {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, BREADY_from_master, 1'b0};
        end else if (BVALID_S2) begin
          BVALID_S = BVALID_S2;
          {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, BREADY_from_master};
        end else begin
          // Nothing
        end
      end
    endcase
  end

  // Latch data at the first rising edge after BVALID_Sx is asserted
  always_ff @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      BID_S_r   <= 0;
      BRESP_S_r <= 0;
    end else if (data_arb_lock == LOCK_NO && data_arb_lock_next == LOCK_S0) begin
      BID_S_r   <= BID_S0;
      BRESP_S_r <= BRESP_S0;
    end else if (data_arb_lock == LOCK_NO && data_arb_lock_next == LOCK_S1) begin
      BID_S_r   <= BID_S1;
      BRESP_S_r <= BRESP_S1;
    end else if (data_arb_lock == LOCK_NO && data_arb_lock_next == LOCK_S2) begin
      BID_S_r   <= BID_S2;
      BRESP_S_r <= BRESP_S2;
    end
  end

  // Decoder
  always_comb begin
    // Default
    BID_M1 = `AXI_ID_BITS'b0;
    BRESP_M1 = 2'b0;
    BVALID_M1 = 1'b0;
    BREADY_from_master = BREADY_M1;

    if (fast_transaction) begin
      unique case (DATA_DECODER(
          BID_S
      ))
        MASTER_0: ;
        MASTER_1: begin
          BID_M1 = BID_S[`AXI_ID_BITS-1:0];
          BRESP_M1 = BRESP_S;
          BVALID_M1 = BVALID_S;
        end
        MASTER_2: ;
        MASTER_U: ;
      endcase
    end else if (slow_transaction) begin
      unique case (DATA_DECODER(
          BID_S_r
      ))
        MASTER_0: ;
        MASTER_1: begin
          BID_M1 = BID_S_r[`AXI_ID_BITS-1:0];
          BRESP_M1 = BRESP_S_r;
          BVALID_M1 = 1'b1;
        end
        MASTER_2: ;
        MASTER_U: ;
      endcase
    end
  end

endmodule
