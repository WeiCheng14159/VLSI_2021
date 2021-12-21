`include "pkg_include.sv"
`include "sensor_ctrl.sv"
`define EN_ADDR 10'h40
`define CLEAR_ADDR 10'h80 

module sensor_wrapper (
    input  logic                       clk,
    input  logic                       rstn,
           AXI_slave_intf.slave        slave,
    input  logic                       sensor_ready,
    input  logic                [31:0] sensor_out,
    output logic                       sensor_en,
    output logic                       sensor_interrupt
);

  parameter STATE_IDLE = 2'b0, STATE_READ = 2'b1, STATE_WRITE = 2'b10;
  logic sctrl_en;
  logic sctrl_clear;
  logic [4:0] sctrl_addr;
  logic [1:0] state;
  logic [1:0] nxt_state;
  logic [`AXI_IDS_BITS-1:0] prevID;
  logic [`AXI_LEN_BITS-1:0] prevLEN;
  logic [`AXI_SIZE_BITS-1:0] prevSIZE;
  logic [`AXI_ADDR_BITS-1:0] prevADDR;
  logic [1:0] prevBURST;
  logic ARFin;
  logic AWFin;
  logic RFin;
  logic BFin;
  logic WFin;
  logic [9:0] sensorADDR;
  logic [`AXI_LEN_BITS-1:0] cnt;
  logic lockAW;
  logic lockB;
  logic lockW;

  assign ARFin = slave.ARVALID & slave.ARREADY;
  assign AWFin = slave.AWVALID & slave.AWREADY;
  assign RFin = slave.RVALID & slave.RREADY;
  assign BFin = slave.BVALID & slave.BREADY;
  assign WFin = slave.WVALID & slave.WREADY;
  assign slave.RID = prevID;
  assign slave.RRESP = `AXI_RESP_OKAY;
  assign slave.RLAST = cnt == prevLEN;
  assign slave.BID = prevID;
  assign slave.BRESP = `AXI_RESP_OKAY;


  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) state <= STATE_IDLE;
    else state <= nxt_state;
  end

  always_comb begin
    case (state)
      STATE_IDLE:
      nxt_state = (slave.AWVALID) ? STATE_WRITE : (slave.ARVALID) ? STATE_READ : STATE_IDLE;
      STATE_READ: nxt_state = (slave.RLAST & RFin) ? STATE_IDLE : STATE_READ;
      STATE_WRITE: nxt_state = (slave.WLAST & BFin) ? STATE_IDLE : STATE_WRITE;
      default: nxt_state = STATE_IDLE;
    endcase
  end

  always_comb begin
    slave.ARREADY = 1'b0;
    slave.AWREADY = 1'b0;
    slave.WREADY  = 1'b0;
    slave.RVALID  = 1'b0;
    slave.BVALID  = 1'b0;
    case (state)
      STATE_IDLE: begin
        slave.ARREADY = ~slave.AWVALID;
        slave.AWREADY = 1'b1;
      end
      STATE_READ: begin
        slave.RVALID = 1'b1;
      end
      STATE_WRITE: begin
        slave.BVALID = lockW;
        slave.WREADY = lockB | lockAW;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      prevID    <= `AXI_IDS_BITS'b0;
      prevLEN   <= `AXI_LEN_BITS'b0;
      prevSIZE  <= `AXI_SIZE_BITS'b0;
      prevADDR  <= `AXI_ADDR_BITS'b0;
      prevBURST <= 2'b0;
      cnt       <= `AXI_LEN_BITS'b0;
      lockAW    <= 1'b0;
      lockB     <= 1'b0;
      lockW     <= 1'b0;
    end else begin
      lockAW <= (lockAW & WFin) ? 1'b0 : (AWFin) ? 1'b1 : lockAW;
      lockW <= (WFin) ? 1'b1 : (lockW & BFin) ? 1'b0 : lockW;
      lockB <= (BFin) ? 1'b1 : (lockB & ~BFin) ? 1'b0 : lockB;
      prevID <= (AWFin) ? slave.AWID : (ARFin) ? slave.ARID : prevID;
      prevLEN <= (AWFin) ? slave.AWLEN : (ARFin) ? slave.ARLEN : prevLEN;
      prevSIZE <= (AWFin) ? slave.AWSIZE : (ARFin) ? slave.ARSIZE : prevSIZE;
      prevADDR <= (AWFin) ? slave.AWADDR : (ARFin) ? slave.ARADDR : prevADDR;
      prevBURST   <= (AWFin) ?slave.AWBURST:(ARFin)?slave.ARBURST: prevBURST;
      cnt         <= ((slave.WLAST & BFin) | (slave.RLAST & RFin)) ? `AXI_LEN_BITS'b0 : (WFin | RFin) ? cnt + `AXI_LEN_BITS'b1 : cnt;
    end
  end

  always_comb begin
    unique if (prevBURST == `AXI_BURST_FIXED) begin
      sensorADDR = prevADDR[2+:10];
    end else if (prevBURST == `AXI_BURST_INC) begin
      sensorADDR = prevADDR[2+:10] + {2'b0, cnt};
    end else sensorADDR = prevADDR[2+:10];
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      sctrl_en <= 1'b0;
      sctrl_clear <= 1'b0;
    end else if (slave.WVALID) begin
      unique if (sensorADDR == `EN_ADDR) sctrl_en <= slave.WDATA[0];
      else if (sensorADDR == `CLEAR_ADDR) sctrl_clear <= slave.WDATA[0];
    end
  end

  sensor_ctrl sensor_ctrl (
      .clk(clk),
      .rst(~rstn),
      .sctrl_en(sctrl_en),
      .sctrl_clear(sctrl_clear),
      .sctrl_addr(sensorADDR[5:0]),
      .sensor_ready(sensor_ready),
      .sensor_out(sensor_out),
      .sctrl_interrupt(sensor_interrupt),
      .sctrl_out(slave.RDATA),
      .sensor_en(sensor_en)
  );
endmodule
