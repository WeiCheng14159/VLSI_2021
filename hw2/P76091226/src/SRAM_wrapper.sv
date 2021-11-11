// `include "sram_pkg.sv"
`include "AXI_define.svh"
`define STATE_BITS 3

module SRAM_wrapper(
    input logic clk,
    input logic rst,
	input logic [`AXI_IDS_BITS-1:0] AWID_S,
	input logic [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input logic [`AXI_LEN_BITS-1:0] AWLEN_S,
	input logic [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input logic [1:0] AWBURST_S,
	input logic AWVALID_S,
	output logic AWREADY_S,
	//WRITE DATA0
	input logic [`AXI_DATA_BITS-1:0] WDATA_S,
	input logic [`AXI_STRB_BITS-1:0] WSTRB_S,
	input logic WLAST_S,
	input logic WVALID_S,
	output logic WREADY_S,
	//WRITE RESPONSE0
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input logic BREADY_S,
	
	//READ ADDRESS0
	input logic [`AXI_IDS_BITS-1:0] ARID_S,
	input logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input logic [`AXI_LEN_BITS-1:0] ARLEN_S,
	input logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input logic [1:0] ARBURST_S,
	input logic ARVALID_S,
	output logic ARREADY_S,
	//READ DATA0
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input logic RREADY_S
);

parameter STATE_IDLE = `STATE_BITS'b0,
          STATE_READ = `STATE_BITS'b1,
          STATE_WRITE = `STATE_BITS'b10;

logic [13:0] A;
logic [`AXI_DATA_BITS-1:0] DI;
logic [`AXI_DATA_BITS-1:0] DO;
logic [`AXI_STRB_BITS-1:0] WEB;
logic CS;
logic OE;
logic [`STATE_BITS-1:0] state;
logic [`STATE_BITS-1:0] nxt_state; 
logic AWFin;
logic WFin;
logic BFin;
logic RFin;
logic ARFin;
logic lockAW;
logic lockAR;
logic lockR;
logic lockW;
logic lockB;
logic A_offset;
logic [13:0] prev_A;
logic [`AXI_IDS_BITS-1:0] prev_ID;
logic [`AXI_LEN_BITS-1:0] prev_LEN;
logic [`AXI_SIZE_BITS-1:0] prev_SIZE;
logic [1:0] prev_BURST;
logic [`AXI_LEN_BITS-1:0] cnt;
logic read;
logic write;
logic [1:0]w_offset;
logic prevWFin;
logic prevAWFin;

assign AWFin = AWVALID_S & AWREADY_S;
assign WFin = WVALID_S & WREADY_S;
assign BFin = BVALID_S & BREADY_S;
assign ARFin = ARVALID_S & ARREADY_S;
assign RFin = RVALID_S & RREADY_S;
assign RLAST_S = cnt == prev_LEN;
assign A_offset = ((cnt[1:0] == 2'b0)) ? ((RFin) ? cnt[1:0] + 2'b1 : cnt[1:0]) : cnt[1:0] + 2'b1;
assign RDATA_S = DO;
assign RID_S = prev_ID; 
assign RRESP_S = `AXI_RESP_OKAY;
assign BID_S = prev_ID;
assign BRESP_S = `AXI_RESP_OKAY;
assign DI = WDATA_S;

always_ff@(posedge clk or negedge rst)begin
	if(~rst)
		state <= STATE_IDLE;
	else 
		state <= nxt_state;
end

always_comb begin
    case(state)
        STATE_IDLE: begin
            nxt_state = (AWVALID_S) ? STATE_WRITE : (ARVALID_S) ? STATE_READ : STATE_IDLE;
        end
        STATE_READ: begin
            nxt_state = (RFin & RLAST_S) ? ((AWVALID_S) ? STATE_WRITE : (ARVALID_S) ? STATE_READ : STATE_IDLE) : STATE_READ;
        end
        STATE_WRITE:
            nxt_state = (BFin & WLAST_S) ? ((AWVALID_S) ? STATE_WRITE : (ARVALID_S) ? STATE_READ : STATE_IDLE): STATE_WRITE;
        default:
            nxt_state = state;
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE:begin
            AWREADY_S = 1'b1;
            ARREADY_S = ~AWVALID_S;
            RVALID_S = 1'b0;
            WREADY_S = 1'b1;
            BVALID_S = 1'b0;
            CS = AWVALID_S | ARVALID_S;
            OE = ~AWVALID_S & ARVALID_S;
            read = 1'b0;
            write = 1'b0; 
            A = (AWVALID_S) ? AWADDR_S[15:2] : ARADDR_S[15:2];
        end
        STATE_READ:begin
            AWREADY_S = RLAST_S & RFin;
            ARREADY_S = RLAST_S & RFin & ~AWVALID_S;
            RVALID_S = 1'b1;
            WREADY_S  = RLAST_S & RFin;
            BVALID_S = 1'b0;
            CS = 1'b1;
            OE = 1'b1;
            read = 1'b1;
            write = 1'b0;
            A = (RLAST_S & RFin) ? (AWVALID_S ? AWADDR_S[15:2] : ARADDR_S[15:2] ) :{prev_A[13:2],A_offset};
        end
        STATE_WRITE:begin
            AWREADY_S = WLAST_S & BFin;
            ARREADY_S = WLAST_S & BFin & ~AWVALID_S;
            RVALID_S = 1'b0;
            WREADY_S  = BFin;
            BVALID_S = prevWFin;
            CS = 1'b1;
            OE = WLAST_S & BFin & ~AWVALID_S & ARVALID_S;
            read = 1'b0;
            write = 1'b1;
            A = (WLAST_S & WFin) ? (AWVALID_S ? AWADDR_S[15:2] : ARADDR_S[15:2]) : {prev_A[13:2],cnt[1:0]};
        end
        default:begin
            AWREADY_S = 1'b0;
            ARREADY_S = 1'b0;
            RVALID_S = 1'b0;
            WREADY_S  = 1'b0;
            BVALID_S = 1'b0;
            CS = 1'b0;
            OE = 1'b0;
            read = 1'b0;
            write = 1'b0;
            A = prev_A;
        end
    endcase
end


always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        cnt <= `AXI_LEN_BITS'b0;
    end
    else if(read)begin
        cnt <= (RLAST_S & RFin) ? `AXI_LEN_BITS'b0 : (RFin) ? cnt + `AXI_LEN_BITS'b1 : cnt; 
    end
    else if(write)begin
        cnt <= (WLAST_S & BFin) ? `AXI_LEN_BITS'b0 : (BFin) ? cnt + `AXI_LEN_BITS'b1 : cnt; 
    end
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        w_offset <= 2'b0;
        prevWFin <= 1'b0;
    end
    else 
        w_offset  <= (AWFin) ? AWADDR_S[1:0] : w_offset;
        prevWFin  <= (BFin) ? 1'b0 : (WFin) ? 1'b1 : prevWFin;
end

always_ff@(posedge clk) begin
    prev_A       <= (AWFin) ? AWADDR_S [15:2] : (ARFin) ? ARADDR_S [15:2] : prev_A;
    prev_ID      <= (AWFin) ? AWID_S          : (ARFin) ? ARID_S          : prev_ID;
    prev_LEN     <= (AWFin) ? AWLEN_S         : (ARFin) ? ARLEN_S         : prev_LEN;
    prev_SIZE    <= (AWFin) ? AWSIZE_S        : (ARFin) ? ARSIZE_S        : prev_SIZE;
    prev_BURST   <= (AWFin) ? AWBURST_S       : (ARFin) ? ARBURST_S       : prev_BURST;
end

always_comb begin
    WEB = 4'hf;
    if(WVALID_S)
        case(WSTRB_S)
            `AXI_STRB_BYTE: WEB[w_offset] = 1'b0;
            `AXI_STRB_HWORD: WEB[{w_offset[1],1'b0}+:2] = 2'b0;
            default:WEB = 4'h0;
        endcase
    else WEB = 4'hf;
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
