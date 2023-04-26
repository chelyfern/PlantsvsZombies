`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:18:00 12/14/2017 
// Design Name: 
// Module Name:    vga_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
// Date: 04/04/2020
// Author: Yue (Julien) Niu
// Description: Port from NEXYS3 to NEXYS4
//////////////////////////////////////////////////////////////////////////////////
module vga_top(
	input ClkPort,
	input BtnC,
	input BtnU,
	input BtnD,
	input BtnL,
	input BtnR,
    input Sw4, Sw3, Sw2, Sw1, Sw0,

	
	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS
	);

    
	wire [4:0] switches;
    assign switches = {Sw4, Sw3, Sw2, Sw1, Sw0};
	
	wire bright;
	wire[9:0] hc, vc;
	wire[15:0] zombiesKilled;
	
	wire [6:0] ssdOut;
	wire [3:0] anode;
	wire [3:0] upperAnodes;
	wire [11:0] rgb;
	display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	vga_bitchange vbc(.clk(ClkPort), .bright(bright), .upButton(BtnU), .downButton(BtnD), .leftButton(BtnL), .rightButton(BtnR), 
	.selectButton(BtnC), .hCount(hc), .vCount(vc), .rgb(rgb), .zombies_killed(zombiesKilled), .switches(switches));
	
	counter cnt(.clk(ClkPort), .displayNumber(zombiesKilled), .anode(anode), .ssdOut(ssdOut));
//	counter cnt(.clk(ClkPort), .displayNumber(zombiesKilled), .anode(upperAnodes), .ssdOut(ssdOut));
	
	assign Dp = 1;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = ssdOut[6 : 0];
    assign {An7, An6, An5, An4, An3, An2, An1, An0} = {upperAnodes, anode};

	
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
	
	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

    

endmodule