`timescale 1ns / 1ps
module vga_bitchange(
	input clk,
	input bright,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
   );
	
	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	//parameter BLUE = 12'b0000_0000_1111;

	wire levelText;
	reg reset;

	initial begin
		reset = 1'b0;
	end
	
	
	always@ (*)
    if (~bright)
		rgb = BLACK; // force black if not bright
	 else if(levelText == 1)
		rgb = WHITE; // text color
    else

    //Write out the text "Level 1 Completed!"
    
	
endmodule
