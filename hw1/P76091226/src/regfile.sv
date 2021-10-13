`include "def.v"
module regfile(
  input logic                 clk,
  input logic                 rst,

  input logic                 we_i,
  input logic   [`RegAddrBus] waddr_i,
  input logic       [`RegBus] wdata_i,

  input logic                 re1_i,
  input logic   [`RegAddrBus] raddr1_i,
  output logic      [`RegBus] rdata1_o,

  input logic                 re2_i,
  input logic   [`RegAddrBus] raddr2_i,
  output logic      [`RegBus] rdata2_o
);

  integer i;
  logic             [`RegBus] regs [0:`RegNum-1];

  /* Write reg file */
  always @(posedge clk, posedge rst) begin
    if(rst) begin
      for(i=0 ; i<`RegNum ; i=i+1) begin
        regs[i] <= `ZeroWord;
      end
    end else begin
      if((we_i == `WriteEnable) && (waddr_i != `RegNumLog2'h0)) begin
        regs[waddr_i] <= wdata_i;
      end
    end
  end

  // rdata1_o
  always @(*) begin
    if(rst) begin
      rdata1_o = `ZeroWord;
    end else if(raddr1_i == `RegNumLog2'h0) begin
      rdata1_o = `ZeroWord;
    end else if((raddr1_i == waddr_i) && (we_i == `WriteEnable) &&
                (re1_i == `ReadEnable)) begin
      rdata1_o = wdata_i;
    end else if(re1_i == `ReadEnable) begin
      rdata1_o = regs[raddr1_i];
    end else begin
      rdata1_o = `ZeroWord;
    end
  end

  // rdata2_o
  always @(*) begin
    if(rst) begin
      rdata2_o = `ZeroWord;
    end else if(raddr2_i == `RegNumLog2'h0) begin
      rdata2_o = `ZeroWord;
    end else if((raddr2_i == waddr_i) && (we_i == `WriteEnable) &&
                (re2_i == `ReadEnable)) begin
      rdata2_o = wdata_i;
    end else if(re2_i == `ReadEnable) begin
      rdata2_o = regs[raddr2_i];
    end else begin
      rdata2_o = `ZeroWord;
    end
  end

endmodule 
