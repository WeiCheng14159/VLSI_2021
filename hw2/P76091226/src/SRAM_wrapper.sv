`include "sram_wrapper_pkg.sv"
`include "AXI_define.svh"

module SRAM_wrapper
  import sram_wrapper_pkg::*;
  (
    input logic clk,
    input logic rstn,
    // AWx
	input logic [`AXI_IDS_BITS-1:0] AWID_S,
	input logic [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input logic [`AXI_LEN_BITS-1:0] AWLEN_S,
	input logic [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input logic [1:0] AWBURST_S,
	input logic AWVALID_S,
	output logic AWREADY_S,
	// Wx
	input logic [`AXI_DATA_BITS-1:0] WDATA_S,
	input logic [`AXI_STRB_BITS-1:0] WSTRB_S,
	input logic WLAST_S,
	input logic WVALID_S,
	output logic WREADY_S,
	// Bx
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input logic BREADY_S,
	// ARx
	input logic [`AXI_IDS_BITS-1:0] ARID_S,
	input logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input logic [`AXI_LEN_BITS-1:0] ARLEN_S,
	input logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input logic [1:0] ARBURST_S,
	input logic ARVALID_S,
	output logic ARREADY_S,
	// Rx
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input logic RREADY_S
);

// SRAM module
logic [13:0] A;
logic [`AXI_DATA_BITS-1:0] DI;
logic [`AXI_DATA_BITS-1:0] DO;
logic [`AXI_STRB_BITS-1:0] WEB;
logic CS;
logic OE;

sram_wrapper_state_t curr_state, next_state;

logic ARx_hs_done, Rx_hs_done, AW_hs_done, Wx_hs_done, Bx_hs_done;

logic [13:0] A_r;
logic [`AXI_IDS_BITS-1:0] ID_r;
logic [`AXI_LEN_BITS-1:0] LEN_r;
logic Wx_hs_done_r;
logic [`AXI_LEN_BITS-1:0] len_cnt;
logic [1:0] w_offset;

// Handshake signal
assign AW_hs_done = AWVALID_S & AWREADY_S;
assign Wx_hs_done = WVALID_S & WREADY_S;
assign Bx_hs_done = BVALID_S & BREADY_S;
assign ARx_hs_done = ARVALID_S & ARREADY_S;
assign Rx_hs_done = RVALID_S & RREADY_S;
// Rx
assign RLAST_S = (len_cnt == LEN_r);
assign RDATA_S = (RVALID_S) ? DO : 32'b0;
assign RID_S = ID_r; 
assign RRESP_S = `AXI_RESP_OKAY;
// Bx
assign BID_S = ID_r;
assign BRESP_S = `AXI_RESP_OKAY;
// Wx
assign DI = WDATA_S;

always_ff@(posedge clk or negedge rstn)begin
	if(~rstn)
		curr_state <= IDLE;
	else 
		curr_state <= next_state;
end // State

always_comb begin
    case(curr_state)
        IDLE: begin
            next_state = (AWVALID_S) ? WRITE : (ARVALID_S) ? READ : IDLE;
        end
        READ: begin
            next_state = (Rx_hs_done & RLAST_S) ? ((AWVALID_S) ? WRITE : (ARVALID_S) ? READ : IDLE) : READ;
        end
        WRITE: begin
            next_state = (Bx_hs_done) ? ((AWVALID_S) ? WRITE : IDLE): WRITE;
        end
        default: next_state = curr_state;
    endcase
end // Next state (C)

always_comb begin
    AWREADY_S = 1'b0;
    WREADY_S  = 1'b0;
    BVALID_S = 1'b0;
    ARREADY_S = 1'b0;
    RVALID_S = 1'b0;
    CS = 1'b0;
    OE = 1'b0;
    A = A_r;

    case(curr_state)
        IDLE: begin
            AWREADY_S = 1'b1;
            WREADY_S = 1'b1;
            BVALID_S = 1'b0;
            ARREADY_S = ~AWVALID_S;
            RVALID_S = 1'b0;
            CS = AWVALID_S | ARVALID_S;
            OE = ~AWVALID_S & ARVALID_S;
            A = (AWVALID_S) ? AWADDR_S[15:2] : ARADDR_S[15:2];
        end
        READ: begin
            AWREADY_S = RLAST_S & Rx_hs_done;
            WREADY_S  = RLAST_S & Rx_hs_done;
            BVALID_S = 1'b0;
            ARREADY_S = RLAST_S & Rx_hs_done & ~AWVALID_S;
            RVALID_S = 1'b1;
            CS = 1'b1;
            OE = 1'b1;
            A = (RLAST_S & Rx_hs_done) ? (AWVALID_S ? AWADDR_S[15:2] : A_r ) :A_r;
        end
        WRITE: begin
            AWREADY_S = WLAST_S & Bx_hs_done;
            WREADY_S  = Bx_hs_done;
            BVALID_S = Wx_hs_done_r;
            ARREADY_S = WLAST_S & Bx_hs_done & ~AWVALID_S;
            RVALID_S = 1'b0;
            CS = 1'b1;
            OE = 1'b0;
            A = (WLAST_S & Bx_hs_done) ? (AWVALID_S ? AWADDR_S[15:2] : ARADDR_S[15:2]) : A_r[13:2];
        end
        default: ;
    endcase
end


always_ff@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        len_cnt <= `AXI_LEN_BITS'b0;
    end else if(curr_state[READ_BIT])begin
        len_cnt <= (RLAST_S & Rx_hs_done) ? `AXI_LEN_BITS'b0 : (Rx_hs_done) ? len_cnt + `AXI_LEN_BITS'b1 : len_cnt; 
    end else if(curr_state[WRITE_BIT])begin
        len_cnt <= (WLAST_S & Bx_hs_done) ? `AXI_LEN_BITS'b0 : (Bx_hs_done) ? len_cnt + `AXI_LEN_BITS'b1 : len_cnt; 
    end else if(curr_state[IDLE_BIT]) begin
        len_cnt <= `AXI_LEN_BITS'b0; 
    end
end

always_ff@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        w_offset <= 2'b0;
        Wx_hs_done_r <= 1'b0;
    end else begin 
        w_offset  <= (AW_hs_done) ? AWADDR_S[1:0] : w_offset;
        Wx_hs_done_r  <= (Bx_hs_done) ? 1'b0 : (Wx_hs_done) ? (WLAST_S) ? 1'b1 : 1'b0 : Wx_hs_done_r;
    end
end

always_ff@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        A_r       <= 14'b0;
        ID_r      <= `AXI_IDS_BITS'b0;
        LEN_r     <= `AXI_LEN_BITS'b0;
    end else begin
        A_r       <= (AW_hs_done) ? AWADDR_S [15:2] : (ARx_hs_done) ? ARADDR_S [15:2] : A_r;
        ID_r      <= (AW_hs_done) ? AWID_S          : (ARx_hs_done) ? ARID_S          : ID_r;
        LEN_r     <= (AW_hs_done) ? AWLEN_S         : (ARx_hs_done) ? ARLEN_S         : LEN_r;
    end
    
end

always_comb begin
    WEB = {WEB_DIS, WEB_DIS, WEB_DIS, WEB_DIS};
    if(WVALID_S) begin
        case(WSTRB_S)
            `AXI_STRB_BYTE: WEB[w_offset] = WEB_ENB;
            `AXI_STRB_HWORD: WEB[{w_offset[1],1'b0}+:2] = {WEB_ENB, WEB_ENB};
            default: WEB = {WEB_ENB, WEB_ENB, WEB_ENB, WEB_ENB};
        endcase
    end
end

  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (clk   ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

endmodule
