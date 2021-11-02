`include "AXI_define.svh"
`include "sram_pkg.sv"

module SRAM_wrapper 
  import sram_pkg::*;
(
  input logic clk,
  input logic rst,
  AXI2SRAM_interface.sram_ports sram2axi_interface
);

  logic CK;
  logic CS;
  logic OE;
  logic [WEB_SIZE-1:0] WEB;
  logic [ADDR_SIZE-1:0] A;
  logic [DATA_SIZE-1:0] DI;
  logic [DATA_SIZE-1:0] DO;
  assign CK = clk;
  assign DI = sram2axi_interface.WDATA;
  
  localparam  IDLEE_BIT = 0,
              RADDR_BIT = 1,
              WRITE_BIT = 2;
    
  typedef enum logic [2:0] {
    IDLEE = 1 << IDLEE_BIT,
    RADDR = 1 << RADDR_BIT,
    WRITE = 1 << WRITE_BIT
  } AR_state_t;
  
  AR_state_t curr_state, next_state;
  
  // State logic
  always_ff @( posedge clk, posedge rst ) begin
    if(rst)
      curr_state <= IDLEE;
    else
      curr_state <= next_state;
  end

  // Read channel (next stage logic)
  // Next state logic
  always_comb begin
    unique case(1'b1)
      curr_state[IDLEE_BIT]: next_state = (sram2axi_interface.ARVALID) ? RADDR : IDLEE;
      curr_state[RADDR_BIT]: next_state = WRITE;
      curr_state[WRITE_BIT]: next_state = (sram2axi_interface.RREADY) ? IDLEE : WRITE;
    endcase
  end

  // latch input value
  logic [`AXI_ADDR_BITS-1:0] ARADDR_r;
  logic [`AXI_IDS_BITS-1:0] ARID_r;
  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      {ARADDR_r ,ARID_r} <= {1'b0, 1'b0};
    end else if(sram2axi_interface.ARVALID) begin
      {ARADDR_r ,ARID_r} <= {sram2axi_interface.ARADDR, sram2axi_interface.ARID};
    end
  end

  // latch data out
  logic [DATA_SIZE-1:0] DO_r;
  always_ff @(posedge clk, posedge rst) begin
    if(rst)
      DO_r <= 0;
    else if(curr_state[RADDR_BIT])
      DO_r <= DO;
  end

  // AXI output (C)
  always_comb begin
    sram2axi_interface.ARREADY = 0;
    sram2axi_interface.RVALID = 0;
    sram2axi_interface.RID = 0;
    sram2axi_interface.RDATA = 0;
    sram2axi_interface.RLAST = 0;
    sram2axi_interface.RRESP = 0;

    unique case(1'b1)
      curr_state[IDLEE_BIT]: begin
      end
    
      curr_state[RADDR_BIT]: begin     
        sram2axi_interface.ARREADY = 1;
      end
    
      curr_state[WRITE_BIT]: begin     
        sram2axi_interface.RVALID = 1;
        sram2axi_interface.RID = ARID_r;
        sram2axi_interface.RDATA = DO_r;
        sram2axi_interface.RLAST = 1;
        sram2axi_interface.RRESP = `AXI_RESP_OKAY;
      end
    
    endcase

  end

  // Memory output (C)
  always_comb begin
    A = EMPTY_ADDR; 
    OE = OE_DIS;
    CS = CS_DIS;
    WEB = EMPTY_WEB;

    unique case(1'b1)    
      curr_state[IDLEE_BIT]: begin
        CS = sram2axi_interface.AWVALID | sram2axi_interface.ARVALID;
        OE = ~sram2axi_interface.AWVALID & sram2axi_interface.ARVALID;
        A = (sram2axi_interface.AWVALID | sram2axi_interface.ARVALID ) ? 
          sram2axi_interface.ARADDR[ADDR_SIZE-1:2] : EMPTY_ADDR; 
        // WEB = (sram2axi_interface.AWVALID & ~sram2axi_interface.ARVALID) ? 
      end
    
      curr_state[RADDR_BIT]: begin // send address to SRAM 
        CS = CS_ENB;
        OE = OE_ENB;
      end
    
      curr_state[WRITE_BIT]: begin // store RW value
      
      end
    endcase
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
