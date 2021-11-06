`include "AXI_define.svh"

interface AXI2CPU_interface ();

  // AXI to master 1 (MEM-stage)
  //READ ADDRESS1
  logic [  `AXI_ID_BITS-1:0] ARID_M1;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M1;
  logic [ `AXI_LEN_BITS-1:0] ARLEN_M1;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1;
  logic [               1:0] ARBURST_M1;
  logic                      ARVALID_M1;
  logic                      ARREADY_M1;
  //READ DATA1
  logic [  `AXI_ID_BITS-1:0] RID_M1;
  logic [`AXI_DATA_BITS-1:0] RDATA_M1;
  logic [               1:0] RRESP_M1;
  logic                      RLAST_M1;
  logic                      RVALID_M1;
  logic                      RREADY_M1;
  //WRITE ADDRESS
  logic [  `AXI_ID_BITS-1:0] AWID_M1;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_M1;
  logic [ `AXI_LEN_BITS-1:0] AWLEN_M1;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1;
  logic [               1:0] AWBURST_M1;
  logic                      AWVALID_M1;
  logic                      AWREADY_M1;
  //WRITE DATA
  logic [`AXI_DATA_BITS-1:0] WDATA_M1;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M1;
  logic                      WLAST_M1;
  logic                      WVALID_M1;
  logic                      WREADY_M1;
  //WRITE RESPONSE
  logic [  `AXI_ID_BITS-1:0] BID_M1;
  logic [               1:0] BRESP_M1;
  logic                      BVALID_M1;
  logic                      BREADY_M1;

  // AXI to master 0 (IF-stage)
  //READ ADDRESM0
  logic [  `AXI_ID_BITS-1:0] ARID_M0;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M0;
  logic [ `AXI_LEN_BITS-1:0] ARLEN_M0;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0;
  logic [               1:0] ARBURST_M0;
  logic                      ARVALID_M0;
  logic                      ARREADY_M0;
  //READ DATA0
  logic [  `AXI_ID_BITS-1:0] RID_M0;
  logic [`AXI_DATA_BITS-1:0] RDATA_M0;
  logic [               1:0] RRESP_M0;
  logic                      RLAST_M0;
  logic                      RVALID_M0;
  logic                      RREADY_M0;

  modport cpu_ports(
      /* Master 1 = MEM stage */
      // AWx
      input AWREADY_M1,
      output AWID_M1, AWADDR_M1, AWLEN_M1, AWSIZE_M1, AWBURST_M1, AWVALID_M1,
      // Wx
      input WREADY_M1,
      output WDATA_M1, WSTRB_M1, WLAST_M1, WVALID_M1,
      // Bx
      input BID_M1, BRESP_M1, BVALID_M1,
      output BREADY_M1,
      // ARx
      input ARREADY_M1,
      output ARID_M1, ARADDR_M1, ARLEN_M1, ARSIZE_M1, ARBURST_M1, ARVALID_M1,
      // Rx
      input RID_M1, RDATA_M1, RRESP_M1, RLAST_M1, RVALID_M1,
      output RREADY_M1,
      /* Master 0 = IF stage */
      // ARx
      input ARREADY_M0,
      output ARID_M0, ARADDR_M0, ARLEN_M0, ARSIZE_M0, ARBURST_M0, ARVALID_M0,
      // Rx
      input RID_M0, RDATA_M0, RRESP_M0, RLAST_M0, RVALID_M0,
      output RREADY_M0
  );

  modport axi_ports(
      /* Master 1 = MEM stage */
      // AWx
      output AWREADY_M1,
      input AWID_M1, AWADDR_M1, AWLEN_M1, AWSIZE_M1, AWBURST_M1, AWVALID_M1,
      // Wx
      output WREADY_M1,
      input WDATA_M1, WSTRB_M1, WLAST_M1, WVALID_M1,
      // Bx
      output BID_M1, BRESP_M1, BVALID_M1,
      input BREADY_M1,
      // ARx
      output ARREADY_M1,
      input ARID_M1, ARADDR_M1, ARLEN_M1, ARSIZE_M1, ARBURST_M1, ARVALID_M1,
      // Rx
      output RID_M1, RDATA_M1, RRESP_M1, RLAST_M1, RVALID_M1,
      input RREADY_M1,
      /* Master 0 = IF stage */
      // ARx
      output ARREADY_M0,
      input ARID_M0, ARADDR_M0, ARLEN_M0, ARSIZE_M0, ARBURST_M0, ARVALID_M0,
      // Rx
      output RID_M0, RDATA_M0, RRESP_M0, RLAST_M0, RVALID_M0,
      input RREADY_M0
  );

endinterface : AXI2CPU_interface
