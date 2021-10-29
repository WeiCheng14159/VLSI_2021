`include "def.v"
`include "CPU.sv"
`include "AXI_define.svh"
// `include "AXI2CPU.sv"

module CPU_wrapper (
  AXI2CPU_interface.cpu_ports cpu2axi_interface,
 	/* Others */
  input clk,
	input rst
);

 logic               [`InstBus] inst_out_i;
 logic                          inst_read_o;
 logic           [`InstAddrBus] inst_addr_o;

 logic                          stallreq_from_imem;
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
  stallreq_from_imem = `Stop;
  stallreq_from_if = `Stop; 
      
  unique case(1'b1)
      
    curr_state[RESET_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = 0;
      cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
      cpu2axi_interface.RREADY_M0 = 1'b0;
    end
    curr_state[SADDR_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = inst_addr_o;
      cpu2axi_interface.ARVALID_M0 = 1'b1; // A3-39
      cpu2axi_interface.RREADY_M0 = 1'b0;
    end
    curr_state[WAITE_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = 0;
      cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
      cpu2axi_interface.RREADY_M0 = 1'b1;
    end
    curr_state[LOADD_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = 0;
      cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
    end
  endcase
end

endmodule
