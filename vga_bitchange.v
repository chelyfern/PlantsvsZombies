`timescale 1ns / 1ps

// Anisha Palaparthi and Chely Fernandez

module vga_bitchange(
	input clk,
	input bright,
	//5 different positions for the zombies
	input [9:0] hCount, vCount,
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
	parameter YELLOW = 12'b1111_1111_0000;
	parameter ORANGE = 12'b1111_1100_0000;
	parameter STEM_GREEN = 12'b0000_1011_0100;
	

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
	//Registers to hold zombie's X position
	reg[9:0] zombie0X;
	reg[9:0] zombie1X;
	reg[9:0] zombie2X;
	reg[9:0] zombie3X;
	reg[9:0] zombie4X;
	reg[49:0] zombieSpeed;// Regisiter to hold zombie speed
	//Store the current state
//	output q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW;
	reg [7:0] state;
	assign {q_I, q_L1, q_NL2, q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW} = state;
	
	//Local parameters for state
	parameter I = 8'b0000_0001, L1 = 8'b0000_0010, NL2 = 8'b0000_0100, L2 = 8'b0000_1000, NL3 = 8'b0001_0000, L3 = 8'b0010_0000, DoneL = 8'b0100_0000, DoneW = 8'b1000_0000;


	initial begin
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
    else if (sunflowerStem == 1)
        rgb = STEM_GREEN;
    else if (greyZone == 1)
        rgb = GREY;
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
			else
				begin
					reset = 1'b0;
				end
			end
		end
	
	//Range from 000 to 160 (vertically)
	assign greyZone = (vCount <= 10'd159) ? 1 : 0;

	//Range from 160 to 287
	assign zombie0 = ((vCount >= 10'd160) && (vCount <= 10'd287)) ? 1 : 0;

	//Range from 288 to 415
	assign zombie0 = ((vCount >= 10'd288) && (vCount <= 10'd415)) ? 1 : 0;

	//Range from 416 to 543
	assign zombie0 = ((vCount >= 10'd416) && (vCount <= 10'd543)) ? 1 : 0;

	//Range from 544 to 671
	assign zombie0 = ((vCount >= 10'd544) && (vCount <= 10'd671)) ? 1 : 0;

	//Range from 672 to 779
	assign zombie0 = ((vCount >= 10'd672) && (vCount <= 10'd779)) ? 1 : 0;
	 
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
//                           ||((vCount < 10'd340) && (vCount > 10'd328) && (hCount > 10'd280) && (hCount < 10'd295))
                           ||((vCount < 10'd332) && (vCount > 10'd318) && (hCount > 10'd280) && (hCount < 10'd295))
                           ||((vCount < 10'd332) && (vCount > 10'd318) && (hCount > 10'd290) && (hCount < 10'd305))
                           ||((vCount < 10'd322) && (vCount > 10'd308) && (hCount > 10'd300) && (hCount < 10'd310))
                           ) ? 1 : 0;
                     
     assign sunflowerStem = (//374-425, 425-475
                               ((vCount <= 10'd380) && (vCount >= 10'd374) && (hCount >= 10'd280) && (hCount <= 10'd296))
                             ||((vCount <= 10'd385) && (vCount >= 10'd380) && (hCount >= 10'd279) && (hCount <= 10'd295))
                             ||((vCount <= 10'd390) && (vCount >= 10'd385) && (hCount >= 10'd278) && (hCount <= 10'd294))
                             ||((vCount <= 10'd395) && (vCount >= 10'd390) && (hCount >= 10'd277) && (hCount <= 10'd293))
                             ||((vCount <= 10'd400) && (vCount >= 10'd395) && (hCount >= 10'd276) && (hCount <= 10'd292))
                             ||((vCount <= 10'd405) && (vCount >= 10'd400) && (hCount >= 10'd275) && (hCount <= 10'd291))
                             ||((vCount <= 10'd410) && (vCount >= 10'd405) && (hCount >= 10'd274) && (hCount <= 10'd290))
                             ||((vCount <= 10'd415) && (vCount >= 10'd410) && (hCount >= 10'd273) && (hCount <= 10'd289))
                             ||((vCount <= 10'd420) && (vCount >= 10'd415) && (hCount >= 10'd272) && (hCount <= 10'd288))
                             ||((vCount <= 10'd425) && (vCount >= 10'd420) && (hCount >= 10'd271) && (hCount <= 10'd287))
                     
                             ||((vCount <= 10'd470) && (vCount >= 10'd465) && (hCount >= 10'd280) && (hCount <= 10'd296))
                             ||((vCount <= 10'd465) && (vCount >= 10'd460) && (hCount >= 10'd279) && (hCount <= 10'd295))
                             ||((vCount <= 10'd460) && (vCount >= 10'd455) && (hCount >= 10'd278) && (hCount <= 10'd294))
                             ||((vCount <= 10'd455) && (vCount >= 10'd450) && (hCount >= 10'd277) && (hCount <= 10'd293))
                             ||((vCount <= 10'd450) && (vCount >= 10'd445) && (hCount >= 10'd276) && (hCount <= 10'd292))
                             ||((vCount <= 10'd445) && (vCount >= 10'd440) && (hCount >= 10'd275) && (hCount <= 10'd291))
                             ||((vCount <= 10'd440) && (vCount >= 10'd435) && (hCount >= 10'd274) && (hCount <= 10'd290))
                             ||((vCount <= 10'd435) && (vCount >= 10'd430) && (hCount >= 10'd273) && (hCount <= 10'd289))
                             ||((vCount <= 10'd430) && (vCount >= 10'd425) && (hCount >= 10'd272) && (hCount <= 10'd288))
                             ||((vCount <= 10'd425) && (vCount >= 10'd420) && (hCount >= 10'd271) && (hCount <= 10'd287))
                             
                             ||((vCount <= 10'd470) && (vCount >= 10'd465) && (hCount >= 10'd225) && (hCount <= 10'd272))
                             ||((vCount <= 10'd465) && (vCount >= 10'd460) && (hCount >= 10'd223) && (hCount <= 10'd295))
                             ||((vCount <= 10'd460) && (vCount >= 10'd455) && (hCount >= 10'd278) && (hCount <= 10'd294))
                             ||((vCount <= 10'd455) && (vCount >= 10'd450) && (hCount >= 10'd277) && (hCount <= 10'd293))
                             ||((vCount <= 10'd450) && (vCount >= 10'd445) && (hCount >= 10'd276) && (hCount <= 10'd292))
                             ||((vCount <= 10'd445) && (vCount >= 10'd440) && (hCount >= 10'd275) && (hCount <= 10'd291))
                             
                          
                             
                           ) ? 1 : 0;
endmodule