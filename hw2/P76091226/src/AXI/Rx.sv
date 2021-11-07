`include "AXI_define.svh"

module Rx
  import axi_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    // Master 0 
    output logic [  `AXI_ID_BITS-1:0] RID_M0,
    output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
    output logic [               1:0] RRESP_M0,
    output logic                      RLAST_M0,
    output logic                      RVALID_M0,
    input  logic                      RREADY_M0,
    // Master 1
    output logic [  `AXI_ID_BITS-1:0] RID_M1,
    output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
    output logic [               1:0] RRESP_M1,
    output logic                      RLAST_M1,
    output logic                      RVALID_M1,
    input  logic                      RREADY_M1,
    // Slave 0
    input  logic [ `AXI_IDS_BITS-1:0] RID_S0,
    input  logic [`AXI_DATA_BITS-1:0] RDATA_S0,
    input  logic [               1:0] RRESP_S0,
    input  logic                      RLAST_S0,
    input  logic                      RVALID_S0,
    output logic                      RREADY_S0,
    // Slave 1
    input  logic [ `AXI_IDS_BITS-1:0] RID_S1,
    input  logic [`AXI_DATA_BITS-1:0] RDATA_S1,
    input  logic [               1:0] RRESP_S1,
    input  logic                      RLAST_S1,
    input  logic                      RVALID_S1,
    output logic                      RREADY_S1,
    // Slave 2
    input  logic [ `AXI_IDS_BITS-1:0] RID_S2,
    input  logic [`AXI_DATA_BITS-1:0] RDATA_S2,
    input  logic [               1:0] RRESP_S2,
    input  logic                      RLAST_S2,
    input  logic                      RVALID_S2,
    output logic                      RREADY_S2
);

  logic [ `AXI_IDS_BITS-1:0] RID_S;
  logic [`AXI_DATA_BITS-1:0] RDATA_S;
  logic [               1:0] RRESP_S;
  logic                      RLAST_S;
  logic                      RVALID_S;

  logic [ `AXI_IDS_BITS-1:0] RID_S_r;
  logic [`AXI_DATA_BITS-1:0] RDATA_S_r;
  logic [               1:0] RRESP_S_r;
  logic                      RLAST_S_r;

  logic                      READY_from_master;

  logic                      fast_transaction;
  logic                      slow_transaction;

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
      data_arb_lock_next = (READY_from_master) ? (RVALID_S1) ? LOCK_S1 : (RVALID_S2) ? LOCK_S2 : LOCK_NO : LOCK_S0;
      LOCK_S1:
      data_arb_lock_next = (READY_from_master) ? (RVALID_S2) ? LOCK_S2 : (RVALID_S0) ? LOCK_S0 : LOCK_NO : LOCK_S1;
      LOCK_S2:
      data_arb_lock_next = (READY_from_master) ? (RVALID_S0) ? LOCK_S0 : (RVALID_S1) ? LOCK_S1 : LOCK_NO : LOCK_S2;
      LOCK_NO: begin
        if (RVALID_S0) data_arb_lock_next =  (READY_from_master) ? LOCK_NO : LOCK_S0;
        else if (RVALID_S1) data_arb_lock_next = (READY_from_master) ? LOCK_NO :LOCK_S1;
        else if (RVALID_S2) data_arb_lock_next = (READY_from_master) ? LOCK_NO :LOCK_S2;
        else data_arb_lock_next = LOCK_NO;
      end
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    // Default 
    RID_S = 0;
    RDATA_S = 0;
    RRESP_S = 0;
    RLAST_S = 0;
    RVALID_S = 0;
    {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, 1'b0};

    unique case (data_arb_lock)
      LOCK_S0: begin
        RID_S = RID_S0;
        RDATA_S = RDATA_S0;
        RRESP_S = RRESP_S0;
        RLAST_S = RLAST_S0;
        RVALID_S = 1'b1;  // Valid should hold
        {RREADY_S0, RREADY_S1, RREADY_S2} = {READY_from_master, 1'b0, 1'b0};
      end
      LOCK_S1: begin
        RID_S = RID_S1;
        RDATA_S = RDATA_S1;
        RRESP_S = RRESP_S1;
        RLAST_S = RLAST_S1;
        RVALID_S = 1'b1;  // Valid should hold
        {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, READY_from_master, 1'b0};
      end
      LOCK_S2: begin
        RID_S = RID_S2;
        RDATA_S = RDATA_S2;
        RRESP_S = RRESP_S2;
        RLAST_S = RLAST_S2;
        RVALID_S = 1'b1;  // Valid should hold
        {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, READY_from_master};
      end
      LOCK_NO: begin
        if (RVALID_S0) begin  // S0 has higher priority
          RID_S = RID_S0;
          RDATA_S = RDATA_S0;
          RRESP_S = RRESP_S0;
          RLAST_S = RLAST_S0;
          RVALID_S = RVALID_S0;
          {RREADY_S0, RREADY_S1, RREADY_S2} = {READY_from_master, 1'b0, 1'b0};
        end else if (RVALID_S1) begin
          RID_S = RID_S1;
          RDATA_S = RDATA_S1;
          RRESP_S = RRESP_S1;
          RLAST_S = RLAST_S1;
          RVALID_S = RVALID_S1;
          {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, READY_from_master, 1'b0};
        end else if (RVALID_S2) begin
          RID_S = RID_S2;
          RDATA_S = RDATA_S2;
          RRESP_S = RRESP_S2;
          RLAST_S = RLAST_S2;
          RVALID_S = RVALID_S2;
          {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, READY_from_master};
        end else begin
          // Nothing
        end
      end
    endcase
  end

  // Latch data at the first rising edge after RVALID_Sx is asserted
  always_ff @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      RID_S_r   <= 0;
      RDATA_S_r <= 0;
      RRESP_S_r <= 0;
      RLAST_S_r <= 0;
    end else if (data_arb_lock != LOCK_S0 && data_arb_lock_next == LOCK_S0) begin
      RID_S_r   <= RID_S0;
      RDATA_S_r <= RDATA_S0;
      RRESP_S_r <= RRESP_S0;
      RLAST_S_r <= RLAST_S0;
    end else if (data_arb_lock != LOCK_S1 && data_arb_lock_next == LOCK_S1) begin
      RID_S_r   <= RID_S1;
      RDATA_S_r <= RDATA_S1;
      RRESP_S_r <= RRESP_S1;
      RLAST_S_r <= RLAST_S1;
    end else if (data_arb_lock != LOCK_S2 && data_arb_lock_next == LOCK_S2) begin
      RID_S_r   <= RID_S2;
      RDATA_S_r <= RDATA_S2;
      RRESP_S_r <= RRESP_S2;
      RLAST_S_r <= RLAST_S2;
    end
  end

  // Decoder
  assign fast_transaction = (data_arb_lock == LOCK_NO & (RVALID_S0 | RVALID_S1 | RVALID_S2));
  assign slow_transaction = (data_arb_lock == LOCK_S0 | data_arb_lock == LOCK_S1 | data_arb_lock == LOCK_S2);

  always_comb begin
    // Default
    {RID_M0, RID_M1} = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
    {RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
    {RRESP_M0, RRESP_M1} = {2'b0, 2'b0};
    {RLAST_M0, RLAST_M1} = {1'b0, 1'b0};
    {RVALID_M0, RVALID_M1} = {1'b0, 1'b0};
    READY_from_master = 1'b0;

    if (fast_transaction) begin
      unique case (DATA_DECODER(
          RID_S
      ))
        AXI_MASTER_0_ID: begin
          {RID_M0, RID_M1} = {RID_S[`AXI_ID_BITS-1:0], `AXI_ID_BITS'b0};
          {RDATA_M0, RDATA_M1} = {RDATA_S, `AXI_DATA_BITS'b0};
          {RRESP_M0, RRESP_M1} = {RRESP_S, 2'b0};
          {RLAST_M0, RLAST_M1} = {RLAST_S, 1'b0};
          {RVALID_M0, RVALID_M1} = {RVALID_S, 1'b0};
          READY_from_master = RREADY_M0;
        end
        AXI_MASTER_1_ID: begin
          {RID_M0, RID_M1} = {`AXI_ID_BITS'b0, RID_S[`AXI_ID_BITS-1:0]};
          {RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, RDATA_S};
          {RRESP_M0, RRESP_M1} = {2'b0, RRESP_S};
          {RLAST_M0, RLAST_M1} = {1'b0, RLAST_S};
          {RVALID_M0, RVALID_M1} = {1'b0, RVALID_S};
          READY_from_master = RREADY_M1;
        end
        AXI_MASTER_2_ID: ;
        AXI_MASTER_U_ID: ;
      endcase
    end else if (slow_transaction) begin  // Use latched value
      unique case (DATA_DECODER(
          RID_S_r
      ))
        AXI_MASTER_0_ID: begin
          {RID_M0, RID_M1} = {RID_S_r[`AXI_ID_BITS-1:0], `AXI_ID_BITS'b0};
          {RDATA_M0, RDATA_M1} = {RDATA_S_r, `AXI_DATA_BITS'b0};
          {RRESP_M0, RRESP_M1} = {RRESP_S_r, 2'b0};
          {RLAST_M0, RLAST_M1} = {RLAST_S_r, 1'b0};
          {RVALID_M0, RVALID_M1} = {1'b1, 1'b0};
          READY_from_master = RREADY_M0;
        end
        AXI_MASTER_1_ID: begin
          {RID_M0, RID_M1} = {`AXI_ID_BITS'b0, RID_S_r[`AXI_ID_BITS-1:0]};
          {RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, RDATA_S_r};
          {RRESP_M0, RRESP_M1} = {2'b0, RRESP_S_r};
          {RLAST_M0, RLAST_M1} = {1'b0, RLAST_S_r};
          {RVALID_M0, RVALID_M1} = {1'b0, 1'b1};
          READY_from_master = RREADY_M1;
        end
        AXI_MASTER_2_ID: ;
        AXI_MASTER_U_ID: ;
      endcase
    end
  end  // always_comb

endmodule
