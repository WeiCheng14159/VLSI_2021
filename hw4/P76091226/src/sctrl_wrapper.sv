`include "pkg_include.sv"
`include "sensor_ctrl.sv"

module sctrl_wrapper
  import sensor_wrapper_pkg::*;
(
    input  logic                       clk,
    input  logic                       rstn,
    input  logic                       sensor_ready,
    input  logic                [31:0] sensor_out,
    output logic                       sensor_en,
    output logic                       sensor_interrupt,
           AXI_slave_intf.slave        slave
);

  logic sctrl_en, sctrl_clear;
  logic [9:0] sensor_addr;
  logic [ADDR_SIZE-1:0] sctrl_addr;
  // AXI register
  logic [`AXI_IDS_BITS-1:0] ID_r;
  logic [`AXI_LEN_BITS-1:0] LEN_r;
  logic [`AXI_SIZE_BITS-1:0] SIZE_r;
  logic [`AXI_ADDR_BITS-1:0] ADDR_r;
  logic [1:0] BURST_r;
  logic lockAW, lockB, lockW;
  logic ARx_hs_done, AWx_hs_done, Rx_hs_done, Bx_hs_done, Wx_hs_done;
  logic [`AXI_LEN_BITS-1:0] cnt;

  sensor_wrapper_state_t curr_state, next_state;

  assign ARx_hs_done = slave.ARVALID & slave.ARREADY;
  assign AWx_hs_done = slave.AWVALID & slave.AWREADY;
  assign Rx_hs_done  = slave.RVALID & slave.RREADY;
  assign Bx_hs_done  = slave.BVALID & slave.BREADY;
  assign Wx_hs_done  = slave.WVALID & slave.WREADY;

  assign slave.RID   = ID_r;
  assign slave.RRESP = `AXI_RESP_OKAY;
  assign slave.RLAST = cnt == LEN_r;
  assign slave.BID   = ID_r;
  assign slave.BRESP = `AXI_RESP_OKAY;

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end  // State (S)

  always_comb begin
    case (curr_state)
      IDLE:
      next_state = (slave.AWVALID) ? WRITE : (slave.ARVALID) ? READ : IDLE;
      READ: next_state = (slave.RLAST & Rx_hs_done) ? IDLE : READ;
      WRITE: next_state = (Bx_hs_done) ? IDLE : WRITE;
      default: next_state = IDLE;
    endcase
  end  // Next state (C)

  always_comb begin
    slave.ARREADY = 1'b0;
    slave.AWREADY = 1'b0;
    slave.WREADY  = 1'b0;
    slave.RVALID  = 1'b0;
    slave.BVALID  = 1'b0;

    case (curr_state)
      IDLE: begin
        slave.ARREADY = ~slave.AWVALID;
        slave.AWREADY = 1'b1;
      end
      READ: begin
        slave.RVALID = 1'b1;
      end
      WRITE: begin
        slave.BVALID = lockW;
        slave.WREADY = lockB | lockAW;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ID_r    <= `AXI_IDS_BITS'b0;
      LEN_r   <= `AXI_LEN_BITS'b0;
      SIZE_r  <= `AXI_SIZE_BITS'b0;
      ADDR_r  <= `AXI_ADDR_BITS'b0;
      BURST_r <= 2'b0;
    end else begin
      ID_r <= (AWx_hs_done) ? slave.AWID : (ARx_hs_done) ? slave.ARID : ID_r;
      LEN_r <= (AWx_hs_done) ? slave.AWLEN : (ARx_hs_done) ? slave.ARLEN : LEN_r;
      SIZE_r <= (AWx_hs_done) ? slave.AWSIZE : (ARx_hs_done) ? slave.ARSIZE : SIZE_r;
      ADDR_r <= (AWx_hs_done) ? slave.AWADDR : (ARx_hs_done) ? slave.ARADDR : ADDR_r;
      BURST_r   <= (AWx_hs_done) ? slave.AWBURST: (ARx_hs_done)? slave.ARBURST: BURST_r;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      cnt <= `AXI_LEN_BITS'b0;
      lockAW <= 1'b0;
      lockB <= 1'b0;
      lockW <= 1'b0;
    end else begin
      cnt <= ((Bx_hs_done) | (slave.RLAST & Rx_hs_done)) ? `AXI_LEN_BITS'b0 : (Wx_hs_done | Rx_hs_done) ? cnt + `AXI_LEN_BITS'b1 : cnt;
      lockAW <= (lockAW & Wx_hs_done) ? 1'b0 : (AWx_hs_done) ? 1'b1 : lockAW;
      lockW <= (Wx_hs_done) ? 1'b1 : (lockW & Bx_hs_done) ? 1'b0 : lockW;
      lockB <= (Bx_hs_done) ? 1'b1 : (lockB & ~Bx_hs_done) ? 1'b0 : lockB;
    end
  end

  // sensor control
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      sctrl_en <= SCTRL_DIS;
      sctrl_clear <= 1'b0;
    end else if (slave.WVALID) begin
      unique if (sensor_addr == SCTRL_ENB_ADDR) sctrl_en <= slave.WDATA[0];
      else if (sensor_addr == SCTRL_CLEAR_ADDR) sctrl_clear <= slave.WDATA[0];
    end
  end

  always_comb begin
    unique if (BURST_r == `AXI_BURST_FIXED) begin
      sensor_addr = ADDR_r[2+:10];
    end else if (BURST_r == `AXI_BURST_INC) begin
      sensor_addr = ADDR_r[2+:10] + {2'b0, cnt};
    end else sensor_addr = ADDR_r[2+:10];
  end

  sensor_ctrl sensor_ctrl (
      .clk(clk),
      .rst(~rstn),
      .sctrl_en(sctrl_en),
      .sctrl_clear(sctrl_clear),
      .sctrl_addr(sensor_addr[5:0]),
      .sensor_ready(sensor_ready),
      .sensor_out(sensor_out),
      .sctrl_interrupt(sensor_interrupt),
      .sctrl_out(slave.RDATA),
      .sensor_en(sensor_en)
  );
endmodule
