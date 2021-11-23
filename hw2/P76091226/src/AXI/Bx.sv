`include "AXI_define.svh"

module Bx
  import axi_pkg::*;
(
    input  logic                     clk,
    input  logic                     rstn,
    // Master 1
    output logic [ `AXI_ID_BITS-1:0] BID_M1,
    output logic [              1:0] BRESP_M1,
    output logic                     BVALID_M1,
    input  logic                     BREADY_M1,
    input  logic                     WVALID_M1,
    input  logic                     WREADY_M1,
    input  logic                     WLAST_M1,
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
  logic                     Bx_enable;

  data_arb_lock_t data_arb_lock, data_arb_lock_next;
  axi_master_id_t decode_result;

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      data_arb_lock <= LOCK_NO;
    end else begin
      data_arb_lock <= data_arb_lock_next;
    end
  end  // State

  // Bx_enable signal is 1'b1 only after Wx is done 
  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) Bx_enable <= 1'b0;
    else
      Bx_enable <= (Bx_enable) ? (BVALID_S0|BVALID_S1|BVALID_S2) ? 1'b0 : Bx_enable : (WVALID_M1 & WREADY_M1 & WLAST_M1) ? 1'b1 :Bx_enable;
  end

  always_comb begin
    data_arb_lock_next = LOCK_NO;
    unique case (1'b1)
      data_arb_lock[LOCK_S0_BIT]:
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : LOCK_NO : LOCK_S0;
      data_arb_lock[LOCK_S1_BIT]:
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S2) ? LOCK_S2 : (BVALID_S0) ? LOCK_S0 : LOCK_NO : LOCK_S1;
      data_arb_lock[LOCK_S2_BIT]:
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : LOCK_NO : LOCK_S2;
      data_arb_lock[LOCK_NO_BIT]: begin
        if (Bx_enable) begin
          if (BVALID_S0)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S0;
          else if (BVALID_S1)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S1;
          else if (BVALID_S2)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S2;
        end else begin
          data_arb_lock_next = LOCK_NO;
        end
      end
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    // Default
    BVALID_S = 1'b0;
    BID_S = `AXI_IDS_BITS'b0;
    BRESP_S = `AXI_RESP_SLVERR;
    {BREADY_S0, BREADY_S1, BREADY_S2} = {1'b0, 1'b0, 1'b0};

    unique case (1'b1)
      data_arb_lock[LOCK_S0_BIT]: begin
        BVALID_S = BVALID_S0;
        BID_S = BID_S0;
        BRESP_S = BRESP_S0;
        BREADY_S0 = BREADY_from_master;
      end
      data_arb_lock[LOCK_S1_BIT]: begin
        BVALID_S = BVALID_S1;
        BID_S = BID_S1;
        BRESP_S = BRESP_S1;
        BREADY_S1 = BREADY_from_master;
      end
      data_arb_lock[LOCK_S2_BIT]: begin
        BVALID_S = BVALID_S2;
        BID_S = BID_S2;
        BRESP_S = BRESP_S2;
        BREADY_S2 = BREADY_from_master;
      end
      data_arb_lock[LOCK_NO_BIT]: ;
    endcase
  end

  // Decoder
  assign decode_result = DATA_DECODER(BID_S);
  always_comb begin
    BID_M1 = `AXI_ID_BITS'b0;
    BRESP_M1 = `AXI_RESP_SLVERR;
    BVALID_M1 = 1'b0;
    BREADY_from_master = 1'b0;

    unique case (1'b1)
      decode_result[AXI_M0_BIT]: ;
      decode_result[AXI_M1_BIT]: begin
        BID_M1 = BID_S[`AXI_ID_BITS-1:0];
        BRESP_M1 = BRESP_S;
        BVALID_M1 = BVALID_S;
        BREADY_from_master = BREADY_M1;
      end
      decode_result[AXI_M2_BIT]: ;
    endcase
  end

endmodule
