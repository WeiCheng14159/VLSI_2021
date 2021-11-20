`ifndef __cpu_types_pkg__
`define __cpu_types_pkg__

// package cpu_types_pkg

// `define InstBus                         31:0
// `define InstAddrBus                     31:0
// `define DataBus                         31:0
// `define DataAddrBus                     31:0
// `define Func3Bus                        2:0
// `define RegBus                          31:0
// `define MulBus                          63:0
// `define RegAddrBus                      4:0
// `define AluOpBus                        14:0
// 
// /* Instruction field */                
// `define OPCODE                          6:0
// `define FUNC3                           14:12
// `define FUNC7                           31:25
// `define RD                              11:7
// `define RS1                             19:15
// `define RS2                             24:20
// `define IMM12                           31:20
// 
// `define NOP                             32'h0000_0013  // addi x0, x0, 0
// `define NopRegAddr                      5'b00000
// 
//   localparam logic [31:0] ZeroWord  = 32'h0000_0000;
//   localparam logic [31:0] StartAddr = 32'h0000_0000;

//   typedef enum {
//     Enable  = 1'b1,
//     Disable = 1'b0
//   } RstEnb;
// 
//   typedef enum {
//     Enable  = 1'b1,
//     Disable = 1'b0
//   } WriteEnb;
// 
//   typedef enum {
//     Enable  = 1'b1,
//     Disable = 1'b0
//   } ReadEnb;
// 
//   typedef enum {
//     Enable  = 1'b1,
//     Disable = 1'b0
//   } ChipEnb;
// 
//   typedef enum {
//     Stall = 1'b1,
//     NoStall = 1'b0
//   } StallReq;
// 
//   typedef enum {
//     Taken = 1'b1,
//     NotTaken = 1'b0
//   } BranchReq;
// 
//   typedef enum {
//     In    = 1'b1,
//     NotIn = 1'b0
//   } DelaySlot;
// 
//   typedef enum {
//     True = 1'b1,
//     False = 1'b0
//   } CpuLogic;

//   localparam IF_STAGE = 0,
//              ID_STAGE = 1,
//              EX_STAGE = 2,
//              ME_STAGE = 3,
//              WB_STAGE = 4;

//   typedef enum {
//     FromReg = 1'b1,
//     FromPC  = 1'b0
//   } AluSrc1Sel;
//   
//   typedef enum {
//     FromReg = 1'b1,
//     FromImm = 1'b0
//   } AluSrc2Sel;

//   typedef struct packed {
//     StallReq from_if;
//     StallReq from_id;
//     StallReq from_ex;
//     StallReq from_me;
//   } StallReqBus;
// 
//   typedef struct packed {
//     logic [31:0] rdata;
//     logic [31:0] wdata;
//     logic [31:0] addr;
//     logic        enb;
//     logic [ 3:0] wen;
//   } MemBus;

// endpackage

interface RegfileInterface ();
  logic        wreg;
  logic [ 4:0] waddr;
  logic [31:0] wdata;
  logic rs1_read, rs2_read;
  logic [31:0] rs1_addr, rs2_addr;
  logic [31:0] rs1_data, rs2_data;

  modport rf_ports(
      input wreg, waddr, wdata, rs1_read, rs2_read, rs1_addr, rs2_addr,
      output rs1_data, rs2_data
  );

  modport id_ports(
      input rs1_data, rs2_data,
      output wreg, waddr, wdata, rs1_read, rs2_read, rs1_addr, rs2_addr
  );
endinterface : RegfileInterface

`endif
