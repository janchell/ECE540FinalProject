// 
// mfp_ahb_const.vh
//
// Verilog include file with AHB definitions
// 

//---------------------------------------------------
// Physical bit-width of memory-mapped I/O interfaces
//---------------------------------------------------
`define MFP_N_LED             16
`define MFP_N_SW              16
`define MFP_N_PB              5

//---------------------------------------------------
// Display addresses
//---------------------------------------------------
`define H_DIS_ADDR_MATCH        (7'h7d)

`define H_DIS_EN_ADDR           (32'h1f700000)
`define H_DIS_DIGL_ADDR         (32'h1f700008)
`define H_DIS_DIGH_ADDR         (32'h1f700004)
`define H_DIS_DP_ADDR           (32'h1f70000C)

//---------------------------------------------------
// Memory-mapped I/O addresses
//---------------------------------------------------
`define H_LED_ADDR    			(32'h1f800000)
`define H_SW_ADDR   			(32'h1f800004)
`define H_PB_ADDR   			(32'h1f800008)
`define H_BotInfo_ADDR   	    (32'h1f80000C)
`define H_BotUpdt_Sync_ADDR   	(32'h1f800010)
`define H_BotCtrl_ADDR   	    (32'h1f800014)
`define H_INT_ACK_ADDR   	    (32'h1f800018)

`define H_LED_IONUM   			(4'h0)
`define H_SW_IONUM  			(4'h1)
`define H_PB_IONUM  			(4'h2)
`define H_IO_BotInfo  			(4'h3)
`define H_IO_BotUpdt_Sync  	    (4'h4)
`define H_IO_BotCtrl  			(4'h5)
`define H_IO_INT_ACK  		    (4'h6)

//---------------------------------------------------
// RAM addresses
//---------------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		    (32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH  (8) 
`define H_RAM_ADDR_WIDTH		(16) 

`define H_RAM_RESET_ADDR_Match  (7'h7f)
`define H_RAM_ADDR_Match 		(1'b0)
`define H_LED_ADDR_Match		(7'h7e)

//---------------------------------------------------
// AHB-Lite values used by MIPSfpga core
//---------------------------------------------------

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b010
