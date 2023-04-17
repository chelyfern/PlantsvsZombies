*timescale 1ns / 1ps

// Anisha Palaparthi and Chely Fernandez

module vga_bitchange(
	input clk,
	input bright,
	//5 different positions for the zombies
	input [9:0] hCount0, vCount0,
	input [9:0] hCount1, vCount1,
	input [9:0] hCount2, vCount2,
	input [9:0] hCount3, vCount3,
	input [9:0] hCount4, vCount4,
	output reg [11:0] rgb,
	output reg [15:0] zombies_killed
    );

	//Color definitions
	parameter BLACK = 12'b0000_0000_0000;
	parameter GREY = 12'b0000_1011_0100;
	parameter LIGHT_GREY = 12'b0011_0011_0010;
	parameter GREEN = 12'b0000_1111_0000;

	//Register definitions
	reg reset;
	wire greyZone;
	wire zombie0; // Wires to hold zombie information
	wire zombie1;
	wire zombie2;
	wire zombie3;
	wire zombie4;
	reg[49:0] zombieSpeed;// Regisiter to hold zombie speed

	initial begin
		zombies_killed = 15'd0;
		reset = 1'b0;
	end


	//Define the color scheme
	always@ (*)
	if (~bright)
		rgb = BLACK;
	else if (greyZone == 1)
		rgb = GREY;
	else
		rgb = GREEN; // background color

	//At every clock, move the zombies to the right by increasnig the zombie "speed"
	always@ (posedge clk)
		begin
		zombieSpeed = zombieSpeed + 50'd1;


