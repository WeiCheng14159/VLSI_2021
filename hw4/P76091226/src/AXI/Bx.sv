`include "pkg_include.sv"

module Bx
  import axi_pkg::*;
(
    input  logic                      clk,
    input  logic                      rstn,
    // Master 0
    output logic [  `AXI_ID_BITS-1:0] BID_M0,
    output logic [`AXI_RESP_BITS-1:0] BRESP_M0,
    output logic                      BVALID_M0,
    input  logic                      BREADY_M0,
    input  logic                      WVALID_M0,
    input  logic                      WREADY_M0,
    input  logic                      WLAST_M0,
    // Master 1
    output logic [  `AXI_ID_BITS-1:0] BID_M1,
    output logic [`AXI_RESP_BITS-1:0] BRESP_M1,
    output logic                      BVALID_M1,
    input  logic                      BREADY_M1,
    input  logic                      WVALID_M1,
    input  logic                      WREADY_M1,
    input  logic                      WLAST_M1,
    // Master 2
    output logic [  `AXI_ID_BITS-1:0] BID_M2,
    output logic [`AXI_RESP_BITS-1:0] BRESP_M2,
    output logic                      BVALID_M2,
    input  logic                      BREADY_M2,
    input  logic                      WVALID_M2,
    input  logic                      WREADY_M2,
    input  logic                      WLAST_M2,
    // Slave 0
    input  logic [ `AXI_IDS_BITS-1:0] BID_S0,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S0,
    input  logic                      BVALID_S0,
    output logic                      BREADY_S0,
    // Slave 1
    input  logic [ `AXI_IDS_BITS-1:0] BID_S1,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S1,
    input  logic                      BVALID_S1,
    output logic                      BREADY_S1,
    // Slave 2
    input  logic [ `AXI_IDS_BITS-1:0] BID_S2,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S2,
    input  logic                      BVALID_S2,
    output logic                      BREADY_S2,
    // Slave 3
    input  logic [ `AXI_IDS_BITS-1:0] BID_S3,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S3,
    input  logic                      BVALID_S3,
    output logic                      BREADY_S3,
    // Slave 4
    input  logic [ `AXI_IDS_BITS-1:0] BID_S4,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S4,
    input  logic                      BVALID_S4,
    output logic                      BREADY_S4,
    // Slave 5
    input  logic [ `AXI_IDS_BITS-1:0] BID_S5,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S5,
    input  logic                      BVALID_S5,
    output logic                      BREADY_S5,
    // Slave 6
    input  logic [ `AXI_IDS_BITS-1:0] BID_S6,
    input  logic [`AXI_RESP_BITS-1:0] BRESP_S6,
    input  logic                      BVALID_S6,
    output logic                      BREADY_S6
);

  logic [ `AXI_IDS_BITS-1:0] BID_S;
  logic [`AXI_RESP_BITS-1:0] BRESP_S;
  logic                      BVALID_S;

  logic                      BREADY_from_master;
  logic                      Bx_enable;

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
      Bx_enable <= (Bx_enable) ? (BVALID_S0|BVALID_S1|BVALID_S2|BVALID_S3|BVALID_S4|BVALID_S5|BVALID_S6) ? 1'b0 : Bx_enable : (WVALID_M1 & WREADY_M1 & WLAST_M1) ? 1'b1 : Bx_enable;
  end

  always_comb begin
    data_arb_lock_next = LOCK_NO;
    unique case (1'b1)
      data_arb_lock[LOCK_S0_BIT]:  // S0
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : (BVALID_S3) ? LOCK_S3 : (BVALID_S4) ? LOCK_S4 : (BVALID_S5) ? LOCK_S5 : (BVALID_S6) ? LOCK_S6 : LOCK_NO : LOCK_S0;
      data_arb_lock[LOCK_S1_BIT]:  // S1
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S2) ? LOCK_S2 : (BVALID_S3) ? LOCK_S3 : (BVALID_S4) ? LOCK_S4 : (BVALID_S5) ? LOCK_S5 : (BVALID_S6) ? LOCK_S6 : (BVALID_S0) ? LOCK_S0 : LOCK_NO : LOCK_S1;
      data_arb_lock[LOCK_S2_BIT]:  // S2
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S3) ? LOCK_S3 : (BVALID_S4) ? LOCK_S4 : (BVALID_S5) ? LOCK_S5 : (BVALID_S6) ? LOCK_S6 : (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : LOCK_NO : LOCK_S2;
      data_arb_lock[LOCK_S3_BIT]:  // S3
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S4) ? LOCK_S4 : (BVALID_S5) ? LOCK_S5 : (BVALID_S6) ? LOCK_S6 : (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : LOCK_NO : LOCK_S3;
      data_arb_lock[LOCK_S4_BIT]:  // S4
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S5) ? LOCK_S5 : (BVALID_S6) ? LOCK_S6 : (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : (BVALID_S3) ? LOCK_S3 : LOCK_NO : LOCK_S4;
      data_arb_lock[LOCK_S5_BIT]:  // S5
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S6) ? LOCK_S6 : (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : (BVALID_S3) ? LOCK_S3 : (BVALID_S4) ? LOCK_S4 : LOCK_NO : LOCK_S5;
      data_arb_lock[LOCK_S6_BIT]:  // S6
      data_arb_lock_next = (BREADY_from_master) ? (BVALID_S0) ? LOCK_S0 : (BVALID_S1) ? LOCK_S1 : (BVALID_S2) ? LOCK_S2 : (BVALID_S3) ? LOCK_S3 : (BVALID_S4) ? LOCK_S4 : (BVALID_S5) ? LOCK_S5 : LOCK_NO : LOCK_S6;
      data_arb_lock[LOCK_NO_BIT]: begin  // NO
        if (Bx_enable) begin
          if (BVALID_S0)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S0;
          else if (BVALID_S1)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S1;
          else if (BVALID_S2)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S2;
          else if (BVALID_S3)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S3;
          else if (BVALID_S4)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S4;
          else if (BVALID_S5)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S5;
          else if (BVALID_S6)
            data_arb_lock_next = (BREADY_from_master) ? LOCK_NO : LOCK_S6;
        end else begin
          data_arb_lock_next = LOCK_NO;
        end
      end
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    BVALID_S = 1'b0;
    BID_S = `AXI_IDS_BITS'b0;
    BRESP_S = `AXI_RESP_SLVERR;
    {BREADY_S0, BREADY_S1, BREADY_S2, BREADY_S3, BREADY_S4, BREADY_S5, BREADY_S6} = {
      1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    };

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
      data_arb_lock[LOCK_S3_BIT]: begin
        BVALID_S = BVALID_S3;
        BID_S = BID_S3;
        BRESP_S = BRESP_S3;
        BREADY_S3 = BREADY_from_master;
      end
      data_arb_lock[LOCK_S4_BIT]: begin
        BVALID_S = BVALID_S4;
        BID_S = BID_S4;
        BRESP_S = BRESP_S4;
        BREADY_S4 = BREADY_from_master;
      end
      data_arb_lock[LOCK_S5_BIT]: begin
        BVALID_S = BVALID_S5;
        BID_S = BID_S5;
        BRESP_S = BRESP_S5;
        BREADY_S5 = BREADY_from_master;
      end
      data_arb_lock[LOCK_S6_BIT]: begin
        BVALID_S = BVALID_S6;
        BID_S = BID_S6;
        BRESP_S = BRESP_S6;
        BREADY_S6 = BREADY_from_master;
      end
      data_arb_lock[LOCK_NO_BIT]: ;
    endcase
  end

  // Decoder
  assign decode_result = DATA_DECODER(BID_S);
  always_comb begin
    BID_M1 = BID_S[`AXI_ID_BITS-1:0];
    BRESP_M1 = BRESP_S;
    BVALID_M1 = 1'b0;
    BREADY_from_master = 1'b0;

    unique case (1'b1)
      decode_result[AXI_M0_BIT]: ;
      decode_result[AXI_M1_BIT]: begin
        BVALID_M1 = BVALID_S;
        BREADY_from_master = BREADY_M1;
      end
      decode_result[AXI_M2_BIT]: ;
    endcase
  end

endmodule
