`include "AXI_define.svh"

module Rx
  import axi_pkg::*;
(
  input logic clk,
  input logic rstn,
    // Master 0 
  output logic [`AXI_ID_BITS-1:0] RID_M0,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
  output logic [1:0] RRESP_M0,
  output logic RLAST_M0,
  output logic RVALID_M0,
  input  logic RREADY_M0,
    // Master 1
  output logic [`AXI_ID_BITS-1:0] RID_M1,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
  output logic [1:0] RRESP_M1,
  output logic RLAST_M1,
  output logic RVALID_M1,
  input logic RREADY_M1,
    // Slave 0
  input logic [`AXI_IDS_BITS-1:0] RID_S0,
  input logic [`AXI_DATA_BITS-1:0] RDATA_S0,
  input logic [1:0] RRESP_S0,
  input logic RLAST_S0,
  input logic RVALID_S0,
  output logic RREADY_S0,
    // Slave 1
  input logic [`AXI_IDS_BITS-1:0] RID_S1,
  input logic [`AXI_DATA_BITS-1:0] RDATA_S1,
  input logic [1:0] RRESP_S1,
  input logic RLAST_S1,
  input logic RVALID_S1,
  output logic RREADY_S1,
    // Slave 2
  input logic [`AXI_IDS_BITS-1:0] RID_S2,
  input logic [`AXI_DATA_BITS-1:0] RDATA_S2,
  input logic [1:0] RRESP_S2,
  input logic RLAST_S2,
  input logic RVALID_S2,
  output logic RREADY_S2
);

logic [`AXI_IDS_BITS-1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [1:0] RRESP_S;
logic RLAST_S;
logic RVALID_S;

logic READY_M;

data_arb_lock_t data_arb_lock, data_arb_lock_next;

always_ff @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    data_arb_lock <= LOCK_NO;
  end else begin
    data_arb_lock <= data_arb_lock_next;
  end
end // State

always_comb begin 
  data_arb_lock_next = LOCK_NO;
  unique case(data_arb_lock)
    LOCK_S0: data_arb_lock_next = (READY_M & RVALID_S0) ? LOCK_NO : LOCK_S0;
    LOCK_S1: data_arb_lock_next = (READY_M & RVALID_S1) ? LOCK_NO : LOCK_S1;
    LOCK_S2: data_arb_lock_next = (READY_M & RVALID_S2) ? LOCK_NO : LOCK_S2;
    LOCK_NO: begin
      if      (RVALID_S0) data_arb_lock_next = LOCK_S0;
      else if (RVALID_S1) data_arb_lock_next = LOCK_S1;
      else if (RVALID_S2) data_arb_lock_next = LOCK_S2;
      else                data_arb_lock_next = LOCK_NO;
    end
  endcase
end // Next state (C)

always_comb begin
  // Default 
  RVALID_S = 0;
  {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, 1'b0};
 
  unique case(data_arb_lock)
    LOCK_S0: begin
      RVALID_S = 1'b1;
      {RREADY_S0, RREADY_S1, RREADY_S2} = {READY_M, 1'b0, 1'b0};
    end
    LOCK_S1: begin
      RVALID_S = 1'b1;
      {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, READY_M, 1'b0};
    end
    LOCK_S2: begin
      RVALID_S = 1'b1;
      {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, READY_M};
    end
    LOCK_NO: begin 
      RVALID_S = 0;
      {RREADY_S0, RREADY_S1, RREADY_S2} = {1'b0, 1'b0, 1'b0};
    end
  endcase
end

// These variables are the latched value 
logic [`AXI_IDS_BITS-1:0] RID_S_r;
logic [`AXI_DATA_BITS-1:0] RDATA_S_r;
logic [1:0] RRESP_S_r;
logic RLAST_S_r;

always_ff @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    RID_S_r <= 0;
    RDATA_S_r <= 0;
    RRESP_S_r <= 0;
    RLAST_S_r <= 0;
  end else if(data_arb_lock == LOCK_NO) begin
   
    unique case(data_arb_lock_next)
      LOCK_S0: begin
        RID_S_r <= RID_S0;
        RDATA_S_r <= RDATA_S0;
        RRESP_S_r <= RRESP_S0;
        RLAST_S_r <= RLAST_S0;
      end
      LOCK_S1: begin
        RID_S_r <= RID_S1;
        RDATA_S_r <= RDATA_S1;
        RRESP_S_r <= RRESP_S1;
        RLAST_S_r <= RLAST_S1;
      end
      LOCK_S2: begin
        RID_S_r <= RID_S2;
        RDATA_S_r <= RDATA_S2;
        RRESP_S_r <= RRESP_S2;
        RLAST_S_r <= RLAST_S2;
      end
      LOCK_NO: begin 
        RID_S_r <= 0;
        RDATA_S_r <= 0;
        RRESP_S_r <= 0;
        RLAST_S_r <= 0;
      end
    endcase
  end
end

always_comb begin
  // Default
  {RID_M0, RID_M1} = {`AXI_ID_BITS'b0, `AXI_ID_BITS'b0};
  {RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
  {RRESP_M0, RRESP_M1} = {2'b0, 2'b0};
  {RLAST_M0, RLAST_M1} = {1'b0, 1'b0};
  {RVALID_M0, RVALID_M1} = {1'b0, 1'b0};
  READY_M = 1'b0;

  unique case(DATA_DECODER(RID_S_r))
    MASTER_0: begin
      {RID_M0, RID_M1} = {RID_S_r, `AXI_ID_BITS'b0};
      {RDATA_M0, RDATA_M1} = {RDATA_S_r, `AXI_DATA_BITS'b0};
      {RRESP_M0, RRESP_M1} = {RRESP_S_r, 2'b0};
      {RLAST_M0, RLAST_M1} = {RLAST_S_r, 1'b0};
      {RVALID_M0, RVALID_M1} = {RVALID_S, 1'b0};
      READY_M = RREADY_M0;
    end
    MASTER_1: begin
      {RID_M0, RID_M1} = {`AXI_ID_BITS'b0, RID_S_r};
      {RDATA_M0, RDATA_M1} = {`AXI_DATA_BITS'b0, RDATA_S_r};
      {RRESP_M0, RRESP_M1} = {2'b0, RRESP_S_r};
      {RLAST_M0, RLAST_M1} = {1'b0, RLAST_S_r};
      {RVALID_M0, RVALID_M1} = {1'b0, RVALID_S};
      READY_M = RREADY_M1;
    end
    MASTER_2: ;
    MASTER_U: ;
  endcase
end

endmodule
