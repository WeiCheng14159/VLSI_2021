`include "AXI_define.svh"

module Wx
  import axi_pkg::*;
(
  input logic                            clk,
  input logic                            rstn,
    // Master 1
  input logic       [`AXI_DATA_BITS-1:0] WDATA_M1,
  input logic       [`AXI_STRB_BITS-1:0] WSTRB_M1,
  input logic                            WLAST_M1,
  input logic                            WVALID_M1,
  output logic                           WREADY_M1,
    // Slave 0
  output logic      [`AXI_DATA_BITS-1:0] WDATA_S0,
  output logic      [`AXI_STRB_BITS-1:0] WSTRB_S0,
  output logic                           WLAST_S0,
  output logic                           WVALID_S0,
  input logic                            WREADY_S0,
  input logic                            AWVALID_S0,
  input logic                            AWREADY_S0,
    // Slave 1
  output logic      [`AXI_DATA_BITS-1:0] WDATA_S1,
  output logic      [`AXI_STRB_BITS-1:0] WSTRB_S1,
  output logic                           WLAST_S1,
  output logic                           WVALID_S1,
  input logic                            WREADY_S1,
  input logic                            AWVALID_S1,
  input logic                            AWREADY_S1,
    // Slave 2
  output logic      [`AXI_DATA_BITS-1:0] WDATA_S2,
  output logic      [`AXI_STRB_BITS-1:0] WSTRB_S2,
  output logic                           WLAST_S2,
  output logic                           WVALID_S2,
  input logic                            WREADY_S2,
  input logic                            AWVALID_S2,
  input logic                            AWREADY_S2
);

logic               [`AXI_DATA_BITS-1:0] WDATA_M;
logic               [`AXI_STRB_BITS-1:0] WSTRB_M;
logic                                    WLAST_M;
logic                                    WVALID_M;
logic                                    WREADY_S;

data_arb_lock_t write_data_arb_lock, write_data_arb_lock_next;

always_ff @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    write_data_arb_lock <= LOCK_NO;
  end else begin
    write_data_arb_lock <= write_data_arb_lock_next;
  end
end // State

typedef enum logic [2:0] {
  Wx_LOCK_S0, Wx_LOCK_S1, Wx_LOCK_S2, Wx_LOCK_NO
} wx_slave_lock_t;

wx_slave_lock_t wx_slave_lock;
always_ff @(posedge clk, negedge rstn) begin
  if(!rstn) 
    wx_slave_lock <= Wx_LOCK_NO;
  else begin
    if(AWVALID_S0/* & AWREADY_S0*/)
      wx_slave_lock <= Wx_LOCK_S0;
    else if(AWVALID_S1/* & AWREADY_S1*/)
      wx_slave_lock <= Wx_LOCK_S1;
    else if(AWVALID_S2/* & AWREADY_S2*/)
      wx_slave_lock <= Wx_LOCK_S2;
  end
end

always_comb begin
  write_data_arb_lock_next = LOCK_NO;
  unique case(write_data_arb_lock)
    LOCK_S0         : write_data_arb_lock_next = (WREADY_S0 && WVALID_S0) ? LOCK_NO : LOCK_S0;
    LOCK_S1         : write_data_arb_lock_next = (WREADY_S1 && WVALID_S1) ? LOCK_NO : LOCK_S1;
    LOCK_S2         : write_data_arb_lock_next = (WREADY_S2 && WVALID_S2) ? LOCK_NO : LOCK_S2;
    LOCK_NO         : 
      begin
        if      (wx_slave_lock == Wx_LOCK_S0 && WVALID_M1 /*|| (AWVALID_S0 && WVALID_S0)*/) write_data_arb_lock_next = LOCK_S0;
        else if (wx_slave_lock == Wx_LOCK_S1 && WVALID_M1) write_data_arb_lock_next = LOCK_S1;
        else if (wx_slave_lock == Wx_LOCK_S2 && WVALID_M1) write_data_arb_lock_next = LOCK_S2;
        else                                               write_data_arb_lock_next = LOCK_NO;
      end
  endcase

end // Next state (C)

logic [`AXI_DATA_BITS-1:0] WDATA_M_r;
logic [`AXI_STRB_BITS-1:0] WSTRB_M_r;
logic WLAST_M_r;
logic WVALID_M_r;

always_ff @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    WDATA_M_r <= 0;
    WSTRB_M_r <= 0;
    WLAST_M_r <= 0;
    WVALID_M_r <= 0;
  end else if( (write_data_arb_lock == LOCK_NO) && 
               ( (write_data_arb_lock_next == LOCK_S0) || 
                 (write_data_arb_lock_next == LOCK_S1) || 
                 (write_data_arb_lock_next == LOCK_S2) ) ) begin
    WDATA_M_r <= WDATA_M1;
    WSTRB_M_r <= WSTRB_M1;
    WLAST_M_r <= WLAST_M1;
    WVALID_M_r <= WVALID_M1;
  end
end

always_comb begin
  // Default
  WREADY_S = 1'b0;
  {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b0};
  
  unique case(write_data_arb_lock)
    LOCK_S0: begin
      WREADY_S = WREADY_S0;
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b1, 1'b0, 1'b0};
    end
    LOCK_S1: begin
      WREADY_S = WREADY_S1;
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b1, 1'b0};
    end
    LOCK_S2: begin
      WREADY_S = WREADY_S2;
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b1};
    end
    LOCK_NO: begin
      WREADY_S = 1'b0;
      {WVALID_S0, WVALID_S1, WVALID_S2} = {1'b0, 1'b0, 1'b0};
    end
  endcase
end

always_comb begin
  // Default
  {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
  {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
  {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, 1'b0};
  
  unique case(write_data_arb_lock)
    LOCK_S0: begin
      {WDATA_S0, WDATA_S1, WDATA_S2} = {WDATA_M_r, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {WSTRB_M_r, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {WLAST_M_r, 1'b0, 1'b0};
    end
    LOCK_S1: begin
      {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, WDATA_M_r, `AXI_DATA_BITS'b0};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, WSTRB_M_r, `AXI_STRB_BITS'b0};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, WLAST_M_r, 1'b0};
    end
    LOCK_S2: begin
      {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, WDATA_M_r};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, WSTRB_M_r};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, WLAST_M_r};
    end
    LOCK_NO: begin 
      {WDATA_S0, WDATA_S1, WDATA_S2} = {`AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0, `AXI_DATA_BITS'b0};
      {WSTRB_S0, WSTRB_S1, WSTRB_S2} = {`AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0, `AXI_STRB_BITS'b0};
      {WLAST_S0, WLAST_S1, WLAST_S2} = {1'b0, 1'b0, 1'b0};
    end
  endcase
end

assign WREADY_M1 = WREADY_S;

endmodule
