`include "def.v"
`include "CPU.sv"
`include "AXI_define.svh"

module CPU_wrapper (
  AXI2CPU_interface.cpu_ports cpu2axi_interface,
 	/* Others */
  input clk,
	input rst
);

 logic               [`InstBus] inst_out_i;
 logic                          inst_read_o;
 logic           [`InstAddrBus] inst_addr_o;
 
 logic               [`DataBus] data_out_i;
 logic                          data_read_o;
 logic                    [3:0] data_write_o;
 logic           [`DataAddrBus] data_addr_o;
 logic               [`DataBus] data_in_o;

logic                stallreq_from_im;
logic                stallreq_from_if;
logic                stallreq_from_mem;
  
assign stallreq_from_mem = `NoStop;

CPU cpu0 (
  .clk, .rst, 

  .inst_out_i, .inst_read_o, .inst_addr_o,
  .data_out_i, .data_read_o, .data_write_o, .data_addr_o, .data_in_o,

  .stallreq_from_im, .stallreq_from_if, .stallreq_from_mem
);

localparam  RESET_BIT = 0,
            SADDR_BIT = 1,
            SWAIT_BIT = 2,
            STEPP_BIT = 3;
            
typedef enum logic [3:0] {
  RESET = 1 << RESET_BIT,
  SADDR = 1 << SADDR_BIT,
  SWAIT = 1 << SWAIT_BIT,
  STEPP = 1 << STEPP_BIT
} wrapper_state_t;

wrapper_state_t if_curr_state, if_next_state;

// State logic
always_ff @( posedge clk, posedge rst ) begin
  if(rst)
    if_curr_state <= RESET;
  else
    if_curr_state <= if_next_state;
end

// Next state logic
always_comb begin
  unique case(1'b1)
    if_curr_state[RESET_BIT]: if_next_state = (inst_read_o) ? SADDR : RESET;
    if_curr_state[SADDR_BIT]: if_next_state = (cpu2axi_interface.ARREADY_M0) ? SWAIT : SADDR;
    if_curr_state[SWAIT_BIT]: if_next_state = (cpu2axi_interface.RVALID_M0) ? STEPP : SWAIT;
    if_curr_state[STEPP_BIT]: if_next_state = SADDR;
  endcase
end

// Output logic (IF-stage)
always_comb begin
  cpu2axi_interface.ARADDR_M0 = 0;
  cpu2axi_interface.ARID_M0 = 0; // master 0
  cpu2axi_interface.ARLEN_M0 = 0; // Burst = 1
  cpu2axi_interface.ARSIZE_M0 = 3'h4; // 4B per transfer
  cpu2axi_interface.ARBURST_M0 = `AXI_BURST_INC;
  cpu2axi_interface.ARVALID_M0 = 1'b0; // A3-39
  cpu2axi_interface.RREADY_M0 = 1'b0;
  stallreq_from_im = `Stop;
  stallreq_from_if = `Stop; 

  case(1'b1)
      
    if_curr_state[RESET_BIT]: begin
    end
    if_curr_state[SADDR_BIT]: begin
      cpu2axi_interface.ARADDR_M0 = inst_addr_o;
      cpu2axi_interface.ARVALID_M0 = 1'b1; // A3-39
    end
    if_curr_state[SWAIT_BIT]: begin
      cpu2axi_interface.RREADY_M0 = 1'b1;
    end
    if_curr_state[STEPP_BIT]: begin
      stallreq_from_im = `NoStop;
      stallreq_from_if = `NoStop; 
    end
  endcase
end

wrapper_state_t me_curr_state, me_next_state;

// State logic
always_ff @( posedge clk, posedge rst ) begin
  if(rst)
    me_curr_state <= RESET;
  else
    me_curr_state <= me_next_state;
end

// Next state logic
always_comb begin
  unique case(1'b1)
    me_curr_state[RESET_BIT]: me_next_state = (data_read_o) ? SADDR : RESET;
    me_curr_state[SADDR_BIT]: me_next_state = (cpu2axi_interface.ARREADY_M1) ? SWAIT : SADDR;
    me_curr_state[SWAIT_BIT]: me_next_state = (cpu2axi_interface.ARVALID_M1) ? STEPP : SWAIT;
    me_curr_state[STEPP_BIT]: me_next_state = (cpu2axi_interface.RLAST_M1) ? RESET : STEPP;
  endcase
end

// Output logic (ME-stage)
always_comb begin
  
  cpu2axi_interface.ARADDR_M1 = 0;
  cpu2axi_interface.ARID_M1 = 0; // master 0
  cpu2axi_interface.ARLEN_M1 = 0; // Burst = 1
  cpu2axi_interface.ARSIZE_M1 = 3'h4; // 4B per transfer
  cpu2axi_interface.ARBURST_M1 = `AXI_BURST_INC;
  cpu2axi_interface.ARVALID_M1 = 1'b0; // A3-39
  cpu2axi_interface.RREADY_M1 = 1'b0;
      
  unique case(1'b1)
      
    me_curr_state[RESET_BIT]: begin
    end
    me_curr_state[SADDR_BIT]: begin
      cpu2axi_interface.ARADDR_M1 = data_addr_o;
      cpu2axi_interface.ARVALID_M1 = 1'b1; // A3-39
    end
    me_curr_state[SWAIT_BIT]: begin
      cpu2axi_interface.ARADDR_M1 = 0;
      cpu2axi_interface.ARVALID_M1 = 1'b0; // A3-39
      cpu2axi_interface.RREADY_M1 = 1'b1;
    end
    me_curr_state[STEPP_BIT]: begin
      cpu2axi_interface.ARADDR_M1 = 0;
      cpu2axi_interface.ARVALID_M1 = 1'b0; // A3-39
    end
  endcase
end

endmodule
