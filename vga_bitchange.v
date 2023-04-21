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

    reg[9:0] sfVPos;
    reg[9:0] sfHPos;
    reg[9:0] sfHeadHPos;
    reg[9:0] sfHeadVPos;
    reg[9:0] sfHeadVPos;
    reg[9:0] sfHeadVPos;
    reg[49:0] sfBounceSpeed;
    reg sfHeadFlag;

	initial begin
		zombies_killed = 15'd0;
		reset = 1'b0;
		sfVPos = 10'd374;
		sfHPos = 10'd225;
		sfHeadHPos = sfHPos;
		sfHeadVPos = sfVPos;
		sfHeadFlag = 1'd0;
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
		
	always@ (posedge clk)
	begin
	   sfBounceSpeed = sfBounceSpeed + 50'd1;
	   if (sfBounceSpeed >= 50'd4000000)
	   begin
	       sfBounceSpeed = 50'd0;
	       if (sfHeadHPos <= (sfHPos - 10'd30))
	           sfHeadFlag = 1'd0;
	       if (sfHeadHPos >= (sfHPos + 10'd30))
	           sfHeadFlag = 1'd1;
	           
	       if (sfHeadFlag == 1'd0)
	           sfHeadHPos = sfHeadHPos + 1'd1;
	       else
	           sfHeadHPos = sfHeadHPos - 1'd1;
	       	           
	       if ((sfHeadFlag == 1'd0) && (sfHeadHPos <= sfHPos))
	           sfHeadVPos = sfHeadVPos - 1'd1;
	       if ((sfHeadFlag == 1'd0) && (sfHeadHPos > sfHPos))
	           sfHeadVPos = sfHeadVPos + 1'd1;
	       if ((sfHeadFlag == 1'd1) && (sfHeadHPos >= sfHPos))
	           sfHeadVPos = sfHeadVPos - 1'd1;
	       if ((sfHeadFlag == 1'd1) && (sfHeadHPos < sfHPos))
	           sfHeadVPos = sfHeadVPos + 1'd1;
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
                               ((vCount <= sfVPos + 10'd6) && (vCount >= sfVPos + 10'd0) && (hCount >= sfHPos + 10'd55) && (hCount <= sfHPos + 10'd71))
                             ||((vCount <= sfVPos + 10'd11) && (vCount >= sfVPos + 10'd6) && (hCount >= sfHPos + 10'd54) && (hCount <= sfHPos + 10'd70))
                             ||((vCount <= sfVPos + 10'd16) && (vCount >= sfVPos + 10'd11) && (hCount >= sfHPos + 10'd53) && (hCount <= sfHPos + 10'd69))
                             ||((vCount <= sfVPos + 10'd21) && (vCount >= sfVPos + 10'd16) && (hCount >= sfHPos + 10'd52) && (hCount <= sfHPos + 10'd68))
                             ||((vCount <= sfVPos + 10'd26) && (vCount >= sfVPos + 10'd21) && (hCount >= sfHPos + 10'd51) && (hCount <= sfHPos + 10'd67))
                             ||((vCount <= sfVPos + 10'd31) && (vCount >= sfVPos + 10'd26) && (hCount >= sfHPos + 10'd50) && (hCount <= sfHPos + 10'd66))
                             ||((vCount <= sfVPos + 10'd36) && (vCount >= sfVPos + 10'd31) && (hCount >= sfHPos + 10'd49) && (hCount <= sfHPos + 10'd65))
                             ||((vCount <= sfVPos + 10'd41) && (vCount >= sfVPos + 10'd36) && (hCount >= sfHPos + 10'd48) && (hCount <= sfHPos + 10'd64))
                             ||((vCount <= sfVPos + 10'd46) && (vCount >= sfVPos + 10'd41) && (hCount >= sfHPos + 10'd47) && (hCount <= sfHPos + 10'd63))
                             ||((vCount <= sfVPos + 10'd51) && (vCount >= sfVPos + 10'd46) && (hCount >= sfHPos + 10'd46) && (hCount <= sfHPos + 10'd62))
                     
                             ||((vCount <= sfVPos + 10'd96) && (vCount >= sfVPos + 10'd91) && (hCount >= sfHPos + 10'd55) && (hCount <= sfHPos + 10'd71))
                             ||((vCount <= sfVPos + 10'd91) && (vCount >= sfVPos + 10'd86) && (hCount >= sfHPos + 10'd54) && (hCount <= sfHPos + 10'd70))
                             ||((vCount <= sfVPos + 10'd86) && (vCount >= sfVPos + 10'd81) && (hCount >= sfHPos + 10'd53) && (hCount <= sfHPos + 10'd69))
                             ||((vCount <= sfVPos + 10'd81) && (vCount >= sfVPos + 10'd76) && (hCount >= sfHPos + 10'd52) && (hCount <= sfHPos + 10'd68))
                             ||((vCount <= sfVPos + 10'd76) && (vCount >= sfVPos + 10'd71) && (hCount >= sfHPos + 10'd51) && (hCount <= sfHPos + 10'd67))
                             ||((vCount <= sfVPos + 10'd71) && (vCount >= sfVPos + 10'd66) && (hCount >= sfHPos + 10'd50) && (hCount <= sfHPos + 10'd66))
                             ||((vCount <= sfVPos + 10'd66) && (vCount >= sfVPos + 10'd61) && (hCount >= sfHPos + 10'd49) && (hCount <= sfHPos + 10'd65))
                             ||((vCount <= sfVPos + 10'd61) && (vCount >= sfVPos + 10'd56) && (hCount >= sfHPos + 10'd48) && (hCount <= sfHPos + 10'd64))
                             ||((vCount <= sfVPos + 10'd56) && (vCount >= sfVPos + 10'd51) && (hCount >= sfHPos + 10'd47) && (hCount <= sfHPos + 10'd63))
                             ||((vCount <= sfVPos + 10'd51) && (vCount >= sfVPos + 10'd46) && (hCount >= sfHPos + 10'd46) && (hCount <= sfHPos + 10'd62))
                             
                             ||((vCount <= sfVPos + 10'd96) && (vCount >= sfVPos + 10'd94) && (hCount >= sfHPos - 10'd4) && (hCount <= sfHPos + 10'd60))
                             ||((vCount <= sfVPos + 10'd95) && (vCount >= sfVPos + 10'd93) && (hCount >= sfHPos - 10'd3) && (hCount <= sfHPos + 10'd59))
                             ||((vCount <= sfVPos + 10'd94) && (vCount >= sfVPos + 10'd92) && (hCount >= sfHPos - 10'd2) && (hCount <= sfHPos + 10'd58))
                             ||((vCount <= sfVPos + 10'd93) && (vCount >= sfVPos + 10'd91) && (hCount >= sfHPos - 10'd1) && (hCount <= sfHPos + 10'd57))
                             ||((vCount <= sfVPos + 10'd92) && (vCount >= sfVPos + 10'd90) && (hCount >= sfHPos - 10'd0) && (hCount <= sfHPos + 10'd56))
                             ||((vCount <= sfVPos + 10'd91) && (vCount >= sfVPos + 10'd89) && (hCount >= sfHPos + 10'd1) && (hCount <= sfHPos + 10'd55))
                             ||((vCount <= sfVPos + 10'd90) && (vCount >= sfVPos + 10'd88) && (hCount >= sfHPos + 10'd2) && (hCount <= sfHPos + 10'd54))
                             ||((vCount <= sfVPos + 10'd89) && (vCount >= sfVPos + 10'd87) && (hCount >= sfHPos + 10'd3) && (hCount <= sfHPos + 10'd53))
                             ||((vCount <= sfVPos + 10'd88) && (vCount >= sfVPos + 10'd86) && (hCount >= sfHPos + 10'd4) && (hCount <= sfHPos + 10'd52))
                             ||((vCount <= sfVPos + 10'd87) && (vCount >= sfVPos + 10'd85) && (hCount >= sfHPos + 10'd5) && (hCount <= sfHPos + 10'd51))
                             ||((vCount <= sfVPos + 10'd86) && (vCount >= sfVPos + 10'd84) && (hCount >= sfHPos + 10'd6) && (hCount <= sfHPos + 10'd50))
                             ||((vCount <= sfVPos + 10'd85) && (vCount >= sfVPos + 10'd83) && (hCount >= sfHPos + 10'd7) && (hCount <= sfHPos + 10'd49))
                             ||((vCount <= sfVPos + 10'd84) && (vCount >= sfVPos + 10'd82) && (hCount >= sfHPos + 10'd8) && (hCount <= sfHPos + 10'd48))
                             ||((vCount <= sfVPos + 10'd83) && (vCount >= sfVPos + 10'd81) && (hCount >= sfHPos + 10'd9) && (hCount <= sfHPos + 10'd47))
                             ||((vCount <= sfVPos + 10'd82) && (vCount >= sfVPos + 10'd80) && (hCount >= sfHPos + 10'd10) && (hCount <= sfHPos + 10'd46))
                             ||((vCount <= sfVPos + 10'd81) && (vCount >= sfVPos + 10'd79) && (hCount >= sfHPos + 10'd11) && (hCount <= sfHPos + 10'd45))
                             ||((vCount <= sfVPos + 10'd80) && (vCount >= sfVPos + 10'd78) && (hCount >= sfHPos + 10'd12) && (hCount <= sfHPos + 10'd44))
                             ||((vCount <= sfVPos + 10'd79) && (vCount >= sfVPos + 10'd77) && (hCount >= sfHPos + 10'd13) && (hCount <= sfHPos + 10'd43))
                             ||((vCount <= sfVPos + 10'd78) && (vCount >= sfVPos + 10'd76) && (hCount >= sfHPos + 10'd14) && (hCount <= sfHPos + 10'd42))
                             ||((vCount <= sfVPos + 10'd77) && (vCount >= sfVPos + 10'd75) && (hCount >= sfHPos + 10'd15) && (hCount <= sfHPos + 10'd41))
                             ||((vCount <= sfVPos + 10'd76) && (vCount >= sfVPos + 10'd74) && (hCount >= sfHPos + 10'd16) && (hCount <= sfHPos + 10'd40))
                             ||((vCount <= sfVPos + 10'd75) && (vCount >= sfVPos + 10'd73) && (hCount >= sfHPos + 10'd17) && (hCount <= sfHPos + 10'd39))
                             ||((vCount <= sfVPos + 10'd74) && (vCount >= sfVPos + 10'd72) && (hCount >= sfHPos + 10'd18) && (hCount <= sfHPos + 10'd38))
                             ||((vCount <= sfVPos + 10'd73) && (vCount >= sfVPos + 10'd71) && (hCount >= sfHPos + 10'd19) && (hCount <= sfHPos + 10'd37))
                             ||((vCount <= sfVPos + 10'd72) && (vCount >= sfVPos + 10'd70) && (hCount >= sfHPos + 10'd20) && (hCount <= sfHPos + 10'd36))
                             ||((vCount <= sfVPos + 10'd71) && (vCount >= sfVPos + 10'd69) && (hCount >= sfHPos + 10'd21) && (hCount <= sfHPos + 10'd35))
                             ||((vCount <= sfVPos + 10'd70) && (vCount >= sfVPos + 10'd68) && (hCount >= sfHPos + 10'd22) && (hCount <= sfHPos + 10'd34))
                             ||((vCount <= sfVPos + 10'd69) && (vCount >= sfVPos + 10'd67) && (hCount >= sfHPos + 10'd23) && (hCount <= sfHPos + 10'd33))
                             ||((vCount <= sfVPos + 10'd68) && (vCount >= sfVPos + 10'd66) && (hCount >= sfHPos + 10'd24) && (hCount <= sfHPos + 10'd32))
                             ||((vCount <= sfVPos + 10'd67) && (vCount >= sfVPos + 10'd65) && (hCount >= sfHPos + 10'd25) && (hCount <= sfHPos + 10'd31))
                             ||((vCount <= sfVPos + 10'd66) && (vCount >= sfVPos + 10'd64) && (hCount >= sfHPos + 10'd26) && (hCount <= sfHPos + 10'd30))
                             ||((vCount <= sfVPos + 10'd65) && (vCount >= sfVPos + 10'd63) && (hCount >= sfHPos + 10'd27) && (hCount <= sfHPos + 10'd29))
                             ||((vCount <= sfVPos + 10'd64) && (vCount >= sfVPos + 10'd62) && (hCount >= sfHPos + 10'd28) && (hCount <= sfHPos + 10'd28))
//                             ||((vCount <= 10'd437) && (vCount >= 10'd435) && (hCount >= 10'd248) && (hCount <= 10'd250))
//                             ||((vCount <= 10'd436) && (vCount >= 10'd434) && (hCount >= 10'd249) && (hCount <= 10'd250))
//                             ||((vCount <= 10'd435) && (vCount >= 10'd433) && (hCount >= 10'd250) && (hCount <= 10'd250))
//                             ||((vCount <= 10'd434) && (vCount >= 10'd432) && (hCount >= 10'd251) && (hCount <= 10'd250))


//                             ||((vCount <= 10'd470) && (vCount >= 10'd465) && (hCount >= 10'd272) && (hCount <= 10'd314))
//                             ||((vCount <= 10'd465) && (vCount >= 10'd460) && (hCount >= 10'd278) && (hCount <= 10'd308))
//                             ||((vCount <= 10'd460) && (vCount >= 10'd455) && (hCount >= 10'd284) && (hCount <= 10'd302))
//                             ||((vCount <= 10'd455) && (vCount >= 10'd450) && (hCount >= 10'd290) && (hCount <= 10'd296))
//                             ||((vCount <= 10'd450) && (vCount >= 10'd445) && (hCount >= 10'd292) && (hCount <= 10'd252))


                             ||((vCount <= sfVPos + 10'd96) && (vCount >= sfVPos + 10'd94) && (hCount <= sfHPos + 10'd124) && (hCount >= sfHPos + 10'd60))
                             ||((vCount <= sfVPos + 10'd95) && (vCount >= sfVPos + 10'd93) && (hCount <= sfHPos + 10'd123) && (hCount >= sfHPos + 10'd61))
                             ||((vCount <= sfVPos + 10'd94) && (vCount >= sfVPos + 10'd92) && (hCount <= sfHPos + 10'd122) && (hCount >= sfHPos + 10'd62))
                             ||((vCount <= sfVPos + 10'd93) && (vCount >= sfVPos + 10'd91) && (hCount <= sfHPos + 10'd120) && (hCount >= sfHPos + 10'd63))
                             ||((vCount <= sfVPos + 10'd92) && (vCount >= sfVPos + 10'd90) && (hCount <= sfHPos + 10'd119) && (hCount >= sfHPos + 10'd64))
                             ||((vCount <= sfVPos + 10'd91) && (vCount >= sfVPos + 10'd89) && (hCount <= sfHPos + 10'd118) && (hCount >= sfHPos + 10'd65))
                             ||((vCount <= sfVPos + 10'd90) && (vCount >= sfVPos + 10'd88) && (hCount <= sfHPos + 10'd117) && (hCount >= sfHPos + 10'd66))
                             ||((vCount <= sfVPos + 10'd89) && (vCount >= sfVPos + 10'd87) && (hCount <= sfHPos + 10'd116) && (hCount >= sfHPos + 10'd67))
                             ||((vCount <= sfVPos + 10'd88) && (vCount >= sfVPos + 10'd86) && (hCount <= sfHPos + 10'd115) && (hCount >= sfHPos + 10'd68))
                             ||((vCount <= sfVPos + 10'd87) && (vCount >= sfVPos + 10'd85) && (hCount <= sfHPos + 10'd114) && (hCount >= sfHPos + 10'd69))
                             ||((vCount <= sfVPos + 10'd86) && (vCount >= sfVPos + 10'd84) && (hCount <= sfHPos + 10'd113) && (hCount >= sfHPos + 10'd70))
                             ||((vCount <= sfVPos + 10'd85) && (vCount >= sfVPos + 10'd83) && (hCount <= sfHPos + 10'd112) && (hCount >= sfHPos + 10'd71))
                             ||((vCount <= sfVPos + 10'd84) && (vCount >= sfVPos + 10'd82) && (hCount <= sfHPos + 10'd111) && (hCount >= sfHPos + 10'd72))
                             ||((vCount <= sfVPos + 10'd83) && (vCount >= sfVPos + 10'd81) && (hCount <= sfHPos + 10'd110) && (hCount >= sfHPos + 10'd73))
                             ||((vCount <= sfVPos + 10'd82) && (vCount >= sfVPos + 10'd80) && (hCount <= sfHPos + 10'd109) && (hCount >= sfHPos + 10'd74))
                             ||((vCount <= sfVPos + 10'd81) && (vCount >= sfVPos + 10'd79) && (hCount <= sfHPos + 10'd108) && (hCount >= sfHPos + 10'd75))
                             ||((vCount <= sfVPos + 10'd80) && (vCount >= sfVPos + 10'd78) && (hCount <= sfHPos + 10'd107) && (hCount >= sfHPos + 10'd76))
                             ||((vCount <= sfVPos + 10'd79) && (vCount >= sfVPos + 10'd77) && (hCount <= sfHPos + 10'd106) && (hCount >= sfHPos + 10'd77))
                             ||((vCount <= sfVPos + 10'd78) && (vCount >= sfVPos + 10'd76) && (hCount <= sfHPos + 10'd105) && (hCount >= sfHPos + 10'd78))
                             ||((vCount <= sfVPos + 10'd77) && (vCount >= sfVPos + 10'd75) && (hCount <= sfHPos + 10'd104) && (hCount >= sfHPos + 10'd79))
                             ||((vCount <= sfVPos + 10'd76) && (vCount >= sfVPos + 10'd74) && (hCount <= sfHPos + 10'd103) && (hCount >= sfHPos + 10'd80))
                             ||((vCount <= sfVPos + 10'd75) && (vCount >= sfVPos + 10'd73) && (hCount <= sfHPos + 10'd102) && (hCount >= sfHPos + 10'd81))
                             ||((vCount <= sfVPos + 10'd74) && (vCount >= sfVPos + 10'd72) && (hCount <= sfHPos + 10'd101) && (hCount >= sfHPos + 10'd82))
                             ||((vCount <= sfVPos + 10'd73) && (vCount >= sfVPos + 10'd71) && (hCount <= sfHPos + 10'd100) && (hCount >= sfHPos + 10'd83))
                             ||((vCount <= sfVPos + 10'd72) && (vCount >= sfVPos + 10'd70) && (hCount <= sfHPos + 10'd99) && (hCount >= sfHPos + 10'd84))
                             ||((vCount <= sfVPos + 10'd71) && (vCount >= sfVPos + 10'd69) && (hCount <= sfHPos + 10'd98) && (hCount >= sfHPos + 10'd85))
                             ||((vCount <= sfVPos + 10'd70) && (vCount >= sfVPos + 10'd68) && (hCount <= sfHPos + 10'd97) && (hCount >= sfHPos + 10'd86))
                             ||((vCount <= sfVPos + 10'd69) && (vCount >= sfVPos + 10'd67) && (hCount <= sfHPos + 10'd96) && (hCount >= sfHPos + 10'd87))
                             ||((vCount <= sfVPos + 10'd68) && (vCount >= sfVPos + 10'd66) && (hCount <= sfHPos + 10'd95) && (hCount >= sfHPos + 10'd88))
                             ||((vCount <= sfVPos + 10'd67) && (vCount >= sfVPos + 10'd65) && (hCount <= sfHPos + 10'd94) && (hCount >= sfHPos + 10'd89))
                             ||((vCount <= sfVPos + 10'd66) && (vCount >= sfVPos + 10'd64) && (hCount <= sfHPos + 10'd93) && (hCount >= sfHPos + 10'd90))
                             ||((vCount <= sfVPos + 10'd65) && (vCount >= sfVPos + 10'd63) && (hCount <= sfHPos + 10'd92) && (hCount >= sfHPos + 10'd91))
                           ) ? 1 : 0;
endmodule