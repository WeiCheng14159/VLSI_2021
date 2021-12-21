`ifndef CSR_PKG_SV
`define CSR_PKG_SV

package CSR_pkg;
  localparam VERSION = "v1.0";
  localparam AUTHOR = "Wei Cheng";

  // Width
  localparam CSR_ADDR_WIDTH = 12;
  localparam CSR_DATA_WIDTH = 32;
  localparam CSR_PC_WIDTH = 32;

  // Interface signal constant
  localparam CSR_EMPTY_DATA = {CSR_DATA_WIDTH{1'b0}};
  localparam CSR_EMPTY_ADDR = {CSR_ADDR_WIDTH{1'b0}};
  localparam CSR_EMPTY_PC = {CSR_PC_WIDTH{1'b0}};
  localparam CSR_WRITE_DIS = 1'b0, CSR_WRITE_ENB = 1'b1;
  localparam CSR_READ_DIS = 1'b0, CSR_READ_ENB = 1'b1;
  localparam CSR_INT_OFF = 1'b0, CSR_INT_ON = 1'b1;
  localparam CSR_STOP = 1'b1, CSR_NOSTOP = 1'b0;

  // CSR registers (Machine level)
  localparam CSR_MVENDORID = 12'hF11;  // Vender ID
  localparam CSR_MARCHID = 12'hF12;  // Architecture ID
  localparam CSR_MIMPID = 12'hF13;  // Implementation ID
  localparam CSR_MHARTID = 12'hF14;  // Hardware thread ID

  localparam CSR_MSTATUS = 12'h300;  // Machine status register
  localparam CSR_MISA = 12'h301;  // ISA and extensions
  localparam CSR_MEDELEG = 12'h302;  // Machine exception delegation register
  localparam CSR_MIDELEG = 12'h303;  // Machine interrupt delegation register
  localparam CSR_MIE = 12'h304;  // Machine interrupt-enable register
  localparam CSR_MTVEC = 12'h305;  // Machine trap-handler base address
  localparam CSR_MCOUNTEREN = 12'h306;  // Machine counter enable

  localparam CSR_MSCRATCH = 12'h340;    // Scratch register for machine trap handlers
  localparam CSR_MEPC = 12'h341;  // Machine exception program counter
  localparam CSR_MCAUSE = 12'h342;  // Machine trap cause
  localparam CSR_MTVAL = 12'h343;  // Machine bad address or instructions
  localparam CSR_MIP = 12'h344;  // Machine interrupt pending

  localparam CSR_SSTATUS = 12'h100;  // Supervisor status register
  localparam CSR_SIE = 12'h104;  // Supervisor interrupt-enable register
  localparam CSR_STVEC = 12'h105;  // Supervisor trap handler base address
  localparam CSR_SSCRATCH = 12'h140;    // Scratch register for supervisor trap handlers
  localparam CSR_SEPC = 12'h141;  // Supervisor exception program counter
  localparam CSR_SCAUSE = 12'h142;  // Supervisor trap cause
  localparam CSR_STVAL = 12'h143;  // Supervisor bad address or instruction
  localparam CSR_SIP = 12'h144;  // Supervisor interrupt pending
  localparam CSR_SATP = 12'h180;    // Supervisor address translation and protection

  localparam CSR_MCYCLE = 12'hb00; // The mcycle CSR holds a count of the number of cycles the hart has executed.
  localparam CSR_MINSTRET = 12'hb02; // The minstret CSR holds a count of the number of instructions the hart has retired.
  localparam CSR_MCYCLEH = 12'hb80;  // Upper 32 bit of counter
  localparam CSR_MINSTRETH = 12'hb82;  // Upper 32 bit of counter

  localparam CSR_RDCYCLE = 12'hc00;  // cycle counter
  localparam CSR_RDCYCLEH = 12'hc80;  // upper 32-bits of cycle counter
  localparam CSR_RDTIME = 12'hc01;  // timer counter
  localparam CSR_RDTIMEH = 12'hc81;  // upper 32-bits of timer counter
  localparam CSR_RDINSTRET = 12'hc02;  // Instructions-retired counter
  localparam CSR_RDINSTRETH  = 12'hc82;    // upper 32-bits of instruction-retired counter

  // mstatus register
  localparam UIE = 5'd0;  // U-mode global interrupt enable
  localparam SIE = 5'd1;  // S-mode global interrupt enable
  localparam MIE = 5'd3;  // M-mode global interrupt enable
  localparam UPIE = 5'd4;  // U-mode
  localparam SPIE = 5'd5;  // S-mode
  localparam MPIE = 5'd7;  // M-mode
  localparam SPP = 5'd8;  // S-mode hold the previous privilege mode
  localparam MPP = 5'd11;  // MPP[1:0] M-mode hold the previous privilege mode
  localparam FS = 5'd13;  // FS[1:0]
  localparam XS = 5'd15;  // XS[1:0]
  localparam MPRV = 5'd17;  // memory privilege
  localparam SUM = 5'd18;
  localparam MXR = 5'd19;
  localparam TVM = 5'd20;
  localparam TW = 5'd21;
  localparam TSR = 5'd22;

  // mie register
  localparam USIE = 5'd0;  // U-mode Software Interrupt Enable
  localparam SSIE = 5'd1;  // S-mode Software Interrupt Enable
  localparam MSIE = 5'd3;  // M-mode Software Interrupt Enable
  localparam UTIE = 5'd4;  // U-mode Timer Interrupt Enable
  localparam STIE = 5'd5;  // S-mode Timer Interrupt Enable
  localparam MTIE = 5'd7;  // M-mode Timer Interrupt Enable
  localparam UEIE = 5'd8;  // U-mode External Interrupt Enable
  localparam SEIE = 5'd9;  // S-mode External Interrupt Enable
  localparam MEIE = 5'd11;  // M-mode External Interrupt Enable

  // mip register
  localparam USIP = 5'd0;  // U-mode Software Interrupt Pending
  localparam SSIP = 5'd1;  // S-mode Software Interrupt Pending
  localparam MSIP = 5'd3;  // M-mode Software Interrupt Pending
  localparam UTIP = 5'd4;  // U-mode Timer Interrupt Pending
  localparam STIP = 5'd5;  // S-mode Timer Interrupt Pending
  localparam MTIP = 5'd7;  // M-mode Timer Interrupt Pending
  localparam UEIP = 5'd8;  // U-mode External Interrupt Pending
  localparam SEIP = 5'd9;  // S-mode External Interrupt Pending
  localparam MEIP = 5'd11;  // M-mode External Interrupt Pending

endpackage : CSR_pkg

`endif
