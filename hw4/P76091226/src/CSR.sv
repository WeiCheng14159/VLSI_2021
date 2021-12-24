`include "pkg_include.sv"

module CSR
  import cpu_pkg::*;
  import CSR_pkg::*;
#(
    parameter [`AXI_ADDR_BITS-1:0] mtvec_addr = {32'h10000}
) (
    input  logic                                       clk,
    input  logic                                       rstn,
    input  logic                                       interrupt,
    output logic                  [CSR_DATA_WIDTH-1:0] CSR_rdata,
    output logic                                       stallreq,
           CSR_ctrl_intf.register                      csr_ctrl_i
);

  logic [CSR_DATA_WIDTH-1:0] mstatus;  // Machine status register
  logic [CSR_DATA_WIDTH-1:0] mie;  // Machine interrupt-enable register
  logic [CSR_DATA_WIDTH-1:0] mtvec; // Machine Trap-Vector Base-Address register
  logic [CSR_DATA_WIDTH-1:0] mepc;  // Machine exception program counter
  logic [CSR_DATA_WIDTH-1:0] mip;  // Machine interrupt pending register
  logic [CSR_DATA_WIDTH-1:0] mcycle;  // Lower 32bits of cycle counter
  logic [CSR_DATA_WIDTH-1:0] mcycleh;  // Upper 32bits of cycle counter
  logic [CSR_DATA_WIDTH-1:0] minstret; // ower 32bits of instruction-retired counter
  logic [CSR_DATA_WIDTH-1:0] minstreth; // Upper 32bits of instruction-retired counter

  // Not in this hw
  logic [CSR_DATA_WIDTH-1:0] mvendorid; // JEDEC manufacturer ID of the provider of the core
  logic [CSR_DATA_WIDTH-1:0] marchid; // the base microarchitecture of the hart.
  logic [CSR_DATA_WIDTH-1:0] mimpid; // Unique encoding of the version of the processor implementation
  logic [CSR_DATA_WIDTH-1:0] mhartid; // The integer ID of the hardware thread running the code

  logic zero;
  // Not implemented CSR reg
  assign mvendorid = CSR_EMPTY_DATA;
  assign marchid = CSR_EMPTY_DATA;
  assign mimpid = CSR_EMPTY_DATA;
  assign mhartid = CSR_EMPTY_DATA;

  assign mtvec = mtvec_addr;

  assign stallreq = csr_ctrl_i.CSR_wait & mie[MEIE] & ~interrupt;

  // mcycleh, mcycle
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      {mcycleh, mcycle} <= {2 * CSR_DATA_WIDTH{1'b0}};
      {minstreth, minstreth} <= {2 * CSR_DATA_WIDTH{1'b0}};
    end else begin
      {mcycleh, mcycle} <= {mcycleh, mcycle} + 1'b1;
      {minstreth, minstreth} <= {minstreth, minstreth} + 1'b1;
    end
  end

  // mstatus
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      mstatus <= CSR_EMPTY_DATA;
    end else if (csr_ctrl_i.CSR_ret) begin
      mstatus[MPIE] <= 1'b1;
      mstatus[MIE] <= mstatus[MPIE];
      mstatus[MPP+:2] <= 2'b11;
    end else if (interrupt) begin
      mstatus[MPIE] <= mip[MEIP] ? mstatus[MIE] : mstatus[MPIE];
      mstatus[MIE] <= mip[MEIP] ? 1'b0 : mstatus[MIE];
      mstatus[MPP+:2] <= mip[MEIP] ? 2'b11 : mstatus[MPP+:2];
    end else if (csr_ctrl_i.CSR_write & csr_ctrl_i.CSR_addr == CSR_MSTATUS) begin
      mstatus[MIE]    <= csr_ctrl_i.CSR_wdata[MIE];
      mstatus[MPIE]   <= csr_ctrl_i.CSR_wdata[MPIE];
      mstatus[MPP+:2] <= csr_ctrl_i.CSR_wdata[MPP+:2];
    end else begin
      mstatus <= mstatus;
    end
  end

  // mie
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      mie <= CSR_EMPTY_DATA;
    end else if (csr_ctrl_i.CSR_write & csr_ctrl_i.CSR_addr == CSR_MIE) begin
      mie[MEIE] <= csr_ctrl_i.CSR_wdata[MEIE];
    end else begin
      mie <= mie;
    end
  end

  // mip
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      mip <= CSR_EMPTY_DATA;
    end else if (interrupt) begin
      mip[MEIP] <= 1'b0;
    end else if (csr_ctrl_i.CSR_wait) begin
      mip[MEIP] <= mie[MEIE] ? 1'b1 : mip[MEIP];
    end else begin
      mip <= mip;
    end
  end

  assign MEIP_r = mip[MEIP];
  assign MEIE_r = mie[MEIE];
  assign MIE_r  = mstatus[MIE];
  assign MPIE_r = mstatus[MPIE];

  // mepc
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      mepc <= CSR_EMPTY_DATA;
    end else if (csr_ctrl_i.CSR_wait) begin
      mepc <= csr_ctrl_i.curr_pc + 32'h4;
    end else if (csr_ctrl_i.CSR_write & csr_ctrl_i.CSR_addr == CSR_MEPC) begin
      mepc[31:2] <= csr_ctrl_i.CSR_wdata[31:2];
    end else begin
      mepc <= mepc;
    end
  end

  always_comb begin
    case (csr_ctrl_i.CSR_addr)
      CSR_MSTATUS:   csr_ctrl_i.CSR_rdata = mstatus;
      CSR_MIE:       csr_ctrl_i.CSR_rdata = mie;
      CSR_MTVEC:     csr_ctrl_i.CSR_rdata = mtvec;
      CSR_MEPC:      csr_ctrl_i.CSR_rdata = mepc;
      CSR_MIP:       csr_ctrl_i.CSR_rdata = mip;
      CSR_MCYCLE:    csr_ctrl_i.CSR_rdata = mcycle;
      CSR_MINSTRET:  csr_ctrl_i.CSR_rdata = minstret;
      CSR_MCYCLEH:   csr_ctrl_i.CSR_rdata = mcycleh;
      CSR_MINSTRETH: csr_ctrl_i.CSR_rdata = minstreth;
      CSR_MVENDORID: csr_ctrl_i.CSR_rdata = mvendorid;
      CSR_MARCHID:   csr_ctrl_i.CSR_rdata = marchid;
      CSR_MIMPID:    csr_ctrl_i.CSR_rdata = mimpid;
      CSR_MHARTID:   csr_ctrl_i.CSR_rdata = mhartid;
      default:       csr_ctrl_i.CSR_rdata = CSR_EMPTY_DATA;
    endcase
  end

  assign CSR_rdata = csr_ctrl_i.CSR_rdata;
  assign csr_ctrl_i.CSR_ret_PC = mepc;
  assign csr_ctrl_i.CSR_ISR_PC = mtvec;

endmodule
