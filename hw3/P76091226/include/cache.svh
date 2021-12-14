//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    def.svh
// Description: Hart defination
// Version:     0.1
//================================================
`ifndef CACHE_SVH
`define CACHE_SVH

// CPU
`define DATA_BITS 32

// Cache
`define CACHE_BLOCK_BITS 2
`define CACHE_INDEX_BITS 6  
`define CACHE_ADDR_BITS 10
`define CACHE_TAG_BITS 22
`define CACHE_LINE_BITS 64
`define CACHE_DATA_BITS 128
`define CACHE_LINES 2**(`CACHE_INDEX_BITS)
`define CACHE_WRITE_BITS 16
`define CACHE_TYPE_BITS 3
`define CACHE_BYTE `CACHE_TYPE_BITS'b000
`define CACHE_HWORD `CACHE_TYPE_BITS'b001
`define CACHE_WORD `CACHE_TYPE_BITS'b010
`define CACHE_BYTE_U `CACHE_TYPE_BITS'b100
`define CACHE_HWORD_U `CACHE_TYPE_BITS'b101

/*
| --------- | --------- | --------- | --------- |
| 31     10 | 9       4 | 3       2 | 1       0 |
| --------- | --------- | --------- | --------- |
| Tag (22b) | Index (6) | Word (2b) | Byte (2b) |
| --------- | --------- | --------- | --------- |
*/

`define TAG_FIELD 31:10
`define INDEX_FIELD 9:4
`define WORD_FIELD 3:2

//Read Write data length
`define WRITE_LEN_BITS 2
`define BYTE `WRITE_LEN_BITS'b00
`define HWORD `WRITE_LEN_BITS'b01
`define WORD `WRITE_LEN_BITS'b10

`endif
