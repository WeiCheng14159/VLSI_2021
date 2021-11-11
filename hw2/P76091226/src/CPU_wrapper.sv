`include "def.v"
`include "CPU.sv"
`include "AXI_define.svh"

module CPU_wrapper (
    input logic clk,
    input logic rst,
    // Master 1 (MEM-stage)
    // AWx
    output logic [`AXI_ID_BITS-1:0] AWID_M1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    output logic [1:0] AWBURST_M1,
    output logic AWVALID_M1,
    input logic AWREADY_M1,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    output logic WLAST_M1,
    output logic WVALID_M1,
    input logic WREADY_M1,
    // Bx
    input logic [`AXI_ID_BITS-1:0] BID_M1,
    input logic [1:0] BRESP_M1,
    input logic BVALID_M1,
    output logic BREADY_M1,
    // ARx
    output logic [`AXI_ID_BITS-1:0] ARID_M1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    output logic [1:0] ARBURST_M1,
    output logic ARVALID_M1,
    input logic ARREADY_M1,
    // Rx
    input logic [`AXI_ID_BITS-1:0] RID_M1,
    input logic [`AXI_DATA_BITS-1:0] RDATA_M1,
    input logic [1:0] RRESP_M1,
    input logic RLAST_M1,
    input logic RVALID_M1,
    output logic RREADY_M1,
    // Master 0 (IF-stage)
    // Wx
    output logic [`AXI_ID_BITS-1:0] AWID_M0,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
    output logic [1:0] AWBURST_M0,
    output logic AWVALID_M0,
    input logic AWREADY_M0,
    // Wx
    output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
    output logic WLAST_M0,
    output logic WVALID_M0,
    input logic WREADY_M0,
    // Bx
    input logic [`AXI_ID_BITS-1:0] BID_M0,
    input logic [1:0] BRESP_M0,
    input logic BVALID_M0,
    output logic BREADY_M0,
    // ARx
    output logic [`AXI_ID_BITS-1:0] ARID_M0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    output logic [1:0] ARBURST_M0,
    output logic ARVALID_M0,
    input logic ARREADY_M0,
    // Rx
    input logic [`AXI_ID_BITS-1:0] RID_M0,
    input logic [`AXI_DATA_BITS-1:0] RDATA_M0,
    input logic [1:0] RRESP_M0,
    input logic RLAST_M0,
    input logic RVALID_M0,
    output logic RREADY_M0
);

  logic [    `InstBus]  inst_out_i;
  logic                 inst_read_o;
  logic [`InstAddrBus]  inst_addr_o;

  logic [    `DataBus]  data_out_i;
  logic                 data_read_o;
  logic [         3:0 ] data_write_o;
  logic [`DataAddrBus]  data_addr_o;
  logic [    `DataBus]  data_in_o;

  logic                 stallreq_from_im;
  logic                 stallreq_from_if;
  logic                 stallreq_from_mem;

  assign stallreq_from_mem = `NoStop;

  CPU cpu0 (
      .clk,
      .rst,

      .inst_out_i,
      .inst_read_o,
      .inst_addr_o,
      .data_out_i,
      .data_read_o,
      .data_write_o,
      .data_addr_o,
      .data_in_o,

      .stallreq_from_im,
      .stallreq_from_if,
      .stallreq_from_mem
  );

  localparam RESET_BIT = 0, SADDR_BIT = 1, SWAIT_BIT = 2, STEPP_BIT = 3;

  typedef enum logic [3:0] {
    RESET = 1 << RESET_BIT,
    SADDR = 1 << SADDR_BIT,
    SWAIT = 1 << SWAIT_BIT,
    STEPP = 1 << STEPP_BIT
  } wrapper_state_t;

  wrapper_state_t if_curr_state, if_next_state;

  // State logic
  always_ff @(posedge clk, posedge rst) begin
    if (rst) if_curr_state <= RESET;
    else if_curr_state <= if_next_state;
  end

  // Next state logic
  always_comb begin
    unique case (1'b1)
      if_curr_state[RESET_BIT]: if_next_state = (inst_read_o) ? SADDR : RESET;
      if_curr_state[SADDR_BIT]: if_next_state = (ARREADY_M0) ? SWAIT : SADDR;
      if_curr_state[SWAIT_BIT]: if_next_state = (RVALID_M0) ? STEPP : SWAIT;
      if_curr_state[STEPP_BIT]: if_next_state = SADDR;
    endcase
  end

  // Output logic (IF-stage)
  always_comb begin
    ARADDR_M0 = 0;
    ARID_M0 = 0;  // master 0
    ARLEN_M0 = 0;  // Burst = 1
    ARSIZE_M0 = 3'h4;  // 4B per transfer
    ARBURST_M0 = `AXI_BURST_INC;
    ARVALID_M0 = 1'b0;  // A3-39
    RREADY_M0 = 1'b0;
    stallreq_from_im = `Stop;
    stallreq_from_if = `Stop;

    case (1'b1)

      if_curr_state[RESET_BIT]: begin
      end
      if_curr_state[SADDR_BIT]: begin
        ARADDR_M0  = inst_addr_o;
        ARVALID_M0 = 1'b1;  // A3-39
      end
      if_curr_state[SWAIT_BIT]: begin
        RREADY_M0 = 1'b1;
      end
      if_curr_state[STEPP_BIT]: begin
        stallreq_from_im = `NoStop;
        stallreq_from_if = `NoStop;
      end
    endcase
  end

  wrapper_state_t me_curr_state, me_next_state;

  // State logic
  always_ff @(posedge clk, posedge rst) begin
    if (rst) me_curr_state <= RESET;
    else me_curr_state <= me_next_state;
  end

  // Next state logic
  always_comb begin
    unique case (1'b1)
      me_curr_state[RESET_BIT]: me_next_state = (data_read_o) ? SADDR : RESET;
      me_curr_state[SADDR_BIT]: me_next_state = (ARREADY_M1) ? SWAIT : SADDR;
      me_curr_state[SWAIT_BIT]: me_next_state = (ARVALID_M1) ? STEPP : SWAIT;
      me_curr_state[STEPP_BIT]: me_next_state = (RLAST_M1) ? RESET : STEPP;
    endcase
  end

  // Output logic (ME-stage)
  always_comb begin

    ARADDR_M1 = 0;
    ARID_M1 = 0;  // master 0
    ARLEN_M1 = 0;  // Burst = 1
    ARSIZE_M1 = 3'h4;  // 4B per transfer
    ARBURST_M1 = `AXI_BURST_INC;
    ARVALID_M1 = 1'b0;  // A3-39
    RREADY_M1 = 1'b0;

    unique case (1'b1)

      me_curr_state[RESET_BIT]: begin
      end
      me_curr_state[SADDR_BIT]: begin
        ARADDR_M1  = data_addr_o;
        ARVALID_M1 = 1'b1;  // A3-39
      end
      me_curr_state[SWAIT_BIT]: begin
        ARADDR_M1  = 0;
        ARVALID_M1 = 1'b0;  // A3-39
        RREADY_M1  = 1'b1;
      end
      me_curr_state[STEPP_BIT]: begin
        ARADDR_M1  = 0;
        ARVALID_M1 = 1'b0;  // A3-39
      end
    endcase
  end

endmodule
