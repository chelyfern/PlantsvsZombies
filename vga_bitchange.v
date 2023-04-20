`timescale 1ns / 1ps

// Anisha Palaparthi and Chely Fernandez

module vga_bitchange(
	input clk,
	input bright,
	//5 different positions for the zombies
	input [9:0] hCount, vCount,
	//Input for different buttons
	input upButton, downButton, leftButton, rightButton, selectButton;
	output reg [11:0] rgb,
	output reg [15:0] zombies_killed,
	output q_I, 
	output q_L1, 
	output q_NL2, 
	output q_L2, 
	output q_NL3, 
	output q_L3, 
	output q_DoneL, 
	output q_DoneW
    );

	//Color definitions
	parameter BLACK = 12'b0000_0000_0000;
	parameter GREY = 12'b0000_1011_0100;
	parameter LIGHT_GREY = 12'b0011_0011_0010;
	parameter GREEN = 12'b0000_1111_0000;
	parameter DARK_GREEN = 12'b0000_0011_0000;
	parameter YELLOW = 12'b1111_1111_0000;
	parameter ORANGE = 12'b1111_1100_0000;
	parameter RED = 12'b1111_0000_0000;
	parameter ZOMBIE_SKIN = 12'b1010_1010_1011;
	

	//End of screen
	parameter END_OF_LAWN = 10'd000;

	//Register definitions
	reg reset;
	wire greyZone;
	wire zombie0; // Wires to hold zombie information
	wire zombie1;
	wire zombie2;
	wire zombie3;
	wire zombie4;
	//Wires to hold if zombie has been "killed"
	wire zombie0Killed;
	wire zombie1Killed;
	wire zombie2Killed;
	wire zombie3Killed;
	wire zombie4Killed;
	//Registers to hold times that zombie has been hit by a pea
	reg[3:0] zombie0Hits;
	reg[3:0] zombie1Hits;
	reg[3:0] zombie2Hits;
	reg[3:0] zombie3Hits;
	reg[3:0] zombie4Hits;
	//Registers to hold zombie's X position
	reg[9:0] zombie0X;
	reg[9:0] zombie1X;
	reg[9:0] zombie2X;
	reg[9:0] zombie3X;
	reg[9:0] zombie4X;
	reg[49:0] zombieSpeed;// Regisiter to hold zombie speed
	//Wires to hold if any of the pea shots are enabled. There are 25 pea shots
	wire peaShot0X;
	wire peaShot1X;
	wire peaShot2X;
	wire peaShot3X;
	wire peaShot4X;
	wire peaShot5X;
	wire peaShot6X;
	wire peaShot7X;
	wire peaShot8X;
	wire peaShot9X;
	wire peaShot10X;
	wire peaShot11X;
	wire peaShot12X;
	wire peaShot13X;
	wire peaShot14X;
	wire peaShot15X;
	wire peaShot16X;
	wire peaShot17X;
	wire peaShot18X;
	wire peaShot19X;
	wire peaShot20X;
	wire peaShot21X;
	wire peaShot22X;
	wire peaShot23X;
	wire peaShot24X;
	//Wire to hold current selected plant box
	wire selectedPlantBox;
	wire isSelectingPlantBox;
	//Wire to hold current selected lawn position
	wire selectedLawnPosition;
	
	//Store the current state
//	output q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW;
	reg [7:0] state;
	assign {q_I, q_L1, q_NL2, q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW} = state;
	
	//Local parameters for state
	parameter I = 8'b0000_0001, L1 = 8'b0000_0010, NL2 = 8'b0000_0100, L2 = 8'b0000_1000, NL3 = 8'b0001_0000, L3 = 8'b0010_0000, DoneL = 8'b0100_0000, DoneW = 8'b1000_0000;


	initial begin
		//Initialize the X position on the zombies to be the right side of the lawn
		zombie0X = 10'd'799;
		zombie1X = 10'd'799;
		zombie2X = 10'd'799;
		zombie3X = 10'd'799;
		zombie4X = 10'd'799;
		//Initialize the zombies to be alive
		zombie0Killed = 1'b0;
		zombie1Killed = 1'b0;
		zombie2Killed = 1'b0;
		zombie3Killed = 1'b0;
		zombie4Killed = 1'b0;
		//TODO: initiliaze the state?
		zombies_killed = 15'd0;
		reset = 1'b0;
	end

	//TODO: define the zombie colors here
	//Define the color scheme
	always@ (*)
    if (~bright)
        rgb = BLACK;
    else if (sunflowerFace == 1)
        rgb = BLACK;
    else if (sunflowerInner == 1)
        rgb = ORANGE;
    else if (sunflowerOuter == 1)
        rgb = YELLOW;
	else if (zombie0 == 1 || zombie1 == 1 || zombie2 == 1 || zombie3 == 1 || zombie4 == 1)
		rgb = ZOMBIE_SKIN;
    else if (greyZone == 1)
        rgb = GREY;
	else if (GRID == 1)
		rgb = DARK_GREEN;
	else if (selectedPlantBox == 1)
		rgb = RED;
	else if (selectedLawnPosition == 1)
		rgb = RED;
    else
        rgb = GREEN; // background color
 
	//At every clock, move the zombies to the right by increasnig the zombie "speed"
	always@ (posedge clk)
		begin
		zombieSpeed = zombieSpeed + 50'd1;
		if (zombieSpeed >=  50'd500000) //500 thousand
			begin
			//Iterate through all zombies: if they have already started moving, then increment their position TODO ask for help on how to implement this
			zombie0X = zombie0X - 10'd1; //Move the zombie to the left
			zombie1X = zombie1X - 10'd1;
			zombie2X = zombie2X - 10'd1;
			zombie3X = zombie3X - 10'd1;
			zombie4X = zombie4X - 10'd1;
			zombieSpeed = 50'd0;
			//If a zombie reaches the end of the lawn, the user loses!
			//Check if any of the zombies have reached the end of the lawn
			if((zombie0X == END_OF_LAWN) || (zombie1X == END_OF_LAWN) || (zombie2X == END_OF_LAWN) || (zombie3X == END_OF_LAWN) || (zombie4X == END_OF_LAWN))
				begin
					state = DoneL;
					reset = 1'b1; //TODO I dont think you need to keep track of num zombies killed
				end
			//If zombies are hit by a pea shot, increment their number of shots
			//Zombie0 can be hit by pea shots 0 through 4
			if (peaShot0X == zombie0X || peaShot1X == zombie0X || peaShot2X == zombie0X || peaShot3X == zombie0X || peaShot4X == zombie0X)
				begin
					//Increment zombie hits
					zombie0Hits = zombie0Hits + 15'd1;
					if(zombie0Hits == 15'd5)
						begin
							zombie0Killed = 1'b1;
							zombies_killed = zombies_killed + 15'd1;
						end
				end
			//Zombie1 can be hit by pea shots 5 through 9
			if (peaShot5X == zombie1X || peaShot6X == zombie1X || peaShot7X == zombie1X || peaShot8X == zombie1X || peaShot9X == zombie1X)
				begin
					//Increment zombie hits
					zombie1Hits = zombie1Hits + 15'd1;
					if(zombie1Hits == 15'd5)
						begin
							zombie1Killed = 1'b1;
							zombies_killed = zombies_killed + 15'd1;
						end
				end
			//Zombie2 can be hit by pea shots 10 through 14
			if (peaShot10X == zombie2X || peaShot11X == zombie2X || peaShot12X == zombie2X || peaShot13X == zombie2X || peaShot14X == zombie2X)
				begin
					//Increment zombie hits
					zombie2Hits = zombie2Hits + 15'd1;
					if(zombie2Hits == 15'd5)
						begin
							zombie2Killed = 1'b1;
							zombies_killed = zombies_killed + 15'd1;
						end
				end
			//Zombie3 can be hit by pea shots 15 through 19
			if (peaShot15X == zombie3X || peaShot16X == zombie3X || peaShot17X == zombie3X || peaShot18X == zombie3X || peaShot19X == zombie3X)
				begin
					//Increment zombie hits
					zombie3Hits = zombie3Hits + 15'd1;
					if(zombie3Hits == 15'd5)
						begin
							zombie3Killed = 1'b1;
							zombies_killed = zombies_killed + 15'd1;
						end
				end
			//Zombie4 can be hit by pea shots 20 through 24
			if (peaShot20X == zombie4X || peaShot21X == zombie4X || peaShot22X == zombie4X || peaShot23X == zombie4X || peaShot24X == zombie4X)
				begin
					//Increment zombie hits
					zombie4Hits = zombie4Hits + 15'd1;
					if(zombie4Hits == 15'd5)
						begin
							zombie4Killed = 1'b1;
							zombies_killed = zombies_killed + 15'd1;
						end
				end
			//If all zombies are killed, go to the next state
			if(zombies_killed == 15'd5 && state == L1)
				begin
					state = NL2;
					reset = 1'b1;
				end
			else
				begin
					reset = 1'b0;
				end
			end
		end

	//Always at the posedge of the clock, check if the user has selected a lawn position
	always@ (posedge clk)
		if(selectButton == 1 && isSelectingPlantBox == 0)
			
	
	
	//Range from 000 to 160 (vertically)
	assign greyZone = (vCount <= 10'd159) ? 1 : 0;

	//Create 5 by 5 grid in the lawn
	assign GRID = ((vCount >= 10'd160) && (vCount <= 10'd4779)
		&& ((hCount >= 10'd0) && (hCount <= 10'd160)
		|| (hCount >= 10'd'320) && (hCount <= 10'd479)
		|| (hCount >= 10'd'640) && (hCount <= 10'd799))
		) ? 1 : 0;

	//Define the selected plant box

	//Range from 160 to 287
	assign zombie0 = ((vCount >= 10'd165) && (vCount <= 10'd282)
		&& (hCount >= zombie0X) && (hCount <= zombie0X + 10'd100)
		) ? 1 : 0;

	//Range from 288 to 415
	assign zombie1 = ((vCount >= 10'd293) && (vCount <= 10'd410)
		&& (hCount >= zombie1X) && (hCount <= zombie1X + 10'd100)
		) ? 1 : 0;

	//Range from 416 to 543
	assign zombie2 = ((vCount >= 10'd421) && (vCount <= 10'd538)
		&& (hCount >= zombie2X) && (hCount <= zombie2X + 10'd100)
		) ? 1 : 0;

	//Range from 544 to 671
	assign zombie3 = ((vCount >= 10'd549) && (vCount <= 10'd666)
		&& (hCount >= zombie3X) && (hCount <= zombie3X + 10'd100)
		) ? 1 : 0;

	//Range from 672 to 779
	assign zombie4 = ((vCount >= 10'd677) && (vCount <= 10'd774)
		&& (hCount >= zombie4X) && (hCount <= zombie4X + 10'd100)
		) ? 1 : 0;
	 
	//sunflower visualization (to be made relative to the top left corner location, need to add stem + movement)
	assign sunflowerOuter = 
	                   ( 
	                   ((vCount >= 10'd361) && (vCount <= 10'd374) && (hCount >= 10'd249) && (hCount <= 10'd326) )
	                   || ((vCount >= 10'd342) && (vCount <= 10'd360) && (hCount >= 10'd243) && (hCount <= 10'd332) )
	               
	                   || ((vCount >= 10'd324) && (vCount <= 10'd342) && (hCount >= 10'd237) && (hCount <= 10'd338) )
	                   || ((vCount >= 10'd307) && (vCount <= 10'd324) && (hCount >= 10'd231) && (hCount <= 10'd344) )
	                   || ((vCount >= 10'd289) && (vCount <= 10'd306) && (hCount >= 10'd225) && (hCount <= 10'd350) )
	               
	                   || ((vCount >= 10'd271) && (vCount <= 10'd288) && (hCount >= 10'd231) && (hCount <= 10'd344) )
	                   || ((vCount >= 10'd253) && (vCount <= 10'd270) && (hCount >= 10'd237) && (hCount <= 10'd338) )
	                   
	                   || ((vCount >= 10'd235) && (vCount <= 10'd252) && (hCount >= 10'd243) && (hCount <= 10'd332) )
	                   || ((vCount >= 10'd220) && (vCount <= 10'd234) && (hCount >= 10'd249) && (hCount <= 10'd326) )
                       ) ? 1 : 0;
	                       	                   
	assign sunflowerInner = ( (vCount < 10'd350) && (vCount > 10'd250) && (hCount > 10'd250) && (hCount < 10'd325) ) ? 1 : 0;

    assign sunflowerFace = ( 
                             ((vCount < 10'd285) && (vCount > 10'd270) && (hCount > 10'd270) && (hCount < 10'd280))
                           ||((vCount < 10'd285) && (vCount > 10'd270) && (hCount > 10'd295) && (hCount < 10'd305))
                           
                           ||((vCount < 10'd322) && (vCount > 10'd310) && (hCount > 10'd265) && (hCount < 10'd275))
                           ||((vCount < 10'd332) && (vCount > 10'd318) && (hCount > 10'd270) && (hCount < 10'd285))
                           ||((vCount < 10'd340) && (vCount > 10'd328) && (hCount > 10'd280) && (hCount < 10'd295))
                           ||((vCount < 10'd332) && (vCount > 10'd318) && (hCount > 10'd290) && (hCount < 10'd305))
                           ||((vCount < 10'd322) && (vCount > 10'd308) && (hCount > 10'd300) && (hCount < 10'd310))
                           ) ? 1 : 0;

endmodule