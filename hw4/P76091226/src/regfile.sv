module regfile
  import cpu_pkg::*;
(
    input logic clk,
    input logic rstn,

    register_ctrl_intf.regfile rf
);

  integer                   i;
  logic   [RegBusWidth-1:0] regs[0:RegNum-1];

  /* Write reg file */
  always @(posedge clk, negedge rstn) begin
    if (~rstn) begin
      for (i = 0; i < RegNum; i = i + 1) begin
        regs[i] <= ZeroWord;
      end
    end else begin
      if ((rf.we == WriteEnable) && (rf.waddr != ZERO_REG)) begin
        regs[rf.waddr] <= rf.wdata;
      end
    end
  end

  // rf.rdata1
  always_comb begin
    if (rf.raddr1 == ZERO_REG) begin
      rf.rdata1 = ZeroWord;
    end else if((rf.raddr1 == rf.waddr) && (rf.we == WriteEnable) &&
                (rf.re1 == ReadEnable)) begin
      rf.rdata1 = rf.wdata;
    end else if (rf.re1 == ReadEnable) begin
      rf.rdata1 = regs[rf.raddr1];
    end else begin
      rf.rdata1 = ZeroWord;
    end
  end

  // rf.rdata2
  always_comb begin
    if (rf.raddr2 == ZERO_REG) begin
      rf.rdata2 = ZeroWord;
    end else if((rf.raddr2 == rf.waddr) && (rf.we == WriteEnable) &&
                (rf.re2 == ReadEnable)) begin
      rf.rdata2 = rf.wdata;
    end else if (rf.re2 == ReadEnable) begin
      rf.rdata2 = regs[rf.raddr2];
    end else begin
      rf.rdata2 = ZeroWord;
    end
  end

endmodule
