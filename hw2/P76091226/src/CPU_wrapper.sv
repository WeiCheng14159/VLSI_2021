`include "def.v"
`include "CPU.sv"
`include "AXI_define.svh"
// `include "AXI2CPU.sv"

module CPU_wrapper (
  AXI2CPU_interface.cpu_ports cpu2axi_interface,
 	/* Others */
  input clk,
	input rst

//  /* Master 0 => IF-stage */
//	// READ ADDRESS for M0
//	output [`AXI_ID_BITS-1:0] ARID_M0,
//	output [`AXI_ADDR_BITS-1:0] ARADDR_M0,
//	output [`AXI_LEN_BITS-1:0] ARLEN_M0,
//	output [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
//	output [1:0] ARBURST_M0,
//	output ARVALID_M0,
//	input ARREADY_M0,
//	//READ DATA for M0
//	input [`AXI_ID_BITS-1:0] RID_M0,
//	input [`AXI_DATA_BITS-1:0] RDATA_M0,
//	input [1:0] RRESP_M0,
//	input RLAST_M0,
//	input RVALID_M0,
//	output RREADY_M0,
//  
//  /* Master 1 => ME-stage */
//	//READ ADDRESS for M1
//	output [`AXI_ID_BITS-1:0] ARID_M1,
//	output [`AXI_ADDR_BITS-1:0] ARADDR_M1,
//	output [`AXI_LEN_BITS-1:0] ARLEN_M1,
//	output [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
//	output [1:0] ARBURST_M1,
//	output ARVALID_M1,
//	input ARREADY_M1,
//	//READ DATA for M1
//	input [`AXI_ID_BITS-1:0] RID_M1,
//	input [`AXI_DATA_BITS-1:0] RDATA_M1,
//	input [1:0] RRESP_M1,
//	input RLAST_M1,
//	input RVALID_M1,
//	output RREADY_M1,
//  //WRITE ADDRESS for M1
//	output [`AXI_ID_BITS-1:0] AWID_M1,
//	output [`AXI_ADDR_BITS-1:0] AWADDR_M1,
//	output [`AXI_LEN_BITS-1:0] AWLEN_M1,
//	output [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
//	output [1:0] AWBURST_M1,
//	output AWVALID_M1,
//	input AWREADY_M1,
//	//WRITE DATA for M1
//	output [`AXI_DATA_BITS-1:0] WDATA_M1,
//	output [`AXI_STRB_BITS-1:0] WSTRB_M1,
//	output WLAST_M1,
//	output WVALID_M1,
//	input WREADY_M1,
//	//WRITE RESPONSE for M1
//	input [`AXI_ID_BITS-1:0] BID_M1,
//	input [1:0] BRESP_M1,
//	input BVALID_M1,
//	output BREADY_M1
);

 logic               [`InstBus] inst_out_i;
 logic                          inst_read_o;
 logic           [`InstAddrBus] inst_addr_o;

 logic                          stallreq_from_if;
 logic                          stallreq_from_mem;
  
CPU cpu0 (
  .clk, .rst,

  .inst_out_i, .inst_read_o, .inst_addr_o,

  .stallreq_from_if, .stallreq_from_mem
);

localparam  RESET_BIT = 0,
            SADDR_BIT = 1,
            WAITE_BIT = 2,
            LOADD_BIT = 3;
            
typedef enum logic [3:0] {
  RESET = 1 << RESET_BIT,
  SADDR = 1 << SADDR_BIT,
  WAITE = 1 << WAITE_BIT,
  LOADD = 1 << LOADD_BIT
} wrapper_state_t;

wrapper_state_t curr_state, next_state;

logic [7:0] cnt;

always_ff @(posedge clk, posedge rst) begin
  if(rst)
    cnt <= 0;
  else
  // else if(curr_state[RESET_BIT])
  //   cnt <= 0;
  // else if (curr_state[SADDR_BIT])
  //   cnt <= cnt + 1;
  // else if (curr_state[LOADD_BIT])
    cnt <= cnt + 1;
end


// State logic
always_ff @( posedge clk, posedge rst ) begin
  if(rst)
    curr_state <= RESET;
  else
    curr_state <= next_state;
end

// Next state logic
always_comb begin
  unique case(1'b1)
    curr_state[RESET_BIT]: next_state = (inst_read_o) ? SADDR : RESET;
    curr_state[SADDR_BIT]: next_state = (cpu2axi_interface.ARREADY_M0) ? WAITE : SADDR;
    curr_state[WAITE_BIT]: next_state = (cpu2axi_interface.ARVALID_M0) ? LOADD : WAITE;
    curr_state[LOADD_BIT]: next_state = (cpu2axi_interface.RLAST_M0) ? RESET : LOADD;
  endcase
end

// Output logic
always_comb begin
  cpu2axi_interface.ARID_M0 = 0; // master 0
  cpu2axi_interface.ARLEN_M0 = 0; // Burst = 1
  cpu2axi_interface.ARSIZE_M0 = 3'h4; // 4B per transfer
  cpu2axi_interface.ARBURST_M0 = `AXI_BURST_INC;
      
  unique case(1'b1)
      
    curr_state[RESET_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = 0;
      cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
      stallreq_from_if = `NoStop; 
      cpu2axi_interface.RREADY_M0 = 1'b0;
    end
    curr_state[SADDR_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = inst_addr_o;
      cpu2axi_interface.ARVALID_M0 = 1'b1; // A3-39
      stallreq_from_if = `Stop; // Stall the IF-stage;
      cpu2axi_interface.RREADY_M0 = 1'b0;
    end
    curr_state[WAITE_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = 0;
      cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
      stallreq_from_if = `Stop; // Stall the IF-stage;
      cpu2axi_interface.RREADY_M0 = 1'b1;
    end
    curr_state[LOADD_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = 0;
      cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
      stallreq_from_if = `Stop; // Stall the IF-stage;
    end
  endcase
end

endmodule
