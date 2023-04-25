`timescale 1ns / 1ps

// Anisha Palaparthi and Chely Fernandez

module vga_bitchange(
	input clk,
	input bright,
	//5 different positions for the zombies
	input [9:0] hCount, vCount,
	//Input for different buttons
	input upButton, downButton, leftButton, rightButton, selectButton,
	output reg [11:0] rgb,
	output reg [15:0] zombies_killed,
	output q_I, 
	output q_L1, 
	output q_NL2, 
	output q_L2, 
	output q_NL3, 
	output q_L3, 
	output q_DoneL, 
	output q_DoneW );

	//Color definitions
	parameter BLACK = 12'b0000_0000_0000;
	parameter ZOMBIE_SKIN = 12'b0000_1011_0100;
	parameter LIGHT_GREY = 12'b0011_0011_0010;
	parameter GREEN = 12'b0000_1111_0000;
	parameter DARK_GREEN = 12'b001110010010;
	parameter YELLOW = 12'b1111_1111_0000;
	parameter ORANGE = 12'b1111_1100_0000;
	parameter RED = 12'b1111_0000_0000;
	parameter GREY = 12'b1010_1010_1011;
	parameter ZOMBIE_HEAD = 12'b1010_1010_1011;
	parameter ZOMBIE_EYE = 12'b1111_1111_1111;

	//Size definitions
	parameter ZOMBIE_HEAD_RADIUS = 10'd21;
	parameter ZOMBIE_BODY_HEIGHT = 10'd50;
	parameter ZOMBIE0_ROW_TOP = 10'd87;
	parameter ZOMBIE_0_ROW_BOTTOM = 10'd173;
	parameter ZOMBIE1_ROW_TOP = 10'd174;
	parameter ZOMBIE_1_ROW_BOTTOM = 10'd260;
	parameter ZOMBIE2_ROW_TOP = 10'd261;
	parameter ZOMBIE_2_ROW_BOTTOM = 10'd347;
	parameter ZOMBIE3_ROW_TOP = 10'd348;
	parameter ZOMBIE_3_ROW_BOTTOM = 10'd434;
	parameter ZOMBIE4_ROW_TOP = 10'd435;
	parameter ZOMBIE_4_ROW_BOTTOM = 10'd521;
	parameter OUTLINE_WIDTH = 10'd02;
	parameter HALF_ZOMBIE_BODY_WIDTH = 10'd08;

	//Time definitions
	parameter TO_KILL_PEA = 50'd5000000;
	parameter TO_KILL_SUN = 50'd5000000;
	parameter TO_KILL_ZOMBIE = 50'd5000000;

	//Plant definitions
	parameter PEASHOOTER = 3'd001;
	parameter SUNFLOWER = 3'd010;
	parameter WALNUT = 3'd100;

    //Column and row widths
    parameter COLUMN_WIDTH = 10'd100;
	parameter HALF_COLUMN_WIDTH = 10'd50;
    parameter ROW_HEIGHT = 10'd87;

	//End of screen
	parameter END_OF_LAWN = 10'd124;

	//Register definitions
	reg reset;
	wire greyZone;
	wire zombie0; // Wires to hold zombie information
	wire zombie1;
	wire zombie2;
	wire zombie3;
	wire zombie4;
	reg[3:0] zombie0Counter;
	reg[3:0] zombie1Counter;
	reg[3:0] zombie2Counter;
	reg[3:0] zombie3Counter;
	reg[3:0] zombie4Counter;
	reg zombie0Stopped;
	reg zombie1Stopped;
	reg zombie2Stopped;
	reg zombie3Stopped;
	reg zombie4Stopped;
	//Wires to hold if zombie has been "killed"
	reg zombie0Killed;
	reg zombie1Killed;
	reg zombie2Killed;
	reg zombie3Killed;
	reg zombie4Killed;
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
	//Registers to hold zombie's Y position
	reg[49:0] zombieSpeed;// Regisiter to hold zombie speed
	
	//Registers to hold how long a zombie has been stopped
	reg[60:0] zombie0StoppedCounter;
	reg[60:0] zombie1StoppedCounter;
	reg[60:0] zombie2StoppedCounter;
	reg[60:0] zombie3StoppedCounter;
	reg[60:0] zombie4StoppedCounter;
	//Registers to hold location of rightmost plant in every row
	reg[9:0] plant0X;
	reg[9:0] plant1X;
	reg[9:0] plant2X;
	reg[9:0] plant3X;
	reg[9:0] plant4X;
	//Registers to hold what type of plant is the rightmost plant in every row
	reg[2:0] plant0Type;
	reg[2:0] plant1Type;
	reg[2:0] plant2Type;
	reg[2:0] plant3Type;
	reg[2:0] plant4Type;
	reg plant0Killed;
	reg plant1Killed;
	reg plant2Killed;
	reg plant3Killed;
	reg plant4Killed;
	//Registers to hold pea shot's X position. There are 25 pea shots
	reg[9:0] peaShot0X;
	reg[9:0] peaShot1X;
	reg[9:0] peaShot2X;
	reg[9:0] peaShot3X;
	reg[9:0] peaShot4X;
	reg[9:0] peaShot5X;
	reg[9:0] peaShot6X;
	reg[9:0] peaShot7X;
	reg[9:0] peaShot8X;
	reg[9:0] peaShot9X;
	reg[9:0] peaShot10X;
	reg[9:0] peaShot11X;
	reg[9:0] peaShot12X;
	reg[9:0] peaShot13X;
	reg[9:0] peaShot14X;
	reg[9:0] peaShot15X;
	reg[9:0] peaShot16X;
	reg[9:0] peaShot17X;
	reg[9:0] peaShot18X;
	reg[9:0] peaShot19X;
	reg[9:0] peaShot20X;
	reg[9:0] peaShot21X;
	reg[9:0] peaShot22X;
	reg[9:0] peaShot23X;
	reg[9:0] peaShot24X;
	//Registers to hold if a plant has been placed on a certain grid box
	reg plant0Placed;
	reg plant1Placed;
	reg plant2Placed;
	reg plant3Placed;
	reg plant4Placed;
	reg plant5Placed;
	reg plant6Placed;
	reg plant7Placed;
	reg plant8Placed;
	reg plant9Placed;
	reg plant10Placed;
	reg plant11Placed;
	reg plant12Placed;
	reg plant13Placed;
	reg plant14Placed;
	reg plant15Placed;
	reg plant16Placed;
	reg plant17Placed;
	reg plant18Placed;
	reg plant19Placed;
	reg plant20Placed;
	reg plant21Placed;
	reg plant22Placed;
	reg plant23Placed;
	reg plant24Placed;

	//Wires for zombie graphics
	wire zombieEye0;
	wire zombieEye1;
	wire zombieEye2;
	wire zombieEye3;
	wire zombieEye4;

	wire zombieHead0;
	wire zombieHead1;
	wire zombieHead2;
	wire zombieHead3;
	wire zombieHead4;

	wire zombieBody0;
	wire zombieBody1;
	wire zombieBody2;
	wire zombieBody3;
	wire zombieBody4;

	wire zombieOutline0;
	wire zombieOutline1;
	wire zombieOutline2;
	wire zombieOutline3;
	wire zombieOutline4;

	//Wires for plant graphics
	wire sunflowerInner;
	wire sunflowerOuter;
	wire sunflowerFace;

	wire selectedPlantBoxOutline;
	wire GRID;

	

	//Wire to hold current selected plant box
	reg selectedPlantBox;
	reg isSelectingPlantBox;
	reg[9:0] selectedPlantBoxX;
	reg[2:0] userPlantSelection; //001 for Pea Shooter, 010 for Sunflower, 100 for Wallnut
	//Wire to hold current selected lawn position
	reg selectedLawnPositionOutline;
	reg isSelectingLawnPosition;
	reg[9:0] selectedGridBoxX;
	reg[9:0] selectedGridBoxY;
	reg [4:0] userGridSelection;
	
	//Store the current state
//	output q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW;
	reg [7:0] state;
	assign {q_I, q_L1, q_NL2, q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW} = state;
	
	//Local parameters for state
	parameter I = 8'b0000_0001, L1 = 8'b0000_0010, NL2 = 8'b0000_0100, L2 = 8'b0000_1000, NL3 = 8'b0001_0000, L3 = 8'b0010_0000, DoneL = 8'b0100_0000, DoneW = 8'b1000_0000;


	initial begin
		//Initialize the X position on the zombies to be the right side of the lawn
		zombie0X = 10'd799;
		zombie1X = 10'd799;
		zombie2X = 10'd799;
		zombie3X = 10'd799;
		zombie4X = 10'd799;
		//Initialize the zombies to be alive
		zombie0Killed = 1'b0;
		zombie1Killed = 1'b0;
		zombie2Killed = 1'b0;
		zombie3Killed = 1'b0;
		zombie4Killed = 1'b0;
		//Initiliaze the X coordinate of the selected plant box
		selectedPlantBoxX = 10'd0;
		//TODO: initiliaze the state?
		zombies_killed = 15'd0;
		reset = 1'b0;
		userPlantSelection = 10'd0;
		isSelectingPlantBox = 0;
		//Initially the zombies are moving
		zombie0Stopped = 1'b0;
		zombie1Stopped = 1'b0;
		zombie2Stopped = 1'b0;
		zombie3Stopped = 1'b0;
		zombie4Stopped = 1'b0;
		//Initially all the zombies are alive
		zombie0Killed = 1'b0;
		zombie1Killed = 1'b0;
		zombie2Killed = 1'b0;
		zombie3Killed = 1'b0;
		zombie4Killed = 1'b0;
	end

	//TODO: define the zombie colors here
	//Define the color scheme
	always@ (*)
    if (~bright)
        rgb = BLACK;
	else if (selectedPlantBoxOutline == 1)
		rgb = RED;
	else if (selectedLawnPositionOutline == 1)
		rgb = RED;
	else if ((zombieEye0 == 1 && ~zombie0Killed) || (zombieEye1 == 1 && ~zombie1Killed) || (zombieEye2 == 1 && ~zombie2Killed) || (zombieEye3 == 1 && ~zombie3Killed) || (zombieEye4 == 1 && ~zombie4Killed))
		rgb = ZOMBIE_EYE;
	else if ((zombieHead0 == 1 && ~zombie0Killed) || (zombieHead1 == 1 && ~zombie1Killed) || (zombieHead2 == 1 && ~zombie2Killed) || (zombieHead3 == 1 && ~zombie3Killed) || (zombieHead4 == 1 && ~zombie4Killed))
		rgb = ZOMBIE_HEAD;
	else if ((zombieOutline0 == 1 && ~zombie0Killed) || (zombieOutline1 == 1 && ~zombie1Killed) || (zombieOutline2 == 1 && ~zombie2Killed) || (zombieOutline3 == 1 && ~zombie3Killed) || (zombieOutline4 == 1 && ~zombie4Killed))
		rgb = BLACK;
	// else if((zombieBody0 == 1 && ~zombie0Killed) || (zombieBody1 == 1 && ~zombie1Killed) || (zombieBody2 == 1 && ~zombie2Killed) || (zombieBody3 == 1 && ~zombie3Killed) || (zombieBody4 == 1 && ~zombie4Killed))
	else if(zombieBody0 == 1 || zombieBody1 == 1 || zombieBody2 == 1 || zombieBody3 == 1 || zombieBody4 == 1)
		rgb = ZOMBIE_SKIN;
	// else if (zombie0 == 1 || zombie1 == 1 || zombie2 == 1 || zombie3 == 1 || zombie4 == 1)
	// 	rgb = ZOMBIE_SKIN;
    else if (sunflowerFace == 1)
        rgb = BLACK;
    else if (sunflowerInner == 1)
        rgb = ORANGE;
    else if (sunflowerOuter == 1)
        rgb = YELLOW;
    else if (greyZone == 1)
        rgb = GREY;
	else if (GRID == 1)
		rgb = DARK_GREEN;
    else
        rgb = GREEN; // background color
 
	//At every clock, move the zombies to the right by increasnig the zombie "speed"
	always @(posedge clk) begin
    zombieSpeed = zombieSpeed + 50'd1;
    if (zombieSpeed >= 50'd1000000) begin
        if (zombie1X <= 50'd600 && ~zombie0Stopped) // Move zombie0 after zombie1 has moved 200 pixels across the screen
            zombie0X = zombie0X - 10'd1;
		
        //Zombie 1 always enters the lawn first
		if (~zombie1Stopped)
			zombie1X = zombie1X - 10'd1;
		
        
        if (zombie0X <= 50'd600 && ~zombie2Stopped) // Move zombie2 after zombie0 has moved 200 pixels across the screen
            zombie2X = zombie2X - 10'd1;

        if (zombie0X <= 50'd700 && ~zombie3Stopped) // Move zombie3 after zombie0 has moved 100 pixels across the screen
            zombie3X = zombie3X - 10'd1;

        if (zombie3X <= 50'd700 && ~zombie4Stopped) // Move zombie4 zombie3 has moved 100 pixels across the screen
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

	//Always at the posedge of the clock, if the zombie is in the same position as the plant, stop the zombie and "eat" the plant
	always@ (posedge clk)
	begin
		if(zombie0X == plant0X)
			zombie0Stopped = 1'b1;
			//Have some type of counter to see how long the zombie has been with the plant
			zombie0Counter = zombie0Counter + 1'd1;
			if((zombie0Counter == TO_KILL_PEA) && (plant0Type == PEASHOOTER)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
				begin
					plant0Killed = 1'b1;
					//Set the plant placed back to 0
					zombie0Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					if(plant4Placed == 1)
					begin
						plant0X = 10'd750;
					end
					
					else if(plant3Placed == 1)
					begin
						plant0X = 10'd650;
					end
					
					else if(plant2Placed == 1)
					begin
						plant0X = 10'd550;
					end
					
					else if(plant1Placed == 1)
					begin
						plant0X = 10'd450;
					end
					
					else if(plant0Placed == 1)
					begin
						plant0X = 10'd350;
					end
					
					else
					begin
						plant0X = 10'd0;
					end
				end
		else
		begin
			zombie0Stopped = 1'b0;
			zombie0Counter = 1'd0;
		end

		if(zombie1X == plant1X)
			zombie1Stopped = 1'b1;
			//Have some type of counter to see how long the zombie has been with the plant
			zombie1Counter = zombie1Counter + 1'd1;
			if((zombie1Counter == TO_KILL_PEA) && (plant1Type == PEASHOOTER)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
				begin
					plant1Killed = 1'b1;
					//Set the plant placed back to 0
					zombie1Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					if(plant4Placed == 1)
					begin
						plant1X = 10'd750;
					end
					
					else if(plant3Placed == 1)
					begin
						plant1X = 10'd650;
					end
					
					else if(plant2Placed == 1)
					begin
						plant1X = 10'd550;
					end
					
					else if(plant1Placed == 1)
					begin
						plant1X = 10'd450;
					end
					
					else if(plant0Placed == 1)
					begin
						plant1X = 10'd350;
					end
					
					else
					begin
						plant1X = 10'd0;
					end
				end

		else
		begin
			zombie1Stopped = 1'b0;
			zombie1Counter = 1'd0;
		end

		if(zombie2X == plant2X)
			zombie2Stopped = 1'b1;
			//Have some type of counter to see how long the zombie has been with the plant
			zombie2Counter = zombie2Counter + 1'd1;
			if((zombie2Counter == TO_KILL_PEA) && (plant2Type == PEASHOOTER)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
				begin
					plant2Killed = 1'b1;
					//Set the plant placed back to 0
					zombie2Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					if(plant4Placed == 1)
					begin
						plant2X = 10'd750;
					end
					
					else if(plant3Placed == 1)
					begin
						plant2X = 10'd650;
					end
					
					else if(plant2Placed == 1)
					begin
						plant2X = 10'd550;
					end
					
					else if(plant1Placed == 1)
					begin
						plant2X = 10'd450;
					end
					
					else if(plant0Placed == 1)
					begin
						plant2X = 10'd350;
					end
					
					else
					begin
						plant2X = 10'd0;
					end
				end

		else
		begin
			zombie2Stopped = 1'b0;
			zombie2Counter = 1'd0;
		end

		if(zombie3X == plant3X)
			zombie3Stopped = 1'b1;
			//Have some type of counter to see how long the zombie has been with the plant
			zombie3Counter = zombie3Counter + 1'd1;
			if((zombie3Counter == TO_KILL_PEA) && (plant3Type == PEASHOOTER)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
				begin
					plant3Killed = 1'b1;
					//Set the plant placed back to 0
					zombie3Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					if(plant4Placed == 1)
					begin
						plant3X = 10'd750;
					end
					
					else if(plant3Placed == 1)
					begin
						plant3X = 10'd650;
					end
					
					else if(plant2Placed == 1)
					begin
						plant3X = 10'd550;
					end
					
					else if(plant1Placed == 1)
					begin
						plant3X = 10'd450;
					end
					
					else if(plant0Placed == 1)
					begin
						plant3X = 10'd350;
					end
					
					else
					begin
						plant3X = 10'd0;
					end
				end


		else
		begin
			zombie3Stopped = 1'b0;
			zombie3Counter = 1'd0;
		end

		if(zombie4X == plant4X)
			zombie4Stopped = 1'b1;
			//Have some type of counter to see how long the zombie has been with the plant
			zombie4Counter = zombie4Counter + 1'd1;
			if((zombie4Counter == TO_KILL_PEA) && (plant4Type == PEASHOOTER)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
				begin
					plant4Killed = 1'b1;
					//Set the plant placed back to 0
					zombie4Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					if(plant4Placed == 1)
					begin
						plant4X = 10'd750;
					end
					
					else if(plant3Placed == 1)
					begin
						plant4X = 10'd650;
					end
					
					else if(plant2Placed == 1)
					begin
						plant4X = 10'd550;
					end
					
					else if(plant1Placed == 1)
					begin
						plant4X = 10'd450;
					end
					
					else if(plant0Placed == 1)
					begin
						plant4X = 10'd350;
					end
					
					else
					begin
						plant4X = 10'd0;
					end
				end
				 
			

		else
		begin
			zombie4Stopped = 1'b0;
			zombie4Counter = 1'd0;
		end

	end

	//Always at the posedge of the clock, check if the user has selected a lawn position
	always@ (posedge clk)
	begin
		if(selectButton == 1 && isSelectingPlantBox == 0)
			begin
				isSelectingPlantBox = 1;
				//Assign the X coordinate of the selected plant box to the middle of the upper left square
				selectedPlantBoxX = 10'd40;
			end
		else if(isSelectingPlantBox == 1 && leftButton == 1)
			begin
				selectedPlantBoxX = selectedPlantBoxX - COLUMN_WIDTH;
			end
		else if(isSelectingPlantBox == 1 && rightButton == 1)
			begin
				selectedPlantBoxX = selectedPlantBoxX + COLUMN_WIDTH;
			end
		else if(selectButton == 1 && isSelectingPlantBox == 1) //User has selected a plant
			begin
				//If user selects leftmost plant box, assign the selection to pea shooter
				if(selectedPlantBoxX == 10'd0)
					begin
						userPlantSelection = PEASHOOTER;
					end
				//If user selects middle plant box, assign the selection to sunflower
				else if(selectedPlantBoxX == 10'd80)
					begin
						userPlantSelection = SUNFLOWER;
					end
				//If user selects rightmost plant box, assign the selection to wallnut
				else if(selectedPlantBoxX == 10'd160)
					begin
						userPlantSelection = WALNUT;
					end
				isSelectingLawnPosition = 1;
				selectedPlantBoxX = 10'd40;
                selectedGridBoxX = 10'd40;
                selectedGridBoxY = 10'd130; //May need to change 87 to 86
			end
		//If user has selected a plant box, then they are selecting a lawn position
		else if(isSelectingLawnPosition == 1 && selectButton == 0)
			begin
                //Start the selected Grid position at the top left corner of the lawn
                if(leftButton == 1)
                    selectedGridBoxX = selectedGridBoxX - COLUMN_WIDTH;
                
                else if(rightButton == 1)
                    selectedGridBoxX = selectedGridBoxX + COLUMN_WIDTH;
                
                else if(upButton == 1)
                    selectedGridBoxY = selectedGridBoxY + ROW_HEIGHT;
                
                else if(downButton == 1)
                    selectedGridBoxY = selectedGridBoxY - ROW_HEIGHT;
                
			end
        else if(isSelectingLawnPosition == 1 && selectButton == 1)
            begin
                //For every box in the grid, check if the selected X and Y coordinates match that box
                //Box 0
				//TODO: fix thisi logic
                if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd130)
                    plant0Placed = 2'd01;
                
                else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd130)
                    plant1Placed = 2'd01;
                
                else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd130)
                    plant2Placed = 2'd01;
                
                else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd130)
                    plant3Placed = 2'd01;
                
                else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd130)
                    plant4Placed = 2'd01;

				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd217)
					plant5Placed = 2'd01;
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd217)
					plant6Placed = 2'd01;
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd217)
					plant7Placed = 2'd01;
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd217)
					plant8Placed = 2'd01;
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd217)
					plant9Placed = 2'd01;
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd304)
					plant10Placed = 2'd01;
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd304)
					plant11Placed = 2'd01;
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd304)
					plant12Placed = 2'd01;
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd304)
					plant13Placed = 2'd01;
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd304)
					plant14Placed = 2'd01;
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd391)
					plant15Placed = 2'd01;
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd391)
					plant16Placed = 2'd01;
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd391)
					plant17Placed = 2'd01;
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd391)
					plant18Placed = 2'd01;
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd391)
					plant19Placed = 2'd01;
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd478)
					plant20Placed = 2'd01;
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd478)
					plant21Placed = 2'd01;
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd478)
					plant22Placed = 2'd01;
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd478)
					plant23Placed = 2'd01;
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd478)
					plant24Placed = 2'd01;
            end
		end

	//Range from 000 to 160 (vertically)
	assign greyZone = (vCount <= 10'd86) ? 1 : 0;

	//Create 5 by 5 grid in the lawn
	//First row, Third Row, and 5th row of lawn
	//2nd column, 4th column
	assign GRID1 = (((vCount >= 10'd87) && (vCount <= 10'd173)
	|| (vCount >= 10'd261) && (vCount <= 10'd347)
	|| (vCount >= 10'd435) && (vCount <= 10'd521))
	&& ((hCount >= 10'd600) && (hCount <= 10'd699)
	|| (hCount >= 10'd400) && (hCount <= 10'd499))
	) ? 1 : 0;

	//Second row, Fourth Row
	//1st column, 3rd column, 5th column
	assign GRID2 = (((vCount >= 10'd174) && (vCount <= 10'd260)
	|| (vCount >= 10'd348) && (vCount <= 10'd434))
	&& ((hCount >= 10'd700) && (hCount <= 10'd799)
	|| (hCount >= 10'd500) && (hCount <= 10'd599)
	|| (hCount >= 10'd300) && (hCount <= 10'd399))
	) ? 1 : 0;


	//Define the selected plant box
	assign selectedPlantBoxOutline = (
		(
			((vCount <= 10'd005) || ((vCount >= 10'd82) && (vCount <= 10'd86)))
		&& (hCount >= selectedPlantBoxX + HALF_COLUMN_WIDTH ) && (hCount <= selectedPlantBoxX - HALF_COLUMN_WIDTH))
		||
		((vCount <= ROW_HEIGHT) 
		&& ((hCount >= selectedPlantBoxX - HALF_COLUMN_WIDTH) && (hCount <= selectedPlantBoxX - HALF_COLUMN_WIDTH + 10'd005)
		|| (hCount >= selectedPlantBoxX + HALF_COLUMN_WIDTH - 10'd005) && (hCount <= selectedPlantBoxX + COLUMN_WIDTH))
		)) ? 1 : 0;

	// //Range from 160 to 287
	// assign zombie0 = ((vCount >= 10'd165) && (vCount <= 10'd282)
	// 	&& (hCount >= zombie0X) && (hCount <= zombie0X + 10'd100)
	// 	) ? 1 : 0;

	// //Range from 288 to 415
	// assign zombie1 = ((vCount >= 10'd293) && (vCount <= 10'd410)
	// 	&& (hCount >= zombie1X) && (hCount <= zombie1X + 10'd100)
	// 	) ? 1 : 0;

	// //Range from 416 to 543
	// assign zombie2 = ((vCount >= 10'd421) && (vCount <= 10'd538)
	// 	&& (hCount >= zombie2X) && (hCount <= zombie2X + 10'd100)
	// 	) ? 1 : 0;

	// //Range from 544 to 671
	// assign zombie3 = ((vCount >= 10'd549) && (vCount <= 10'd666)
	// 	&& (hCount >= zombie3X) && (hCount <= zombie3X + 10'd100)
	// 	) ? 1 : 0;

	// //Range from 672 to 779
	// assign zombie4 = ((vCount >= 10'd677) && (vCount <= 10'd774)
	// 	&& (hCount >= zombie4X) && (hCount <= zombie4X + 10'd100)
	// 	) ? 1 : 0;

	//Using the zombie body width, create the zombie body in the lower part of the row
	assign zombieBody0 = ((vCount >= ZOMBIE0_ROW_TOP) && (vCount <= ZOMBIE0_ROW_TOP + ZOMBIE_BODY_HEIGHT)
		&& (hCount >= zombie0X - HALF_ZOMBIE_BODY_WIDTH) && (hCount <= zombie0X + HALF_ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody1 = ((vCount >= ZOMBIE1_ROW_TOP) && (vCount <= ZOMBIE1_ROW_TOP + ZOMBIE_BODY_HEIGHT)
		&& (hCount >= zombie1X - HALF_ZOMBIE_BODY_WIDTH) && (hCount <= zombie1X + HALF_ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody2 = ((vCount >= ZOMBIE2_ROW_TOP) && (vCount <= ZOMBIE2_ROW_TOP + ZOMBIE_BODY_HEIGHT)
		&& (hCount >= zombie2X - HALF_ZOMBIE_BODY_WIDTH) && (hCount <= zombie2X + HALF_ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody3 = ((vCount >= ZOMBIE3_ROW_TOP) && (vCount <= ZOMBIE3_ROW_TOP + ZOMBIE_BODY_HEIGHT)
		&& (hCount >= zombie3X - HALF_ZOMBIE_BODY_WIDTH) && (hCount <= zombie3X + HALF_ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody4 = ((vCount >= ZOMBIE4_ROW_TOP) && (vCount <= ZOMBIE4_ROW_TOP + ZOMBIE_BODY_HEIGHT)
		&& (hCount >= zombie4X - HALF_ZOMBIE_BODY_WIDTH) && (hCount <= zombie4X + HALF_ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	//Create (for now) square zombie heads
	
	 
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