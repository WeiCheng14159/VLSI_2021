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

  logic                      READY_from_master;

  data_arb_lock_t data_arb_lock, data_arb_lock_next;
  axi_master_id_t decode_result;

  always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      data_arb_lock <= LOCK_NO;
    end else begin
      data_arb_lock <= data_arb_lock_next;
    end
  end  // State

  always_comb begin
    data_arb_lock_next = LOCK_NO;
    unique case (1'b1)
      data_arb_lock[LOCK_S0_BIT]:
      data_arb_lock_next = (READY_from_master) ? (RVALID_S1) ? LOCK_S1 : (RVALID_S2) ? LOCK_S2 : LOCK_NO : LOCK_S0;
      data_arb_lock[LOCK_S1_BIT]:
      data_arb_lock_next = (READY_from_master) ? (RVALID_S2) ? LOCK_S2 : (RVALID_S0) ? LOCK_S0 : LOCK_NO : LOCK_S1;
      data_arb_lock[LOCK_S2_BIT]:
      data_arb_lock_next = (READY_from_master) ? (RVALID_S0) ? LOCK_S0 : (RVALID_S1) ? LOCK_S1 : LOCK_NO : LOCK_S2;
      data_arb_lock[LOCK_NO_BIT]: begin
        if (RVALID_S0)
          data_arb_lock_next = (READY_from_master) ? LOCK_NO : LOCK_S0;
        else if (RVALID_S1)
          data_arb_lock_next = (READY_from_master) ? LOCK_NO : LOCK_S1;
        else if (RVALID_S2)
          data_arb_lock_next = (READY_from_master) ? LOCK_NO : LOCK_S2;
        else data_arb_lock_next = LOCK_NO;
      end
    endcase
  end  // Next state (C)

  // Arbiter
  always_comb begin
    RID_S = `AXI_IDS_BITS'b0;
    RDATA_S = `AXI_DATA_BITS'b0;
    RRESP_S = 2'b0;
    RLAST_S = 1'b0;
    RVALID_S = 1'b0;
    {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, 1'b0};

    case (1'b1)
      data_arb_lock[LOCK_S0_BIT]: begin
        RID_S = RID_S0;
        RDATA_S = RDATA_S0;
        RRESP_S = RRESP_S0;
        RLAST_S = RLAST_S0;
        RVALID_S = RVALID_S0;
        RREADY_S0 = READY_from_master;
      end
      data_arb_lock[LOCK_S1_BIT]: begin
        RID_S = RID_S1;
        RDATA_S = RDATA_S1;
        RRESP_S = RRESP_S1;
        RLAST_S = RLAST_S1;
        RVALID_S = RVALID_S1;
        RREADY_S1 = READY_from_master;
      end
      data_arb_lock[LOCK_S2_BIT]: begin
        RID_S = RID_S2;
        RDATA_S = RDATA_S2;
        RRESP_S = RRESP_S2;
        RLAST_S = RLAST_S2;
        RVALID_S = RVALID_S2;
        RREADY_S2 = READY_from_master;
      end
      data_arb_lock[LOCK_NO_BIT]: begin
        if (RVALID_S0) begin  // S0 has higher priority
          RID_S = RID_S0;
          RDATA_S = RDATA_S0;
          RRESP_S = RRESP_S0;
          RLAST_S = RLAST_S0;
          RVALID_S = RVALID_S0;
          RREADY_S0 = READY_from_master;
        end else if (RVALID_S1) begin
          RID_S = RID_S1;
          RDATA_S = RDATA_S1;
          RRESP_S = RRESP_S1;
          RLAST_S = RLAST_S1;
          RVALID_S = RVALID_S1;
          RREADY_S1 = READY_from_master;
        end else if (RVALID_S2) begin
          RID_S = RID_S2;
          RDATA_S = RDATA_S2;
          RRESP_S = RRESP_S2;
          RLAST_S = RLAST_S2;
          RVALID_S = RVALID_S2;
          RREADY_S2 = READY_from_master;
        end else begin
          // Nothing
        end
      end
    endcase
  end

  // Decoder
  assign decode_result = DATA_DECODER(RID_S);
  always_comb begin
    // Default
    {RID_M0, RID_M1} = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
    {RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
    {RRESP_M0, RRESP_M1} = {2'b0, 2'b0};
    {RLAST_M0, RLAST_M1} = {1'b0, 1'b0};
    {RVALID_M0, RVALID_M1} = {1'b0, 1'b0};

    unique case (1'b1)
      decode_result[AXI_M0_BIT]: begin
        RID_M0 = RID_S[`AXI_ID_BITS-1:0];
        RDATA_M0 = RDATA_S;
        RRESP_M0 = RRESP_S;
        RLAST_M0 = RLAST_S;
        RVALID_M0 = RVALID_S;
      end
      decode_result[AXI_M1_BIT]: begin
        RID_M1 = RID_S[`AXI_ID_BITS-1:0];
        RDATA_M1 = RDATA_S;
        RRESP_M1 = RRESP_S;
        RLAST_M1 = RLAST_S;
        RVALID_M1 = RVALID_S;
      end
      decode_result[AXI_M2_BIT]: ;
    endcase
  end  // always_comb

  always_comb begin
    READY_from_master = 1'b0;
    unique case (1'b1)
      decode_result[AXI_M0_BIT]: READY_from_master = RREADY_M0;
      decode_result[AXI_M1_BIT]: READY_from_master = RREADY_M1;
      decode_result[AXI_M2_BIT]: ;
    endcase
  end  // always_comb

endmodule
