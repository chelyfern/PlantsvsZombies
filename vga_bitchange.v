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
	parameter BROWN = 12'b0111_0011_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter PEA_GREEN = 12'b0111_1111_0010;

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
    parameter sfScale = 10'd1;
    parameter walnutScale = 10'd1; 
    parameter psScale = 10'd1;


    reg[9:0] sfVPos;
    reg[9:0] sfHPos;
    reg[9:0] sfVPosTemp;
    reg[9:0] sfHeadHPos;
    reg[9:0] sfHeadVPos;
    reg[49:0] sfBounceSpeed;
    reg sfHeadFlag;
    
    reg[9:0] psVPos;
    reg[9:0] psHPos;
    reg[9:0] psVPosTemp;
    reg[9:0] pVPos;
    reg[9:0] pHPos;
    reg[49:0] pSpeed;
    
    reg[9:0] wVPos;
    reg[9:0] wHPos;
    reg blink;

	initial begin
		zombies_killed = 15'd0;
		reset = 1'b0;
		
		sfVPos = 10'd220;
		
		sfVPosTemp = sfVPos + 10'd154;
		sfHPos = 10'd500;//500
		sfHeadHPos = sfHPos;
		sfHeadVPos = sfVPosTemp;
		sfHeadFlag = 1'd0;
		
		psVPos = 10'd220;
		psVPosTemp = psVPos + 10'd90; 
		psHPos = 10'd225;//225
		pVPos = psVPos + 10'd50;
		pHPos = psHPos + 10'd115;
		
		wVPos = 10'd218;
		wHPos = 10'd400;
//		blink = 1'd1;
	end

	//TODO: define the zombie colors here
	//Define the color scheme
	always@ (*)
    if (~bright)
        rgb = BLACK;
    else if (pea == 1)
        rgb = PEA_GREEN;
    else if (walnutBlack == 1)
        rgb = BLACK;
    else if (walnutWhite == 1)
        rgb = WHITE;
    else if (walnut == 1)
        rgb = BROWN;
    else if (peashooterBlack == 1)
        rgb = BLACK;
    else if (peashooterHead == 1)
        rgb = PEA_GREEN;
    else if (peashooterStem == 1)
        rgb = STEM_GREEN;
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
		
	always@ (posedge clk)
	begin
	   sfBounceSpeed = sfBounceSpeed + 50'd1;
       pSpeed = pSpeed + 50'd1;
	   if (sfBounceSpeed >= 50'd4000000)
	   begin
	       sfBounceSpeed = 50'd0;	       
	       if (sfHeadHPos <= (sfHPos - 10'd30))
	       begin
	           sfHeadFlag = 1'd0;
	       end
	       if (sfHeadHPos >= (sfHPos + 10'd30))
	       begin
	           sfHeadFlag = 1'd1;
	       end
	           
	       if (sfHeadFlag == 1'd0)
	           sfHeadHPos = sfHeadHPos + 1'd1;
	       else
	           sfHeadHPos = sfHeadHPos - 1'd1;
	       	           
	       if ((sfHeadFlag == 1'd0) && (sfHeadHPos <= sfHPos))
	       begin
	           blink = 1'd1;
	           sfHeadVPos = sfHeadVPos - 1'd1;
	       end
	       if ((sfHeadFlag == 1'd0) && (sfHeadHPos > sfHPos))
	       begin
	           blink = 1'd0;
	           sfHeadVPos = sfHeadVPos + 1'd1;
	       end
	       if ((sfHeadFlag == 1'd1) && (sfHeadHPos >= sfHPos))
	       begin
	           blink = 1'd0;
	           sfHeadVPos = sfHeadVPos - 1'd1;
	       end
	       if ((sfHeadFlag == 1'd1) && (sfHeadHPos < sfHPos))
	       begin
	           blink = 1'd0;
	           sfHeadVPos = sfHeadVPos + 1'd1;
	       end
	   end
	   if (pSpeed >= 50'd1000000)
	   begin
	       pSpeed = 50'd0;
	       pHPos = pHPos + 10'd1;
	       if (pHPos >= 10'd800) 
		      pHPos = psHPos + 10'd50;
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
	
	assign pea = ((vCount >= pVPos) && (vCount <= pVPos + 10'd14) && (hCount >= pHPos) && (hCount <= pHPos + 10'd14)) ? 1 : 0;
	
	assign peashooterHead = (((vCount >= psVPos) && (vCount <= psVPos + 10'd5) && (hCount >= psHPos + 10'd27) && (hCount <= psHPos + 10'd48))
                           ||((vCount >= psVPos + 10'd3) && (vCount <= psVPos + 10'd8) && (hCount >= psHPos + 10'd23) && (hCount <= psHPos + 10'd52))
                           
                           ||((vCount >= psVPos + 10'd6) && (vCount <= psVPos + 10'd11) && (hCount >= psHPos + 10'd19) && (hCount <= psHPos + 10'd56))
                           ||((vCount >= psVPos + 10'd9) && (vCount <= psVPos + 10'd14) && (hCount >= psHPos + 10'd17) && (hCount <= psHPos + 10'd58))
                           ||((vCount >= psVPos + 10'd12) && (vCount <= psVPos + 10'd17) && (hCount >= psHPos + 10'd15) && (hCount <= psHPos + 10'd60))
                           ||((vCount >= psVPos + 10'd15) && (vCount <= psVPos + 10'd20) && (hCount >= psHPos + 10'd13) && (hCount <= psHPos + 10'd62))
                           ||((vCount >= psVPos + 10'd18) && (vCount <= psVPos + 10'd23) && (hCount >= psHPos + 10'd11) && (hCount <= psHPos + 10'd64))
                           ||((vCount >= psVPos + 10'd21) && (vCount <= psVPos + 10'd26) && (hCount >= psHPos + 10'd9) && (hCount <= psHPos + 10'd66))
        
                           ||((vCount >= psVPos + 10'd24) && (vCount <= psVPos + 10'd29) && (hCount >= psHPos + 10'd8) && (hCount <= psHPos + 10'd67))
                           ||((vCount >= psVPos + 10'd27) && (vCount <= psVPos + 10'd32) && (hCount >= psHPos + 10'd7) && (hCount <= psHPos + 10'd68))
                           ||((vCount >= psVPos + 10'd30) && (vCount <= psVPos + 10'd35) && (hCount >= psHPos + 10'd6) && (hCount <= psHPos + 10'd69))
                           ||((vCount >= psVPos + 10'd33) && (vCount <= psVPos + 10'd38) && (hCount >= psHPos + 10'd5) && (hCount <= psHPos + 10'd70))
                           ||((vCount >= psVPos + 10'd36) && (vCount <= psVPos + 10'd41) && (hCount >= psHPos + 10'd4) && (hCount <= psHPos + 10'd71))
                           ||((vCount >= psVPos + 10'd39) && (vCount <= psVPos + 10'd44) && (hCount >= psHPos + 10'd3) && (hCount <= psHPos + 10'd72))
                           ||((vCount >= psVPos + 10'd42) && (vCount <= psVPos + 10'd47) && (hCount >= psHPos + 10'd2) && (hCount <= psHPos + 10'd73))
                           ||((vCount >= psVPos + 10'd45) && (vCount <= psVPos + 10'd50) && (hCount >= psHPos + 10'd1) && (hCount <= psHPos + 10'd74))
                           ||((vCount >= psVPos + 10'd48) && (vCount <= psVPos + 10'd53) && (hCount >= psHPos) && (hCount <= psHPos + 10'd75))
                           
                                     
                           ||((vCount >= psVPos + 10'd51) && (vCount <= psVPos + 10'd56) && (hCount >= psHPos + 10'd1) && (hCount <= psHPos + 10'd74))
                           ||((vCount >= psVPos + 10'd54) && (vCount <= psVPos + 10'd59) && (hCount >= psHPos + 10'd2) && (hCount <= psHPos + 10'd73))
                           ||((vCount >= psVPos + 10'd57) && (vCount <= psVPos + 10'd62) && (hCount >= psHPos + 10'd3) && (hCount <= psHPos + 10'd72))
                           ||((vCount >= psVPos + 10'd60) && (vCount <= psVPos + 10'd65) && (hCount >= psHPos + 10'd4) && (hCount <= psHPos + 10'd71))
                           ||((vCount >= psVPos + 10'd63) && (vCount <= psVPos + 10'd68) && (hCount >= psHPos + 10'd5) && (hCount <= psHPos + 10'd70))
                           ||((vCount >= psVPos + 10'd66) && (vCount <= psVPos + 10'd71) && (hCount >= psHPos + 10'd6) && (hCount <= psHPos + 10'd69))
                           ||((vCount >= psVPos + 10'd69) && (vCount <= psVPos + 10'd74) && (hCount >= psHPos + 10'd7) && (hCount <= psHPos + 10'd68))
                           ||((vCount >= psVPos + 10'd72) && (vCount <= psVPos + 10'd77) && (hCount >= psHPos + 10'd8) && (hCount <= psHPos + 10'd67))
                           
                           ||((vCount >= psVPos + 10'd75) && (vCount <= psVPos + 10'd80) && (hCount >= psHPos + 10'd9) && (hCount <= psHPos + 10'd66))
                           ||((vCount >= psVPos + 10'd78) && (vCount <= psVPos + 10'd83) && (hCount >= psHPos + 10'd11) && (hCount <= psHPos + 10'd64))
                           ||((vCount >= psVPos + 10'd81) && (vCount <= psVPos + 10'd86) && (hCount >= psHPos + 10'd13) && (hCount <= psHPos + 10'd62))
                           ||((vCount >= psVPos + 10'd84) && (vCount <= psVPos + 10'd89) && (hCount >= psHPos + 10'd15) && (hCount <= psHPos + 10'd60))
                           ||((vCount >= psVPos + 10'd87) && (vCount <= psVPos + 10'd92) && (hCount >= psHPos + 10'd17) && (hCount <= psHPos + 10'd58))
                           ||((vCount >= psVPos + 10'd90) && (vCount <= psVPos + 10'd95) && (hCount >= psHPos + 10'd19) && (hCount <= psHPos + 10'd56))
                           
                           ||((vCount >= psVPos + 10'd93) && (vCount <= psVPos + 10'd98) && (hCount >= psHPos + 10'd23) && (hCount <= psHPos + 10'd52))
                           ||((vCount >= psVPos + 10'd96) && (vCount <= psVPos + 10'd101) && (hCount >= psHPos + 10'd27) && (hCount <= psHPos + 10'd48))
                           
                           ||((vCount >= psVPos + 10'd35) && (vCount <= psVPos + 10'd65) && (hCount >= psHPos + 10'd68) && (hCount <= psHPos + 10'd119))
                           ||((vCount >= psVPos + 10'd30) && (vCount <= psVPos + 10'd70) && (hCount >= psHPos + 10'd78) && (hCount <= psHPos + 10'd119))
                           ||((vCount >= psVPos + 10'd25) && (vCount <= psVPos + 10'd75) && (hCount >= psHPos + 10'd88) && (hCount <= psHPos + 10'd119))
                           ||((vCount >= psVPos + 10'd20) && (vCount <= psVPos + 10'd80) && (hCount >= psHPos + 10'd98) && (hCount <= psHPos + 10'd119))
                           ||((vCount >= psVPos + 10'd15) && (vCount <= psVPos + 10'd85) && (hCount >= psHPos + 10'd108) && (hCount <= psHPos + 10'd119))
	                        ) ? 1 : 0;
	                       
    assign peashooterBlack = ((vCount >= psVPos + 10'd35) && (vCount <= psVPos + 10'd50) && (hCount >= psHPos + 10'd45) && (hCount <= psHPos + 10'd60)) ? 1 : 0;
	
	assign peashooterStem = (
                             ((vCount <= psVPosTemp + 10'd96) && (vCount >= psVPosTemp + 10'd86) && (hCount >= psHPos + 10'd55) && (hCount <= psHPos + 10'd71))
                             ||((vCount <= psVPosTemp + 10'd91) && (vCount >= psVPosTemp + 10'd81) && (hCount >= psHPos + 10'd54) && (hCount <= psHPos + 10'd70))
                             ||((vCount <= psVPosTemp + 10'd86) && (vCount >= psVPosTemp + 10'd76) && (hCount >= psHPos + 10'd53) && (hCount <= psHPos + 10'd69))
                             ||((vCount <= psVPosTemp + 10'd81) && (vCount >= psVPosTemp + 10'd71) && (hCount >= psHPos + 10'd52) && (hCount <= psHPos + 10'd68))
                             ||((vCount <= psVPosTemp + 10'd76) && (vCount >= psVPosTemp + 10'd66) && (hCount >= psHPos + 10'd51) && (hCount <= psHPos + 10'd67))
                             ||((vCount <= psVPosTemp + 10'd71) && (vCount >= psVPosTemp + 10'd61) && (hCount >= psHPos + 10'd50) && (hCount <= psHPos + 10'd66))
                             ||((vCount <= psVPosTemp + 10'd66) && (vCount >= psVPosTemp + 10'd56) && (hCount >= psHPos + 10'd49) && (hCount <= psHPos + 10'd65))
                             ||((vCount <= psVPosTemp + 10'd61) && (vCount >= psVPosTemp + 10'd51) && (hCount >= psHPos + 10'd48) && (hCount <= psHPos + 10'd64))
                             ||((vCount <= psVPosTemp + 10'd56) && (vCount >= psVPosTemp + 10'd46) && (hCount >= psHPos + 10'd47) && (hCount <= psHPos + 10'd63))
                             ||((vCount <= psVPosTemp + 10'd51) && (vCount >= psVPosTemp + 10'd41) && (hCount >= psHPos + 10'd46) && (hCount <= psHPos + 10'd62))
                             
                             ||((vCount <= psVPosTemp + 10'd6) && (vCount >= psVPosTemp + 10'd0) && (hCount >= psHPos + 10'd37) && (hCount <= psHPos + 10'd53))
                             ||((vCount <= psVPosTemp + 10'd11) && (vCount >= psVPosTemp + 10'd1) && (hCount >= psHPos + 10'd38) && (hCount <= psHPos + 10'd54))
                             ||((vCount <= psVPosTemp + 10'd16) && (vCount >= psVPosTemp + 10'd6) && (hCount >= psHPos + 10'd39) && (hCount <= psHPos + 10'd55))
                             ||((vCount <= psVPosTemp + 10'd21) && (vCount >= psVPosTemp + 10'd11) && (hCount >= psHPos + 10'd40) && (hCount <= psHPos + 10'd56))
                             ||((vCount <= psVPosTemp + 10'd26) && (vCount >= psVPosTemp + 10'd16) && (hCount >= psHPos + 10'd41) && (hCount <= psHPos + 10'd57))
                             ||((vCount <= psVPosTemp + 10'd31) && (vCount >= psVPosTemp + 10'd21) && (hCount >= psHPos + 10'd42) && (hCount <= psHPos + 10'd58))
                             ||((vCount <= psVPosTemp + 10'd36) && (vCount >= psVPosTemp + 10'd26) && (hCount >= psHPos + 10'd43) && (hCount <= psHPos + 10'd59))
                             ||((vCount <= psVPosTemp + 10'd41) && (vCount >= psVPosTemp + 10'd31) && (hCount >= psHPos + 10'd44) && (hCount <= psHPos + 10'd60))
                             ||((vCount <= psVPosTemp + 10'd46) && (vCount >= psVPosTemp + 10'd36) && (hCount >= psHPos + 10'd45) && (hCount <= psHPos + 10'd61))
                             ||((vCount <= psVPosTemp + 10'd51) && (vCount >= psVPosTemp + 10'd41) && (hCount >= psHPos + 10'd46) && (hCount <= psHPos + 10'd62))
                             
                             ||((vCount <= psVPosTemp + 10'd96) && (vCount >= psVPosTemp + 10'd94) && (hCount >= psHPos - 10'd4) && (hCount <= psHPos + 10'd60))
                             ||((vCount <= psVPosTemp + 10'd95) && (vCount >= psVPosTemp + 10'd93) && (hCount >= psHPos - 10'd3) && (hCount <= psHPos + 10'd59))
                             ||((vCount <= psVPosTemp + 10'd94) && (vCount >= psVPosTemp + 10'd92) && (hCount >= psHPos - 10'd2) && (hCount <= psHPos + 10'd58))
                             ||((vCount <= psVPosTemp + 10'd93) && (vCount >= psVPosTemp + 10'd91) && (hCount >= psHPos - 10'd1) && (hCount <= psHPos + 10'd57))
                             ||((vCount <= psVPosTemp + 10'd92) && (vCount >= psVPosTemp + 10'd90) && (hCount >= psHPos - 10'd0) && (hCount <= psHPos + 10'd56))
                             ||((vCount <= psVPosTemp + 10'd91) && (vCount >= psVPosTemp + 10'd89) && (hCount >= psHPos + 10'd1) && (hCount <= psHPos + 10'd55))
                             ||((vCount <= psVPosTemp + 10'd90) && (vCount >= psVPosTemp + 10'd88) && (hCount >= psHPos + 10'd2) && (hCount <= psHPos + 10'd54))
                             ||((vCount <= psVPosTemp + 10'd89) && (vCount >= psVPosTemp + 10'd87) && (hCount >= psHPos + 10'd3) && (hCount <= psHPos + 10'd53))
                             ||((vCount <= psVPosTemp + 10'd88) && (vCount >= psVPosTemp + 10'd86) && (hCount >= psHPos + 10'd4) && (hCount <= psHPos + 10'd52))
                             ||((vCount <= psVPosTemp + 10'd87) && (vCount >= psVPosTemp + 10'd85) && (hCount >= psHPos + 10'd5) && (hCount <= psHPos + 10'd51))
                             ||((vCount <= psVPosTemp + 10'd86) && (vCount >= psVPosTemp + 10'd84) && (hCount >= psHPos + 10'd6) && (hCount <= psHPos + 10'd50))
                             ||((vCount <= psVPosTemp + 10'd85) && (vCount >= psVPosTemp + 10'd83) && (hCount >= psHPos + 10'd7) && (hCount <= psHPos + 10'd49))
                             ||((vCount <= psVPosTemp + 10'd84) && (vCount >= psVPosTemp + 10'd82) && (hCount >= psHPos + 10'd8) && (hCount <= psHPos + 10'd48))
                             ||((vCount <= psVPosTemp + 10'd83) && (vCount >= psVPosTemp + 10'd81) && (hCount >= psHPos + 10'd9) && (hCount <= psHPos + 10'd47))
                             ||((vCount <= psVPosTemp + 10'd82) && (vCount >= psVPosTemp + 10'd80) && (hCount >= psHPos + 10'd10) && (hCount <= psHPos + 10'd46))
                             ||((vCount <= psVPosTemp + 10'd81) && (vCount >= psVPosTemp + 10'd79) && (hCount >= psHPos + 10'd11) && (hCount <= psHPos + 10'd45))
                             ||((vCount <= psVPosTemp + 10'd80) && (vCount >= psVPosTemp + 10'd78) && (hCount >= psHPos + 10'd12) && (hCount <= psHPos + 10'd44))
                             ||((vCount <= psVPosTemp + 10'd79) && (vCount >= psVPosTemp + 10'd77) && (hCount >= psHPos + 10'd13) && (hCount <= psHPos + 10'd43))
                             ||((vCount <= psVPosTemp + 10'd78) && (vCount >= psVPosTemp + 10'd76) && (hCount >= psHPos + 10'd14) && (hCount <= psHPos + 10'd42))
                             ||((vCount <= psVPosTemp + 10'd77) && (vCount >= psVPosTemp + 10'd75) && (hCount >= psHPos + 10'd15) && (hCount <= psHPos + 10'd41))
                             ||((vCount <= psVPosTemp + 10'd76) && (vCount >= psVPosTemp + 10'd74) && (hCount >= psHPos + 10'd16) && (hCount <= psHPos + 10'd40))
                             ||((vCount <= psVPosTemp + 10'd75) && (vCount >= psVPosTemp + 10'd73) && (hCount >= psHPos + 10'd17) && (hCount <= psHPos + 10'd39))
                             ||((vCount <= psVPosTemp + 10'd74) && (vCount >= psVPosTemp + 10'd72) && (hCount >= psHPos + 10'd18) && (hCount <= psHPos + 10'd38))
                             ||((vCount <= psVPosTemp + 10'd73) && (vCount >= psVPosTemp + 10'd71) && (hCount >= psHPos + 10'd19) && (hCount <= psHPos + 10'd37))
                             ||((vCount <= psVPosTemp + 10'd72) && (vCount >= psVPosTemp + 10'd70) && (hCount >= psHPos + 10'd20) && (hCount <= psHPos + 10'd36))
                             ||((vCount <= psVPosTemp + 10'd71) && (vCount >= psVPosTemp + 10'd69) && (hCount >= psHPos + 10'd21) && (hCount <= psHPos + 10'd35))
                             ||((vCount <= psVPosTemp + 10'd70) && (vCount >= psVPosTemp + 10'd68) && (hCount >= psHPos + 10'd22) && (hCount <= psHPos + 10'd34))
                             ||((vCount <= psVPosTemp + 10'd69) && (vCount >= psVPosTemp + 10'd67) && (hCount >= psHPos + 10'd23) && (hCount <= psHPos + 10'd33))
                             ||((vCount <= psVPosTemp + 10'd68) && (vCount >= psVPosTemp + 10'd66) && (hCount >= psHPos + 10'd24) && (hCount <= psHPos + 10'd32))
                             ||((vCount <= psVPosTemp + 10'd67) && (vCount >= psVPosTemp + 10'd65) && (hCount >= psHPos + 10'd25) && (hCount <= psHPos + 10'd31))
                             ||((vCount <= psVPosTemp + 10'd66) && (vCount >= psVPosTemp + 10'd64) && (hCount >= psHPos + 10'd26) && (hCount <= psHPos + 10'd30))
                             ||((vCount <= psVPosTemp + 10'd65) && (vCount >= psVPosTemp + 10'd63) && (hCount >= psHPos + 10'd27) && (hCount <= psHPos + 10'd29))
                             ||((vCount <= psVPosTemp + 10'd64) && (vCount >= psVPosTemp + 10'd62) && (hCount >= psHPos + 10'd28) && (hCount <= psHPos + 10'd28))


                             ||((vCount <= psVPosTemp + 10'd96) && (vCount >= psVPosTemp + 10'd94) && (hCount <= psHPos + 10'd124) && (hCount >= psHPos + 10'd60))
                             ||((vCount <= psVPosTemp + 10'd95) && (vCount >= psVPosTemp + 10'd93) && (hCount <= psHPos + 10'd123) && (hCount >= psHPos + 10'd61))
                             ||((vCount <= psVPosTemp + 10'd94) && (vCount >= psVPosTemp + 10'd92) && (hCount <= psHPos + 10'd122) && (hCount >= psHPos + 10'd62))
                             ||((vCount <= psVPosTemp + 10'd93) && (vCount >= psVPosTemp + 10'd91) && (hCount <= psHPos + 10'd120) && (hCount >= psHPos + 10'd63))
                             ||((vCount <= psVPosTemp + 10'd92) && (vCount >= psVPosTemp + 10'd90) && (hCount <= psHPos + 10'd119) && (hCount >= psHPos + 10'd64))
                             ||((vCount <= psVPosTemp + 10'd91) && (vCount >= psVPosTemp + 10'd89) && (hCount <= psHPos + 10'd118) && (hCount >= psHPos + 10'd65))
                             ||((vCount <= psVPosTemp + 10'd90) && (vCount >= psVPosTemp + 10'd88) && (hCount <= psHPos + 10'd117) && (hCount >= psHPos + 10'd66))
                             ||((vCount <= psVPosTemp + 10'd89) && (vCount >= psVPosTemp + 10'd87) && (hCount <= psHPos + 10'd116) && (hCount >= psHPos + 10'd67))
                             ||((vCount <= psVPosTemp + 10'd88) && (vCount >= psVPosTemp + 10'd86) && (hCount <= psHPos + 10'd115) && (hCount >= psHPos + 10'd68))
                             ||((vCount <= psVPosTemp + 10'd87) && (vCount >= psVPosTemp + 10'd85) && (hCount <= psHPos + 10'd114) && (hCount >= psHPos + 10'd69))
                             ||((vCount <= psVPosTemp + 10'd86) && (vCount >= psVPosTemp + 10'd84) && (hCount <= psHPos + 10'd113) && (hCount >= psHPos + 10'd70))
                             ||((vCount <= psVPosTemp + 10'd85) && (vCount >= psVPosTemp + 10'd83) && (hCount <= psHPos + 10'd112) && (hCount >= psHPos + 10'd71))
                             ||((vCount <= psVPosTemp + 10'd84) && (vCount >= psVPosTemp + 10'd82) && (hCount <= psHPos + 10'd111) && (hCount >= psHPos + 10'd72))
                             ||((vCount <= psVPosTemp + 10'd83) && (vCount >= psVPosTemp + 10'd81) && (hCount <= psHPos + 10'd110) && (hCount >= psHPos + 10'd73))
                             ||((vCount <= psVPosTemp + 10'd82) && (vCount >= psVPosTemp + 10'd80) && (hCount <= psHPos + 10'd109) && (hCount >= psHPos + 10'd74))
                             ||((vCount <= psVPosTemp + 10'd81) && (vCount >= psVPosTemp + 10'd79) && (hCount <= psHPos + 10'd108) && (hCount >= psHPos + 10'd75))
                             ||((vCount <= psVPosTemp + 10'd80) && (vCount >= psVPosTemp + 10'd78) && (hCount <= psHPos + 10'd107) && (hCount >= psHPos + 10'd76))
                             ||((vCount <= psVPosTemp + 10'd79) && (vCount >= psVPosTemp + 10'd77) && (hCount <= psHPos + 10'd106) && (hCount >= psHPos + 10'd77))
                             ||((vCount <= psVPosTemp + 10'd78) && (vCount >= psVPosTemp + 10'd76) && (hCount <= psHPos + 10'd105) && (hCount >= psHPos + 10'd78))
                             ||((vCount <= psVPosTemp + 10'd77) && (vCount >= psVPosTemp + 10'd75) && (hCount <= psHPos + 10'd104) && (hCount >= psHPos + 10'd79))
                             ||((vCount <= psVPosTemp + 10'd76) && (vCount >= psVPosTemp + 10'd74) && (hCount <= psHPos + 10'd103) && (hCount >= psHPos + 10'd80))
                             ||((vCount <= psVPosTemp + 10'd75) && (vCount >= psVPosTemp + 10'd73) && (hCount <= psHPos + 10'd102) && (hCount >= psHPos + 10'd81))
                             ||((vCount <= psVPosTemp + 10'd74) && (vCount >= psVPosTemp + 10'd72) && (hCount <= psHPos + 10'd101) && (hCount >= psHPos + 10'd82))
                             ||((vCount <= psVPosTemp + 10'd73) && (vCount >= psVPosTemp + 10'd71) && (hCount <= psHPos + 10'd100) && (hCount >= psHPos + 10'd83))
                             ||((vCount <= psVPosTemp + 10'd72) && (vCount >= psVPosTemp + 10'd70) && (hCount <= psHPos + 10'd99) && (hCount >= psHPos + 10'd84))
                             ||((vCount <= psVPosTemp + 10'd71) && (vCount >= psVPosTemp + 10'd69) && (hCount <= psHPos + 10'd98) && (hCount >= psHPos + 10'd85))
                             ||((vCount <= psVPosTemp + 10'd70) && (vCount >= psVPosTemp + 10'd68) && (hCount <= psHPos + 10'd97) && (hCount >= psHPos + 10'd86))
                             ||((vCount <= psVPosTemp + 10'd69) && (vCount >= psVPosTemp + 10'd67) && (hCount <= psHPos + 10'd96) && (hCount >= psHPos + 10'd87))
                             ||((vCount <= psVPosTemp + 10'd68) && (vCount >= psVPosTemp + 10'd66) && (hCount <= psHPos + 10'd95) && (hCount >= psHPos + 10'd88))
                             ||((vCount <= psVPosTemp + 10'd67) && (vCount >= psVPosTemp + 10'd65) && (hCount <= psHPos + 10'd94) && (hCount >= psHPos + 10'd89))
                             ||((vCount <= psVPosTemp + 10'd66) && (vCount >= psVPosTemp + 10'd64) && (hCount <= psHPos + 10'd93) && (hCount >= psHPos + 10'd90))
                             ||((vCount <= psVPosTemp + 10'd65) && (vCount >= psVPosTemp + 10'd63) && (hCount <= psHPos + 10'd92) && (hCount >= psHPos + 10'd91))
                             ) ? 1 : 0;
	
	assign walnut = 
	               (
	               ((vCount >= wVPos) && (vCount <= wVPos + 10'd5) && (hCount >= wHPos + 10'd27) && (hCount <= wHPos + 10'd48))
	               ||((vCount >= wVPos + 10'd3) && (vCount <= wVPos + 10'd8) && (hCount >= wHPos + 10'd23) && (hCount <= wHPos + 10'd52))
	               
	               ||((vCount >= wVPos + 10'd6) && (vCount <= wVPos + 10'd11) && (hCount >= wHPos + 10'd19) && (hCount <= wHPos + 10'd56))
	               ||((vCount >= wVPos + 10'd9) && (vCount <= wVPos + 10'd14) && (hCount >= wHPos + 10'd17) && (hCount <= wHPos + 10'd58))
	               ||((vCount >= wVPos + 10'd12) && (vCount <= wVPos + 10'd17) && (hCount >= wHPos + 10'd15) && (hCount <= wHPos + 10'd60))
	               ||((vCount >= wVPos + 10'd15) && (vCount <= wVPos + 10'd20) && (hCount >= wHPos + 10'd13) && (hCount <= wHPos + 10'd62))
	               ||((vCount >= wVPos + 10'd18) && (vCount <= wVPos + 10'd23) && (hCount >= wHPos + 10'd11) && (hCount <= wHPos + 10'd64))
	               ||((vCount >= wVPos + 10'd21) && (vCount <= wVPos + 10'd26) && (hCount >= wHPos + 10'd9) && (hCount <= wHPos + 10'd66))

	               ||((vCount >= wVPos + 10'd24) && (vCount <= wVPos + 10'd29) && (hCount >= wHPos + 10'd8) && (hCount <= wHPos + 10'd67))
	               ||((vCount >= wVPos + 10'd27) && (vCount <= wVPos + 10'd32) && (hCount >= wHPos + 10'd7) && (hCount <= wHPos + 10'd68))
	               ||((vCount >= wVPos + 10'd30) && (vCount <= wVPos + 10'd35) && (hCount >= wHPos + 10'd6) && (hCount <= wHPos + 10'd69))
	               ||((vCount >= wVPos + 10'd33) && (vCount <= wVPos + 10'd38) && (hCount >= wHPos + 10'd5) && (hCount <= wHPos + 10'd70))
	               ||((vCount >= wVPos + 10'd36) && (vCount <= wVPos + 10'd41) && (hCount >= wHPos + 10'd4) && (hCount <= wHPos + 10'd71))
	               ||((vCount >= wVPos + 10'd39) && (vCount <= wVPos + 10'd44) && (hCount >= wHPos + 10'd3) && (hCount <= wHPos + 10'd72))
	               ||((vCount >= wVPos + 10'd42) && (vCount <= wVPos + 10'd47) && (hCount >= wHPos + 10'd2) && (hCount <= wHPos + 10'd73))
	               ||((vCount >= wVPos + 10'd45) && (vCount <= wVPos + 10'd50) && (hCount >= wHPos + 10'd1) && (hCount <= wHPos + 10'd74))
	               ||((vCount >= wVPos + 10'd48) && (vCount <= wVPos + 10'd53) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))
	               
	               
	               ||((vCount >= wVPos + 10'd51) && (vCount <= wVPos + 10'd56) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))
	               ||((vCount >= wVPos + 10'd54) && (vCount <= wVPos + 10'd59) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))
	               ||((vCount >= wVPos + 10'd57) && (vCount <= wVPos + 10'd62) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))
	               ||((vCount >= wVPos + 10'd60) && (vCount <= wVPos + 10'd65) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))
	               ||((vCount >= wVPos + 10'd63) && (vCount <= wVPos + 10'd68) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))
	               ||((vCount >= wVPos + 10'd66) && (vCount <= wVPos + 10'd71) && (hCount >= wHPos) && (hCount <= wHPos + 10'd75))	  
	                         
	               ||((vCount >= wVPos + 10'd69) && (vCount <= wVPos + 10'd74) && (hCount >= wHPos + 10'd1) && (hCount <= wHPos + 10'd74))
	               ||((vCount >= wVPos + 10'd72) && (vCount <= wVPos + 10'd77) && (hCount >= wHPos + 10'd2) && (hCount <= wHPos + 10'd73))
	               ||((vCount >= wVPos + 10'd75) && (vCount <= wVPos + 10'd80) && (hCount >= wHPos + 10'd3) && (hCount <= wHPos + 10'd72))
	               ||((vCount >= wVPos + 10'd78) && (vCount <= wVPos + 10'd83) && (hCount >= wHPos + 10'd4) && (hCount <= wHPos + 10'd71))
	               ||((vCount >= wVPos + 10'd81) && (vCount <= wVPos + 10'd86) && (hCount >= wHPos + 10'd5) && (hCount <= wHPos + 10'd70))
	               ||((vCount >= wVPos + 10'd84) && (vCount <= wVPos + 10'd89) && (hCount >= wHPos + 10'd6) && (hCount <= wHPos + 10'd69))
	               ||((vCount >= wVPos + 10'd87) && (vCount <= wVPos + 10'd92) && (hCount >= wHPos + 10'd7) && (hCount <= wHPos + 10'd68))
	               ||((vCount >= wVPos + 10'd90) && (vCount <= wVPos + 10'd95) && (hCount >= wHPos + 10'd8) && (hCount <= wHPos + 10'd67))
	               
	               ||((vCount >= wVPos + 10'd93) && (vCount <= wVPos + 10'd98) && (hCount >= wHPos + 10'd9) && (hCount <= wHPos + 10'd66))
	               ||((vCount >= wVPos + 10'd96) && (vCount <= wVPos + 10'd101) && (hCount >= wHPos + 10'd11) && (hCount <= wHPos + 10'd64))
	               ||((vCount >= wVPos + 10'd99) && (vCount <= wVPos + 10'd104) && (hCount >= wHPos + 10'd13) && (hCount <= wHPos + 10'd62))
	               ||((vCount >= wVPos + 10'd102) && (vCount <= wVPos + 10'd107) && (hCount >= wHPos + 10'd15) && (hCount <= wHPos + 10'd60))
	               ||((vCount >= wVPos + 10'd105) && (vCount <= wVPos + 10'd110) && (hCount >= wHPos + 10'd17) && (hCount <= wHPos + 10'd58))
	               ||((vCount >= wVPos + 10'd108) && (vCount <= wVPos + 10'd113) && (hCount >= wHPos + 10'd19) && (hCount <= wHPos + 10'd56))
	               
	               ||((vCount >= wVPos + 10'd111) && (vCount <= wVPos + 10'd116) && (hCount >= wHPos + 10'd23) && (hCount <= wHPos + 10'd52))
	               ||((vCount >= wVPos + 10'd114) && (vCount <= wVPos + 10'd119) && (hCount >= wHPos + 10'd27) && (hCount <= wHPos + 10'd48))
                   ) ? 1 : 0;
    
    assign walnutWhite =   (
                           ( 
	                       ((vCount >= wVPos + 10'd44) && (vCount <= wVPos + 10'd70) && (hCount >= wHPos + 10'd30) && (hCount <= wHPos + 10'd47))
	                       ||((vCount >= wVPos + 10'd47) && (vCount <= wVPos + 10'd65) && (hCount >= wHPos + 10'd55) && (hCount <= wHPos + 10'd69))
                           ) && (blink == 1'd0)
                           ) ? 1 : 0;
  
    assign walnutBlack = 
                           (
                           ( 
	                       (((vCount >= wVPos + 10'd49) && (vCount <= wVPos + 10'd65) && (hCount >= wHPos + 10'd35) && (hCount <= wHPos + 10'd45))
	                       ||((vCount >= wVPos + 10'd51) && (vCount <= wVPos + 10'd63) && (hCount >= wHPos + 10'd59) && (hCount <= wHPos + 10'd67)))
	                       && (blink == 1'd0)
	                       )
	                       || ((vCount >= wVPos + 10'd74) && (vCount <= wVPos + 10'd79) && (hCount >= wHPos + 10'd39) && (hCount <= wHPos + 10'd44))
	                       || ((vCount >= wVPos + 10'd76) && (vCount <= wVPos + 10'd81) && (hCount >= wHPos + 10'd42) && (hCount <= wHPos + 10'd59))
	                       || ((vCount >= wVPos + 10'd74) && (vCount <= wVPos + 10'd79) && (hCount >= wHPos + 10'd57) && (hCount <= wHPos + 10'd62))
                           ) ? 1 : 0;
	 
	//sunflower visualization (to be made relative to the top left corner location, need to add stem + movement)
	assign sunflowerOuter = 
	                   ( 
	                   ((vCount >= sfHeadVPos - 10'd13) && (vCount <= sfHeadVPos) && (hCount >= sfHeadHPos + 10'd24) && (hCount <= sfHeadHPos + 10'd101) )
	                   || ((vCount >= sfHeadVPos - 10'd32) && (vCount <= sfHeadVPos + 10'd14) && (hCount >= sfHeadHPos + 10'd18) && (hCount <= sfHeadHPos + 10'd107) )
	               
	                   || ((vCount >= sfHeadVPos - 10'd50) && (vCount <= sfHeadVPos - 10'd32) && (hCount >= sfHeadHPos + 10'd12) && (hCount <= sfHeadHPos + 10'd113) )
	                   || ((vCount >= sfHeadVPos - 10'd67) && (vCount <= sfHeadVPos - 10'd50) && (hCount >= sfHeadHPos + 10'd6) && (hCount <= sfHeadHPos + 10'd119) )
	                   || ((vCount >= sfHeadVPos - 10'd85) && (vCount <= sfHeadVPos - 10'd68) && (hCount >= sfHeadHPos + 10'd0) && (hCount <= sfHeadHPos + 10'd125) )
	               
	                   || ((vCount >= sfHeadVPos - 10'd103) && (vCount <= sfHeadVPos - 10'd86) && (hCount >= sfHeadHPos + 10'd6) && (hCount <= sfHeadHPos + 10'd119) )
	                   || ((vCount >= sfHeadVPos - 10'd121) && (vCount <= sfHeadVPos - 10'd104) && (hCount >= sfHeadHPos + 10'd12) && (hCount <= sfHeadHPos + 10'd113) )
	                   
	                   || ((vCount >= sfHeadVPos - 10'd139) && (vCount <= sfHeadVPos - 10'd122) && (hCount >= sfHeadHPos + 10'd18) && (hCount <= sfHeadHPos + 10'd107) )
	                   || ((vCount >= sfHeadVPos - 10'd154) && (vCount <= sfHeadVPos - 10'd140) && (hCount >= sfHeadHPos + 10'd24) && (hCount <= sfHeadHPos + 10'd101) )
                       ) ? 1 : 0;
	                       	                   
	assign sunflowerInner = ( (vCount < sfHeadVPos - 10'd24) && (vCount > sfHeadVPos - 10'd124) && (hCount > sfHeadHPos + 10'd25) && (hCount < sfHeadHPos + 10'd100) ) ? 1 : 0;

    assign sunflowerFace = ( 
                             ((vCount < sfHeadVPos - 10'd89) && (vCount > sfHeadVPos - 10'd104) && (hCount > sfHeadHPos + 10'd45) && (hCount < sfHeadHPos + 10'd55))
                           ||((vCount < sfHeadVPos - 10'd89) && (vCount > sfHeadVPos - 10'd104) && (hCount > sfHeadHPos + 10'd70) && (hCount < sfHeadHPos + 10'd80))
                           
                           ||((vCount < sfHeadVPos - 10'd52) && (vCount > sfHeadVPos - 10'd64) && (hCount > sfHeadHPos + 10'd40) && (hCount < sfHeadHPos + 10'd50))
                           ||((vCount < sfHeadVPos - 10'd42) && (vCount > sfHeadVPos - 10'd56) && (hCount > sfHeadHPos + 10'd45) && (hCount < sfHeadHPos + 10'd80))
//                           ||((vCount < 10'd340) && (vCount > 10'd328) && (hCount > 10'd280) && (hCount < 10'd295))
//                           ||((vCount < sfHeadVPos - 10'd42) && (vCount > sfHeadVPos - 10'd56) && (hCount > sfHeadHPos + 10'd55) && (hCount < sfHeadHPos + 10'd65))
//                           ||((vCount < sfHeadVPos - 10'd42) && (vCount > sfHeadVPos - 10'd56) && (hCount > sfHeadHPos + 10'd65) && (hCount < sfHeadHPos + 10'd75))
                           ||((vCount < sfHeadVPos - 10'd52) && (vCount > sfHeadVPos - 10'd64) && (hCount > sfHeadHPos + 10'd75) && (hCount < sfHeadHPos + 10'd85))
                           ) ? 1 : 0;
                     
     assign sunflowerStem = (//374-425, 425-475
                               ((vCount <= sfVPosTemp + 10'd6) && (vCount >= sfVPosTemp + 10'd0) && (hCount >= sfHPos + 10'd55) && (hCount <= sfHPos + 10'd71))
                             ||((vCount <= sfVPosTemp + 10'd11) && (vCount >= sfVPosTemp + 10'd6) && (hCount >= sfHPos + 10'd54) && (hCount <= sfHPos + 10'd70))
                             ||((vCount <= sfVPosTemp + 10'd16) && (vCount >= sfVPosTemp + 10'd11) && (hCount >= sfHPos + 10'd53) && (hCount <= sfHPos + 10'd69))
                             ||((vCount <= sfVPosTemp + 10'd21) && (vCount >= sfVPosTemp + 10'd16) && (hCount >= sfHPos + 10'd52) && (hCount <= sfHPos + 10'd68))
                             ||((vCount <= sfVPosTemp + 10'd26) && (vCount >= sfVPosTemp + 10'd21) && (hCount >= sfHPos + 10'd51) && (hCount <= sfHPos + 10'd67))
                             ||((vCount <= sfVPosTemp + 10'd31) && (vCount >= sfVPosTemp + 10'd26) && (hCount >= sfHPos + 10'd50) && (hCount <= sfHPos + 10'd66))
                             ||((vCount <= sfVPosTemp + 10'd36) && (vCount >= sfVPosTemp + 10'd31) && (hCount >= sfHPos + 10'd49) && (hCount <= sfHPos + 10'd65))
                             ||((vCount <= sfVPosTemp + 10'd41) && (vCount >= sfVPosTemp + 10'd36) && (hCount >= sfHPos + 10'd48) && (hCount <= sfHPos + 10'd64))
                             ||((vCount <= sfVPosTemp + 10'd46) && (vCount >= sfVPosTemp + 10'd41) && (hCount >= sfHPos + 10'd47) && (hCount <= sfHPos + 10'd63))
                             ||((vCount <= sfVPosTemp + 10'd51) && (vCount >= sfVPosTemp + 10'd46) && (hCount >= sfHPos + 10'd46) && (hCount <= sfHPos + 10'd62))
                     
                             ||((vCount <= sfVPosTemp + 10'd96) && (vCount >= sfVPosTemp + 10'd91) && (hCount >= sfHPos + 10'd55) && (hCount <= sfHPos + 10'd71))
                             ||((vCount <= sfVPosTemp + 10'd91) && (vCount >= sfVPosTemp + 10'd86) && (hCount >= sfHPos + 10'd54) && (hCount <= sfHPos + 10'd70))
                             ||((vCount <= sfVPosTemp + 10'd86) && (vCount >= sfVPosTemp + 10'd81) && (hCount >= sfHPos + 10'd53) && (hCount <= sfHPos + 10'd69))
                             ||((vCount <= sfVPosTemp + 10'd81) && (vCount >= sfVPosTemp + 10'd76) && (hCount >= sfHPos + 10'd52) && (hCount <= sfHPos + 10'd68))
                             ||((vCount <= sfVPosTemp + 10'd76) && (vCount >= sfVPosTemp + 10'd71) && (hCount >= sfHPos + 10'd51) && (hCount <= sfHPos + 10'd67))
                             ||((vCount <= sfVPosTemp + 10'd71) && (vCount >= sfVPosTemp + 10'd66) && (hCount >= sfHPos + 10'd50) && (hCount <= sfHPos + 10'd66))
                             ||((vCount <= sfVPosTemp + 10'd66) && (vCount >= sfVPosTemp + 10'd61) && (hCount >= sfHPos + 10'd49) && (hCount <= sfHPos + 10'd65))
                             ||((vCount <= sfVPosTemp + 10'd61) && (vCount >= sfVPosTemp + 10'd56) && (hCount >= sfHPos + 10'd48) && (hCount <= sfHPos + 10'd64))
                             ||((vCount <= sfVPosTemp + 10'd56) && (vCount >= sfVPosTemp + 10'd51) && (hCount >= sfHPos + 10'd47) && (hCount <= sfHPos + 10'd63))
                             ||((vCount <= sfVPosTemp + 10'd51) && (vCount >= sfVPosTemp + 10'd46) && (hCount >= sfHPos + 10'd46) && (hCount <= sfHPos + 10'd62))
                             
                             ||((vCount <= sfVPosTemp + 10'd96) && (vCount >= sfVPosTemp + 10'd94) && (hCount >= sfHPos - 10'd4) && (hCount <= sfHPos + 10'd60))
                             ||((vCount <= sfVPosTemp + 10'd95) && (vCount >= sfVPosTemp + 10'd93) && (hCount >= sfHPos - 10'd3) && (hCount <= sfHPos + 10'd59))
                             ||((vCount <= sfVPosTemp + 10'd94) && (vCount >= sfVPosTemp + 10'd92) && (hCount >= sfHPos - 10'd2) && (hCount <= sfHPos + 10'd58))
                             ||((vCount <= sfVPosTemp + 10'd93) && (vCount >= sfVPosTemp + 10'd91) && (hCount >= sfHPos - 10'd1) && (hCount <= sfHPos + 10'd57))
                             ||((vCount <= sfVPosTemp + 10'd92) && (vCount >= sfVPosTemp + 10'd90) && (hCount >= sfHPos - 10'd0) && (hCount <= sfHPos + 10'd56))
                             ||((vCount <= sfVPosTemp + 10'd91) && (vCount >= sfVPosTemp + 10'd89) && (hCount >= sfHPos + 10'd1) && (hCount <= sfHPos + 10'd55))
                             ||((vCount <= sfVPosTemp + 10'd90) && (vCount >= sfVPosTemp + 10'd88) && (hCount >= sfHPos + 10'd2) && (hCount <= sfHPos + 10'd54))
                             ||((vCount <= sfVPosTemp + 10'd89) && (vCount >= sfVPosTemp + 10'd87) && (hCount >= sfHPos + 10'd3) && (hCount <= sfHPos + 10'd53))
                             ||((vCount <= sfVPosTemp + 10'd88) && (vCount >= sfVPosTemp + 10'd86) && (hCount >= sfHPos + 10'd4) && (hCount <= sfHPos + 10'd52))
                             ||((vCount <= sfVPosTemp + 10'd87) && (vCount >= sfVPosTemp + 10'd85) && (hCount >= sfHPos + 10'd5) && (hCount <= sfHPos + 10'd51))
                             ||((vCount <= sfVPosTemp + 10'd86) && (vCount >= sfVPosTemp + 10'd84) && (hCount >= sfHPos + 10'd6) && (hCount <= sfHPos + 10'd50))
                             ||((vCount <= sfVPosTemp + 10'd85) && (vCount >= sfVPosTemp + 10'd83) && (hCount >= sfHPos + 10'd7) && (hCount <= sfHPos + 10'd49))
                             ||((vCount <= sfVPosTemp + 10'd84) && (vCount >= sfVPosTemp + 10'd82) && (hCount >= sfHPos + 10'd8) && (hCount <= sfHPos + 10'd48))
                             ||((vCount <= sfVPosTemp + 10'd83) && (vCount >= sfVPosTemp + 10'd81) && (hCount >= sfHPos + 10'd9) && (hCount <= sfHPos + 10'd47))
                             ||((vCount <= sfVPosTemp + 10'd82) && (vCount >= sfVPosTemp + 10'd80) && (hCount >= sfHPos + 10'd10) && (hCount <= sfHPos + 10'd46))
                             ||((vCount <= sfVPosTemp + 10'd81) && (vCount >= sfVPosTemp + 10'd79) && (hCount >= sfHPos + 10'd11) && (hCount <= sfHPos + 10'd45))
                             ||((vCount <= sfVPosTemp + 10'd80) && (vCount >= sfVPosTemp + 10'd78) && (hCount >= sfHPos + 10'd12) && (hCount <= sfHPos + 10'd44))
                             ||((vCount <= sfVPosTemp + 10'd79) && (vCount >= sfVPosTemp + 10'd77) && (hCount >= sfHPos + 10'd13) && (hCount <= sfHPos + 10'd43))
                             ||((vCount <= sfVPosTemp + 10'd78) && (vCount >= sfVPosTemp + 10'd76) && (hCount >= sfHPos + 10'd14) && (hCount <= sfHPos + 10'd42))
                             ||((vCount <= sfVPosTemp + 10'd77) && (vCount >= sfVPosTemp + 10'd75) && (hCount >= sfHPos + 10'd15) && (hCount <= sfHPos + 10'd41))
                             ||((vCount <= sfVPosTemp + 10'd76) && (vCount >= sfVPosTemp + 10'd74) && (hCount >= sfHPos + 10'd16) && (hCount <= sfHPos + 10'd40))
                             ||((vCount <= sfVPosTemp + 10'd75) && (vCount >= sfVPosTemp + 10'd73) && (hCount >= sfHPos + 10'd17) && (hCount <= sfHPos + 10'd39))
                             ||((vCount <= sfVPosTemp + 10'd74) && (vCount >= sfVPosTemp + 10'd72) && (hCount >= sfHPos + 10'd18) && (hCount <= sfHPos + 10'd38))
                             ||((vCount <= sfVPosTemp + 10'd73) && (vCount >= sfVPosTemp + 10'd71) && (hCount >= sfHPos + 10'd19) && (hCount <= sfHPos + 10'd37))
                             ||((vCount <= sfVPosTemp + 10'd72) && (vCount >= sfVPosTemp + 10'd70) && (hCount >= sfHPos + 10'd20) && (hCount <= sfHPos + 10'd36))
                             ||((vCount <= sfVPosTemp + 10'd71) && (vCount >= sfVPosTemp + 10'd69) && (hCount >= sfHPos + 10'd21) && (hCount <= sfHPos + 10'd35))
                             ||((vCount <= sfVPosTemp + 10'd70) && (vCount >= sfVPosTemp + 10'd68) && (hCount >= sfHPos + 10'd22) && (hCount <= sfHPos + 10'd34))
                             ||((vCount <= sfVPosTemp + 10'd69) && (vCount >= sfVPosTemp + 10'd67) && (hCount >= sfHPos + 10'd23) && (hCount <= sfHPos + 10'd33))
                             ||((vCount <= sfVPosTemp + 10'd68) && (vCount >= sfVPosTemp + 10'd66) && (hCount >= sfHPos + 10'd24) && (hCount <= sfHPos + 10'd32))
                             ||((vCount <= sfVPosTemp + 10'd67) && (vCount >= sfVPosTemp + 10'd65) && (hCount >= sfHPos + 10'd25) && (hCount <= sfHPos + 10'd31))
                             ||((vCount <= sfVPosTemp + 10'd66) && (vCount >= sfVPosTemp + 10'd64) && (hCount >= sfHPos + 10'd26) && (hCount <= sfHPos + 10'd30))
                             ||((vCount <= sfVPosTemp + 10'd65) && (vCount >= sfVPosTemp + 10'd63) && (hCount >= sfHPos + 10'd27) && (hCount <= sfHPos + 10'd29))
                             ||((vCount <= sfVPosTemp + 10'd64) && (vCount >= sfVPosTemp + 10'd62) && (hCount >= sfHPos + 10'd28) && (hCount <= sfHPos + 10'd28))


                             ||((vCount <= sfVPosTemp + 10'd96) && (vCount >= sfVPosTemp + 10'd94) && (hCount <= sfHPos + 10'd124) && (hCount >= sfHPos + 10'd60))
                             ||((vCount <= sfVPosTemp + 10'd95) && (vCount >= sfVPosTemp + 10'd93) && (hCount <= sfHPos + 10'd123) && (hCount >= sfHPos + 10'd61))
                             ||((vCount <= sfVPosTemp + 10'd94) && (vCount >= sfVPosTemp + 10'd92) && (hCount <= sfHPos + 10'd122) && (hCount >= sfHPos + 10'd62))
                             ||((vCount <= sfVPosTemp + 10'd93) && (vCount >= sfVPosTemp + 10'd91) && (hCount <= sfHPos + 10'd120) && (hCount >= sfHPos + 10'd63))
                             ||((vCount <= sfVPosTemp + 10'd92) && (vCount >= sfVPosTemp + 10'd90) && (hCount <= sfHPos + 10'd119) && (hCount >= sfHPos + 10'd64))
                             ||((vCount <= sfVPosTemp + 10'd91) && (vCount >= sfVPosTemp + 10'd89) && (hCount <= sfHPos + 10'd118) && (hCount >= sfHPos + 10'd65))
                             ||((vCount <= sfVPosTemp + 10'd90) && (vCount >= sfVPosTemp + 10'd88) && (hCount <= sfHPos + 10'd117) && (hCount >= sfHPos + 10'd66))
                             ||((vCount <= sfVPosTemp + 10'd89) && (vCount >= sfVPosTemp + 10'd87) && (hCount <= sfHPos + 10'd116) && (hCount >= sfHPos + 10'd67))
                             ||((vCount <= sfVPosTemp + 10'd88) && (vCount >= sfVPosTemp + 10'd86) && (hCount <= sfHPos + 10'd115) && (hCount >= sfHPos + 10'd68))
                             ||((vCount <= sfVPosTemp + 10'd87) && (vCount >= sfVPosTemp + 10'd85) && (hCount <= sfHPos + 10'd114) && (hCount >= sfHPos + 10'd69))
                             ||((vCount <= sfVPosTemp + 10'd86) && (vCount >= sfVPosTemp + 10'd84) && (hCount <= sfHPos + 10'd113) && (hCount >= sfHPos + 10'd70))
                             ||((vCount <= sfVPosTemp + 10'd85) && (vCount >= sfVPosTemp + 10'd83) && (hCount <= sfHPos + 10'd112) && (hCount >= sfHPos + 10'd71))
                             ||((vCount <= sfVPosTemp + 10'd84) && (vCount >= sfVPosTemp + 10'd82) && (hCount <= sfHPos + 10'd111) && (hCount >= sfHPos + 10'd72))
                             ||((vCount <= sfVPosTemp + 10'd83) && (vCount >= sfVPosTemp + 10'd81) && (hCount <= sfHPos + 10'd110) && (hCount >= sfHPos + 10'd73))
                             ||((vCount <= sfVPosTemp + 10'd82) && (vCount >= sfVPosTemp + 10'd80) && (hCount <= sfHPos + 10'd109) && (hCount >= sfHPos + 10'd74))
                             ||((vCount <= sfVPosTemp + 10'd81) && (vCount >= sfVPosTemp + 10'd79) && (hCount <= sfHPos + 10'd108) && (hCount >= sfHPos + 10'd75))
                             ||((vCount <= sfVPosTemp + 10'd80) && (vCount >= sfVPosTemp + 10'd78) && (hCount <= sfHPos + 10'd107) && (hCount >= sfHPos + 10'd76))
                             ||((vCount <= sfVPosTemp + 10'd79) && (vCount >= sfVPosTemp + 10'd77) && (hCount <= sfHPos + 10'd106) && (hCount >= sfHPos + 10'd77))
                             ||((vCount <= sfVPosTemp + 10'd78) && (vCount >= sfVPosTemp + 10'd76) && (hCount <= sfHPos + 10'd105) && (hCount >= sfHPos + 10'd78))
                             ||((vCount <= sfVPosTemp + 10'd77) && (vCount >= sfVPosTemp + 10'd75) && (hCount <= sfHPos + 10'd104) && (hCount >= sfHPos + 10'd79))
                             ||((vCount <= sfVPosTemp + 10'd76) && (vCount >= sfVPosTemp + 10'd74) && (hCount <= sfHPos + 10'd103) && (hCount >= sfHPos + 10'd80))
                             ||((vCount <= sfVPosTemp + 10'd75) && (vCount >= sfVPosTemp + 10'd73) && (hCount <= sfHPos + 10'd102) && (hCount >= sfHPos + 10'd81))
                             ||((vCount <= sfVPosTemp + 10'd74) && (vCount >= sfVPosTemp + 10'd72) && (hCount <= sfHPos + 10'd101) && (hCount >= sfHPos + 10'd82))
                             ||((vCount <= sfVPosTemp + 10'd73) && (vCount >= sfVPosTemp + 10'd71) && (hCount <= sfHPos + 10'd100) && (hCount >= sfHPos + 10'd83))
                             ||((vCount <= sfVPosTemp + 10'd72) && (vCount >= sfVPosTemp + 10'd70) && (hCount <= sfHPos + 10'd99) && (hCount >= sfHPos + 10'd84))
                             ||((vCount <= sfVPosTemp + 10'd71) && (vCount >= sfVPosTemp + 10'd69) && (hCount <= sfHPos + 10'd98) && (hCount >= sfHPos + 10'd85))
                             ||((vCount <= sfVPosTemp + 10'd70) && (vCount >= sfVPosTemp + 10'd68) && (hCount <= sfHPos + 10'd97) && (hCount >= sfHPos + 10'd86))
                             ||((vCount <= sfVPosTemp + 10'd69) && (vCount >= sfVPosTemp + 10'd67) && (hCount <= sfHPos + 10'd96) && (hCount >= sfHPos + 10'd87))
                             ||((vCount <= sfVPosTemp + 10'd68) && (vCount >= sfVPosTemp + 10'd66) && (hCount <= sfHPos + 10'd95) && (hCount >= sfHPos + 10'd88))
                             ||((vCount <= sfVPosTemp + 10'd67) && (vCount >= sfVPosTemp + 10'd65) && (hCount <= sfHPos + 10'd94) && (hCount >= sfHPos + 10'd89))
                             ||((vCount <= sfVPosTemp + 10'd66) && (vCount >= sfVPosTemp + 10'd64) && (hCount <= sfHPos + 10'd93) && (hCount >= sfHPos + 10'd90))
                             ||((vCount <= sfVPosTemp + 10'd65) && (vCount >= sfVPosTemp + 10'd63) && (hCount <= sfHPos + 10'd92) && (hCount >= sfHPos + 10'd91))
                           ) ? 1 : 0;
endmodule