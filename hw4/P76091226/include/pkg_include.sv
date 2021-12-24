// This file include all used package

// Interface
`include "AXI_master_intf.sv"
`include "AXI_slave_intf.sv"
// AXI
`include "master_pkg.sv"
`include "sram_wrapper_pkg.sv"
`include "axi_pkg.sv"
`include "AXI_define.svh"
// Cache
`include "i_cache_pkg.sv"
`include "d_cache_pkg.sv"
`include "cache.svh"
`include "cache2cpu_intf.sv"
`include "cache2mem_intf.sv"
// CPU
`include "cpu_wrapper_pkg.sv"
`include "cpu_pkg.sv"
`include "CSR_pkg.sv"
`include "CSR_ctrl_intf.sv"
`include "register_ctrl_intf.sv"
// Sensor
`include "sensor_wrapper_pkg.sv"
// DRAM
`include "dram_wrapper_pkg.sv"
// ROM
`include "rom_wrapper_pkg.sv"
