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

  logic                     BREADY_from_master;

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
        if (BVALID_S0)
          data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S0;
        else if (BVALID_S1)
          data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S1;
        else if (BVALID_S2)
          data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S2;
        else data_arb_lock_next = LOCK_NO;
      end
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    // Default
    BVALID_S = 1'b0;
    BID_S = 0;
    BRESP_S = `AXI_RESP_SLVERR;
    {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, 1'b0};

    unique case (data_arb_lock)
      LOCK_S0: begin
        BVALID_S = BVALID_S0;
        BID_S = BID_S0;
        BRESP_S = BRESP_S0;
        {BREADY_S0, BREADY_S1, BREADY_S2} = {BREADY_from_master, 1'b0, 1'b0};
      end
      LOCK_S1: begin
        BVALID_S = BVALID_S1;
        BID_S = BID_S1;
        BRESP_S = BRESP_S1;
        {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, BREADY_from_master, 1'b0};
      end
      LOCK_S2: begin
        BVALID_S = BVALID_S2;
        BID_S = BID_S2;
        BRESP_S = BRESP_S2;
        {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, BREADY_from_master};
      end
      LOCK_NO: begin
        if (BVALID_S0) begin
          BVALID_S = BVALID_S0;
          BID_S = BID_S0;
          BRESP_S = BRESP_S0;
          {BREADY_S0, BREADY_S1, BREADY_S2} = {BREADY_from_master, 1'b0, 1'b0};
        end else if (BVALID_S1) begin
          BVALID_S = BVALID_S1;
          BID_S = BID_S1;
          BRESP_S = BRESP_S1;
          {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, BREADY_from_master, 1'b0};
        end else if (BVALID_S2) begin
          BVALID_S = BVALID_S2;
          BID_S = BID_S2;
          BRESP_S = BRESP_S2;
          {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, BREADY_from_master};
        end else begin
          // Nothing
        end
      end
    endcase
  end

  // Decoder
  axi_master_id_t decode_result;
  assign decode_result = DATA_DECODER(BID_S);
  always_comb begin
    // Default
    BID_M1 = `AXI_ID_BITS'b0;
    BRESP_M1 = `AXI_RESP_SLVERR;
    BVALID_M1 = 1'b0;
    BREADY_from_master = 1'b0;

    unique case (decode_result)
      AXI_MASTER_0_ID: ;
      AXI_MASTER_1_ID: begin
        BID_M1 = BID_S[`AXI_ID_BITS-1:0];
        BRESP_M1 = BRESP_S;
        BVALID_M1 = BVALID_S;
        BREADY_from_master = BREADY_M1;
      end
      AXI_MASTER_2_ID: ;
      AXI_MASTER_U_ID: ;
    endcase
  end

endmodule
