`timescale 1ns / 1ns
`default_nettype none

//    This file is part of the ZXUNO Spectrum core. 
//    Creation date is 02:28:18 2014-02-06 by Miguel Angel Rodriguez Jodar
//    (c)2014-2020 ZXUNO association.
//    ZXUNO official repository: http://svn.zxuno.com/svn/zxuno
//    Username: guest   Password: zxuno
//    Github repository for this core: https://github.com/mcleod-ideafix/zxuno_spectrum_core
//
//    ZXUNO Spectrum core is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    ZXUNO Spectrum core is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with the ZXUNO Spectrum core.  If not, see <https://www.gnu.org/licenses/>.
//
//    Any distributed copy of this file must keep this notice intact.

module guest_mist
(
   input         CLOCK_27,   // Input clock 27 MHz

   output  [5:0] VGA_R,
   output  [5:0] VGA_G,
   output  [5:0] VGA_B,
   output        VGA_HS,
   output        VGA_VS,

   output        LED,

   output        AUDIO_L,
   output        AUDIO_R,
	
	output [15:0] DAC_L,
	output [15:0] DAC_R,
	

   output        UART_TX,
   input         UART_RX,

   input         SPI_SCK,
   output        SPI_DO,
   input         SPI_DI,
   input         SPI_SS2,
   input         SPI_SS3,
	input         SPI_SS4,
   input         CONF_DATA0,

   output [12:0] SDRAM_A,
   inout  [15:0] SDRAM_DQ,
   output        SDRAM_DQML,
   output        SDRAM_DQMH,
   output        SDRAM_nWE,
   output        SDRAM_nCAS,
   output        SDRAM_nRAS,
   output        SDRAM_nCS,
   output  [1:0] SDRAM_BA,
   output        SDRAM_CLK,
   output        SDRAM_CKE
);

parameter CONF_STR = {
        "ZXUNO;;",
        "S0,VHD,Load SD;",
        "O56,Scanlines,Off,25%,50%,75%;",
        "T0,Reset"
};



// the status register is controlled by the on screen display (OSD)
wire [63:0] status;
wire tv15khz;
wire [1:0] buttons;
wire ypbpr, no_csync;

wire [7:0] joy0, joy1;

wire [1:0] scanlines = status[6:5];

wire ps2_kbd_clk, ps2_kbd_data;
wire ps2_mouse_clk, ps2_mouse_data;

user_io #(.STRLEN($size(CONF_STR)>>3)) user_io (
	.clk_sys        ( clk_sys        ),
	.clk_sd         ( clk_sys        ),
	.conf_str       ( CONF_STR       ),

	.SPI_CLK        ( SPI_SCK        ),
	.SPI_SS_IO      ( CONF_DATA0     ),
	.SPI_MISO       ( SPI_DO         ),
	.SPI_MOSI       ( SPI_DI         ),

	.scandoubler_disable ( tv15khz   ),
	.buttons        ( buttons        ),

	.joystick_0     ( joy0           ),
	.joystick_1     ( joy1           ),

	// ps2 interface
	.ps2_kbd_clk    ( ps2_kbd_clk    ),
	.ps2_kbd_data   ( ps2_kbd_data   ),
	.ps2_mouse_clk  ( ps2_mouse_clk  ),
	.ps2_mouse_data ( ps2_mouse_data ),

	.status         ( status         ),
	.ypbpr          ( ypbpr          ),
	.no_csync       ( no_csync       ),

	// interface to embedded legacy sd card wrapper
	.sd_lba         ( sd_lba         ),
	.sd_rd          ( sd_rd          ),
	.sd_wr          ( sd_wr          ),
	.sd_ack         ( sd_ack         ),
	.sd_ack_conf    ( sd_ack_conf    ),
	.sd_conf        ( sd_conf        ),
	.sd_sdhc        ( sd_sdhc        ),
	.sd_dout        ( sd_dout        ),
	.sd_dout_strobe ( sd_dout_strobe ),
	.sd_din         ( sd_din         ),
	.sd_buff_addr   ( sd_buff_addr   )
);

wire [31:0] sd_lba;
wire sd_rd;
wire sd_wr;
wire sd_ack, sd_ack_conf;
wire sd_conf;
wire sd_sdhc; 
wire [7:0] sd_dout;
wire sd_dout_strobe;
wire [7:0] sd_din;
wire sd_din_strobe;
wire [8:0] sd_buff_addr;


wire sd_cs, sd_sck, sd_sdi, sd_sdo;

sd_card sd_card (
	.clk_sys         ( clk_sys        ),   // at least 2xsd_sck
	// connection to io controller
	.sd_lba          ( sd_lba         ),
	.sd_rd           ( sd_rd          ),
	.sd_wr           ( sd_wr          ),
	.sd_ack          ( sd_ack         ),
	.sd_conf         ( sd_conf        ),
	.sd_ack_conf     ( sd_ack_conf    ),
	.sd_sdhc         ( sd_sdhc        ),
	.sd_buff_dout    ( sd_dout        ),
	.sd_buff_wr      ( sd_dout_strobe ),
	.sd_buff_din     ( sd_din         ),
	.sd_buff_addr    ( sd_buff_addr   ),

	.allow_sdhc 	( 1'b1            ),   

	// connection to local CPU
	.sd_cs   		( sd_cs           ),
	.sd_sck  		( sd_sck          ),
	.sd_sdi  		( sd_sdi          ),
	.sd_sdo  		( sd_sdo          )
);


	wire audio_out_left;
   wire audio_out_right;
	
	
   wire clk_sys;
   wire clk_mem;

   wire locked;

   relojes	relojes_inst (
			.inclk0 	(CLOCK_27),
			.c0 		(clk_sys ),
			.c1 		(clk_mem ),
			.locked 	( locked )
	);


   wire [2:0] ri, gi, bi, ro, go, bo;
   wire hsync_pal, vsync_pal, csync_pal;
   wire vga_enable, scanlines_enable;
   wire clk14en_tovga;
   
 
//   wire [20:0] sram_addr_int;
//   assign sram_addr = sram_addr_int[19:0];
	



   zxuno #(.FPGA_MODEL(3'b010), .MASTERCLK(28000000)) la_maquina (
    .sysclk(clk_sys),
    .srdclk(clk_mem),
    .power_on_reset_n(1'b1),  // s�lo para simulaci�n. Para implementacion, dejar a 1
    .r(ri),
    .g(gi),
    .b(bi),
    .hsync(hsync_pal),
    .vsync(vsync_pal),
    .csync(csync_pal),
    .clkps2(ps2_kbd_clk),
    .dataps2(ps2_kbd_data),
    .ear_ext( UART_RX ),  // negada porque el hardware tiene un transistor inversor
    .audio_out_left(AUDIO_L),
    .audio_out_right(AUDIO_R),
	 
	 .left (DAC_L),
	 .right(DAC_R), 
    
    .midi_out(UART_TX),
    .clkbd(),
    .wsbd(),
    .dabd(),
	 
    .uart_tx(),
    .uart_rx(1'b1),
    .uart_rts(),

//    .sram_addr(sram_addr_int),
//    .sram_data(sram_data),
//    .sram_we_n(sram_we_n),

	.sdramCk (SDRAM_CLK ),
	.sdramCe (SDRAM_CKE ),
	.sdramCs (SDRAM_nCS ),
	.sdramRas(SDRAM_nRAS),
	.sdramCas(SDRAM_nCAS),
	.sdramWe (SDRAM_nWE),
	.sdramDqm({SDRAM_DQMH,SDRAM_DQML}),
	.sdramDQ (SDRAM_DQ ),
	.sdramBA (SDRAM_BA ),
	.sdramA  (SDRAM_A  ),

//    .flash_cs_n(flash_cs_n),
//    .flash_clk(flash_clk),
//    .flash_di(flash_mosi),
//    .flash_do(flash_miso),
    
    .sd_cs_n(sd_cs),
    .sd_clk(sd_sck),
    .sd_mosi(sd_sdi),
    .sd_miso(sd_sdo),
    

    .joy1up(joy0[0]),
    .joy1down(joy0[1]),
    .joy1left(joy0[2]),
    .joy1right(joy0[3]),
    .joy1fire1(joy0[4]),
    .joy1fire2(joy0[5]),   

	 
    .joy2up(joy1[0]),
    .joy2down(joy1[1]),
    .joy2left(joy1[2]),
    .joy2right(joy1[3]),
    .joy2fire1(joy1[4]),
    .joy2fire2(joy1[5]),   

    .mouseclk(ps2_mouse_clk),
    .mousedata(ps2_mouse_data),
    
//    .clk14en_tovga(clk14en_tovga),
//    .vga_enable(vga_enable),
//    .scanlines_enable(scanlines_enable),
//    .freq_option(pll_frequency_option),
    
    .ad724_xtal(),
    .ad724_mode(),
    .ad724_enable_gencolorclk()
    );
//
//	vga_scandoubler #(.CLKVIDEO(14000)) salida_vga (
//		.clk(clk_sys),
//    .clkcolor4x(1'b1),
//    .clk14en(clk14en_tovga),
//    .enable_scandoubling(vga_enable),
//    .disable_scaneffect(~scanlines_enable),
//		.ri(ri),
//		.gi(gi),
//		.bi(bi),
//		.hsync_ext_n(hsync_pal),
//		.vsync_ext_n(vsync_pal),
//      .csync_ext_n(csync_pal),
//		.ro(ro),
//		.go(go),
//		.bo(bo),
//		.hsync(VGA_HS),
//		.vsync(VGA_VS)
//   );	 
//   
mist_video #(.COLOR_DEPTH(3), .SD_HCNT_WIDTH(10), .SYNC_AND(1)) mist_video (
	.clk_sys     ( clk_sys    ),

	// OSD SPI interface
	.SPI_SCK     ( SPI_SCK    ),
	.SPI_SS3     ( SPI_SS3    ),
	.SPI_DI      ( SPI_DI     ),

	// scanlines (00-none 01-25% 10-50% 11-75%)
	.scanlines   ( scanlines  ),

	// non-scandoubled pixel clock divider 0 - clk_sys/4, 1 - clk_sys/2
	.ce_divider  ( 1'b0       ),

	// 0 = HVSync 31KHz, 1 = CSync 15KHz
	.scandoubler_disable ( tv15khz ),
	// disable csync without scandoubler
	.no_csync    ( no_csync   ),
	// YPbPr always uses composite sync
	.ypbpr       ( ypbpr      ),
	// Rotate OSD [0] - rotate [1] - left or right
	.rotate      ( 2'b00      ),
	// composite-like blending
	.blend       ( 1'b0       ),

	// video in
	.R           ( ri     ),
	.G           ( gi     ),
	.B           ( bi     ),

	.HSync       ( hsync_pal   ),
	.VSync       ( vsync_pal   ),

	// MiST video output signals
	.VGA_R       ( VGA_R      ),
	.VGA_G       ( VGA_G      ),
	.VGA_B       ( VGA_B      ),
	.VGA_VS      ( VGA_VS     ),
	.VGA_HS      ( VGA_HS     )
);
	
    assign LED = !sd_cs;
   //assign uart_reset = 1'bz;
   

	

   
endmodule
