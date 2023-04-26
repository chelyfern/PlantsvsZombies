`timescale 1ns / 1ps

// Anisha Palaparthi and Chely Fernandez

module vga_bitchange(
	input clk,
	input bright,
    //Switches input for switches 0 - 4
    input [4:0] switches,
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
	parameter ZOMBIE_HEAD = 12'b0000_1011_0100;
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
	parameter OUTLINE_WIDTH = 10'd05;
	parameter HALF_ZOMBIE_BODY_WIDTH = 10'd08;
	parameter ZOMBIE_BODY_WIDTH = 10'd16;
	parameter ZOMBIE_HEAD_SCALE = 10'd2;
	parameter ZOMBIE_EYE_SCALE = 10'd3;


    //Column and row widths
    parameter COLUMN_WIDTH = 10'd100;
	parameter HALF_COLUMN_WIDTH = 10'd50;
    parameter ROW_HEIGHT = 10'd87;
	parameter HALF_ROW_HEIGHT = 10'd43;
	
	parameter STEM_GREEN = 12'b0000_1011_0100;
	parameter BROWN = 12'b0111_0011_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter PEA_GREEN = 12'b0111_1111_0010;
	
	parameter SFSCALE = 10'd3;
    parameter WSCALE = 10'd2; 
    parameter PSSCALE = 10'd3;

	//Time definitions
	parameter TO_KILL_PEA = 50'd5000000;
	parameter TO_KILL_SUN = 50'd5000000;
	parameter TO_KILL_ZOMBIE = 50'd5000000;

	//Plant definitions
	parameter PEASHOOTER = 3'b001;
	parameter SUNFLOWER = 3'b010;
	parameter WALNUT = 3'b100;

	//End of screen
	parameter END_OF_LAWN_X = 10'd300;
	parameter END_OF_LAWN_Y = 10'd521;
	parameter BEGINNING_OF_LAWN_X = 10'd799;
	parameter BEGINNING_OF_LAWN_Y = 10'd87;

    //With respect to the grid
	parameter FIRST_COL_MIDDLE_X = 10'd350;
	parameter SECOND_COL_MIDDLE_X = 10'd450;
	parameter THIRD_COL_MIDDLE_X = 10'd550;
    parameter FOURTH_COL_MIDDLE_X = 10'd650;
    parameter FIFTH_COL_MIDDLE_X = 10'd750;
	parameter ZEROTH_ROW_MIDDLE_Y = 10'd43;
	parameter FIRST_ROW_MIDDLE_Y = 10'd130;
	parameter SECOND_ROW_MIDDLE_Y = 10'd217;
	parameter THIRD_ROW_MIDDLE_Y = 10'd304;
	parameter FOURTH_ROW_MIDDLE_Y = 10'd391;
	parameter FIFTH_ROW_MIDDLE_Y = 10'd478;



	
	
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
	//Registers to hold if zombie has reached the end of the lawn
	reg zombie0ReachedEnd;
	reg zombie1ReachedEnd;
	reg zombie2ReachedEnd;
	reg zombie3ReachedEnd;
	reg zombie4ReachedEnd;
	//Registers to hold if zombie has been "killed"
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
	reg[9:0] zombie0Y;
	reg[9:0] zombie1Y;
	reg[9:0] zombie2Y;
	reg[9:0] zombie3Y;
	reg[9:0] zombie4Y;
	//Registers to hold zombie head's X position
	reg[9:0] zombie0HeadX;
	reg[9:0] zombie1HeadX;
	reg[9:0] zombie2HeadX;
	reg[9:0] zombie3HeadX;
	reg[9:0] zombie4HeadX;
	//Registers to hold zombie head's Y position
	reg[9:0] zombie0HeadY;
	reg[9:0] zombie1HeadY;
	reg[9:0] zombie2HeadY;
	reg[9:0] zombie3HeadY;
	reg[9:0] zombie4HeadY;
	//Registers to hold zombie eye's X position
	reg[9:0] zombie0EyeX;
	reg[9:0] zombie1EyeX;
	reg[9:0] zombie2EyeX;
	reg[9:0] zombie3EyeX;
	reg[9:0] zombie4EyeX;
	reg[49:0] zombieSpeed;// Regisiter to hold zombie speed

	//Register to hold count of select button press
	reg[3:0] selectButtonCounter;
	

	//Wires for plant graphics
	wire sunflowerInner;
	wire sunflowerOuter;
	wire sunflowerFace;

	wire selectedPlantBoxOutline;
	wire GRID;

	

	//Wire to hold current selected plant box
	// reg selectedPlantBox;
	reg isSelectingPlantBox;
	reg[9:0] selectedPlantBoxX;
	reg[2:0] userPlantSelection; //001 for Pea Shooter, 010 for Sunflower, 100 for Wallnut
	//Wire to hold current selected lawn position
	wire selectedLawnPositionOutline;
	reg isSelectingLawnPosition;
	reg[9:0] selectedGridBoxX;
	reg[9:0] selectedGridBoxY;
	reg [4:0] userGridSelection;
	
	
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
	// reg plant0Killed;
	// reg plant1Killed;
	// reg plant2Killed;
	// reg plant3Killed;
	// reg plant4Killed;
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



	
	//Store the current state
//	output q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW;
	reg [7:0] state;
	assign {q_I, q_L1, q_NL2, q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW} = state;
	
	//Local parameters for state
	parameter I = 8'b0000_0001, L1 = 8'b0000_0010, NL2 = 8'b0000_0100, L2 = 8'b0000_1000, NL3 = 8'b0001_0000, L3 = 8'b0010_0000, DoneL = 8'b0100_0000, DoneW = 8'b1000_0000;

    
    //sun logic
    reg[49:0] numSuns;
    parameter SECS_BETWEEN_SUNS = 10'd30;
    reg [49:0] sunTimer;

	initial begin
		state = L1;
		selectButtonCounter = 4'd0;
		//Initialize the X position on the zombies to be the right side of the lawn
		zombie0X = BEGINNING_OF_LAWN_X;
		zombie1X = BEGINNING_OF_LAWN_X;
		zombie2X = BEGINNING_OF_LAWN_X;
		zombie3X = BEGINNING_OF_LAWN_X;
		zombie4X = BEGINNING_OF_LAWN_X;
		//Initialize the zombie Y position to be in the middle of their respective rows
		zombie0Y = FIRST_ROW_MIDDLE_Y;
		zombie1Y = SECOND_ROW_MIDDLE_Y;
		zombie2Y = THIRD_ROW_MIDDLE_Y;
		zombie3Y = FOURTH_ROW_MIDDLE_Y;
		zombie4Y = FIFTH_ROW_MIDDLE_Y;
		//Initialize the X and Y position of the zombie heads
		zombie0HeadX = BEGINNING_OF_LAWN_X - 10'd05;
		zombie0HeadY = ZEROTH_ROW_MIDDLE_Y - 10'd15; //TODO MAYBE FIX LATER IN CASE YOU CANT SET ZOMBIE0Y TO zombie0HeadY
		zombie1HeadX = BEGINNING_OF_LAWN_X - 10'd05;
		zombie1HeadY = FIRST_ROW_MIDDLE_Y - 10'd15;
		zombie2HeadX = BEGINNING_OF_LAWN_X - 10'd05;
		zombie2HeadY = SECOND_ROW_MIDDLE_Y - 10'd15;
		zombie3HeadX = BEGINNING_OF_LAWN_X - 10'd05;
		zombie3HeadY = THIRD_ROW_MIDDLE_Y - 10'd15;
		zombie4HeadX = BEGINNING_OF_LAWN_X - 10'd05;
		zombie4HeadY = FOURTH_ROW_MIDDLE_Y - 10'd15;
		//Initialize the X position of the zombie eyes

		//Initialize the zombies to be alive
		zombie0Killed = 1'b0;
		zombie1Killed = 1'b0;
		zombie2Killed = 1'b0;
		zombie3Killed = 1'b0;
		zombie4Killed = 1'b0;
		//Initiliaze the X coordinate of the selected plant box
		selectedPlantBoxX = 10'd350;
		//Initiliaze the X and Y coordinates of the selected grid box
		selectedGridBoxX = 10'd350;
		selectedGridBoxY = 10'd130;
		zombies_killed = 15'd0;
		reset = 1'b0;
		userPlantSelection = 10'd0;
		isSelectingPlantBox = 0;
		isSelectingLawnPosition = 0;
		//Initially the zombies are moving
		zombie0Stopped = 1'b0;
		zombie1Stopped = 1'b0;
		zombie2Stopped = 1'b0;
		zombie3Stopped = 1'b0;
		zombie4Stopped = 1'b0;
		
		//Initially the zombies have not reached the end
		zombie0ReachedEnd = 1'b0;
		zombie1ReachedEnd = 1'b0;
		zombie2ReachedEnd = 1'b0;
		zombie3ReachedEnd = 1'b0;
		zombie4ReachedEnd = 1'b0;
		sfVPos = 10'd220;
		
		sfVPosTemp = sfVPos + 10'd154;
		sfHPos = 10'd500;//500
		sfHeadHPos = sfHPos;
		sfHeadVPos = sfVPosTemp;
		sfHeadFlag = 1'd0;
		
		psVPos = 10'd220;
		psVPosTemp = psVPos + 10'd90; 
		psHPos = 10'd225;//225
		pVPos = psVPos + 10'd65;
		pHPos = psHPos + 10'd115;
		
		wVPos = 10'd218;
		wHPos = 10'd400;
	end

	//TODO: define the zombie colors here
	//Define the color scheme
	always@ (*)
    // if (~bright)
    //     rgb = BLACK;
	if (selectedPlantBoxOutline == 1 && isSelectingPlantBox == 1)
		rgb = RED;
	else if (selectedLawnPositionOutline == 1 && isSelectingLawnPosition == 1)
		rgb = RED;
	// else if ((zombieEye0 == 1 && ~zombie0Killed) || (zombieEye1 == 1 && ~zombie1Killed) || (zombieEye2 == 1 && ~zombie2Killed) || (zombieEye3 == 1 && ~zombie3Killed) || (zombieEye4 == 1 && ~zombie4Killed))
	else if((zombieEye0 && ~zombie0ReachedEnd) || (zombieEye1 && ~zombie1ReachedEnd) || (zombieEye2 && ~zombie2ReachedEnd) || (zombieEye3 && ~zombie3ReachedEnd) || (zombieEye4 && ~zombie4ReachedEnd))
		rgb = ZOMBIE_EYE;
	//else if ((zombieHead0 == 1 && ~zombie0Killed) || (zombieHead1 == 1 && ~zombie1Killed) || (zombieHead2 == 1 && ~zombie2Killed) || (zombieHead3 == 1 && ~zombie3Killed) || (zombieHead4 == 1 && ~zombie4Killed))
	else if((zombieHead0 && ~zombie0ReachedEnd) || (zombieHead1 && ~zombie1ReachedEnd) || (zombieHead2 && ~zombie2ReachedEnd) || (zombieHead3 && ~zombie3ReachedEnd) || (zombieHead4 && ~zombie4ReachedEnd))
		rgb = ZOMBIE_HEAD;
	else if ((zombieOutline0 == 1 && ~zombie0Killed) || (zombieOutline1 == 1 && ~zombie1Killed) || (zombieOutline2 == 1 && ~zombie2Killed) || (zombieOutline3 == 1 && ~zombie3Killed) || (zombieOutline4 == 1 && ~zombie4Killed))
		rgb = BLACK;
	// else if((zombieBody0 == 1 && ~zombie0Killed) || (zombieBody1 == 1 && ~zombie1Killed) || (zombieBody2 == 1 && ~zombie2Killed) || (zombieBody3 == 1 && ~zombie3Killed) || (zombieBody4 == 1 && ~zombie4Killed))
	else if((zombieBody0 == 1 && ~zombie0ReachedEnd) || (zombieBody1 == 1 && ~zombie1ReachedEnd) || (zombieBody2 == 1 && ~zombie2ReachedEnd) || (zombieBody3 == 1 && ~zombie3ReachedEnd) || (zombieBody4 == 1 && ~zombie4ReachedEnd))
		rgb = ZOMBIE_SKIN;
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
    else if (greyZone == 1)
        rgb = GREY;
	else if (GRID1 == 1 || GRID2 == 1)
		rgb = DARK_GREEN;
    else
        rgb = GREEN; // background color

 
	//At every clock, move the zombies to the right by increasnig the zombie "speed"
	always @(posedge clk) begin
    zombieSpeed = zombieSpeed + 50'd1;
    if (zombieSpeed >= 50'd50000000) begin
        if (zombie1X <= 50'd600 && ~zombie0Stopped) // Move zombie0 after zombie1 has moved 200 pixels across the screen
		begin
            zombie0X = zombie0X - 10'd1;
			zombie0HeadX = zombie0HeadX - 10'd1;
		end
		
        //Zombie 1 always enters the lawn first
		if (~zombie1Stopped)
		begin
			zombie1X = zombie1X - 10'd1;
			zombie1HeadX = zombie1HeadX - 10'd1;
		end
        
        if (zombie0X <= 50'd600 && ~zombie2Stopped) // Move zombie2 after zombie0 has moved 200 pixels across the screen
		begin
            zombie2X = zombie2X - 10'd1;
			zombie2HeadX = zombie2HeadX - 10'd1;
		end

        if (zombie0X <= 50'd700 && ~zombie3Stopped) // Move zombie3 after zombie0 has moved 100 pixels across the screen
		begin
            zombie3X = zombie3X - 10'd1;
			zombie3HeadX = zombie3HeadX - 10'd1;
		end

        if (zombie3X <= 50'd700 && ~zombie4Stopped) // Move zombie4 zombie3 has moved 100 pixels across the screen
		begin
            zombie4X = zombie4X - 10'd1;
			zombie4HeadX = zombie4HeadX - 10'd1;
		end

        zombieSpeed = 50'd0;
			//If a zombie reaches the end of the lawn, the user loses!
			//Check if any of the zombies have reached the end of the lawn
			if((zombie0X == END_OF_LAWN_X) || (zombie1X == END_OF_LAWN_X) || (zombie2X == END_OF_LAWN_X) || (zombie3X == END_OF_LAWN_X) || (zombie4X == END_OF_LAWN_X))
				begin
					state = DoneL;
					reset = 1'b1; //TODO I dont think you need to keep track of num zombies killed
					//Stop the zombie after it reaches the end of the lawn
					if(zombie0X == END_OF_LAWN_X)
						begin
							zombie0ReachedEnd = 1'b1;
						end
					if(zombie1X == END_OF_LAWN_X)
						begin
							zombie1ReachedEnd = 1'b1;
						end
					if(zombie2X == END_OF_LAWN_X)
						begin
							zombie2ReachedEnd = 1'b1;
						end
					if(zombie3X == END_OF_LAWN_X)
						begin
							zombie3ReachedEnd = 1'b1;
						end
					if(zombie4X == END_OF_LAWN_X)
						begin
							zombie4ReachedEnd = 1'b1;
						end
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
					//Determine which plant killed the zombie
                    //If zombie X was in the first grid box, plant0 killed it
                    if(zombie0X == FIRST_COL_MIDDLE_X)
                        begin
                            plant0Placed = 1'b0;
                        end
                    else if(zombie0X == SECOND_COL_MIDDLE_X)
                        begin
                            plant1Placed = 1'b0;
                        end
                    else if(zombie0X == THIRD_COL_MIDDLE_X)
                        begin
                            plant2Placed = 1'b0;
                        end
                    else if(zombie0X == FOURTH_COL_MIDDLE_X)
                        begin
                            plant3Placed = 1'b0;
                        end
                    else if(zombie0X == FIFTH_COL_MIDDLE_X)
                        begin
                            plant4Placed = 1'b0;
                        end
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
                    if(zombie1X == FIRST_COL_MIDDLE_X)
                        begin
                            plant5Placed = 1'b0;
                        end
                    else if(zombie1X == SECOND_COL_MIDDLE_X)
                        begin
                            plant6Placed = 1'b0;
                        end
                    else if(zombie1X == THIRD_COL_MIDDLE_X)
                        begin
                            plant7Placed = 1'b0;
                        end
                    else if(zombie1X == FOURTH_COL_MIDDLE_X)
                        begin
                            plant8Placed = 1'b0;
                        end
                    else if(zombie1X == FIFTH_COL_MIDDLE_X)
                        begin
                            plant9Placed = 1'b0;
                        end
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
					if(zombie2X == FIRST_COL_MIDDLE_X)
                        begin
                            plant10Placed = 1'b0;
                        end
                    else if(zombie2X == SECOND_COL_MIDDLE_X)
                        begin
                            plant11Placed = 1'b0;
                        end
                    else if(zombie2X == THIRD_COL_MIDDLE_X)
                        begin
                            plant12Placed = 1'b0;
                        end
                    else if(zombie2X == FOURTH_COL_MIDDLE_X)
                        begin
                            plant13Placed = 1'b0;
                        end
                    else if(zombie2X == FIFTH_COL_MIDDLE_X)
                        begin
                            plant14Placed = 1'b0;
                        end
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
					if(zombie3X == FIRST_COL_MIDDLE_X)
                        begin
                            plant15Placed = 1'b0;
                        end
                    else if(zombie3X == SECOND_COL_MIDDLE_X)
                        begin
                            plant16Placed = 1'b0;
                        end
                    else if(zombie3X == THIRD_COL_MIDDLE_X)
                        begin
                            plant17Placed = 1'b0;
                        end
                    else if(zombie3X == FOURTH_COL_MIDDLE_X)
                        begin
                            plant18Placed = 1'b0;
                        end
                    else if(zombie3X == FIFTH_COL_MIDDLE_X)
                        begin
                            plant19Placed = 1'b0;
                        end

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
					if(zombie4X == FIRST_COL_MIDDLE_X)
                        begin
                            plant20Placed = 1'b0;
                        end
                    else if(zombie4X == SECOND_COL_MIDDLE_X)
                        begin
                            plant21Placed = 1'b0;
                        end
                    else if(zombie4X == THIRD_COL_MIDDLE_X)
                        begin
                            plant22Placed = 1'b0;
                        end
                    else if(zombie4X == FOURTH_COL_MIDDLE_X)
                        begin
                            plant23Placed = 1'b0;
                        end
                    else if(zombie4X == FIFTH_COL_MIDDLE_X)
                        begin
                            plant24Placed = 1'b0;
                        end
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
		if(selectButton == 1'b1)
		begin
			selectButtonCounter = selectButtonCounter + 4'd1;
		end
		// if((selectButton == 1'b1) && (isSelectingPlantBox == 1'b0) && (isSelectingLawnPosition == 1'b0))
		if(selectButtonCounter == 4'd1)
			begin
				isSelectingPlantBox = 1'b1;
				//Assign the X coordinate of the selected plant box to the middle of the upper left square
				selectedPlantBoxX = FIRST_COL_MIDDLE_X;

				if(switches == 10'd0)
                    begin
                        selectedPlantBoxX = FIRST_COL_MIDDLE_X;
                    end
                else if(switches == 10'd1)
                    begin
                        selectedPlantBoxX = SECOND_COL_MIDDLE_X;
                    end
                else if(switches == 10'd2)
                    begin
                        selectedPlantBoxX = THIRD_COL_MIDDLE_X;
                    end
			end

		else if(selectButtonCounter == 4'd2) //User has selected a plant
			begin
				//If user selects leftmost plant box, assign the selection to pea shooter
				if(selectedPlantBoxX == FIRST_COL_MIDDLE_X)
					begin
						userPlantSelection = PEASHOOTER;
					end
				//If user selects middle plant box, assign the selection to sunflower
				else if(selectedPlantBoxX == SECOND_COL_MIDDLE_X)
					begin
						userPlantSelection = SUNFLOWER;
					end
				//If user selects rightmost plant box, assign the selection to wallnut
				else if(selectedPlantBoxX == THIRD_COL_MIDDLE_X)
					begin
						userPlantSelection = WALNUT;
					end
				isSelectingPlantBox = 1'b0;
				isSelectingLawnPosition = 1'b1;
				selectedPlantBoxX = FIRST_COL_MIDDLE_X;
                selectedGridBoxX = FIRST_COL_MIDDLE_X;
                selectedGridBoxY = 10'd130; //May need to change 87 to 86
			
		
                //Map the switches to the X and Y coordinates of the selected lawn position
                //3 is the 0th grid box at X = 350, Y = 130
                if(switches == 10'd3)
                    begin
                        selectedGridBoxX = FIRST_COL_MIDDLE_X;
                        selectedGridBoxY = FIRST_ROW_MIDDLE_Y;
                    end
                //4 is the 1st grid box at X = 450, Y = 130
                else if(switches == 10'd4)
                    begin
                        selectedGridBoxX = SECOND_COL_MIDDLE_X;
                        selectedGridBoxY = FIRST_ROW_MIDDLE_Y;
                    end
                //5 is the 2nd grid box at X = 550, Y = 130
                else if(switches == 10'd5)
                    begin
                        selectedGridBoxX = THIRD_COL_MIDDLE_X;
                        selectedGridBoxY = FIRST_ROW_MIDDLE_Y;
                    end
                //6 is the 3rd grid box at X = 650, Y = 130
                else if(switches == 10'd6)
                    begin
                        selectedGridBoxX = FOURTH_COL_MIDDLE_X;
                        selectedGridBoxY = FIRST_ROW_MIDDLE_Y;
                    end
                //7 is the 4th grid box at X = 750, Y = 130
                else if(switches == 10'd7)
                    begin
                        selectedGridBoxX = FIFTH_COL_MIDDLE_X;
                        selectedGridBoxY = FIRST_ROW_MIDDLE_Y;
                    end
                //8 is the 5th grid box at X = 350, Y = 217
                else if(switches == 10'd8)
                    begin
                        selectedGridBoxX = FIRST_COL_MIDDLE_X;
                        selectedGridBoxY = SECOND_ROW_MIDDLE_Y;
                    end
                //9 is the 6th grid box at X = 450, Y = 217
                else if(switches == 10'd9)
                    begin
                        selectedGridBoxX = SECOND_COL_MIDDLE_X;
                        selectedGridBoxY = SECOND_ROW_MIDDLE_Y;
                    end
                //10 is the 7th grid box at X = 550, Y = 217
                else if(switches == 10'd10)
                    begin
                        selectedGridBoxX = THIRD_COL_MIDDLE_X;
                        selectedGridBoxY = SECOND_ROW_MIDDLE_Y;
                    end
                //11 is the 8th grid box at X = 650, Y = 217
                else if(switches == 10'd11)
                    begin
                        selectedGridBoxX = FOURTH_COL_MIDDLE_X;
                        selectedGridBoxY = SECOND_ROW_MIDDLE_Y;
                    end
                //12 is the 9th grid box at X = 750, Y = 217
                else if(switches == 10'd12)
                    begin
                        selectedGridBoxX = FIFTH_COL_MIDDLE_X;
                        selectedGridBoxY = SECOND_ROW_MIDDLE_Y;
                    end
                //13 is the 10th grid box at X = 350, Y = 304
                else if(switches == 10'd13)
                    begin
                        selectedGridBoxX = FIRST_COL_MIDDLE_X;
                        selectedGridBoxY = THIRD_ROW_MIDDLE_Y;
                    end
                //14 is the 11th grid box at X = 450, Y = 304
                else if(switches == 10'd14)
                    begin
                        selectedGridBoxX = SECOND_COL_MIDDLE_X;
                        selectedGridBoxY = THIRD_ROW_MIDDLE_Y;
                    end
                //15 is the 12th grid box at X = 550, Y = 304
                else if(switches == 10'd15)
                    begin
                        selectedGridBoxX = THIRD_COL_MIDDLE_X;
                        selectedGridBoxY = THIRD_ROW_MIDDLE_Y;
                    end
                //16 is the 13th grid box at X = 650, Y = 304
                else if(switches == 10'd16)
                    begin
                        selectedGridBoxX = FOURTH_COL_MIDDLE_X;
                        selectedGridBoxY = THIRD_ROW_MIDDLE_Y;
                    end
                //17 is the 14th grid box at X = 750, Y = 304
                else if(switches == 10'd17)
                    begin
                        selectedGridBoxX = FIFTH_COL_MIDDLE_X;
                        selectedGridBoxY = THIRD_ROW_MIDDLE_Y;
                    end
                //18 is the 15th grid box at X = 350, Y = 391
                else if(switches == 10'd18)
                    begin
                        selectedGridBoxX = FIRST_COL_MIDDLE_X;
                        selectedGridBoxY = FOURTH_ROW_MIDDLE_Y;
                    end
                //19 is the 16th grid box at X = 450, Y = 391
                else if(switches == 10'd19)
                    begin
                        selectedGridBoxX = SECOND_COL_MIDDLE_X;
                        selectedGridBoxY = FOURTH_ROW_MIDDLE_Y;
                    end
                //20 is the 17th grid box at X = 550, Y = 391
                else if(switches == 10'd20)
                    begin
                        selectedGridBoxX = THIRD_COL_MIDDLE_X;
                        selectedGridBoxY = FOURTH_ROW_MIDDLE_Y;
                    end
                //21 is the 18th grid box at X = 650, Y = 391
                else if(switches == 10'd21)
                    begin
                        selectedGridBoxX = FOURTH_COL_MIDDLE_X;
                        selectedGridBoxY = FOURTH_ROW_MIDDLE_Y;
                    end
                //22 is the 19th grid box at X = 750, Y = 391
                else if(switches == 10'd22)
                    begin
                        selectedGridBoxX = FIFTH_COL_MIDDLE_X;
                        selectedGridBoxY = FOURTH_ROW_MIDDLE_Y;
                    end
                //23 is the 20th grid box at X = 350, Y = 478
                else if(switches == 10'd23)
                    begin
                        selectedGridBoxX = FIRST_COL_MIDDLE_X;
                        selectedGridBoxY = FIFTH_ROW_MIDDLE_Y;
                    end
                //24 is the 21st grid box at X = 450, Y = 478
                else if(switches == 10'd24)
                    begin
                        selectedGridBoxX = SECOND_COL_MIDDLE_X;
                        selectedGridBoxY = FIFTH_ROW_MIDDLE_Y;
                    end
                //25 is the 22nd grid box at X = 550, Y = 478
                else if(switches == 10'd25)
                    begin
                        selectedGridBoxX = THIRD_COL_MIDDLE_X;
                        selectedGridBoxY = FIFTH_ROW_MIDDLE_Y;
                    end
                //26 is the 23rd grid box at X = 650, Y = 478
                else if(switches == 10'd26)
                    begin
                        selectedGridBoxX = FOURTH_COL_MIDDLE_X;
                        selectedGridBoxY = FIFTH_ROW_MIDDLE_Y;
                    end
                //27 is the 24th grid box at X = 750, Y = 478
                else if(switches == 10'd27)
                    begin
                        selectedGridBoxX = FIFTH_COL_MIDDLE_X;
                        selectedGridBoxY = FIFTH_ROW_MIDDLE_Y;
                    end
				end
        else if(selectButtonCounter == 4'd3)
            begin
                //For every box in the grid, check if the selected X and Y coordinates match that box
                //Box 0
				//TODO: fix thisi logic
                if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd130)
				begin
                    plant0Placed = 2'd01;
				end
                
                else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd130)
				begin
                    plant1Placed = 2'd01;
				end
                
                else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd130)
				begin
                    plant2Placed = 2'd01;
				end
                
                else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd130)
				begin
                    plant3Placed = 2'd01;
				end
                
                else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd130)
				begin
                    plant4Placed = 2'd01;
				end

				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd217)
				begin
					plant5Placed = 2'd01;
				end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd217)
				begin
					plant6Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd217)
				begin
					plant7Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd217)
				begin
					plant8Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd217)
				begin
					plant9Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd304)
				begin
					plant10Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd304)
				begin
					plant11Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd304)
				begin
					plant12Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd304)
				begin
					plant13Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd304)
				begin
					plant14Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd391)
				begin
					plant15Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd391)
				begin
					plant16Placed = 2'd01;

					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd391)
				begin
					plant17Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd391)
				begin
					plant18Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd391)
				begin
					plant19Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd478)
				begin
					plant20Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd478)
				begin
					plant21Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd478)
				begin
					plant22Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd478)
				begin
					plant23Placed = 2'd01;
					end
				else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd478)
				begin
					plant24Placed = 2'd01;
				end

				//Reset the selected grid box
				selectedGridBoxX = 10'd350;
				selectedGridBoxY = 10'd130;
				
				//Reset the selection flag
				isSelectingLawnPosition = 1'b0;
				selectButtonCounter = 4'd0;

            end
		end
    
    always@ (posedge clk)
	begin
	   sfBounceSpeed = sfBounceSpeed + 50'd1;
       pSpeed = pSpeed + 50'd1;
	   if (sfBounceSpeed >= 50'd6000000)
	   begin
	       sfBounceSpeed = 50'd0;	       
	       if (sfHeadHPos <= (sfHPos - (10'd30 / SFSCALE)))
	       begin
	           sfHeadFlag = 1'd0;
	       end
	       if (sfHeadHPos >= (sfHPos + (10'd30 / SFSCALE)))
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
		//Horizontal lines
		(((vCount <= 10'd05) || ((vCount >= 10'd82) && (vCount <= 10'd87)))
		&& (hCount >= selectedPlantBoxX - HALF_COLUMN_WIDTH ) && (hCount <= selectedPlantBoxX + HALF_COLUMN_WIDTH))
		||
		//Vertical lines
		((vCount <= ROW_HEIGHT) 
		&& ((hCount >= selectedPlantBoxX - HALF_COLUMN_WIDTH) && (hCount <= selectedPlantBoxX - HALF_COLUMN_WIDTH + 10'd005)
		|| (hCount >= selectedPlantBoxX + HALF_COLUMN_WIDTH - 10'd005) && (hCount <= selectedPlantBoxX + HALF_COLUMN_WIDTH))
		)) ? 1 : 0;

	// Define the selected grid box
	assign selectedLawnPositionOutline = (
		//Horizontal lines
		((((vCount <= selectedGridBoxY + HALF_ROW_HEIGHT) && (vCount >= selectedGridBoxY + HALF_ROW_HEIGHT - 10'd05)) ||
		((vCount <= selectedGridBoxY - HALF_ROW_HEIGHT + 10'd05) && (vCount >= selectedGridBoxY - HALF_ROW_HEIGHT)))
		&& ((hCount >= selectedGridBoxX - HALF_COLUMN_WIDTH) && (hCount <= selectedGridBoxX + HALF_COLUMN_WIDTH)))
		||
		//Grid 0
		//Vertical lines
		(vCount <= selectedGridBoxY + HALF_ROW_HEIGHT) && (vCount >= selectedGridBoxY - HALF_ROW_HEIGHT)
		&& ((hCount >= selectedGridBoxX - HALF_COLUMN_WIDTH) && (hCount <= selectedGridBoxX - HALF_COLUMN_WIDTH + 10'd005)
		|| (hCount >= selectedGridBoxX + HALF_COLUMN_WIDTH - 10'd005) && (hCount <= selectedGridBoxX + HALF_COLUMN_WIDTH))

		//Horizontal lines

		//Grid 1

		) ? 1 : 0;


	//Using the zombie body width, create the zombie body in the lower part of the row
	assign zombieBody0 = ((vCount >= ZOMBIE_0_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_0_ROW_BOTTOM)
		&& (hCount >= zombie0X) && (hCount <= zombie0X + ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody1 = ((vCount >= ZOMBIE_1_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_1_ROW_BOTTOM)
		&& (hCount >= zombie1X) && (hCount <= zombie1X + ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody2 = ((vCount >= ZOMBIE_2_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_2_ROW_BOTTOM)
		&& (hCount >= zombie2X) && (hCount <= zombie2X + ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody3 = ((vCount >= ZOMBIE_3_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_3_ROW_BOTTOM)
		&& (hCount >= zombie3X) && (hCount <= zombie3X + ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	assign zombieBody4 = ((vCount >= ZOMBIE_4_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_4_ROW_BOTTOM)
		&& (hCount >= zombie4X) && (hCount <= zombie4X + ZOMBIE_BODY_WIDTH)
		) ? 1 : 0;

	//Create zombie heads using zombie_face module
	zombie_face zombie0Face(.clk(clk), .zombieHeadX(zombie0HeadX),
	.zombieHeadY(zombie0HeadY), .hCount(hCount), .vCount(vCount), .zombieHead(zombieHead0),
	.zombieEye(zombieEye0));

	zombie_face zombie1Face(.clk(clk), .zombieHeadX(zombie1HeadX),
	.zombieHeadY(zombie1HeadY), .hCount(hCount), .vCount(vCount), .zombieHead(zombieHead1),
	.zombieEye(zombieEye1));

	zombie_face zombie2Face(.clk(clk), .zombieHeadX(zombie2HeadX),
	.zombieHeadY(zombie2HeadY), .hCount(hCount), .vCount(vCount), .zombieHead(zombieHead2),
	.zombieEye(zombieEye2));

	zombie_face zombie3Face(.clk(clk), .zombieHeadX(zombie3HeadX),
	.zombieHeadY(zombie3HeadY), .hCount(hCount), .vCount(vCount), .zombieHead(zombieHead3),
	.zombieEye(zombieEye3));

	zombie_face zombie4Face(.clk(clk), .zombieHeadX(zombie4HeadX),
	.zombieHeadY(zombie4HeadY), .hCount(hCount), .vCount(vCount), .zombieHead(zombieHead4),
	.zombieEye(zombieEye4));

	//Create zombiie heads WITHOUT using zombie_face module
	
	 
    //PLANTS
	assign pea = ((vCount >= pVPos) && (vCount <= pVPos + 10'd14) && (hCount >= pHPos) && (hCount <= pHPos + 10'd14)) ? 1 : 0;
	

	assign peashooterHead = (((vCount >= (psVPos + 10'd60)) && (vCount <= (psVPos + 10'd60 + (10'd5 / PSSCALE))) && (hCount >= (psHPos + (10'd27 / PSSCALE))) && (hCount <= (psHPos + (10'd48 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd3 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd8 / PSSCALE))) && (hCount >= (psHPos + (10'd23 / PSSCALE))) && (hCount <= (psHPos + (10'd52 / PSSCALE))))
                           
                           ||((vCount >= (psVPos + 10'd60 + (10'd6 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd11 / PSSCALE))) && (hCount >= (psHPos + (10'd19 / PSSCALE))) && (hCount <= (psHPos + (10'd56 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd9 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd14 / PSSCALE))) && (hCount >= (psHPos + (10'd17 / PSSCALE))) && (hCount <= (psHPos + (10'd58 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd12 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd17 / PSSCALE))) && (hCount >= (psHPos + (10'd15 / PSSCALE))) && (hCount <= (psHPos + (10'd60 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd15 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd20 / PSSCALE))) && (hCount >= (psHPos + (10'd13 / PSSCALE))) && (hCount <= (psHPos + (10'd62 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd18 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd23 / PSSCALE))) && (hCount >= (psHPos + (10'd11 / PSSCALE))) && (hCount <= (psHPos + (10'd64 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd21 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd26 / PSSCALE))) && (hCount >= (psHPos + (10'd9 / PSSCALE))) && (hCount <= (psHPos + (10'd66 / PSSCALE))))
        
                           ||((vCount >= (psVPos + 10'd60 + (10'd24 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd29 / PSSCALE))) && (hCount >= (psHPos + (10'd8 / PSSCALE))) && (hCount <= (psHPos + (10'd67 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd27 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd32 / PSSCALE))) && (hCount >= (psHPos + (10'd7 / PSSCALE))) && (hCount <= (psHPos + (10'd68 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd30 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd35 / PSSCALE))) && (hCount >= (psHPos + (10'd6 / PSSCALE))) && (hCount <= (psHPos + (10'd69 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd33 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd38 / PSSCALE))) && (hCount >= (psHPos + (10'd5 / PSSCALE))) && (hCount <= (psHPos + (10'd70 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd36 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd41 / PSSCALE))) && (hCount >= (psHPos + (10'd4 / PSSCALE))) && (hCount <= (psHPos + (10'd71 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd39 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd44 / PSSCALE))) && (hCount >= (psHPos + (10'd3 / PSSCALE))) && (hCount <= (psHPos + (10'd72 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd42 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd47 / PSSCALE))) && (hCount >= (psHPos + (10'd2 / PSSCALE))) && (hCount <= (psHPos + (10'd73 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd45 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd50 / PSSCALE))) && (hCount >= (psHPos + (10'd1 / PSSCALE))) && (hCount <= (psHPos + (10'd74 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd48 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd53 / PSSCALE))) && (hCount >= (psHPos)) && (hCount <= (psHPos + (10'd75 / PSSCALE))))
                           
                                     
                           ||((vCount >= (psVPos + 10'd60 + (10'd51 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd56 / PSSCALE))) && (hCount >= (psHPos + (10'd1 / PSSCALE))) && (hCount <= (psHPos + (10'd74 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd54 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd59 / PSSCALE))) && (hCount >= (psHPos + (10'd2 / PSSCALE))) && (hCount <= (psHPos + (10'd73 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd57 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd62 / PSSCALE))) && (hCount >= (psHPos + (10'd3 / PSSCALE))) && (hCount <= (psHPos + (10'd72 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd60 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd65 / PSSCALE))) && (hCount >= (psHPos + (10'd4 / PSSCALE))) && (hCount <= (psHPos + (10'd71 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd63 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd68 / PSSCALE))) && (hCount >= (psHPos + (10'd5 / PSSCALE))) && (hCount <= (psHPos + (10'd70 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd66 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd71 / PSSCALE))) && (hCount >= (psHPos + (10'd6 / PSSCALE))) && (hCount <= (psHPos + (10'd69 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd69 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd74 / PSSCALE))) && (hCount >= (psHPos + (10'd7 / PSSCALE))) && (hCount <= (psHPos + (10'd68 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd72 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd77 / PSSCALE))) && (hCount >= (psHPos + (10'd8 / PSSCALE))) && (hCount <= (psHPos + (10'd67 / PSSCALE))))
                           
                           ||((vCount >= (psVPos + 10'd60 + (10'd75 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd80 / PSSCALE))) && (hCount >= (psHPos + (10'd9 / PSSCALE))) && (hCount <= (psHPos + (10'd66 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd78 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd83 / PSSCALE))) && (hCount >= (psHPos + (10'd11 / PSSCALE))) && (hCount <= (psHPos + (10'd64 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd81 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd86 / PSSCALE))) && (hCount >= (psHPos + (10'd13 / PSSCALE))) && (hCount <= (psHPos + (10'd62 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd84 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd89 / PSSCALE))) && (hCount >= (psHPos + (10'd15 / PSSCALE))) && (hCount <= (psHPos + (10'd60 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd87 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd92 / PSSCALE))) && (hCount >= (psHPos + (10'd17 / PSSCALE))) && (hCount <= (psHPos + (10'd58 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd90 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd95 / PSSCALE))) && (hCount >= (psHPos + (10'd19 / PSSCALE))) && (hCount <= (psHPos + (10'd56 / PSSCALE))))
                           
                           ||((vCount >= (psVPos + 10'd60 + (10'd93 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd98 / PSSCALE))) && (hCount >= (psHPos + (10'd23 / PSSCALE))) && (hCount <= (psHPos + (10'd52 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd96 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd101 / PSSCALE))) && (hCount >= (psHPos + (10'd27 / PSSCALE))) && (hCount <= (psHPos + (10'd48 / PSSCALE))))
                           
                           ||((vCount >= (psVPos + 10'd60 + (10'd35 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd65 / PSSCALE))) && (hCount >= (psHPos + (10'd68 / PSSCALE))) && (hCount <= (psHPos + (10'd119 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd30 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd70 / PSSCALE))) && (hCount >= (psHPos + (10'd78 / PSSCALE))) && (hCount <= (psHPos + (10'd119 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd25 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd75 / PSSCALE))) && (hCount >= (psHPos + (10'd88 / PSSCALE))) && (hCount <= (psHPos + (10'd119 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd20 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd80 / PSSCALE))) && (hCount >= (psHPos + (10'd98 / PSSCALE))) && (hCount <= (psHPos + (10'd119 / PSSCALE))))
                           ||((vCount >= (psVPos + 10'd60 + (10'd15 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd85 / PSSCALE))) && (hCount >= (psHPos + (10'd108 / PSSCALE))) && (hCount <= (psHPos + (10'd119 / PSSCALE))))
	                        ) ? 1 : 0;
	                       
    assign peashooterBlack = ((vCount >= (psVPos + 10'd60 + (10'd35 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd50 / PSSCALE))) && (hCount >= (psHPos + (10'd45 / PSSCALE))) && (hCount <= (psHPos + (10'd60 / PSSCALE)))) ? 1 : 0;
	
	assign peashooterStem = (
                             ((vCount <= (psVPosTemp + (10'd96 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd86 / PSSCALE))) && (hCount >= (psHPos + (10'd55 / PSSCALE))) && (hCount <= (psHPos + (10'd71 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd91 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd81 / PSSCALE))) && (hCount >= (psHPos + (10'd54 / PSSCALE))) && (hCount <= (psHPos + (10'd70 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd86 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd76 / PSSCALE))) && (hCount >= (psHPos + (10'd53 / PSSCALE))) && (hCount <= (psHPos + (10'd69 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd81 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd71 / PSSCALE))) && (hCount >= (psHPos + (10'd52 / PSSCALE))) && (hCount <= (psHPos + (10'd68 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd76 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd66 / PSSCALE))) && (hCount >= (psHPos + (10'd51 / PSSCALE))) && (hCount <= (psHPos + (10'd67 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd71 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd61 / PSSCALE))) && (hCount >= (psHPos + (10'd50 / PSSCALE))) && (hCount <= (psHPos + (10'd66 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd66 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd56 / PSSCALE))) && (hCount >= (psHPos + (10'd49 / PSSCALE))) && (hCount <= (psHPos + (10'd65 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd61 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd51 / PSSCALE))) && (hCount >= (psHPos + (10'd48 / PSSCALE))) && (hCount <= (psHPos + (10'd64 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd56 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd46 / PSSCALE))) && (hCount >= (psHPos + (10'd47 / PSSCALE))) && (hCount <= (psHPos + (10'd63 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd51 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd41 / PSSCALE))) && (hCount >= (psHPos + (10'd46 / PSSCALE))) && (hCount <= (psHPos + (10'd62 / PSSCALE))))
                             
                             ||((vCount <= (psVPosTemp + (10'd6 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd0 / PSSCALE))) && (hCount >= (psHPos + (10'd37 / PSSCALE))) && (hCount <= (psHPos + (10'd53 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd11 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd1 / PSSCALE))) && (hCount >= (psHPos + (10'd38 / PSSCALE))) && (hCount <= (psHPos + (10'd54 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd16 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd6 / PSSCALE))) && (hCount >= (psHPos + (10'd39 / PSSCALE))) && (hCount <= (psHPos + (10'd55 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd21 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd11 / PSSCALE))) && (hCount >= (psHPos + (10'd40 / PSSCALE))) && (hCount <= (psHPos + (10'd56 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd26 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd16 / PSSCALE))) && (hCount >= (psHPos + (10'd41 / PSSCALE))) && (hCount <= (psHPos + (10'd57 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd31 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd21 / PSSCALE))) && (hCount >= (psHPos + (10'd42 / PSSCALE))) && (hCount <= (psHPos + (10'd58 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd36 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd26 / PSSCALE))) && (hCount >= (psHPos + (10'd43 / PSSCALE))) && (hCount <= (psHPos + (10'd59 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd41 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd31 / PSSCALE))) && (hCount >= (psHPos + (10'd44 / PSSCALE))) && (hCount <= (psHPos + (10'd60 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd46 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd36 / PSSCALE))) && (hCount >= (psHPos + (10'd45 / PSSCALE))) && (hCount <= (psHPos + (10'd61 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd51 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd41 / PSSCALE))) && (hCount >= (psHPos + (10'd46 / PSSCALE))) && (hCount <= (psHPos + (10'd62 / PSSCALE))))
                             
                             ||((vCount <= (psVPosTemp + (10'd96 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd94 / PSSCALE))) && (hCount >= (psHPos - (10'd4 / PSSCALE))) && (hCount <= (psHPos + (10'd60 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd95 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd93 / PSSCALE))) && (hCount >= (psHPos - (10'd3 / PSSCALE))) && (hCount <= (psHPos + (10'd59 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd94 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd92 / PSSCALE))) && (hCount >= (psHPos - (10'd2 / PSSCALE))) && (hCount <= (psHPos + (10'd58 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd93 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd91 / PSSCALE))) && (hCount >= (psHPos - (10'd1 / PSSCALE))) && (hCount <= (psHPos + (10'd57 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd92 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd90 / PSSCALE))) && (hCount >= (psHPos - (10'd0 / PSSCALE))) && (hCount <= (psHPos + (10'd56 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd91 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd89 / PSSCALE))) && (hCount >= (psHPos + (10'd1 / PSSCALE))) && (hCount <= (psHPos + (10'd55 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd90 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd88 / PSSCALE))) && (hCount >= (psHPos + (10'd2 / PSSCALE))) && (hCount <= (psHPos + (10'd54 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd89 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd87 / PSSCALE))) && (hCount >= (psHPos + (10'd3 / PSSCALE))) && (hCount <= (psHPos + (10'd53 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd88 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd86 / PSSCALE))) && (hCount >= (psHPos + (10'd4 / PSSCALE))) && (hCount <= (psHPos + (10'd52 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd87 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd85 / PSSCALE))) && (hCount >= (psHPos + (10'd5 / PSSCALE))) && (hCount <= (psHPos + (10'd51 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd86 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd84 / PSSCALE))) && (hCount >= (psHPos + (10'd6 / PSSCALE))) && (hCount <= (psHPos + (10'd50 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd85 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd83 / PSSCALE))) && (hCount >= (psHPos + (10'd7 / PSSCALE))) && (hCount <= (psHPos + (10'd49 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd84 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd82 / PSSCALE))) && (hCount >= (psHPos + (10'd8 / PSSCALE))) && (hCount <= (psHPos + (10'd48 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd83 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd81 / PSSCALE))) && (hCount >= (psHPos + (10'd9 / PSSCALE))) && (hCount <= (psHPos + (10'd47 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd82 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd80 / PSSCALE))) && (hCount >= (psHPos + (10'd10 / PSSCALE))) && (hCount <= (psHPos + (10'd46 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd81 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd79 / PSSCALE))) && (hCount >= (psHPos + (10'd11 / PSSCALE))) && (hCount <= (psHPos + (10'd45 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd80 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd78 / PSSCALE))) && (hCount >= (psHPos + (10'd12 / PSSCALE))) && (hCount <= (psHPos + (10'd44 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd79 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd77 / PSSCALE))) && (hCount >= (psHPos + (10'd13 / PSSCALE))) && (hCount <= (psHPos + (10'd43 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd78 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd76 / PSSCALE))) && (hCount >= (psHPos + (10'd14 / PSSCALE))) && (hCount <= (psHPos + (10'd42 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd77 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd75 / PSSCALE))) && (hCount >= (psHPos + (10'd15 / PSSCALE))) && (hCount <= (psHPos + (10'd41 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd76 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd74 / PSSCALE))) && (hCount >= (psHPos + (10'd16 / PSSCALE))) && (hCount <= (psHPos + (10'd40 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd75 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd73 / PSSCALE))) && (hCount >= (psHPos + (10'd17 / PSSCALE))) && (hCount <= (psHPos + (10'd39 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd74 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd72 / PSSCALE))) && (hCount >= (psHPos + (10'd18 / PSSCALE))) && (hCount <= (psHPos + (10'd38 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd73 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd71 / PSSCALE))) && (hCount >= (psHPos + (10'd19 / PSSCALE))) && (hCount <= (psHPos + (10'd37 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd72 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd70 / PSSCALE))) && (hCount >= (psHPos + (10'd20 / PSSCALE))) && (hCount <= (psHPos + (10'd36 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd71 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd69 / PSSCALE))) && (hCount >= (psHPos + (10'd21 / PSSCALE))) && (hCount <= (psHPos + (10'd35 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd70 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd68 / PSSCALE))) && (hCount >= (psHPos + (10'd22 / PSSCALE))) && (hCount <= (psHPos + (10'd34 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd69 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd67 / PSSCALE))) && (hCount >= (psHPos + (10'd23 / PSSCALE))) && (hCount <= (psHPos + (10'd33 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd68 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd66 / PSSCALE))) && (hCount >= (psHPos + (10'd24 / PSSCALE))) && (hCount <= (psHPos + (10'd32 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd67 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd65 / PSSCALE))) && (hCount >= (psHPos + (10'd25 / PSSCALE))) && (hCount <= (psHPos + (10'd31 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd66 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd64 / PSSCALE))) && (hCount >= (psHPos + (10'd26 / PSSCALE))) && (hCount <= (psHPos + (10'd30 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd65 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd63 / PSSCALE))) && (hCount >= (psHPos + (10'd27 / PSSCALE))) && (hCount <= (psHPos + (10'd29 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd64 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd62 / PSSCALE))) && (hCount >= (psHPos + (10'd28 / PSSCALE))) && (hCount <= (psHPos + (10'd28 / PSSCALE))))


                             ||((vCount <= (psVPosTemp + (10'd96 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd94 / PSSCALE))) && (hCount <= (psHPos + (10'd124 / PSSCALE))) && (hCount >= (psHPos + (10'd60 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd95 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd93 / PSSCALE))) && (hCount <= (psHPos + (10'd123 / PSSCALE))) && (hCount >= (psHPos + (10'd61 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd94 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd92 / PSSCALE))) && (hCount <= (psHPos + (10'd122 / PSSCALE))) && (hCount >= (psHPos + (10'd62 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd93 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd91 / PSSCALE))) && (hCount <= (psHPos + (10'd120 / PSSCALE))) && (hCount >= (psHPos + (10'd63 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd92 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd90 / PSSCALE))) && (hCount <= (psHPos + (10'd119 / PSSCALE))) && (hCount >= (psHPos + (10'd64 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd91 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd89 / PSSCALE))) && (hCount <= (psHPos + (10'd118 / PSSCALE))) && (hCount >= (psHPos + (10'd65 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd90 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd88 / PSSCALE))) && (hCount <= (psHPos + (10'd117 / PSSCALE))) && (hCount >= (psHPos + (10'd66 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd89 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd87 / PSSCALE))) && (hCount <= (psHPos + (10'd116 / PSSCALE))) && (hCount >= (psHPos + (10'd67 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd88 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd86 / PSSCALE))) && (hCount <= (psHPos + (10'd115 / PSSCALE))) && (hCount >= (psHPos + (10'd68 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd87 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd85 / PSSCALE))) && (hCount <= (psHPos + (10'd114 / PSSCALE))) && (hCount >= (psHPos + (10'd69 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd86 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd84 / PSSCALE))) && (hCount <= (psHPos + (10'd113 / PSSCALE))) && (hCount >= (psHPos + (10'd70 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd85 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd83 / PSSCALE))) && (hCount <= (psHPos + (10'd112 / PSSCALE))) && (hCount >= (psHPos + (10'd71 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd84 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd82 / PSSCALE))) && (hCount <= (psHPos + (10'd111 / PSSCALE))) && (hCount >= (psHPos + (10'd72 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd83 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd81 / PSSCALE))) && (hCount <= (psHPos + (10'd110 / PSSCALE))) && (hCount >= (psHPos + (10'd73 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd82 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd80 / PSSCALE))) && (hCount <= (psHPos + (10'd109 / PSSCALE))) && (hCount >= (psHPos + (10'd74 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd81 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd79 / PSSCALE))) && (hCount <= (psHPos + (10'd108 / PSSCALE))) && (hCount >= (psHPos + (10'd75 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd80 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd78 / PSSCALE))) && (hCount <= (psHPos + (10'd107 / PSSCALE))) && (hCount >= (psHPos + (10'd76 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd79 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd77 / PSSCALE))) && (hCount <= (psHPos + (10'd106 / PSSCALE))) && (hCount >= (psHPos + (10'd77 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd78 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd76 / PSSCALE))) && (hCount <= (psHPos + (10'd105 / PSSCALE))) && (hCount >= (psHPos + (10'd78 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd77 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd75 / PSSCALE))) && (hCount <= (psHPos + (10'd104 / PSSCALE))) && (hCount >= (psHPos + (10'd79 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd76 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd74 / PSSCALE))) && (hCount <= (psHPos + (10'd103 / PSSCALE))) && (hCount >= (psHPos + (10'd80 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd75 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd73 / PSSCALE))) && (hCount <= (psHPos + (10'd102 / PSSCALE))) && (hCount >= (psHPos + (10'd81 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd74 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd72 / PSSCALE))) && (hCount <= (psHPos + (10'd101 / PSSCALE))) && (hCount >= (psHPos + (10'd82 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd73 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd71 / PSSCALE))) && (hCount <= (psHPos + (10'd100 / PSSCALE))) && (hCount >= (psHPos + (10'd83 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd72 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd70 / PSSCALE))) && (hCount <= (psHPos + (10'd99 / PSSCALE))) && (hCount >= (psHPos + (10'd84 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd71 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd69 / PSSCALE))) && (hCount <= (psHPos + (10'd98 / PSSCALE))) && (hCount >= (psHPos + (10'd85 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd70 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd68 / PSSCALE))) && (hCount <= (psHPos + (10'd97 / PSSCALE))) && (hCount >= (psHPos + (10'd86 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd69 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd67 / PSSCALE))) && (hCount <= (psHPos + (10'd96 / PSSCALE))) && (hCount >= (psHPos + (10'd87 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd68 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd66 / PSSCALE))) && (hCount <= (psHPos + (10'd95 / PSSCALE))) && (hCount >= (psHPos + (10'd88 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd67 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd65 / PSSCALE))) && (hCount <= (psHPos + (10'd94 / PSSCALE))) && (hCount >= (psHPos + (10'd89 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd66 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd64 / PSSCALE))) && (hCount <= (psHPos + (10'd93 / PSSCALE))) && (hCount >= (psHPos + (10'd90 / PSSCALE))))
                             ||((vCount <= (psVPosTemp + (10'd65 / PSSCALE))) && (vCount >= (psVPosTemp + (10'd63 / PSSCALE))) && (hCount <= (psHPos + (10'd92 / PSSCALE))) && (hCount >= (psHPos + (10'd91 / PSSCALE))))
                             ) ? 1 : 0;	
	assign walnut = 
	               (
	               ((vCount >= wVPos) && (vCount <= (wVPos + (10'd5 / WSCALE))) && (hCount >= (wHPos + (10'd27 / WSCALE))) && (hCount <= (wHPos + (10'd48 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd3 / WSCALE))) && (vCount <= (wVPos + (10'd8 / WSCALE))) && (hCount >= (wHPos + (10'd23 / WSCALE))) && (hCount <= (wHPos + (10'd52 / WSCALE) / WSCALE)))
	               
	               ||((vCount >= (wVPos + (10'd6 / WSCALE))) && (vCount <= (wVPos + (10'd11 / WSCALE))) && (hCount >= (wHPos + (10'd19 / WSCALE))) && (hCount <= (wHPos + (10'd56 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd9 / WSCALE))) && (vCount <= (wVPos + (10'd14 / WSCALE))) && (hCount >= (wHPos + (10'd17 / WSCALE))) && (hCount <= (wHPos + (10'd58 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd12 / WSCALE))) && (vCount <= (wVPos + (10'd17 / WSCALE))) && (hCount >= (wHPos + (10'd15 / WSCALE))) && (hCount <= (wHPos + (10'd60 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd15 / WSCALE))) && (vCount <= (wVPos + (10'd20 / WSCALE))) && (hCount >= (wHPos + (10'd13 / WSCALE))) && (hCount <= (wHPos + (10'd62 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd18 / WSCALE))) && (vCount <= (wVPos + (10'd23 / WSCALE))) && (hCount >= (wHPos + (10'd11 / WSCALE))) && (hCount <= (wHPos + (10'd64 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd21 / WSCALE))) && (vCount <= (wVPos + (10'd26 / WSCALE))) && (hCount >= (wHPos + (10'd9 / WSCALE))) && (hCount <= (wHPos + (10'd66 / WSCALE))))

	               ||((vCount >= (wVPos + (10'd24 / WSCALE))) && (vCount <= (wVPos + (10'd29 / WSCALE))) && (hCount >= (wHPos + (10'd8 / WSCALE))) && (hCount <= (wHPos + (10'd67 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd27 / WSCALE))) && (vCount <= (wVPos + (10'd32 / WSCALE))) && (hCount >= (wHPos + (10'd7 / WSCALE))) && (hCount <= (wHPos + (10'd68 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd30 / WSCALE))) && (vCount <= (wVPos + (10'd35 / WSCALE))) && (hCount >= (wHPos + (10'd6 / WSCALE))) && (hCount <= (wHPos + (10'd69 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd33 / WSCALE))) && (vCount <= (wVPos + (10'd38 / WSCALE))) && (hCount >= (wHPos + (10'd5 / WSCALE))) && (hCount <= (wHPos + (10'd70 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd36 / WSCALE))) && (vCount <= (wVPos + (10'd41 / WSCALE))) && (hCount >= (wHPos + (10'd4 / WSCALE))) && (hCount <= (wHPos + (10'd71 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd39 / WSCALE))) && (vCount <= (wVPos + (10'd44 / WSCALE))) && (hCount >= (wHPos + (10'd3 / WSCALE))) && (hCount <= (wHPos + (10'd72 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd42 / WSCALE))) && (vCount <= (wVPos + (10'd47 / WSCALE))) && (hCount >= (wHPos + (10'd2 / WSCALE))) && (hCount <= (wHPos + (10'd73 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd45 / WSCALE))) && (vCount <= (wVPos + (10'd50 / WSCALE))) && (hCount >= (wHPos + (10'd1 / WSCALE))) && (hCount <= (wHPos + (10'd74 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd48 / WSCALE))) && (vCount <= (wVPos + (10'd53 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))
	               
	               
	               ||((vCount >= (wVPos + (10'd51 / WSCALE))) && (vCount <= (wVPos + (10'd56 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd54 / WSCALE))) && (vCount <= (wVPos + (10'd59 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd57 / WSCALE))) && (vCount <= (wVPos + (10'd62 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd60 / WSCALE))) && (vCount <= (wVPos + (10'd65 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd63 / WSCALE))) && (vCount <= (wVPos + (10'd68 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd66 / WSCALE))) && (vCount <= (wVPos + (10'd71 / WSCALE))) && (hCount >= wHPos) && (hCount <= (wHPos + (10'd75 / WSCALE))))	  
	                         
	               ||((vCount >= (wVPos + (10'd69 / WSCALE))) && (vCount <= (wVPos + (10'd74 / WSCALE))) && (hCount >= (wHPos + (10'd1 / WSCALE))) && (hCount <= (wHPos + (10'd74 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd72 / WSCALE))) && (vCount <= (wVPos + (10'd77 / WSCALE))) && (hCount >= (wHPos + (10'd2 / WSCALE))) && (hCount <= (wHPos + (10'd73 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd75 / WSCALE))) && (vCount <= (wVPos + (10'd80 / WSCALE))) && (hCount >= (wHPos + (10'd3 / WSCALE))) && (hCount <= (wHPos + (10'd72 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd78 / WSCALE))) && (vCount <= (wVPos + (10'd83 / WSCALE))) && (hCount >= (wHPos + (10'd4 / WSCALE))) && (hCount <= (wHPos + (10'd71 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd81 / WSCALE))) && (vCount <= (wVPos + (10'd86 / WSCALE))) && (hCount >= (wHPos + (10'd5 / WSCALE))) && (hCount <= (wHPos + (10'd70 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd84 / WSCALE))) && (vCount <= (wVPos + (10'd89 / WSCALE))) && (hCount >= (wHPos + (10'd6 / WSCALE))) && (hCount <= (wHPos + (10'd69 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd87 / WSCALE))) && (vCount <= (wVPos + (10'd92 / WSCALE))) && (hCount >= (wHPos + (10'd7 / WSCALE))) && (hCount <= (wHPos + (10'd68 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd90 / WSCALE))) && (vCount <= (wVPos + (10'd95 / WSCALE))) && (hCount >= (wHPos + (10'd8 / WSCALE))) && (hCount <= (wHPos + (10'd67 / WSCALE))))
	               
	               ||((vCount >= (wVPos + (10'd93 / WSCALE))) && (vCount <= (wVPos + (10'd98 / WSCALE))) && (hCount >= (wHPos + (10'd9 / WSCALE))) && (hCount <= (wHPos + (10'd66 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd96 / WSCALE))) && (vCount <= (wVPos + (10'd101 / WSCALE))) && (hCount >= (wHPos + (10'd11 / WSCALE))) && (hCount <= (wHPos + (10'd64 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd99 / WSCALE))) && (vCount <= (wVPos + (10'd104 / WSCALE))) && (hCount >= (wHPos + (10'd13 / WSCALE))) && (hCount <= (wHPos + (10'd62 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd102 / WSCALE))) && (vCount <= (wVPos + (10'd107 / WSCALE))) && (hCount >= (wHPos + (10'd15 / WSCALE))) && (hCount <= (wHPos + (10'd60 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd105 / WSCALE))) && (vCount <= (wVPos + (10'd110 / WSCALE))) && (hCount >= (wHPos + (10'd17 / WSCALE))) && (hCount <= (wHPos + (10'd58 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd108 / WSCALE))) && (vCount <= (wVPos + (10'd113 / WSCALE))) && (hCount >= (wHPos + (10'd19 / WSCALE))) && (hCount <= (wHPos + (10'd56 / WSCALE))))
	               
	               ||((vCount >= (wVPos + (10'd111 / WSCALE))) && (vCount <= (wVPos + (10'd116 / WSCALE))) && (hCount >= (wHPos + (10'd23 / WSCALE))) && (hCount <= (wHPos + (10'd52 / WSCALE))))
	               ||((vCount >= (wVPos + (10'd114 / WSCALE))) && (vCount <= (wVPos + (10'd119 / WSCALE))) && (hCount >= (wHPos + (10'd27 / WSCALE))) && (hCount <= (wHPos + (10'd48 / WSCALE))))
                   ) ? 1 : 0;
    
    assign walnutWhite =   (
                           ( 
	                       ((vCount >= (wVPos + (10'd44 / WSCALE))) && (vCount <= (wVPos + (10'd70 / WSCALE))) && (hCount >= (wHPos + (10'd30 / WSCALE))) && (hCount <= (wHPos + (10'd47 / WSCALE))))
	                       ||((vCount >= (wVPos + (10'd47 / WSCALE))) && (vCount <= (wVPos + (10'd65 / WSCALE))) && (hCount >= (wHPos + (10'd55 / WSCALE))) && (hCount <= (wHPos + (10'd69 / WSCALE))))
                           ) && (blink == 1'd0)
                           ) ? 1 : 0;
  
    assign walnutBlack = 
                           (
                           ( 
	                       (((vCount >= (wVPos + (10'd49 / WSCALE))) && (vCount <= (wVPos + (10'd65 / WSCALE))) && (hCount >= (wHPos + (10'd35 / WSCALE))) && (hCount <= (wHPos + (10'd45 / WSCALE))))
	                       ||((vCount >= (wVPos + (10'd51 / WSCALE))) && (vCount <= (wVPos + (10'd63 / WSCALE))) && (hCount >= (wHPos + (10'd59 / WSCALE))) && (hCount <= (wHPos + (10'd67 / WSCALE)))))
	                       && (blink == 1'd0)
	                       )
	                       || ((vCount >= (wVPos + (10'd74 / WSCALE))) && (vCount <= (wVPos + (10'd79 / WSCALE))) && (hCount >= (wHPos + (10'd39 / WSCALE))) && (hCount <= (wHPos + (10'd44 / WSCALE))))
	                       || ((vCount >= (wVPos + (10'd76 / WSCALE))) && (vCount <= (wVPos + (10'd81 / WSCALE))) && (hCount >= (wHPos + (10'd42 / WSCALE))) && (hCount <= (wHPos + (10'd59 / WSCALE))))
	                       || ((vCount >= (wVPos + (10'd74 / WSCALE))) && (vCount <= (wVPos + (10'd79 / WSCALE))) && (hCount >= (wHPos + (10'd57 / WSCALE))) && (hCount <= wHPos + (10'd62 / WSCALE)))
                           ) ? 1 : 0;
	 
	
	//sunflower visualization (to be made relative to the top left corner location, need to add stem + movement / WSCALE
	assign sunflowerOuter = 
	                   ( 
	                   ((vCount >= (sfHeadVPos - (10'd13 / SFSCALE)))&& (vCount <= (sfHeadVPos)) && (hCount >= (sfHeadHPos + (10'd24 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd101 / SFSCALE))))
	                   || ((vCount >= (sfHeadVPos - (10'd32 / SFSCALE))) && (vCount <= (sfHeadVPos + (10'd14 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd18 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd107 / SFSCALE))))
	               
	                   || ((vCount >= (sfHeadVPos - (10'd50 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd32 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd12 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd113 / SFSCALE))))
	                   || ((vCount >= (sfHeadVPos - (10'd67 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd50 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd6 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd119 / SFSCALE))))
	                   || ((vCount >= (sfHeadVPos - (10'd85 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd68 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd0 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd125 / SFSCALE))))
	               
	                   || ((vCount >= (sfHeadVPos - (10'd103 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd86 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd6 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd119 / SFSCALE))))
	                   || ((vCount >= (sfHeadVPos - (10'd121 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd104 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd12 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd113 / SFSCALE))))
	                   
	                   || ((vCount >= (sfHeadVPos - (10'd139 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd122 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd18 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd107 / SFSCALE))))
	                   || ((vCount >= (sfHeadVPos - (10'd154 / SFSCALE))) && (vCount <= (sfHeadVPos - (10'd140 / SFSCALE))) && (hCount >= (sfHeadHPos + (10'd24 / SFSCALE))) && (hCount <= (sfHeadHPos + (10'd101 / SFSCALE))))
                       ) ? 1 : 0;
	                       	                   
	assign sunflowerInner = ( (vCount < (sfHeadVPos - (10'd24 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd124 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd25 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd100 / SFSCALE)))) ? 1 : 0;

    assign sunflowerFace = ( 
                             ((vCount < (sfHeadVPos - (10'd89 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd104 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd45 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd55 / SFSCALE))))
                           ||((vCount < (sfHeadVPos - (10'd89 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd104 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd70 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd80 / SFSCALE))))
                           
                           ||((vCount < (sfHeadVPos - (10'd52 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd64 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd40 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd50 / SFSCALE))))
                           ||((vCount < (sfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd45 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd80 / SFSCALE))))
//                           ||((vCount < (10'd340 / SFSCALE))) && (vCount > (10'd328 / SFSCALE))) && (hCount > (10'd280 / SFSCALE))) && (hCount < (10'd295 / SFSCALE))))
//                           ||((vCount < (sfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd55 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd65 / SFSCALE))))
//                           ||((vCount < (sfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd65 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd75 / SFSCALE))))
                           ||((vCount < (sfHeadVPos - (10'd52 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd64 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd75 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd85 / SFSCALE))))
                           ) ? 1 : 0;
                     
     assign sunflowerStem = (//374-425, 425-475
                               ((vCount <= (sfVPosTemp + (10'd6 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd0 / SFSCALE))) && (hCount >= (sfHPos + (10'd55 / SFSCALE))) && (hCount <= (sfHPos + (10'd71  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd11 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd6 / SFSCALE))) && (hCount >= (sfHPos + (10'd54 / SFSCALE))) && (hCount <= (sfHPos + (10'd70  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd16 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd11 / SFSCALE))) && (hCount >= (sfHPos + (10'd53 / SFSCALE))) && (hCount <= (sfHPos + (10'd69  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd21 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd16 / SFSCALE))) && (hCount >= (sfHPos + (10'd52 / SFSCALE))) && (hCount <= (sfHPos + (10'd68  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd26 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd21 / SFSCALE))) && (hCount >= (sfHPos + (10'd51 / SFSCALE))) && (hCount <= (sfHPos + (10'd67  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd31 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd26 / SFSCALE))) && (hCount >= (sfHPos + (10'd50 / SFSCALE))) && (hCount <= (sfHPos + (10'd66  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd36 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd31 / SFSCALE))) && (hCount >= (sfHPos + (10'd49 / SFSCALE))) && (hCount <= (sfHPos + (10'd65  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd41 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd36 / SFSCALE))) && (hCount >= (sfHPos + (10'd48 / SFSCALE))) && (hCount <= (sfHPos + (10'd64  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd46 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd41 / SFSCALE))) && (hCount >= (sfHPos + (10'd47 / SFSCALE))) && (hCount <= (sfHPos + (10'd63  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd51 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd46 / SFSCALE))) && (hCount >= (sfHPos + (10'd46 / SFSCALE))) && (hCount <= (sfHPos + (10'd62  / SFSCALE))))
                     
                             ||((vCount <= (sfVPosTemp + (10'd96 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd91 / SFSCALE))) && (hCount >= (sfHPos + (10'd55 / SFSCALE))) && (hCount <= (sfHPos + (10'd71  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd91 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd86 / SFSCALE))) && (hCount >= (sfHPos + (10'd54 / SFSCALE))) && (hCount <= (sfHPos + (10'd70  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd86 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd81 / SFSCALE))) && (hCount >= (sfHPos + (10'd53 / SFSCALE))) && (hCount <= (sfHPos + (10'd69  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd81 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd76 / SFSCALE))) && (hCount >= (sfHPos + (10'd52 / SFSCALE))) && (hCount <= (sfHPos + (10'd68  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd76 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd71 / SFSCALE))) && (hCount >= (sfHPos + (10'd51 / SFSCALE))) && (hCount <= (sfHPos + (10'd67  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd71 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd66 / SFSCALE))) && (hCount >= (sfHPos + (10'd50 / SFSCALE))) && (hCount <= (sfHPos + (10'd66  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd66 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd61 / SFSCALE))) && (hCount >= (sfHPos + (10'd49 / SFSCALE))) && (hCount <= (sfHPos + (10'd65  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd61 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd56 / SFSCALE))) && (hCount >= (sfHPos + (10'd48 / SFSCALE))) && (hCount <= (sfHPos + (10'd64  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd56 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd51 / SFSCALE))) && (hCount >= (sfHPos + (10'd47 / SFSCALE))) && (hCount <= (sfHPos + (10'd63  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd51 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd46 / SFSCALE))) && (hCount >= (sfHPos + (10'd46 / SFSCALE))) && (hCount <= (sfHPos + (10'd62  / SFSCALE))))
                             
                             ||((vCount <= (sfVPosTemp + (10'd96 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd94 / SFSCALE))) && (hCount >= (sfHPos - (10'd4 / SFSCALE))) && (hCount <= (sfHPos + (10'd60  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd95 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd93 / SFSCALE))) && (hCount >= (sfHPos - (10'd3 / SFSCALE))) && (hCount <= (sfHPos + (10'd59  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd94 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd92 / SFSCALE))) && (hCount >= (sfHPos - (10'd2 / SFSCALE))) && (hCount <= (sfHPos + (10'd58  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd93 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd91 / SFSCALE))) && (hCount >= (sfHPos - (10'd1 / SFSCALE))) && (hCount <= (sfHPos + (10'd57  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd92 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd90 / SFSCALE))) && (hCount >= (sfHPos - (10'd0 / SFSCALE))) && (hCount <= (sfHPos + (10'd56  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd91 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd89 / SFSCALE))) && (hCount >= (sfHPos + (10'd1 / SFSCALE))) && (hCount <= (sfHPos + (10'd55  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd90 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd88 / SFSCALE))) && (hCount >= (sfHPos + (10'd2 / SFSCALE))) && (hCount <= (sfHPos + (10'd54  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd89 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd87 / SFSCALE))) && (hCount >= (sfHPos + (10'd3 / SFSCALE))) && (hCount <= (sfHPos + (10'd53  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd88 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd86 / SFSCALE))) && (hCount >= (sfHPos + (10'd4 / SFSCALE))) && (hCount <= (sfHPos + (10'd52  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd87 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd85 / SFSCALE))) && (hCount >= (sfHPos + (10'd5 / SFSCALE))) && (hCount <= (sfHPos + (10'd51  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd86 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd84 / SFSCALE))) && (hCount >= (sfHPos + (10'd6 / SFSCALE))) && (hCount <= (sfHPos + (10'd50  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd85 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd83 / SFSCALE))) && (hCount >= (sfHPos + (10'd7 / SFSCALE))) && (hCount <= (sfHPos + (10'd49  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd84 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd82 / SFSCALE))) && (hCount >= (sfHPos + (10'd8 / SFSCALE))) && (hCount <= (sfHPos + (10'd48  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd83 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd81 / SFSCALE))) && (hCount >= (sfHPos + (10'd9 / SFSCALE))) && (hCount <= (sfHPos + (10'd47  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd82 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd80 / SFSCALE))) && (hCount >= (sfHPos + (10'd10 / SFSCALE))) && (hCount <= (sfHPos + (10'd46  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd81 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd79 / SFSCALE))) && (hCount >= (sfHPos + (10'd11 / SFSCALE))) && (hCount <= (sfHPos + (10'd45  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd80 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd78 / SFSCALE))) && (hCount >= (sfHPos + (10'd12 / SFSCALE))) && (hCount <= (sfHPos + (10'd44  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd79 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd77 / SFSCALE))) && (hCount >= (sfHPos + (10'd13 / SFSCALE))) && (hCount <= (sfHPos + (10'd43  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd78 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd76 / SFSCALE))) && (hCount >= (sfHPos + (10'd14 / SFSCALE))) && (hCount <= (sfHPos + (10'd42  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd77 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd75 / SFSCALE))) && (hCount >= (sfHPos + (10'd15 / SFSCALE))) && (hCount <= (sfHPos + (10'd41  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd76 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd74 / SFSCALE))) && (hCount >= (sfHPos + (10'd16 / SFSCALE))) && (hCount <= (sfHPos + (10'd40  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd75 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd73 / SFSCALE))) && (hCount >= (sfHPos + (10'd17 / SFSCALE))) && (hCount <= (sfHPos + (10'd39  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd74 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd72 / SFSCALE))) && (hCount >= (sfHPos + (10'd18 / SFSCALE))) && (hCount <= (sfHPos + (10'd38  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd73 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd71 / SFSCALE))) && (hCount >= (sfHPos + (10'd19 / SFSCALE))) && (hCount <= (sfHPos + (10'd37  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd72 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd70 / SFSCALE))) && (hCount >= (sfHPos + (10'd20 / SFSCALE))) && (hCount <= (sfHPos + (10'd36  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd71 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd69 / SFSCALE))) && (hCount >= (sfHPos + (10'd21 / SFSCALE))) && (hCount <= (sfHPos + (10'd35  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd70 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd68 / SFSCALE))) && (hCount >= (sfHPos + (10'd22 / SFSCALE))) && (hCount <= (sfHPos + (10'd34  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd69 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd67 / SFSCALE))) && (hCount >= (sfHPos + (10'd23 / SFSCALE))) && (hCount <= (sfHPos + (10'd33  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd68 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd66 / SFSCALE))) && (hCount >= (sfHPos + (10'd24 / SFSCALE))) && (hCount <= (sfHPos + (10'd32  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd67 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd65 / SFSCALE))) && (hCount >= (sfHPos + (10'd25 / SFSCALE))) && (hCount <= (sfHPos + (10'd31  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd66 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd64 / SFSCALE))) && (hCount >= (sfHPos + (10'd26 / SFSCALE))) && (hCount <= (sfHPos + (10'd30  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd65 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd63 / SFSCALE))) && (hCount >= (sfHPos + (10'd27 / SFSCALE))) && (hCount <= (sfHPos + (10'd29  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd64 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd62 / SFSCALE))) && (hCount >= (sfHPos + (10'd28 / SFSCALE))) && (hCount <= (sfHPos + (10'd28  / SFSCALE))))


                             ||((vCount <= (sfVPosTemp + (10'd96 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd94 / SFSCALE))) && (hCount <= (sfHPos + (10'd124 / SFSCALE))) && (hCount >= (sfHPos + (10'd60  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd95 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd93 / SFSCALE))) && (hCount <= (sfHPos + (10'd123 / SFSCALE))) && (hCount >= (sfHPos + (10'd61  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd94 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd92 / SFSCALE))) && (hCount <= (sfHPos + (10'd122 / SFSCALE))) && (hCount >= (sfHPos + (10'd62  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd93 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd91 / SFSCALE))) && (hCount <= (sfHPos + (10'd120 / SFSCALE))) && (hCount >= (sfHPos + (10'd63  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd92 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd90 / SFSCALE))) && (hCount <= (sfHPos + (10'd119 / SFSCALE))) && (hCount >= (sfHPos + (10'd64  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd91 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd89 / SFSCALE))) && (hCount <= (sfHPos + (10'd118 / SFSCALE))) && (hCount >= (sfHPos + (10'd65  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd90 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd88 / SFSCALE))) && (hCount <= (sfHPos + (10'd117 / SFSCALE))) && (hCount >= (sfHPos + (10'd66  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd89 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd87 / SFSCALE))) && (hCount <= (sfHPos + (10'd116 / SFSCALE))) && (hCount >= (sfHPos + (10'd67  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd88 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd86 / SFSCALE))) && (hCount <= (sfHPos + (10'd115 / SFSCALE))) && (hCount >= (sfHPos + (10'd68  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd87 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd85 / SFSCALE))) && (hCount <= (sfHPos + (10'd114 / SFSCALE))) && (hCount >= (sfHPos + (10'd69  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd86 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd84 / SFSCALE))) && (hCount <= (sfHPos + (10'd113 / SFSCALE))) && (hCount >= (sfHPos + (10'd70  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd85 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd83 / SFSCALE))) && (hCount <= (sfHPos + (10'd112 / SFSCALE))) && (hCount >= (sfHPos + (10'd71  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd84 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd82 / SFSCALE))) && (hCount <= (sfHPos + (10'd111 / SFSCALE))) && (hCount >= (sfHPos + (10'd72  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd83 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd81 / SFSCALE))) && (hCount <= (sfHPos + (10'd110 / SFSCALE))) && (hCount >= (sfHPos + (10'd73  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd82 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd80 / SFSCALE))) && (hCount <= (sfHPos + (10'd109 / SFSCALE))) && (hCount >= (sfHPos + (10'd74  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd81 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd79 / SFSCALE))) && (hCount <= (sfHPos + (10'd108 / SFSCALE))) && (hCount >= (sfHPos + (10'd75  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd80 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd78 / SFSCALE))) && (hCount <= (sfHPos + (10'd107 / SFSCALE))) && (hCount >= (sfHPos + (10'd76  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd79 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd77 / SFSCALE))) && (hCount <= (sfHPos + (10'd106 / SFSCALE))) && (hCount >= (sfHPos + (10'd77  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd78 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd76 / SFSCALE))) && (hCount <= (sfHPos + (10'd105 / SFSCALE))) && (hCount >= (sfHPos + (10'd78  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd77 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd75 / SFSCALE))) && (hCount <= (sfHPos + (10'd104 / SFSCALE))) && (hCount >= (sfHPos + (10'd79  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd76 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd74 / SFSCALE))) && (hCount <= (sfHPos + (10'd103 / SFSCALE))) && (hCount >= (sfHPos + (10'd80  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd75 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd73 / SFSCALE))) && (hCount <= (sfHPos + (10'd102 / SFSCALE))) && (hCount >= (sfHPos + (10'd81  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd74 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd72 / SFSCALE))) && (hCount <= (sfHPos + (10'd101 / SFSCALE))) && (hCount >= (sfHPos + (10'd82  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd73 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd71 / SFSCALE))) && (hCount <= (sfHPos + (10'd100 / SFSCALE))) && (hCount >= (sfHPos + (10'd83  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd72 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd70 / SFSCALE))) && (hCount <= (sfHPos + (10'd99 / SFSCALE))) && (hCount >= (sfHPos + (10'd84  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd71 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd69 / SFSCALE))) && (hCount <= (sfHPos + (10'd98 / SFSCALE))) && (hCount >= (sfHPos + (10'd85  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd70 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd68 / SFSCALE))) && (hCount <= (sfHPos + (10'd97 / SFSCALE))) && (hCount >= (sfHPos + (10'd86  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd69 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd67 / SFSCALE))) && (hCount <= (sfHPos + (10'd96 / SFSCALE))) && (hCount >= (sfHPos + (10'd87  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd68 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd66 / SFSCALE))) && (hCount <= (sfHPos + (10'd95 / SFSCALE))) && (hCount >= (sfHPos + (10'd88  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd67 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd65 / SFSCALE))) && (hCount <= (sfHPos + (10'd94 / SFSCALE))) && (hCount >= (sfHPos + (10'd89  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd66 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd64 / SFSCALE))) && (hCount <= (sfHPos + (10'd93 / SFSCALE))) && (hCount >= (sfHPos + (10'd90  / SFSCALE))))
                             ||((vCount <= (sfVPosTemp + (10'd65 / SFSCALE))) && (vCount >= (sfVPosTemp + (10'd63 / SFSCALE))) && (hCount <= (sfHPos + (10'd92 / SFSCALE))) && (hCount >= (sfHPos + (10'd91  / SFSCALE))))
                           ) ? 1 : 0;


endmodule