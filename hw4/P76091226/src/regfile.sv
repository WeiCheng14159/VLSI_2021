module regfile
  import cpu_pkg::*;
(
    input logic clk,
    input logic rstn,

    input logic                        we_i,
    input reg_addr_t                   waddr_i,
    input logic      [RegBusWidth-1:0] wdata_i,

    input  logic                        re1_i,
    input  reg_addr_t                   raddr1_i,
    output logic      [RegBusWidth-1:0] rdata1_o,

    input  logic                        re2_i,
    input  reg_addr_t                   raddr2_i,
    output logic      [RegBusWidth-1:0] rdata2_o
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
      if ((we_i == WriteEnable) && (waddr_i != ZERO_REG)) begin
        regs[waddr_i] <= wdata_i;
      end
    end
  end

  // rdata1_o
  always_comb begin
    if (raddr1_i == ZERO_REG) begin
      rdata1_o = ZeroWord;
    end else if((raddr1_i == waddr_i) && (we_i == WriteEnable) &&
                (re1_i == ReadEnable)) begin
      rdata1_o = wdata_i;
    end else if (re1_i == ReadEnable) begin
      rdata1_o = regs[raddr1_i];
    end else begin
      rdata1_o = ZeroWord;
    end
  end

  // rdata2_o
  always_comb begin
    if (raddr2_i == ZERO_REG) begin
      rdata2_o = ZeroWord;
    end else if((raddr2_i == waddr_i) && (we_i == WriteEnable) &&
                (re2_i == ReadEnable)) begin
      rdata2_o = wdata_i;
    end else if (re2_i == ReadEnable) begin
      rdata2_o = regs[raddr2_i];
    end else begin
      rdata2_o = ZeroWord;
    end
  end

endmodule
