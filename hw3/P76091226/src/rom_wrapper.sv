`include "pkg_include.sv"

module rom_wrapper
  import rom_wrapper_pkg::*;
#(
    parameter [`AXI_ADDR_BITS-1:0] addr_upper_bound = {32'h27C}
) (
    input  logic                                clk,
    input  logic                                rstn,
           AXI_slave_intf.slave                 slave,
    // ROM module
    input  logic                [DATA_SIZE-1:0] ROM_out,
    output logic                                ROM_read,
    output logic                                ROM_enable,
    output logic                [ADDR_SIZE-1:0] ROM_address
);

  rom_wrapper_state_t curr_state, next_state;
  logic ARx_hs_done, Rx_hs_done;

  logic [ADDR_SIZE-1:0] ROM_address_r;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_r;
  logic [`AXI_IDS_BITS-1:0] ID_r;
  logic [`AXI_LEN_BITS-1:0] LEN_r;
  logic [`AXI_LEN_BITS-1:0] len_cnt;
  logic addr_overflow;

  // Handshake signal
  assign ARx_hs_done = slave.ARVALID & slave.ARREADY;
  assign Rx_hs_done = slave.RVALID & slave.RREADY;
  // Rx
  assign slave.RLAST = (len_cnt == LEN_r);
  assign slave.RDATA = ROM_out;
  assign slave.RID = ID_r;
  assign slave.RRESP = `AXI_RESP_OKAY;
  // Bx
  assign slave.BID = ID_r;
  assign slave.BRESP = `AXI_RESP_SLVERR;
  // Other
  assign addr_overflow = (ARADDR_r > addr_upper_bound);
  assign ROM_address_r = ARADDR_r[15:2];

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end  // State

  always_comb begin
    next_state = IDLE;
    case (curr_state)
      IDLE: next_state = (slave.ARVALID) ? READ : IDLE;
      READ: next_state = (Rx_hs_done & slave.RLAST) ? IDLE : READ;
    endcase
  end  // Next state (C)

  always_comb begin
    slave.AWREADY = 1'b0;
    slave.WREADY = 1'b0;
    slave.BVALID = 1'b0;
    slave.ARREADY = 1'b0;
    slave.RVALID = 1'b0;
    ROM_read = ROM_READ_DIS;
    ROM_enable = 1'b0;
    ROM_address = ROM_address_r;

    case (curr_state)
      IDLE: begin
        slave.ARREADY = ~slave.AWVALID;
        slave.RVALID = 1'b0;
        ROM_read = (slave.ARVALID) ? ROM_READ_ENB : ROM_READ_DIS;
        ROM_enable = (slave.ARVALID) ? ROM_ENB : ROM_DIS;
        ROM_address = slave.ARADDR[15:2];
      end
      READ: begin
        slave.ARREADY = slave.RLAST & Rx_hs_done;
        slave.RVALID = 1'b1;
        ROM_read = ROM_READ_ENB;
        ROM_enable = ROM_ENB;
        ROM_address = (ROM_address_r + len_cnt + 1'b1);
      end
      default: ;
    endcase
  end


  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      len_cnt <= `AXI_LEN_BITS'b0;
    end else if (curr_state[READ_BIT]) begin
      len_cnt <= (slave.RLAST & Rx_hs_done) ? `AXI_LEN_BITS'b0 : (Rx_hs_done) ? len_cnt + `AXI_LEN_BITS'b1 : len_cnt;
    end else if (curr_state[IDLE_BIT]) begin
      len_cnt <= `AXI_LEN_BITS'b0;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ARADDR_r <= `AXI_ADDR_BITS'b0;
      ID_r     <= `AXI_IDS_BITS'b0;
      LEN_r    <= `AXI_LEN_BITS'b0;
    end else begin
      ARADDR_r <= (ARx_hs_done) ? slave.ARADDR : ARADDR_r;
      ID_r     <= (ARx_hs_done) ? slave.ARID : ID_r;
      LEN_r    <= (ARx_hs_done) ? slave.ARLEN : LEN_r;
    end

  end

endmodule
