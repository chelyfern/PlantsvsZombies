*timescale 1ns / 1ps

// Anisha Palaparthi and Chely Fernandez

module vga_bitchange(
	input clk,
	output reg [15:0] zombies_killed
    );

	//Color definitions
	parameter GREY = 12'b0000_1011_0100;
	parameter LIGHT_GREY = 12'b0011_0011_0010;
	parameter GREEN = 12'b0000_1111_0000;

	//Register definitions
	reg reset;

	initial begin
		zombies_killed = 15'd0;
		reset = 1'b0;
	end


	//Define the color scheme
	always@ (*)

