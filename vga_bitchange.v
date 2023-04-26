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
	output reg [15:0] numSuns,
	output q_I, 
	output q_L1, 
	output q_NL2, 
	output q_L2, 
	output q_NL3, 
	output q_L3, 
	output q_DoneL, 
	output q_DoneW );

    reg youLose;
    wire youLose_RED;
    reg youWin;
    wire youWin_BLUE;
    
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
	parameter BLUE = 12'b0000_0000_1111;
	
	parameter STEM_GREEN = 12'b0000_1011_0100;
	parameter BROWN = 12'b0111_0011_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter PEA_GREEN = 12'b0111_1111_0010;
	
	parameter SFSCALE = 10'd4;
    parameter WSCALE = 10'd3; 
    parameter PSSCALE = 10'd4;

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
//	parameter ZOMBIE_HEAD_SCALE = 10'd2;
//	parameter ZOMBIE_EYE_SCALE = 10'd3;

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
	parameter HALF_ROW_HEIGHT = 10'd43;

	//End of screen
	parameter END_OF_LAWN_X = 10'd300;
	parameter END_OF_LAWN_Y = 10'd521;
	parameter BEGINNING_OF_LAWN_X = 10'd799;
	parameter BEGINNING_OF_LAWN_Y = 10'd87;
	
	
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
	reg[9:0] plantRow0Type;
	reg[9:0] plantRow1Type;
	reg[9:0] plantRow2Type;
	reg[9:0] plantRow3Type;
	reg[9:0] plantRow4Type;
    
    reg[2:0] plant0Type;
	reg[2:0] plant1Type;
	reg[2:0] plant2Type;
	// reg[2:0] plant3Type;
	// reg[2:0] plant4Type;
    reg[2:0] plant5Type;
	reg[2:0] plant6Type;
	reg[2:0] plant7Type;
	// reg[2:0] plant8Type;
	// reg[2:0] plant9Type;
	reg[2:0] plant10Type;
	reg[2:0] plant11Type;
	reg[2:0] plant12Type;
	// reg[2:0] plant13Type;
	// reg[2:0] plant14Type;
	reg[2:0] plant15Type;
	reg[2:0] plant16Type;
	reg[2:0] plant17Type;
	// reg[2:0] plant18Type;
	// reg[2:0] plant19Type;
	reg[2:0] plant20Type;
	reg[2:0] plant21Type;
	reg[2:0] plant22Type;
	// reg[2:0] plant23Type;
	// reg[2:0] plant24Type;
	
	//to be commented
	// reg[2:0] plant0Killed;
	// reg[2:0] plant1Killed;
	// reg[2:0] plant2Killed;
	// reg[2:0] plant3Killed;
	// reg[2:0] plant4Killed;
	//Registers to hold pea shot's X position. There are 25 pea shots
	wire[9:0] peaShot0X;
	wire[9:0] peaShot1X;
	wire[9:0] peaShot2X;
	// wire[9:0] peaShot3X;
	// wire[9:0] peaShot4X;
	wire[9:0] peaShot5X;
	wire[9:0] peaShot6X;
	wire[9:0] peaShot7X;
	// wire[9:0] peaShot8X;
	// wire[9:0] peaShot9X;
	wire[9:0] peaShot10X;
	wire[9:0] peaShot11X;
	wire[9:0] peaShot12X;
	// wire[9:0] peaShot13X;
	// wire[9:0] peaShot14X;
	wire[9:0] peaShot15X;
	wire[9:0] peaShot16X;
	wire[9:0] peaShot17X;
	// wire[9:0] peaShot18X;
	// wire[9:0] peaShot19X;
	wire[9:0] peaShot20X;
	wire[9:0] peaShot21X;
	wire[9:0] peaShot22X;
	// wire[9:0] peaShot23X;
	// wire[9:0] peaShot24X;
	//Registers to hold if a plant has been placed on a certain grid box
	reg plant0Placed;
	reg plant1Placed;
	reg plant2Placed;
	// reg plant3Placed;
	// reg plant4Placed;
	reg plant5Placed;
	reg plant6Placed;
	reg plant7Placed;
	// reg plant8Placed;
	// reg plant9Placed;
	reg plant10Placed;
	reg plant11Placed;
	reg plant12Placed;
	// reg plant13Placed;
	// reg plant14Placed;
	reg plant15Placed;
	reg plant16Placed;
	reg plant17Placed;
	// reg plant18Placed;
	// reg plant19Placed;
	reg plant20Placed;
	reg plant21Placed;
	reg plant22Placed;
	// reg plant23Placed;
	// reg plant24Placed;

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
	// wire sunflowerInner;
	// wire sunflowerOuter;
	// wire sunflowerFace;

	wire selectedPlantBoxOutline;
	wire GRID;

	assign pen0 = (peaShot0X == zombie0X) ? 1 : 0;
    assign pen1 = (peaShot1X == zombie0X) ? 1 : 0;
    assign pen2 = (peaShot2X == zombie0X) ? 1 : 0;
    // assign pen3 = (peaShot3X == zombie0X) ? 1 : 0;
    // assign pen4 = (peaShot4X == zombie0X) ? 1 : 0;
    assign pen5 = (peaShot5X == zombie1X) ? 1 : 0;
    assign pen6 = (peaShot6X == zombie1X) ? 1 : 0;
    assign pen7 = (peaShot7X == zombie1X) ? 1 : 0;
    // assign pen8 = (peaShot8X == zombie0X) ? 1 : 0;
    // assign pen9 = (peaShot9X == zombie0X) ? 1 : 0;
    assign pen10 = (peaShot10X == zombie2X) ? 1 : 0;
    assign pen11 = (peaShot11X == zombie2X) ? 1 : 0;
    assign pen12 = (peaShot12X == zombie2X) ? 1 : 0;
    // assign pen13 = (peaShot13X == zombie0X) ? 1 : 0;
    // assign pen14 = (peaShot14X == zombie0X) ? 1 : 0;
    assign pen15 = (peaShot15X == zombie3X) ? 1 : 0;
    assign pen16 = (peaShot16X == zombie3X) ? 1 : 0;
    assign pen17 = (peaShot17X == zombie3X) ? 1 : 0;
    // assign pen18 = (peaShot18X == zombie0X) ? 1 : 0;
    // assign pen19 = (peaShot19X == zombie0X) ? 1 : 0;
    assign pen20 = (peaShot20X == zombie4X) ? 1 : 0;
    assign pen21 = (peaShot21X == zombie4X) ? 1 : 0;
    assign pen22 = (peaShot22X == zombie4X) ? 1 : 0;
    // assign pen23 = (peaShot23X == zombie0X) ? 1 : 0;
    // assign pen24 = (peaShot24X == zombie0X) ? 1 : 0;

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
	
	//Store the current state
//	output q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW;
	reg [7:0] state;
	assign {q_I, q_L1, q_NL2, q_I, q_L1, q_NL2, q_L2, q_NL3, q_L3, q_DoneL, q_DoneW} = state;
	
	//Local parameters for state
	parameter I = 8'b0000_0001, L1 = 8'b0000_0010, NL2 = 8'b0000_0100, L2 = 8'b0000_1000, NL3 = 8'b0001_0000, L3 = 8'b0010_0000, DoneL = 8'b0100_0000, DoneW = 8'b1000_0000;

    
    //sun logic
//    reg[15:0] numSuns;
    parameter SECS_BETWEEN_SUNS = 10'd10;
    reg [49:0] sunTimer;

	initial begin
	   youLose = 1'b0;
        youWin = 1'b0;
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
		selectedPlantBoxX = 10'd0;
		//Initiliaze the X and Y coordinates of the selected grid box
		selectedGridBoxX = 10'd350;
		selectedGridBoxY = 10'd130;
		//TODO: initiliaze the state?
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
		
		numSuns = 16'd50;
		sunTimer = 50'd0;
		
//		plant0Placed = 1'd1;
//		plant0Type = WALNUT;
		
//		plant7Placed = 1'd1;
//		plant7Type = SUNFLOWER;
		
//		plant6Placed = 1'd1;
//		plant6Type = WALNUT;
				
//		plant21Placed = 1'd1;
//		plant21Type = PEASHOOTER;
		
//		plant17Placed = 1'd1;
//		plant17Type = PEASHOOTER;
		
//		plant16Placed = 1'd1;
//		plant16Type = SUNFLOWER;
	end

	//TODO: define the zombie colors here
	//Define the color scheme
	always@ (*)
    if (~bright)
        rgb = BLACK;
    else if(youLose_RED == 1)
        begin
            rgb = RED;
        end
    else if (youWin_BLUE == 1)
        begin
            rgb = BLUE;
        end 
	else if (selectedPlantBoxOutline == 1 && isSelectingPlantBox == 1)
		rgb = RED;
	else if (selectedLawnPositionOutline == 1 && isSelectingLawnPosition == 1)
		rgb = RED;
	// else if ((zombieEye0 == 1 && ~zombie0Killed) || (zombieEye1 == 1 && ~zombie1Killed) || (zombieEye2 == 1 && ~zombie2Killed) || (zombieEye3 == 1 && ~zombie3Killed) || (zombieEye4 == 1 && ~zombie4Killed))
    // else if((zombieEye0 && ~zombie0ReachedEnd) || (zombieEye1 && ~zombie1ReachedEnd) || (zombieEye2 && ~zombie2ReachedEnd) || (zombieEye3 && ~zombie3ReachedEnd) || (zombieEye4 && ~zombie4ReachedEnd))
    else if((zombieEye0 && ~zombie0ReachedEnd && ~zombie0Killed) || (zombieEye1 && ~zombie1ReachedEnd && ~zombie1Killed) || (zombieEye2 && ~zombie2ReachedEnd && ~zombie2Killed) || (zombieEye3 && ~zombie3ReachedEnd && ~zombie3Killed) || (zombieEye4 && ~zombie4ReachedEnd && ~zombie4Killed))
        rgb = ZOMBIE_EYE;
    //else if ((zombieHead0 == 1 && ~zombie0Killed) || (zombieHead1 == 1 && ~zombie1Killed) || (zombieHead2 == 1 && ~zombie2Killed) || (zombieHead3 == 1 && ~zombie3Killed) || (zombieHead4 == 1 && ~zombie4Killed))
    // else if((zombieHead0 && ~zombie0ReachedEnd) || (zombieHead1 && ~zombie1ReachedEnd) || (zombieHead2 && ~zombie2ReachedEnd) || (zombieHead3 && ~zombie3ReachedEnd) || (zombieHead4 && ~zombie4ReachedEnd))
    else if((zombieHead0 && ~zombie0ReachedEnd && ~zombie0Killed) || (zombieHead1 && ~zombie1ReachedEnd && ~zombie1Killed) || (zombieHead2 && ~zombie2ReachedEnd && ~zombie2Killed) || (zombieHead3 && ~zombie3ReachedEnd && ~zombie3Killed) || (zombieHead4 && ~zombie4ReachedEnd && ~zombie4Killed))
        rgb = ZOMBIE_HEAD;
    // else if((zombieBody0 == 1 && ~zombie0ReachedEnd) || (zombieBody1 == 1 && ~zombie1ReachedEnd) || (zombieBody2 == 1 && ~zombie2ReachedEnd) || (zombieBody3 == 1 && ~zombie3ReachedEnd) || (zombieBody4 == 1 && ~zombie4ReachedEnd))
    else if((zombieBody0 && ~zombie0ReachedEnd && ~zombie0Killed) || (zombieBody1 && ~zombie1ReachedEnd && ~zombie1Killed) || (zombieBody2 && ~zombie2ReachedEnd && ~zombie2Killed) || (zombieBody3 && ~zombie3ReachedEnd && ~zombie3Killed) || (zombieBody4 && ~zombie4ReachedEnd && ~zombie4Killed))
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
    else if (sunflowerStem == 1)
        rgb = STEM_GREEN;
    else if (greyZone == 1)
        rgb = GREY;
	else if (GRID1 == 1 || GRID2 == 1)
		rgb = DARK_GREEN;
    else
        rgb = GREEN; // background color
        
    assign en = 1'd1;
   
    
    reg[9:0] VPOS0 = 10'd87;
    reg[9:0] HPOS0 = 10'd300;
    reg[9:0] VPOS1 = 10'd87;
    reg[9:0] HPOS1 = 10'd400;
    reg[9:0] VPOS2 = 10'd87;
    reg[9:0] HPOS2 = 10'd500;
    reg[9:0] VPOS3 = 10'd87;
    reg[9:0] HPOS3 = 10'd600;
    reg[9:0] VPOS4 = 10'd87;
    reg[9:0] HPOS4 = 10'd700;

    reg[9:0] VPOS5 = 10'd174;
    reg[9:0] HPOS5 = 10'd300;
    reg[9:0] VPOS6 = 10'd174;
    reg[9:0] HPOS6 = 10'd400;
    reg[9:0] VPOS7 = 10'd174;
    reg[9:0] HPOS7 = 10'd500;
    reg[9:0] VPOS8 = 10'd174;
    reg[9:0] HPOS8 = 10'd600;
    reg[9:0] VPOS9 = 10'd174;
    reg[9:0] HPOS9 = 10'd700;
    
    reg[9:0] VPOS10 = 10'd261;
    reg[9:0] HPOS10 = 10'd300;
    reg[9:0] VPOS11 = 10'd261;
    reg[9:0] HPOS11 = 10'd400;
    reg[9:0] VPOS12 = 10'd261;
    reg[9:0] HPOS12 = 10'd500;
    reg[9:0] VPOS13 = 10'd261;
    reg[9:0] HPOS13 = 10'd600;
    reg[9:0] VPOS14 = 10'd261;
    reg[9:0] HPOS14 = 10'd700;

    reg[9:0] VPOS15 = 10'd348;
    reg[9:0] HPOS15 = 10'd300;
    reg[9:0] VPOS16 = 10'd348;
    reg[9:0] HPOS16 = 10'd400;
    reg[9:0] VPOS17 = 10'd348;
    reg[9:0] HPOS17 = 10'd500;
    reg[9:0] VPOS18 = 10'd348;
    reg[9:0] HPOS18 = 10'd600;
    reg[9:0] VPOS19 = 10'd348;
    reg[9:0] HPOS19 = 10'd700;
    
    reg[9:0] VPOS20 = 10'd435;
    reg[9:0] HPOS20 = 10'd300;
    reg[9:0] VPOS21 = 10'd435;
    reg[9:0] HPOS21 = 10'd400;
    reg[9:0] VPOS22 = 10'd435;
    reg[9:0] HPOS22 = 10'd500;
    reg[9:0] VPOS23 = 10'd435;
    reg[9:0] HPOS23 = 10'd600;
    reg[9:0] VPOS24 = 10'd435;
    reg[9:0] HPOS24 = 10'd700;
    
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

    assign psen0 = ((plant0Placed == 1'd1) && (plant0Type == PEASHOOTER)) ? 1 : 0;
    assign psen1 = ((plant1Placed == 1'd1) && (plant1Type == PEASHOOTER)) ? 1 : 0;
    assign psen2 = ((plant2Placed == 1'd1) && (plant2Type == PEASHOOTER)) ? 1 : 0;
    // assign psen3 = ((plant3Placed == 1'd1) && (plant3Type == PEASHOOTER)) ? 1 : 0;
    // assign psen4 = ((plant4Placed == 1'd1) && (plant4Type == PEASHOOTER)) ? 1 : 0;
    assign psen5 = ((plant5Placed == 1'd1) && (plant5Type == PEASHOOTER)) ? 1 : 0;
    assign psen6 = ((plant6Placed == 1'd1) && (plant6Type == PEASHOOTER)) ? 1 : 0;
    assign psen7 = ((plant7Placed == 1'd1) && (plant7Type == PEASHOOTER)) ? 1 : 0;
    // assign psen8 = ((plant8Placed == 1'd1) && (plant8Type == PEASHOOTER)) ? 1 : 0;
    // assign psen9 = ((plant9Placed == 1'd1) && (plant9Type == PEASHOOTER)) ? 1 : 0;
    assign psen10 = ((plant10Placed == 1'd1) && (plant10Type == PEASHOOTER)) ? 1 : 0;
    assign psen11 = ((plant11Placed == 1'd1) && (plant11Type == PEASHOOTER)) ? 1 : 0;
    assign psen12 = ((plant12Placed == 1'd1) && (plant12Type == PEASHOOTER)) ? 1 : 0;
    // assign psen13 = ((plant13Placed == 1'd1) && (plant13Type == PEASHOOTER)) ? 1 : 0;
    // assign psen14 = ((plant14Placed == 1'd1) && (plant14Type == PEASHOOTER)) ? 1 : 0;
    assign psen15 = ((plant15Placed == 1'd1) && (plant15Type == PEASHOOTER)) ? 1 : 0;
    assign psen16 = ((plant16Placed == 1'd1) && (plant16Type == PEASHOOTER)) ? 1 : 0;
    assign psen17 = ((plant17Placed == 1'd1) && (plant17Type == PEASHOOTER)) ? 1 : 0;
    // assign psen18 = ((plant18Placed == 1'd1) && (plant18Type == PEASHOOTER)) ? 1 : 0;
    // assign psen19 = ((plant19Placed == 1'd1) && (plant19Type == PEASHOOTER)) ? 1 : 0;
    assign psen20 = ((plant20Placed == 1'd1) && (plant20Type == PEASHOOTER)) ? 1 : 0;
    assign psen21 = ((plant21Placed == 1'd1) && (plant21Type == PEASHOOTER)) ? 1 : 0;
    assign psen22 = ((plant22Placed == 1'd1) && (plant22Type == PEASHOOTER)) ? 1 : 0;
    // assign psen23 = ((plant23Placed == 1'd1) && (plant23Type == PEASHOOTER)) ? 1 : 0;
    // assign psen24 = ((plant24Placed == 1'd1) && (plant24Type == PEASHOOTER)) ? 1 : 0;

    assign wen0 = ((plant0Placed == 1'd1) && (plant0Type == WALNUT)) ? 1 : 0;
    assign wen1 = ((plant1Placed == 1'd1) && (plant1Type == WALNUT)) ? 1 : 0;
    assign wen2 = ((plant2Placed == 1'd1) && (plant2Type == WALNUT)) ? 1 : 0;
    // assign wen3 = ((plant3Placed == 1'd1) && (plant3Type == WALNUT)) ? 1 : 0;
    // assign wen4 = ((plant4Placed == 1'd1) && (plant4Type == WALNUT)) ? 1 : 0;
    assign wen5 = ((plant5Placed == 1'd1) && (plant5Type == WALNUT)) ? 1 : 0;
    assign wen6 = ((plant6Placed == 1'd1) && (plant6Type == WALNUT)) ? 1 : 0;
    assign wen7 = ((plant7Placed == 1'd1) && (plant7Type == WALNUT)) ? 1 : 0;
    // assign wen8 = ((plant8Placed == 1'd1) && (plant8Type == WALNUT)) ? 1 : 0;
    // assign wen9 = ((plant9Placed == 1'd1) && (plant9Type == WALNUT)) ? 1 : 0;
    assign wen10 = ((plant10Placed == 1'd1) && (plant10Type == WALNUT)) ? 1 : 0;
    assign wen11 = ((plant11Placed == 1'd1) && (plant11Type == WALNUT)) ? 1 : 0;
    assign wen12 = ((plant12Placed == 1'd1) && (plant12Type == WALNUT)) ? 1 : 0;
    // assign wen13 = ((plant13Placed == 1'd1) && (plant13Type == WALNUT)) ? 1 : 0;
    // assign wen14 = ((plant14Placed == 1'd1) && (plant14Type == WALNUT)) ? 1 : 0;
    assign wen15 = ((plant15Placed == 1'd1) && (plant15Type == WALNUT)) ? 1 : 0;
    assign wen16 = ((plant16Placed == 1'd1) && (plant16Type == WALNUT)) ? 1 : 0;
    assign wen17 = ((plant17Placed == 1'd1) && (plant17Type == WALNUT)) ? 1 : 0;
    // assign wen18 = ((plant18Placed == 1'd1) && (plant18Type == WALNUT)) ? 1 : 0;
    // assign wen19 = ((plant19Placed == 1'd1) && (plant19Type == WALNUT)) ? 1 : 0;
    assign wen20 = ((plant20Placed == 1'd1) && (plant20Type == WALNUT)) ? 1 : 0;
    assign wen21 = ((plant21Placed == 1'd1) && (plant21Type == WALNUT)) ? 1 : 0;
    assign wen22 = ((plant22Placed == 1'd1) && (plant22Type == WALNUT)) ? 1 : 0;
    // assign wen23 = ((plant23Placed == 1'd1) && (plant23Type == WALNUT)) ? 1 : 0;
    // assign wen24 = ((plant24Placed == 1'd1) && (plant24Type == WALNUT)) ? 1 : 0;
    
    assign sfen0 = ((plant0Placed == 1'd1) && (plant0Type == SUNFLOWER)) ? 1 : 0;
    assign sfen1 = ((plant1Placed == 1'd1) && (plant1Type == SUNFLOWER)) ? 1 : 0;
    assign sfen2 = ((plant2Placed == 1'd1) && (plant2Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen3 = ((plant3Placed == 1'd1) && (plant3Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen4 = ((plant4Placed == 1'd1) && (plant4Type == SUNFLOWER)) ? 1 : 0;
    assign sfen5 = ((plant5Placed == 1'd1) && (plant5Type == SUNFLOWER)) ? 1 : 0;
    assign sfen6 = ((plant6Placed == 1'd1) && (plant6Type == SUNFLOWER)) ? 1 : 0;
    assign sfen7 = ((plant7Placed == 1'd1) && (plant7Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen8 = ((plant8Placed == 1'd1) && (plant8Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen9 = ((plant9Placed == 1'd1) && (plant9Type == SUNFLOWER)) ? 1 : 0;
    assign sfen10 = ((plant10Placed == 1'd1) && (plant10Type == SUNFLOWER)) ? 1 : 0;
    assign sfen11 = ((plant11Placed == 1'd1) && (plant11Type == SUNFLOWER)) ? 1 : 0;
    assign sfen12 = ((plant12Placed == 1'd1) && (plant12Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen13 = ((plant13Placed == 1'd1) && (plant13Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen14 = ((plant14Placed == 1'd1) && (plant14Type == SUNFLOWER)) ? 1 : 0;
    assign sfen15 = ((plant15Placed == 1'd1) && (plant15Type == SUNFLOWER)) ? 1 : 0;
    assign sfen16 = ((plant16Placed == 1'd1) && (plant16Type == SUNFLOWER)) ? 1 : 0;
    assign sfen17 = ((plant17Placed == 1'd1) && (plant17Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen18 = ((plant18Placed == 1'd1) && (plant18Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen19 = ((plant19Placed == 1'd1) && (plant19Type == SUNFLOWER)) ? 1 : 0;
    assign sfen20 = ((plant20Placed == 1'd1) && (plant20Type == SUNFLOWER)) ? 1 : 0;
    assign sfen21 = ((plant21Placed == 1'd1) && (plant21Type == SUNFLOWER)) ? 1 : 0;
    assign sfen22 = ((plant22Placed == 1'd1) && (plant22Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen23 = ((plant23Placed == 1'd1) && (plant23Type == SUNFLOWER)) ? 1 : 0;
    // assign sfen24 = ((plant24Placed == 1'd1) && (plant24Type == SUNFLOWER)) ? 1 : 0;
    
    wire [2:0] row0Placed = {/*plant4Placed, plant3Placed,*/ plant2Placed, plant1Placed, plant0Placed};
    wire [2:0] row1Placed = {/*plant9Placed, plant8Placed,*/ plant7Placed, plant6Placed, plant5Placed};
    wire [2:0] row2Placed = {/*plant14Placed, plant13Placed, */plant12Placed, plant11Placed, plant10Placed};
    wire [2:0] row3Placed = {/*plant19Placed, plant18Placed, */plant17Placed, plant16Placed, plant15Placed};
    wire [2:0] row4Placed = {/*plant24Placed, plant23Placed, */plant22Placed, plant21Placed, plant20Placed};
    
    always @ (*)
	 begin
         case (row0Placed)
            3'b1XX: begin
                plant0X = THIRD_COL_MIDDLE_X;
                    end
            5'b01X: begin
                plant0X = SECOND_COL_MIDDLE_X;
                    end
            5'b001: begin
                plant0X = FIRST_COL_MIDDLE_X;
                    end
            3'b000: begin
                plant0X = END_OF_LAWN_X;
                    end
         endcase
         case (row1Placed)
            3'b1XX: begin
                plant1X = THIRD_COL_MIDDLE_X;
                    end
            5'b01X: begin
                plant1X = SECOND_COL_MIDDLE_X;
                    end
            5'b001: begin
                plant1X = FIRST_COL_MIDDLE_X;
                    end
            3'b000: begin
                plant1X = END_OF_LAWN_X;
                    end
         endcase
         case (row2Placed)
            3'b1XX: begin
                plant2X = THIRD_COL_MIDDLE_X;
                    end
            5'b01X: begin
                plant2X = SECOND_COL_MIDDLE_X;
                    end
            5'b001: begin
                plant2X = FIRST_COL_MIDDLE_X;
                    end
            3'b000: begin
                plant2X = END_OF_LAWN_X;
                    end
         endcase
         case (row3Placed)
            3'b1XX: begin
                plant3X = THIRD_COL_MIDDLE_X;
                    end
            5'b01X: begin
                plant3X = SECOND_COL_MIDDLE_X;
                    end
            5'b001: begin
                plant3X = FIRST_COL_MIDDLE_X;
                    end
            3'b000: begin
                plant3X = END_OF_LAWN_X;
                    end
         endcase
         case (row4Placed)
            3'b1XX: begin
                plant4X = THIRD_COL_MIDDLE_X;
                    end
            5'b01X: begin
                plant4X = SECOND_COL_MIDDLE_X;
                    end
            5'b001: begin
                plant4X = FIRST_COL_MIDDLE_X;
                    end
            3'b000: begin
                plant4X = END_OF_LAWN_X;
                    end
         endcase
	 end
    
    //25 possible peashooters
    //ps[0] = head, ps[1] = black, ps[2] = steam, ps[3] = pea
    wire [3:0] peashooter0;
    wire [3:0] peashooter1;
    wire [3:0] peashooter2;
    // wire [3:0] peashooter3;
    // wire [3:0] peashooter4;
    wire [3:0] peashooter5;
    wire [3:0] peashooter6;
    wire [3:0] peashooter7;
    // wire [3:0] peashooter8;
    // wire [3:0] peashooter9;
    wire [3:0] peashooter10;
    wire [3:0] peashooter11;
    wire [3:0] peashooter12;
    // wire [3:0] peashooter13;
    // wire [3:0] peashooter14;
    wire [3:0] peashooter15;
    wire [3:0] peashooter16;
    wire [3:0] peashooter17;
    // wire [3:0] peashooter18;
    // wire [3:0] peashooter19;
    wire [3:0] peashooter20;
    wire [3:0] peashooter21;
    wire [3:0] peashooter22;
    // wire [3:0] peashooter23;
    // wire [3:0] peashooter24;
    
   
    assign pea = ( peashooter0[3]
                    || peashooter1[3]
                    || peashooter2[3]
                    // || peashooter3[3]
                    // || peashooter4[3]
                    || peashooter5[3]
                    || peashooter6[3]
                    || peashooter7[3]
                    // || peashooter8[3]
                    // || peashooter9[3]
                    || peashooter10[3]
                    || peashooter11[3]
                    || peashooter12[3]
                    // || peashooter13[3]
                    // || peashooter14[3]
                    || peashooter15[3]
                    || peashooter16[3]
                    || peashooter17[3]
                    // || peashooter18[3]
                    // || peashooter19[3]
                    || peashooter20[3]
                    || peashooter21[3]
                    || peashooter22[3]
                    // || peashooter23[3]
                    // || peashooter24[3]
                    ) ? 1 : 0;


    assign peashooterBlack = ( peashooter0[1]
                    || peashooter1[1]
                    || peashooter2[1]
                    // || peashooter3[1]
                    // || peashooter4[1]
                    || peashooter5[1]
                    || peashooter6[1]
                    || peashooter7[1]
                    // || peashooter8[1]
                    // || peashooter9[1]
                    || peashooter10[1]
                    || peashooter11[1]
                    || peashooter12[1]
                    // || peashooter13[1]
                    // || peashooter14[1]
                    || peashooter15[1]
                    || peashooter16[1]
                    || peashooter17[1]
                    // || peashooter18[1]
                    // || peashooter19[1]
                    || peashooter20[1]
                    || peashooter21[1]
                    || peashooter22[1]
                    || displayPeashooterBlack
                    // || peashooter23[1]
                    // || peashooter24[1]
                    ) ? 1 : 0;

                    

    assign peashooterHead = (peashooter0[0]
                    || peashooter1[0]
                    || peashooter2[0]
                    // || peashooter3[0]
                    // || peashooter4[0]
                    || peashooter5[0]
                    || peashooter6[0]
                    || peashooter7[0]
                    // || peashooter8[0]
                    // || peashooter9[0]
                    || peashooter10[0]
                    || peashooter11[0]
                    || peashooter12[0]
                    // || peashooter13[0]
                    // || peashooter14[0]
                    || peashooter15[0]
                    || peashooter16[0]
                    || peashooter17[0]
                    // || peashooter18[0]
                    // || peashooter19[0]
                    || peashooter20[0]
                    || peashooter21[0]
                    || peashooter22[0]
                    || displayPeashooterHead
                    // || peashooter23[0]
                    // || peashooter24[0]
                    ) ? 1 : 0;

                    

    assign peashooterStem = ( peashooter0[2]
                    || peashooter1[2]
                    || peashooter2[2]
                    // || peashooter3[2]
                    // || peashooter4[2]
                    || peashooter5[2]
                    || peashooter6[2]
                    || peashooter7[2]
                    // || peashooter8[2]
                    // || peashooter9[2]
                    || peashooter10[2]
                    || peashooter11[2]
                    || peashooter12[2]
                    // || peashooter13[2]
                    // || peashooter14[2]
                    || peashooter15[2]
                    || peashooter16[2]
                    || peashooter17[2]
                    // || peashooter18[2]
                    // || peashooter19[2]
                    || peashooter20[2]
                    || peashooter21[2]
                    || peashooter22[2]
                    // || peashooter23[2]
                    // || peashooter24[2]
                    ) ? 1 : 0;

    //25 possible sunflowers
    //sf[0] = outer, sf[1] = inner, sf[2] = face, sf[3] = stem
    wire [3:0] sunflower0;
    wire [3:0] sunflower1;
    wire [3:0] sunflower2;
    // wire [3:0] sunflower3;
    // wire [3:0] sunflower4;
    wire [3:0] sunflower5;
    wire [3:0] sunflower6;
    wire [3:0] sunflower7;
    // wire [3:0] sunflower8;
    // wire [3:0] sunflower9;
    wire [3:0] sunflower10;
    wire [3:0] sunflower11;
    wire [3:0] sunflower12;
    // wire [3:0] sunflower13;
    // wire [3:0] sunflower14;
    wire [3:0] sunflower15;
    wire [3:0] sunflower16;
    wire [3:0] sunflower17;
    // wire [3:0] sunflower18;
    // wire [3:0] sunflower19;
    wire [3:0] sunflower20;
    wire [3:0] sunflower21;
    wire [3:0] sunflower22;
    // wire [3:0] sunflower23;
    // wire [3:0] sunflower24;

    assign sunflowerFace = ( sunflower0[2]
                    || sunflower1[2]
                    || sunflower2[2]
                    // || sunflower3[2]
                    // || sunflower4[2]
                    || sunflower5[2]
                    || sunflower6[2]
                    || sunflower7[2]
                    // || sunflower8[2]
                    // || sunflower9[2]
                    || sunflower10[2]
                    || sunflower11[2]
                    || sunflower12[2]
                    // || sunflower13[2]
                    // || sunflower14[2]
                    || sunflower15[2]
                    || sunflower16[2]
                    || sunflower17[2]
                    // || sunflower18[2]
                    // || sunflower19[2]
                    || sunflower20[2]
                    || sunflower21[2]
                    || sunflower22[2]
                    || displaySunflowerFace
                    // || sunflower23[2]
                    // || sunflower24[2]
                    ) ? 1 : 0;
    
    
    assign sunflowerInner = ( sunflower0[1]
                    || sunflower1[1]
                    || sunflower2[1]
                    // || sunflower3[1]
                    // || sunflower4[1]
                    || sunflower5[1]
                    || sunflower6[1]
                    || sunflower7[1]
                    // || sunflower8[1]
                    // || sunflower9[1]
                    || sunflower10[1]
                    || sunflower11[1]
                    || sunflower12[1]
                    // || sunflower13[1]
                    // || sunflower14[1]
                    || sunflower15[1]
                    || sunflower16[1]
                    || sunflower17[1]
                    // || sunflower18[1]
                    // || sunflower19[1]
                    || sunflower20[1]
                    || sunflower21[1]
                    || sunflower22[1]
                    || displaySunflowerInner
                    // || sunflower23[1]
                    // || sunflower24[1]
                    ) ? 1 : 0;
    
    
    assign sunflowerOuter = ( sunflower0[0]
                    || sunflower1[0]
                    || sunflower2[0]
                    // || sunflower3[0]
                    // || sunflower4[0]
                    || sunflower5[0]
                    || sunflower6[0]
                    || sunflower7[0]
                    // || sunflower8[0]
                    // || sunflower9[0]
                    || sunflower10[0]
                    || sunflower11[0]
                    || sunflower12[0]
                    // || sunflower13[0]
                    // || sunflower14[0]
                    || sunflower15[0]
                    || sunflower16[0]
                    || sunflower17[0]
                    // || sunflower18[0]
                    // || sunflower19[0]
                    || sunflower20[0]
                    || sunflower21[0]
                    || sunflower22[0]
                    || displaySunflowerOuter
                    // || sunflower23[0]
                    // || sunflower24[0]
                    ) ? 1 : 0;
    

    assign sunflowerStem = ( sunflower0[3]
                    || sunflower1[3]
                    || sunflower2[3]
                    // || sunflower3[3]
                    // || sunflower4[3]
                    || sunflower5[3]
                    || sunflower6[3]
                    || sunflower7[3]
                    // || sunflower8[3]
                    // || sunflower9[3]
                    || sunflower10[3]
                    || sunflower11[3]
                    || sunflower12[3]
                    // || sunflower13[3]
                    // || sunflower14[3]
                    || sunflower15[3]
                    || sunflower16[3]
                    || sunflower17[3]
                    // || sunflower18[3]
                    // || sunflower19[3]
                    || sunflower20[3]
                    || sunflower21[3]
                    || sunflower22[3]) ? 1 : 0;
                    // || sunflower23[3]
                    // || sunflower24[3]
                    
    



    //25 possible walnuts
    //w[0] = walnut, w[1] = black, w[2] = white
    wire [2:0] walnut0;
    wire [2:0] walnut1;
    wire [2:0] walnut2;
    // wire [2:0] walnut3;
    // wire [2:0] walnut4;
    wire [2:0] walnut5;
    wire [2:0] walnut6;
    wire [2:0] walnut7;
    // wire [2:0] walnut8;
    // wire [2:0] walnut9;
    wire [2:0] walnut10;
    wire [2:0] walnut11;
    wire [2:0] walnut12;
    // wire [2:0] walnut13;
    // wire [2:0] walnut14;
    wire [2:0] walnut15;
    wire [2:0] walnut16;
    wire [2:0] walnut17;
    // wire [2:0] walnut18;
    // wire [2:0] walnut19;
    wire [2:0] walnut20;
    wire [2:0] walnut21;
    wire [2:0] walnut22;
    // wire [2:0] walnut23;
    // wire [2:0] walnut24;

    assign walnutBlack = (
              walnut0[1]
            ||  walnut1[1]
            ||  walnut2[1]
            // ||  walnut3[1]
            // ||  walnut4[1]
            ||  walnut5[1]
            ||  walnut6[1]
            ||  walnut7[1]
            // ||  walnut8[1]
            // ||  walnut9[1]
            ||  walnut10[1]
            ||  walnut11[1]
            ||  walnut12[1]
            // ||  walnut13[1]
            // ||  walnut14[1]
            ||  walnut15[1]
            ||  walnut16[1]
            ||  walnut17[1]
            // ||  walnut18[1]
            // ||  walnut19[1]
            ||  walnut20[1]
            ||  walnut21[1]
            ||  walnut22[1]
            || displayWalnutBlack
            // ||  walnut23[1]
            // ||  walnut24[1]
    ) ? 1 : 0;

    
    assign walnutWhite = (
              walnut0[2]
            ||  walnut1[2]
            ||  walnut2[2]
            // ||  walnut3[2]
            // ||  walnut4[2]
            ||  walnut5[2]
            ||  walnut6[2]
            ||  walnut7[2]
            // ||  walnut8[2]
            // ||  walnut9[2]
            ||  walnut10[2]
            ||  walnut11[2]
            ||  walnut12[2]
            // ||  walnut13[2]
            // ||  walnut14[2]
            ||  walnut15[2]
            ||  walnut16[2]
            ||  walnut17[2]
            // ||  walnut18[2]
            // ||  walnut19[2]
            ||  walnut20[2]
            ||  walnut21[2]
            ||  walnut22[2]
            || displayWalnutWhite
            // ||  walnut23[2]
            // ||  walnut24[2]
    ) ? 1 : 0;

    
    assign walnut = (
              walnut0[0]
            ||  walnut1[0]
            ||  walnut2[0]
            // ||  walnut3[0]
            // ||  walnut4[0]
            ||  walnut5[0]
            ||  walnut6[0]
            ||  walnut7[0]
            // ||  walnut8[0]
            // ||  walnut9[0]
            ||  walnut10[0]
            ||  walnut11[0]
            ||  walnut12[0]
            // ||  walnut13[0]
            // ||  walnut14[0]
            ||  walnut15[0]
            ||  walnut16[0]
            ||  walnut17[0]
            // ||  walnut18[0]
            // ||  walnut19[0]
            ||  walnut20[0]
            ||  walnut21[0]
            ||  walnut22[0]
            || displayWalnut
            // ||  walnut23[0]
            // ||  walnut24[0]
    ) ? 1 : 0;

        peashooter ps0(
    .clk(clk), .psVPosGiven(VPOS0), .psHPosGiven(HPOS0), .hCount(hCount), .vCount(vCount), .enable(psen0), .hitZombie(pen0), .pSpeed(pSpeed),
    .peashooterHead(peashooter0[0]), .peashooterBlack(peashooter0[1]), .peashooterStem(peashooter0[2]), .pea(peashooter0[3]), .peaX(peaShot0X)
    );

    peashooter ps1(.clk(clk),.psVPosGiven(VPOS1),.psHPosGiven(HPOS1),.hCount(hCount), .vCount(vCount),.enable(psen1), .hitZombie(pen1),.pSpeed(pSpeed),
    .peashooterHead(peashooter1[0]),.peashooterBlack(peashooter1[1]),.peashooterStem(peashooter1[2]),.pea(peashooter1[3]), .peaX(peaShot1X)
    );
    
    peashooter ps2(
    .clk(clk), .psVPosGiven(VPOS2), .psHPosGiven(HPOS2), .hCount(hCount), .vCount(vCount), .enable(psen2), .hitZombie(pen2),.pSpeed(pSpeed),
    .peashooterHead(peashooter2[0]), .peashooterBlack(peashooter2[1]), .peashooterStem(peashooter2[2]), .pea(peashooter2[3]), .peaX(peaShot2X)
    );
    
    // peashooter ps3(
    // .clk(clk), .psVPosGiven(VPOS3), .psHPosGiven(HPOS3), .hCount(hCount), .vCount(vCount), .enable(psen3), .hitZombie(pen3),
    // .peashooterHead(peashooter3[0]), .peashooterBlack(peashooter3[1]), .peashooterStem(peashooter3[2]), .pea(peashooter3[3]), .peaX(peaShot3X)
    // );

    // peashooter ps4(
    // .clk(clk), .psVPosGiven(VPOS4), .psHPosGiven(HPOS4), .hCount(hCount), .vCount(vCount), .enable(psen4), .hitZombie(pen4),
    // .peashooterHead(peashooter4[0]), .peashooterBlack(peashooter4[1]), .peashooterStem(peashooter4[2]), .pea(peashooter4[3]), .peaX(peaShot4X)
    // );
    
    peashooter ps5(
    .clk(clk), .psVPosGiven(VPOS5), .psHPosGiven(HPOS5), .hCount(hCount), .vCount(vCount), .enable(psen5), .hitZombie(pen5),.pSpeed(pSpeed),
    .peashooterHead(peashooter5[0]), .peashooterBlack(peashooter5[1]), .peashooterStem(peashooter5[2]), .pea(peashooter5[3]), .peaX(peaShot5X)
    );
    
    peashooter ps6(
    .clk(clk), .psVPosGiven(VPOS6), .psHPosGiven(HPOS6), .hCount(hCount), .vCount(vCount), .enable(psen6), .hitZombie(pen6),.pSpeed(pSpeed),
    .peashooterHead(peashooter6[0]), .peashooterBlack(peashooter6[1]), .peashooterStem(peashooter6[2]), .pea(peashooter6[3]), .peaX(peaShot6X)
    );
    
    peashooter ps7(
    .clk(clk), .psVPosGiven(VPOS7), .psHPosGiven(HPOS7), .hCount(hCount), .vCount(vCount), .enable(psen7), .hitZombie(pen7),.pSpeed(pSpeed),
    .peashooterHead(peashooter7[0]), .peashooterBlack(peashooter7[1]), .peashooterStem(peashooter7[2]), .pea(peashooter7[3]), .peaX(peaShot7X)
    );
    
    // peashooter ps8(
    // .clk(clk), .psVPosGiven(VPOS8), .psHPosGiven(HPOS8), .hCount(hCount), .vCount(vCount), .enable(psen8), .hitZombie(pen8),
    // .peashooterHead(peashooter8[0]), .peashooterBlack(peashooter8[1]), .peashooterStem(peashooter8[2]), .pea(peashooter8[3]), .peaX(peaShot8X)
    // );
    
    // peashooter ps9(
    // .clk(clk), .psVPosGiven(VPOS9), .psHPosGiven(HPOS9), .hCount(hCount), .vCount(vCount), .enable(psen9), .hitZombie(pen9),
    // .peashooterHead(peashooter9[0]), .peashooterBlack(peashooter9[1]), .peashooterStem(peashooter9[2]), .pea(peashooter9[3]), .peaX(peaShot9X)
    // );
    
    peashooter ps10(
    .clk(clk), .psVPosGiven(VPOS10), .psHPosGiven(HPOS10), .hCount(hCount), .vCount(vCount), .enable(psen10), .hitZombie(pen10),.pSpeed(pSpeed),
    .peashooterHead(peashooter10[0]), .peashooterBlack(peashooter10[1]), .peashooterStem(peashooter10[2]), .pea(peashooter10[3]), .peaX(peaShot10X)
    );
    
    peashooter ps11(
    .clk(clk), .psVPosGiven(VPOS11), .psHPosGiven(HPOS11), .hCount(hCount), .vCount(vCount), .enable(psen11), .hitZombie(pen11),.pSpeed(pSpeed),
    .peashooterHead(peashooter11[0]), .peashooterBlack(peashooter11[1]), .peashooterStem(peashooter11[2]), .pea(peashooter11[3]), .peaX(peaShot11X)
    );
    
    peashooter ps12(
    .clk(clk), .psVPosGiven(VPOS12), .psHPosGiven(HPOS12), .hCount(hCount), .vCount(vCount), .enable(psen12), .hitZombie(pen12),.pSpeed(pSpeed),
    .peashooterHead(peashooter12[0]), .peashooterBlack(peashooter12[1]), .peashooterStem(peashooter12[2]), .pea(peashooter12[3]), .peaX(peaShot12X)
    );
    
    // peashooter ps13(
    // .clk(clk), .psVPosGiven(VPOS13), .psHPosGiven(HPOS13), .hCount(hCount), .vCount(vCount), .enable(psen13), .hitZombie(pen13),
    // .peashooterHead(peashooter13[0]), .peashooterBlack(peashooter13[1]), .peashooterStem(peashooter13[2]), .pea(peashooter13[3]), .peaX(peaShot13X)
    // );

    // peashooter ps14(
    // .clk(clk), .psVPosGiven(VPOS14), .psHPosGiven(HPOS14), .hCount(hCount), .vCount(vCount), .enable(psen14), .hitZombie(pen14),
    // .peashooterHead(peashooter14[0]), .peashooterBlack(peashooter14[1]), .peashooterStem(peashooter14[2]), .pea(peashooter14[3]), .peaX(peaShot14X)
    // );

    peashooter ps15(
    .clk(clk), .psVPosGiven(VPOS15), .psHPosGiven(HPOS15), .hCount(hCount), .vCount(vCount), .enable(psen15), .hitZombie(pen15),.pSpeed(pSpeed),
    .peashooterHead(peashooter15[0]), .peashooterBlack(peashooter15[1]), .peashooterStem(peashooter15[2]), .pea(peashooter15[3]), .peaX(peaShot15X)
    );

    peashooter ps16(
    .clk(clk), .psVPosGiven(VPOS16), .psHPosGiven(HPOS16), .hCount(hCount), .vCount(vCount), .enable(psen16), .hitZombie(pen16),.pSpeed(pSpeed),
    .peashooterHead(peashooter16[0]), .peashooterBlack(peashooter16[1]), .peashooterStem(peashooter16[2]), .pea(peashooter16[3]), .peaX(peaShot16X)
    );

    peashooter ps17(
    .clk(clk), .psVPosGiven(VPOS17), .psHPosGiven(HPOS17), .hCount(hCount), .vCount(vCount), .enable(psen17), .hitZombie(pen17),.pSpeed(pSpeed),
    .peashooterHead(peashooter17[0]), .peashooterBlack(peashooter17[1]), .peashooterStem(peashooter17[2]), .pea(peashooter17[3]), .peaX(peaShot17X)
    );

    // peashooter ps18(
    // .clk(clk), .psVPosGiven(VPOS18), .psHPosGiven(HPOS18), .hCount(hCount), .vCount(vCount), .enable(psen18), .hitZombie(pen18),
    // .peashooterHead(peashooter18[0]), .peashooterBlack(peashooter18[1]), .peashooterStem(peashooter18[2]), .pea(peashooter18[3]), .peaX(peaShot18X)
    // );

    // peashooter ps19(
    // .clk(clk), .psVPosGiven(VPOS19), .psHPosGiven(HPOS19), .hCount(hCount), .vCount(vCount), .enable(psen19), .hitZombie(pen19),
    // .peashooterHead(peashooter19[0]), .peashooterBlack(peashooter19[1]), .peashooterStem(peashooter19[2]), .pea(peashooter19[3]), .peaX(peaShot19X)
    // );

    peashooter ps20(
    .clk(clk), .psVPosGiven(VPOS20), .psHPosGiven(HPOS20), .hCount(hCount), .vCount(vCount), .enable(psen20), .hitZombie(pen20),.pSpeed(pSpeed),
    .peashooterHead(peashooter20[0]), .peashooterBlack(peashooter20[1]), .peashooterStem(peashooter20[2]), .pea(peashooter20[3]), .peaX(peaShot20X)
    );

    peashooter ps21(
    .clk(clk), .psVPosGiven(VPOS21), .psHPosGiven(HPOS21), .hCount(hCount), .vCount(vCount), .enable(psen21), .hitZombie(pen21),.pSpeed(pSpeed),
    .peashooterHead(peashooter21[0]), .peashooterBlack(peashooter21[1]), .peashooterStem(peashooter21[2]), .pea(peashooter21[3]), .peaX(peaShot21X)
    );

    peashooter ps22(
    .clk(clk), .psVPosGiven(VPOS22), .psHPosGiven(HPOS22), .hCount(hCount), .vCount(vCount), .enable(psen22), .hitZombie(pen22),.pSpeed(pSpeed),
    .peashooterHead(peashooter22[0]), .peashooterBlack(peashooter22[1]), .peashooterStem(peashooter22[2]), .pea(peashooter22[3]), .peaX(peaShot22X)
    );

    // peashooter ps23(
    // .clk(clk), .psVPosGiven(VPOS23), .psHPosGiven(HPOS23), .hCount(hCount), .vCount(vCount), .enable(psen23), .hitZombie(pen23),
    // .peashooterHead(peashooter23[0]), .peashooterBlack(peashooter23[1]), .peashooterStem(peashooter23[2]), .pea(peashooter23[3]), .peaX(peaShot23X)
    // );

    // peashooter ps24(
    // .clk(clk), .psVPosGiven(VPOS24), .psHPosGiven(HPOS24), .hCount(hCount), .vCount(vCount), .enable(psen24), .hitZombie(pen24),
    // .peashooterHead(peashooter24[0]), .peashooterBlack(peashooter24[1]), .peashooterStem(peashooter24[2]), .pea(peashooter24[3]), .peaX(peaShot24X)
    // );

    wire sunflowerOuter;
    wire sunflowerInner;
    wire sunflowerFace;
    wire sunflowerStem; 
    wire blink;
    
    sunflower sf0(
    .clk(clk), .sfVPosGiven(VPOS0), .sfHPosGiven(HPOS0), .hCount(hCount), .vCount(vCount), .enable(sfen0), .sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower0[0]), .sunflowerInner(sunflower0[1]), .sunflowerFace(sunflower0[2]), .sunflowerStem(sunflower0[3]), .blink(blink0)
    );
    
    sunflower sf1(
    .clk(clk), .sfVPosGiven(VPOS1), .sfHPosGiven(HPOS1), .hCount(hCount), .vCount(vCount), .enable(sfen1),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower1[0]), .sunflowerInner(sunflower1[1]), .sunflowerFace(sunflower1[2]), .sunflowerStem(sunflower1[3]), .blink(blink1)
    );
    
    sunflower sf2(
    .clk(clk), .sfVPosGiven(VPOS2), .sfHPosGiven(HPOS2), .hCount(hCount), .vCount(vCount), .enable(sfen2),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower2[0]), .sunflowerInner(sunflower2[1]), .sunflowerFace(sunflower2[2]), .sunflowerStem(sunflower2[3]), .blink(blink2)
    );
    
    // sunflower sf3(
    // .clk(clk), .sfVPosGiven(VPOS3), .sfHPosGiven(HPOS3), .hCount(hCount), .vCount(vCount), .enable(sfen3),
    // .sunflowerOuter(sunflower3[0]), .sunflowerInner(sunflower3[1]), .sunflowerFace(sunflower3[2]), .sunflowerStem(sunflower3[3]), .blink(blink3)
    // );
    
    // sunflower sf4(
    // .clk(clk), .sfVPosGiven(VPOS4), .sfHPosGiven(HPOS4), .hCount(hCount), .vCount(vCount), .enable(sfen4),
    // .sunflowerOuter(sunflower4[0]), .sunflowerInner(sunflower4[1]), .sunflowerFace(sunflower4[2]), .sunflowerStem(sunflower4[3]), .blink(blink4)
    // );
    
    sunflower sf5(
    .clk(clk), .sfVPosGiven(VPOS5), .sfHPosGiven(HPOS5), .hCount(hCount), .vCount(vCount), .enable(sfen5),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower5[0]), .sunflowerInner(sunflower5[1]), .sunflowerFace(sunflower5[2]), .sunflowerStem(sunflower5[3]), .blink(blink5)
    );

    sunflower sf6(
    .clk(clk), .sfVPosGiven(VPOS6), .sfHPosGiven(HPOS6), .hCount(hCount), .vCount(vCount), .enable(sfen6),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower6[0]), .sunflowerInner(sunflower6[1]), .sunflowerFace(sunflower6[2]), .sunflowerStem(sunflower6[3]), .blink(blink6)
    );    
    
    sunflower sf7(
    .clk(clk), .sfVPosGiven(VPOS7), .sfHPosGiven(HPOS7), .hCount(hCount), .vCount(vCount), .enable(sfen7),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower7[0]), .sunflowerInner(sunflower7[1]), .sunflowerFace(sunflower7[2]), .sunflowerStem(sunflower7[3]), .blink(blink7)
    );

    // sunflower sf8(
    // .clk(clk), .sfVPosGiven(VPOS8), .sfHPosGiven(HPOS8), .hCount(hCount), .vCount(vCount), .enable(sfen8),
    // .sunflowerOuter(sunflower8[0]), .sunflowerInner(sunflower8[1]), .sunflowerFace(sunflower8[2]), .sunflowerStem(sunflower8[3]), .blink(blink8)
    // );

    // sunflower sf9(
    // .clk(clk), .sfVPosGiven(VPOS9), .sfHPosGiven(HPOS9), .hCount(hCount), .vCount(vCount), .enable(sfen9),
    // .sunflowerOuter(sunflower9[0]), .sunflowerInner(sunflower9[1]), .sunflowerFace(sunflower9[2]), .sunflowerStem(sunflower9[3]), .blink(blink9)
    // );
    
    sunflower sf10(
    .clk(clk), .sfVPosGiven(VPOS10), .sfHPosGiven(HPOS10), .hCount(hCount), .vCount(vCount), .enable(sfen10),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower10[0]), .sunflowerInner(sunflower10[1]), .sunflowerFace(sunflower10[2]), .sunflowerStem(sunflower10[3]), .blink(blink10)
    );

    sunflower sf11(
    .clk(clk), .sfVPosGiven(VPOS11), .sfHPosGiven(HPOS11), .hCount(hCount), .vCount(vCount), .enable(sfen11),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower11[0]), .sunflowerInner(sunflower11[1]), .sunflowerFace(sunflower11[2]), .sunflowerStem(sunflower11[3]), .blink(blink11)
    );

    sunflower sf12(
    .clk(clk), .sfVPosGiven(VPOS12), .sfHPosGiven(HPOS12), .hCount(hCount), .vCount(vCount), .enable(sfen12),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower12[0]), .sunflowerInner(sunflower12[1]), .sunflowerFace(sunflower12[2]), .sunflowerStem(sunflower12[3]), .blink(blink12)
    );
    
    // sunflower sf13(
    // .clk(clk), .sfVPosGiven(VPOS13), .sfHPosGiven(HPOS13), .hCount(hCount), .vCount(vCount), .enable(sfen13),
    // .sunflowerOuter(sunflower13[0]), .sunflowerInner(sunflower13[1]), .sunflowerFace(sunflower13[2]), .sunflowerStem(sunflower13[3]), .blink(blink13)
    // );

    // sunflower sf14(
    // .clk(clk), .sfVPosGiven(VPOS14), .sfHPosGiven(HPOS14), .hCount(hCount), .vCount(vCount), .enable(sfen14),
    // .sunflowerOuter(sunflower14[0]), .sunflowerInner(sunflower14[1]), .sunflowerFace(sunflower14[2]), .sunflowerStem(sunflower14[3]), .blink(blink14)
    // );

    sunflower sf15(
    .clk(clk), .sfVPosGiven(VPOS15), .sfHPosGiven(HPOS15), .hCount(hCount), .vCount(vCount), .enable(sfen15),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower15[0]), .sunflowerInner(sunflower15[1]), .sunflowerFace(sunflower15[2]), .sunflowerStem(sunflower15[3]), .blink(blink15)
    );

    sunflower sf16(
    .clk(clk), .sfVPosGiven(VPOS16), .sfHPosGiven(HPOS16), .hCount(hCount), .vCount(vCount), .enable(sfen16),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower16[0]), .sunflowerInner(sunflower16[1]), .sunflowerFace(sunflower16[2]), .sunflowerStem(sunflower16[3]), .blink(blink16)
    );

    sunflower sf17(
    .clk(clk), .sfVPosGiven(VPOS17), .sfHPosGiven(HPOS17), .hCount(hCount), .vCount(vCount), .enable(sfen17),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower17[0]), .sunflowerInner(sunflower17[1]), .sunflowerFace(sunflower17[2]), .sunflowerStem(sunflower17[3]), .blink(blink17)
    );
    
    // sunflower sf18(
    // .clk(clk), .sfVPosGiven(VPOS18), .sfHPosGiven(HPOS18), .hCount(hCount), .vCount(vCount), .enable(sfen18),
    // .sunflowerOuter(sunflower18[0]), .sunflowerInner(sunflower18[1]), .sunflowerFace(sunflower18[2]), .sunflowerStem(sunflower18[3]), .blink(blink18)
    // );

    // sunflower sf19(
    // .clk(clk), .sfVPosGiven(VPOS19), .sfHPosGiven(HPOS19), .hCount(hCount), .vCount(vCount), .enable(sfen19),
    // .sunflowerOuter(sunflower19[0]), .sunflowerInner(sunflower19[1]), .sunflowerFace(sunflower19[2]), .sunflowerStem(sunflower19[3]), .blink(blink19)
    // );

    sunflower sf20(
    .clk(clk), .sfVPosGiven(VPOS20), .sfHPosGiven(HPOS20), .hCount(hCount), .vCount(vCount), .enable(sfen20),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower20[0]), .sunflowerInner(sunflower20[1]), .sunflowerFace(sunflower20[2]), .sunflowerStem(sunflower20[3]), .blink(blink20)
    );

    sunflower sf21(
    .clk(clk), .sfVPosGiven(VPOS21), .sfHPosGiven(HPOS21), .hCount(hCount), .vCount(vCount), .enable(sfen21),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower21[0]), .sunflowerInner(sunflower21[1]), .sunflowerFace(sunflower21[2]), .sunflowerStem(sunflower21[3]), .blink(blink21)
    );

    sunflower sf22(
    .clk(clk), .sfVPosGiven(VPOS22), .sfHPosGiven(HPOS22), .hCount(hCount), .vCount(vCount), .enable(sfen22),.sfBounceSpeed(sfBounceSpeed),
    .sunflowerOuter(sunflower22[0]), .sunflowerInner(sunflower22[1]), .sunflowerFace(sunflower22[2]), .sunflowerStem(sunflower22[3]), .blink(blink22)
    );

    // sunflower sf23(
    // .clk(clk), .sfVPosGiven(VPOS23), .sfHPosGiven(HPOS23), .hCount(hCount), .vCount(vCount), .enable(sfen23),
    // .sunflowerOuter(sunflower23[0]), .sunflowerInner(sunflower23[1]), .sunflowerFace(sunflower23[2]), .sunflowerStem(sunflower23[3]), .blink(blink23)
    // );

    // sunflower sf24(
    // .clk(clk), .sfVPosGiven(VPOS24), .sfHPosGiven(HPOS24), .hCount(hCount), .vCount(vCount), .enable(sfen24),
    // .sunflowerOuter(sunflower24[0]), .sunflowerInner(sunflower24[1]), .sunflowerFace(sunflower24[2]), .sunflowerStem(sunflower24[3]), .blink(blink24)
    // );

    wire walnut;
    wire walnutBlack;
    wire walnutWhite;
    
    walnut w0(
	.wVPosGiven(VPOS0), .wHPosGiven(HPOS0), .hCount(hCount), .vCount(vCount), .blink(blink0),
    .enable(wen0), .walnut(walnut0[0]), .walnutBlack(walnut0[1]), .walnutWhite(walnut0[2])
    );
    
    walnut w1(
	.wVPosGiven(VPOS1), .wHPosGiven(HPOS1), .hCount(hCount), .vCount(vCount), .blink(blink1),
    .enable(wen1), .walnut(walnut1[0]), .walnutBlack(walnut1[1]), .walnutWhite(walnut1[2])
    );
    
    walnut w2(
	.wVPosGiven(VPOS2), .wHPosGiven(HPOS2), .hCount(hCount), .vCount(vCount), .blink(blink2),
    .enable(wen2), .walnut(walnut2[0]), .walnutBlack(walnut2[1]), .walnutWhite(walnut2[2])
    );
    
    // walnut w3(
	// .wVPosGiven(VPOS3), .wHPosGiven(HPOS3), .hCount(hCount), .vCount(vCount), .blink(blink3),
    // .enable(wen3), .walnut(walnut3[0]), .walnutBlack(walnut3[1]), .walnutWhite(walnut3[2])
    // );
    
    // walnut w4(
	// .wVPosGiven(VPOS4), .wHPosGiven(HPOS4), .hCount(hCount), .vCount(vCount), .blink(blink4),
    // .enable(wen4), .walnut(walnut4[0]), .walnutBlack(walnut4[1]), .walnutWhite(walnut4[2])
    // );
    
    walnut w5(
	.wVPosGiven(VPOS5), .wHPosGiven(HPOS5), .hCount(hCount), .vCount(vCount), .blink(blink5),
    .enable(wen5), .walnut(walnut5[0]), .walnutBlack(walnut5[1]), .walnutWhite(walnut5[2])
    );
    
    walnut w6(
	.wVPosGiven(VPOS6), .wHPosGiven(HPOS6), .hCount(hCount), .vCount(vCount), .blink(blink6),
    .enable(wen6), .walnut(walnut6[0]), .walnutBlack(walnut6[1]), .walnutWhite(walnut6[2])
    );
    
    walnut w7(
	.wVPosGiven(VPOS7), .wHPosGiven(HPOS7), .hCount(hCount), .vCount(vCount), .blink(blink7),
    .enable(wen7), .walnut(walnut7[0]), .walnutBlack(walnut7[1]), .walnutWhite(walnut7[2])
    );
    
    // walnut w8(
	// .wVPosGiven(VPOS8), .wHPosGiven(HPOS8), .hCount(hCount), .vCount(vCount), .blink(blink8),
    // .enable(wen8), .walnut(walnut8[0]), .walnutBlack(walnut8[1]), .walnutWhite(walnut8[2])
    // );
    
    // walnut w9(
	// .wVPosGiven(VPOS9), .wHPosGiven(HPOS9), .hCount(hCount), .vCount(vCount), .blink(blink9),
    // .enable(wen9), .walnut(walnut9[0]), .walnutBlack(walnut9[1]), .walnutWhite(walnut9[2])
    // );
    
    walnut w10(
	.wVPosGiven(VPOS10), .wHPosGiven(HPOS10), .hCount(hCount), .vCount(vCount), .blink(blink10),
    .enable(wen10), .walnut(walnut10[0]), .walnutBlack(walnut10[1]), .walnutWhite(walnut10[2])
    );
    
    walnut w11(
	.wVPosGiven(VPOS11), .wHPosGiven(HPOS11), .hCount(hCount), .vCount(vCount), .blink(blink11),
    .enable(wen11), .walnut(walnut11[0]), .walnutBlack(walnut11[1]), .walnutWhite(walnut11[2])
    );
    
    walnut w12(
	.wVPosGiven(VPOS12), .wHPosGiven(HPOS12), .hCount(hCount), .vCount(vCount), .blink(blink12),
    .enable(wen12), .walnut(walnut12[0]), .walnutBlack(walnut12[1]), .walnutWhite(walnut12[2])
    );
    
    // walnut w13(
	// .wVPosGiven(VPOS13), .wHPosGiven(HPOS13), .hCount(hCount), .vCount(vCount), .blink(blink13),
    // .enable(wen13), .walnut(walnut13[0]), .walnutBlack(walnut13[1]), .walnutWhite(walnut13[2])
    // );
    
    // walnut w14(
	// .wVPosGiven(VPOS14), .wHPosGiven(HPOS14), .hCount(hCount), .vCount(vCount), .blink(blink14),
    // .enable(wen14), .walnut(walnut14[0]), .walnutBlack(walnut14[1]), .walnutWhite(walnut14[2])
    // );
    
    walnut w15(
	.wVPosGiven(VPOS15), .wHPosGiven(HPOS15), .hCount(hCount), .vCount(vCount), .blink(blink15),
    .enable(wen15), .walnut(walnut15[0]), .walnutBlack(walnut15[1]), .walnutWhite(walnut15[2])
    );
    
    walnut w16(
	.wVPosGiven(VPOS16), .wHPosGiven(HPOS16), .hCount(hCount), .vCount(vCount), .blink(blink16),
    .enable(wen16), .walnut(walnut16[0]), .walnutBlack(walnut16[1]), .walnutWhite(walnut16[2])
    );
    
    walnut w17(
	.wVPosGiven(VPOS17), .wHPosGiven(HPOS17), .hCount(hCount), .vCount(vCount), .blink(blink17),
    .enable(wen17), .walnut(walnut17[0]), .walnutBlack(walnut17[1]), .walnutWhite(walnut17[2])
    );
    
    // walnut w18(
	// .wVPosGiven(VPOS18), .wHPosGiven(HPOS18), .hCount(hCount), .vCount(vCount), .blink(blink18),
    // .enable(wen18), .walnut(walnut18[0]), .walnutBlack(walnut18[1]), .walnutWhite(walnut18[2])
    // );
    
    // walnut w19(
	// .wVPosGiven(VPOS19), .wHPosGiven(HPOS19), .hCount(hCount), .vCount(vCount), .blink(blink19),
    // .enable(wen19), .walnut(walnut19[0]), .walnutBlack(walnut19[1]), .walnutWhite(walnut19[2])
    // );
    
    walnut w20(
	.wVPosGiven(VPOS20), .wHPosGiven(HPOS20), .hCount(hCount), .vCount(vCount), .blink(blink20),
    .enable(wen20), .walnut(walnut20[0]), .walnutBlack(walnut20[1]), .walnutWhite(walnut20[2])
    );
    
    walnut w21(
	.wVPosGiven(VPOS21), .wHPosGiven(HPOS21), .hCount(hCount), .vCount(vCount), .blink(blink21),
    .enable(wen21), .walnut(walnut21[0]), .walnutBlack(walnut21[1]), .walnutWhite(walnut21[2])
    );
    
    walnut w22(
	.wVPosGiven(VPOS22), .wHPosGiven(HPOS22), .hCount(hCount), .vCount(vCount), .blink(blink22),
    .enable(wen22), .walnut(walnut22[0]), .walnutBlack(walnut22[1]), .walnutWhite(walnut22[2])
    );
    
    // walnut w23(
	// .wVPosGiven(VPOS23), .wHPosGiven(HPOS23), .hCount(hCount), .vCount(vCount), .blink(blink23),
    // .enable(wen23), .walnut(walnut23[0]), .walnutBlack(walnut23[1]), .walnutWhite(walnut23[2])
    // );
    
    // walnut w24(
	// .wVPosGiven(VPOS24), .wHPosGiven(HPOS24), .hCount(hCount), .vCount(vCount), .blink(blink24),
    // .enable(wen24), .walnut(walnut24[0]), .walnutBlack(walnut24[1]), .walnutWhite(walnut24[2])
    // );

    always@ (posedge clk)
        begin
            sunTimer = sunTimer + 1'd1;
            if (sunTimer >= (SECS_BETWEEN_SUNS * 50'd100000000))
            begin
                sunTimer = 50'd0;
                
                if (numSuns < 16'd2000)
                    numSuns = numSuns + 16'd25;
            end
        end
 
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
				    youLose = 1'b1;
//					state = DoneL;
//					reset = 1'b1; //TODO I dont think you need to keep track of num zombies killed
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
			if (peaShot0X == zombie0X || peaShot1X == zombie0X || peaShot2X == zombie0X /*|| peaShot3X == zombie0X || peaShot4X == zombie0X*/)
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
			if (peaShot5X == zombie1X || peaShot6X == zombie1X || peaShot7X == zombie1X /*|| peaShot8X == zombie1X || peaShot9X == zombie1X*/)
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
			if (peaShot10X == zombie2X || peaShot11X == zombie2X || peaShot12X == zombie2X /*|| peaShot13X == zombie2X || peaShot14X == zombie2X*/)
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
			if (peaShot15X == zombie3X || peaShot16X == zombie3X || peaShot17X == zombie3X /*|| peaShot18X == zombie3X || peaShot19X == zombie3X*/)
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
			if (peaShot20X == zombie4X || peaShot21X == zombie4X || peaShot22X == zombie4X /*|| peaShot23X == zombie4X || peaShot24X == zombie4X*/)
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
			if(zombies_killed == 4'd5 && state == L1)
				begin
				    youWin = 1'b1;
//					state = NL2;
//					reset = 1'b1;
				end
			end
		end

    assign youLose_RED = (youLose == 1'b1) ? 1 : 0;
    assign youWin_BLUE = (youWin == 1'b1) ? 1 : 0;

	//Always at the posedge of the clock, if the zombie is in the same position as the plant, stop the zombie and "eat" the plant
	always@ (posedge clk)
	begin
		if(zombie0X == plant0X)
			zombie0Stopped = 1'b1;
			//Have some type of counter to see how long the zombie has been with the plant
			zombie0Counter = zombie0Counter + 1'd1;
			if((zombie0Counter == TO_KILL_PEA) ) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
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
                    // else if(zombie0X == FOURTH_COL_MIDDLE_X)
                    //     begin
                    //         plant3Placed = 1'b0;
                    //     end
                    // else if(zombie0X == FIFTH_COL_MIDDLE_X)
                    //     begin
                    //         plant4Placed = 1'b0;
                    //     end
					zombie0Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					// if(plant4Placed == 1)
					// begin
					// 	plant0X = 10'd750;
					// end
					
					// else if(plant3Placed == 1)
					// begin
					// 	plant0X = 10'd650;
					// end
					
					// else if(plant2Placed == 1)
					// begin
					// 	plant0X = 10'd550;
					// end
					
					// else if(plant1Placed == 1)
					// begin
					// 	plant0X = 10'd450;
					// end
					
					// else if(plant0Placed == 1)
					// begin
					// 	plant0X = 10'd350;
					// end
					
					// else
					// begin
					// 	plant0X = 10'd0;
					// end
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
			if((zombie1Counter == TO_KILL_PEA) ) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
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
                    // else if(zombie1X == FOURTH_COL_MIDDLE_X)
                    //     begin
                    //         plant8Placed = 1'b0;
                    //     end
                    // else if(zombie1X == FIFTH_COL_MIDDLE_X)
                    //     begin
                    //         plant9Placed = 1'b0;
                    //     end
					//Set the plant placed back to 0
					zombie1Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					// if(plant4Placed == 1)
					// begin
					// 	plant1X = 10'd750;
					// end
					
					// else if(plant3Placed == 1)
					// begin
					// 	plant1X = 10'd650;
					// end
					
					// else if(plant2Placed == 1)
					// begin
					// 	plant1X = 10'd550;
					// end
					
					// else if(plant1Placed == 1)
					// begin
					// 	plant1X = 10'd450;
					// end
					
					// else if(plant0Placed == 1)
					// begin
					// 	plant1X = 10'd350;
					// end
					
					// else
					// begin
					// 	plant1X = 10'd0;
					// end
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
			if((zombie2Counter == TO_KILL_PEA)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
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
                    // else if(zombie2X == FOURTH_COL_MIDDLE_X)
                    //     begin
                    //         plant13Placed = 1'b0;
                    //     end
                    // else if(zombie2X == FIFTH_COL_MIDDLE_X)
                    //     begin
                    //         plant14Placed = 1'b0;
                    //     end
					//Set the plant placed back to 0
					zombie2Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					// if(plant4Placed == 1)
					// begin
					// 	plant2X = 10'd750;
					// end
					
					// else if(plant3Placed == 1)
					// begin
					// 	plant2X = 10'd650;
					// end
					
					// else if(plant2Placed == 1)
					// begin
					// 	plant2X = 10'd550;
					// end
					
					// else if(plant1Placed == 1)
					// begin
					// 	plant2X = 10'd450;
					// end
					
					// else if(plant0Placed == 1)
					// begin
					// 	plant2X = 10'd350;
					// end
					
					// else
					// begin
					// 	plant2X = 10'd0;
					// end
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
			if((zombie3Counter == TO_KILL_PEA)) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
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
                    // else if(zombie3X == FOURTH_COL_MIDDLE_X)
                    //     begin
                    //         plant18Placed = 1'b0;
                    //     end
                    // else if(zombie3X == FIFTH_COL_MIDDLE_X)
                    //     begin
                    //         plant19Placed = 1'b0;
                    //     end

					//Set the plant placed back to 0
					zombie3Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					// if(plant4Placed == 1)
					// begin
					// 	plant3X = 10'd750;
					// end
					
					// else if(plant3Placed == 1)
					// begin
					// 	plant3X = 10'd650;
					// end
					
					// else if(plant2Placed == 1)
					// begin
					// 	plant3X = 10'd550;
					// end
					
					// else if(plant1Placed == 1)
					// begin
					// 	plant3X = 10'd450;
					// end
					
					// else if(plant0Placed == 1)
					// begin
					// 	plant3X = 10'd350;
					// end
					
					// else
					// begin
					// 	plant3X = 10'd0;
					// end
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
			if((zombie4Counter == TO_KILL_PEA) ) //TO DO, EDIT HOW LONG THE ZOMBIE NEEDS TO BE WITH THE PLANT FOR
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
                    // else if(zombie4X == FOURTH_COL_MIDDLE_X)
                    //     begin
                    //         plant23Placed = 1'b0;
                    //     end
                    // else if(zombie4X == FIFTH_COL_MIDDLE_X)
                    //     begin
                    //         plant24Placed = 1'b0;
                    //     end
					//Set the plant placed back to 0
					zombie4Counter = 1'd0;
					//Compute the new position of the rightmost plant by iterating through the plant placements in this row
					// if(plant4Placed == 1)
					// begin
					// 	plant4X = 10'd750;
					// end
					
					// else if(plant3Placed == 1)
					// begin
					// 	plant4X = 10'd650;
					// end
					
					// else if(plant2Placed == 1)
					// begin
					// 	plant4X = 10'd550;
					// end
					
					// else if(plant1Placed == 1)
					// begin
					// 	plant4X = 10'd450;
					// end
					
					// else if(plant0Placed == 1)
					// begin
					// 	plant4X = 10'd350;
					// end
					
					// else
					// begin
					// 	plant4X = 10'd0;
					// end
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
		
		if (selectButtonCounter == 4'd0)
            begin
                //Reset the selected grid box
				selectedGridBoxX = 10'd350;
				selectedGridBoxY = 10'd130;
				selectedPlantBoxX = FIRST_COL_MIDDLE_X;
//                selectedGridBoxX = FIRST_COL_MIDDLE_X;
//                selectedGridBoxY = 10'd130; //May need to change 87 to 86
				
				//Reset the selection flag
				isSelectingLawnPosition = 1'b0;
				selectButtonCounter = 4'd0;
            end
		// if((selectButton == 1'b1) && (isSelectingPlantBox == 1'b0) && (isSelectingLawnPosition == 1'b0))
		else if(selectButtonCounter == 4'd1)
			begin
				isSelectingPlantBox = 1'b1;
				//Assign the X coordinate of the selected plant box to the middle of the upper left square
//				selectedPlantBoxX = FIRST_COL_MIDDLE_X;

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
//				selectedPlantBoxX = FIRST_COL_MIDDLE_X;
//                selectedGridBoxX = FIRST_COL_MIDDLE_X;
//                selectedGridBoxY = 10'd130; //May need to change 87 to 86
			
		
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
                    plant0Type = userPlantSelection;
				end
                
                else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd130)
				begin
                    plant1Placed = 2'd01;
                    plant1Type = userPlantSelection;
				end
                
                else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd130)
				begin
                    plant2Placed = 2'd01;
                    plant2Type = userPlantSelection;
				end
                
                // else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd130)
				// begin
                //     plant3Placed = 2'd01;
                //     plant3Type = userPlantSelection;
				// end
                
                // else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd130)
				// begin
                //     plant4Placed = 2'd01;
                //     plant4Type = userPlantSelection;
				// end

				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd217)
				begin
					plant5Placed = 2'd01;
                    plant5Type = userPlantSelection;
				end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd217)
				begin
					plant6Placed = 2'd01;
                    plant6Type = userPlantSelection;
					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd217)
				begin
					plant7Placed = 2'd01;
                    plant7Type = userPlantSelection;
					end
				// else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd217)
				// begin
				// 	plant8Placed = 2'd01;
                //     plant8Type = userPlantSelection;
				// 	end
				// else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd217)
				// begin
				// 	plant9Placed = 2'd01;
                //     plant9Type = userPlantSelection;
				// 	end
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd304)
				begin
					plant10Placed = 2'd01;
                    plant10Type = userPlantSelection;
					end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd304)
				begin
					plant11Placed = 2'd01;
                    plant11Type = userPlantSelection;
					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd304)
				begin
					plant12Placed = 2'd01;
                    plant12Type = userPlantSelection;
					end
				// else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd304)
				// begin
				// 	plant13Placed = 2'd01;
                //     plant13Type = userPlantSelection;
				// 	end
				// else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd304)
				// begin
				// 	plant14Placed = 2'd01;
                //     plant14Type = userPlantSelection;
				// 	end
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd391)
				begin
					plant15Placed = 2'd01;
                    plant15Type = userPlantSelection;
					end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd391)
				begin
					plant16Placed = 2'd01;
                    plant16Type = userPlantSelection;

					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd391)
				begin
					plant17Placed = 2'd01;
                    plant17Type = userPlantSelection;
					end
				// else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd391)
				// begin
				// 	plant18Placed = 2'd01;
                //     plant18Type = userPlantSelection;
				// 	end
				// else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd391)
				// begin
				// 	plant19Placed = 2'd01;
                //     plant19Type = userPlantSelection;
				// 	end
				else if(selectedGridBoxX == 10'd350 && selectedGridBoxY == 10'd478)
				begin
					plant20Placed = 2'd01;
                    plant20Type = userPlantSelection;
					end
				else if(selectedGridBoxX == 10'd450 && selectedGridBoxY == 10'd478)
				begin
					plant21Placed = 2'd01;
                    plant21Type = userPlantSelection;
					end
				else if(selectedGridBoxX == 10'd550 && selectedGridBoxY == 10'd478)
				begin
					plant22Placed = 2'd01;
                    plant22Type = userPlantSelection;
					end
				// else if(selectedGridBoxX == 10'd650 && selectedGridBoxY == 10'd478)
				// begin
				// 	plant23Placed = 2'd01;
                //     plant23Type = userPlantSelection;
				// 	end
				// else if(selectedGridBoxX == 10'd750 && selectedGridBoxY == 10'd478)
				// begin
				// 	plant24Placed = 2'd01;
                //     plant24Type = userPlantSelection;
				// end

				//Reset the selected grid box
				selectedGridBoxX = 10'd350;
				selectedGridBoxY = 10'd130;
				selectedPlantBoxX = FIRST_COL_MIDDLE_X;
//                selectedGridBoxX = FIRST_COL_MIDDLE_X;
//                selectedGridBoxY = 10'd130; //May need to change 87 to 86
				
				//Reset the selection flag
				isSelectingLawnPosition = 1'b0;
				selectButtonCounter = 4'd0;

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

	//Define the selected grid box
	// assign selectedLawnPositionOutline = (
	// 	//Horizontal lines


	// 	//Vertical lines
	// 	((vCount >= ROW_HEIGHT)

	// )

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
//Using the zombie body width, create the zombie body in the lower part of the row
    assign zombieBody0 = ((vCount >= ZOMBIE_0_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_0_ROW_BOTTOM)
        && (hCount >= zombie0X + 4'd10) && (hCount <= zombie0X + ZOMBIE_BODY_WIDTH + 4'd10)
        ) ? 1 : 0;
    assign zombieBody1 = ((vCount >= ZOMBIE_1_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_1_ROW_BOTTOM)
        && (hCount >= zombie1X + 4'd10) && (hCount <= zombie1X + ZOMBIE_BODY_WIDTH + 4'd10)
        ) ? 1 : 0;
    assign zombieBody2 = ((vCount >= ZOMBIE_2_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_2_ROW_BOTTOM)
        && (hCount >= zombie2X + 4'd10) && (hCount <= zombie2X + ZOMBIE_BODY_WIDTH + 4'd10)
        ) ? 1 : 0;
    assign zombieBody3 = ((vCount >= ZOMBIE_3_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_3_ROW_BOTTOM)
        && (hCount >= zombie3X + 4'd10) && (hCount <= zombie3X + ZOMBIE_BODY_WIDTH + 4'd10)
        ) ? 1 : 0;
    assign zombieBody4 = ((vCount >= ZOMBIE_4_ROW_BOTTOM - ZOMBIE_BODY_HEIGHT) && (vCount <= ZOMBIE_4_ROW_BOTTOM)
        && (hCount >= zombie4X + 4'd10) && (hCount <= zombie4X + ZOMBIE_BODY_WIDTH + 4'd10)
        ) ? 1 : 0;
        
    
parameter ZOMBIE_HEAD_SCALE = 10'd2;
parameter ZOMBIE_EYE_SCALE = 10'd4;

assign zombieHead0 = (((vCount >= (zombie0HeadY + 10'd60)) && (vCount <= (zombie0HeadY + 10'd60 + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd3 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd6 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd9 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd14 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd12 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd15 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd20 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd18 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd21 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd26 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
        
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd24 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd29 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd27 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd32 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd30 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd35 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd33 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd38 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd36 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd41 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd39 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd44 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd42 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd47 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd45 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd50 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd48 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd53 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX)) && (hCount <= (zombie0HeadX + (10'd75 / ZOMBIE_HEAD_SCALE))))
                           
                                     
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd51 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd56 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd54 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd59 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd57 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd62 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd60 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd65 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd63 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd68 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd66 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd71 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd69 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd74 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd72 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd77 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd75 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd80 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd78 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd83 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd81 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd86 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd84 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd89 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd87 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd92 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd90 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd95 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd93 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd98 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd96 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd101 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie0HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie0HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
);

assign zombieEye0 = (((vCount >= (zombie0HeadY + 10'd60)) && (vCount <= (zombie0HeadY + 10'd60 + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd3 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd6 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd9 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd14 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd12 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd15 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd20 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd18 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd21 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd26 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
        
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd24 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd29 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd27 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd32 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd30 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd35 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd33 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd38 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd36 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd41 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd39 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd44 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd42 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd47 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd45 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd50 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd48 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd53 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX)) && (hCount <= (zombie0HeadX + (10'd75 / ZOMBIE_EYE_SCALE))))
                           
                                     
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd51 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd56 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd54 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd59 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd57 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd62 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd60 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd65 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd63 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd68 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd66 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd71 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd69 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd74 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd72 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd77 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd75 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd80 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd78 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd83 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd81 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd86 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd84 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd89 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd87 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd92 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd90 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd95 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd93 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd98 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie0HeadY + 10'd60 + (10'd96 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie0HeadY + 10'd60 + (10'd101 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie0HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie0HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
);

assign zombieHead1 = (((vCount >= (zombie1HeadY + 10'd60)) && (vCount <= (zombie1HeadY + 10'd60 + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd3 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd6 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd9 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd14 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd12 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd15 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd20 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd18 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd21 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd26 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
        
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd24 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd29 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd27 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd32 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd30 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd35 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd33 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd38 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd36 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd41 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd39 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd44 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd42 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd47 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd45 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd50 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd48 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd53 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX)) && (hCount <= (zombie1HeadX + (10'd75 / ZOMBIE_HEAD_SCALE))))
                           
                                     
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd51 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd56 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd54 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd59 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd57 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd62 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd60 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd65 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd63 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd68 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd66 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd71 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd69 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd74 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd72 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd77 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd75 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd80 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd78 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd83 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd81 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd86 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd84 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd89 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd87 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd92 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd90 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd95 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd93 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd98 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd96 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd101 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie1HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie1HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
);

assign zombieEye1 = (((vCount >= (zombie1HeadY + 10'd60)) && (vCount <= (zombie1HeadY + 10'd60 + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd3 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd6 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd9 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd14 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd12 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd15 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd20 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd18 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd21 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd26 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
        
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd24 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd29 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd27 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd32 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd30 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd35 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd33 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd38 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd36 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd41 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd39 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd44 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd42 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd47 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd45 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd50 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd48 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd53 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX)) && (hCount <= (zombie1HeadX + (10'd75 / ZOMBIE_EYE_SCALE))))
                           
                                     
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd51 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd56 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd54 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd59 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd57 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd62 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd60 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd65 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd63 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd68 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd66 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd71 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd69 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd74 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd72 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd77 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd75 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd80 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd78 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd83 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd81 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd86 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd84 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd89 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd87 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd92 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd90 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd95 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd93 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd98 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie1HeadY + 10'd60 + (10'd96 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie1HeadY + 10'd60 + (10'd101 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie1HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie1HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
);

assign zombieHead2 = (((vCount >= (zombie2HeadY + 10'd60)) && (vCount <= (zombie2HeadY + 10'd60 + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd3 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd6 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd9 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd14 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd12 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd15 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd20 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd18 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd21 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd26 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
        
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd24 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd29 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd27 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd32 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd30 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd35 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd33 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd38 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd36 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd41 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd39 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd44 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd42 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd47 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd45 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd50 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd48 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd53 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX)) && (hCount <= (zombie2HeadX + (10'd75 / ZOMBIE_HEAD_SCALE))))
                           
                                     
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd51 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd56 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd54 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd59 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd57 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd62 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd60 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd65 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd63 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd68 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd66 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd71 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd69 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd74 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd72 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd77 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd75 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd80 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd78 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd83 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd81 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd86 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd84 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd89 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd87 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd92 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd90 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd95 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd93 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd98 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd96 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd101 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie2HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie2HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
);

assign zombieEye2 = (((vCount >= (zombie2HeadY + 10'd60)) && (vCount <= (zombie2HeadY + 10'd60 + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd3 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd6 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd9 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd14 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd12 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd15 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd20 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd18 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd21 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd26 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
        
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd24 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd29 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd27 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd32 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd30 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd35 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd33 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd38 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd36 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd41 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd39 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd44 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd42 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd47 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd45 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd50 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd48 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd53 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX)) && (hCount <= (zombie2HeadX + (10'd75 / ZOMBIE_EYE_SCALE))))
                           
                                     
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd51 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd56 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd54 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd59 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd57 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd62 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd60 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd65 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd63 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd68 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd66 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd71 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd69 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd74 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd72 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd77 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd75 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd80 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd78 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd83 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd81 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd86 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd84 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd89 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd87 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd92 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd90 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd95 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd93 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd98 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie2HeadY + 10'd60 + (10'd96 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie2HeadY + 10'd60 + (10'd101 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie2HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie2HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
);

assign zombieHead3 = (((vCount >= (zombie3HeadY + 10'd60)) && (vCount <= (zombie3HeadY + 10'd60 + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd3 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd6 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd9 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd14 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd12 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd15 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd20 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd18 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd21 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd26 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
        
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd24 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd29 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd27 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd32 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd30 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd35 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd33 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd38 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd36 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd41 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd39 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd44 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd42 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd47 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd45 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd50 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd48 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd53 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX)) && (hCount <= (zombie3HeadX + (10'd75 / ZOMBIE_HEAD_SCALE))))
                           
                                     
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd51 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd56 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd54 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd59 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd57 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd62 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd60 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd65 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd63 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd68 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd66 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd71 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd69 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd74 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd72 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd77 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd75 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd80 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd78 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd83 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd81 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd86 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd84 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd89 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd87 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd92 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd90 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd95 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd93 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd98 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd96 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd101 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie3HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie3HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
);

assign zombieEye3 = (((vCount >= (zombie3HeadY + 10'd60)) && (vCount <= (zombie3HeadY + 10'd60 + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd3 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd6 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd9 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd14 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd12 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd15 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd20 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd18 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd21 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd26 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
        
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd24 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd29 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd27 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd32 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd30 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd35 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd33 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd38 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd36 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd41 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd39 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd44 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd42 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd47 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd45 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd50 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd48 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd53 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX)) && (hCount <= (zombie3HeadX + (10'd75 / ZOMBIE_EYE_SCALE))))
                           
                                     
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd51 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd56 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd54 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd59 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd57 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd62 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd60 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd65 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd63 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd68 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd66 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd71 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd69 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd74 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd72 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd77 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd75 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd80 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd78 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd83 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd81 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd86 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd84 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd89 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd87 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd92 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd90 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd95 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd93 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd98 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie3HeadY + 10'd60 + (10'd96 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie3HeadY + 10'd60 + (10'd101 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie3HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie3HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
);

assign zombieHead4 = (((vCount >= (zombie4HeadY + 10'd60)) && (vCount <= (zombie4HeadY + 10'd60 + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd3 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd6 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd9 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd14 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd12 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd15 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd20 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd18 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd21 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd26 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
        
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd24 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd29 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd27 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd32 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd30 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd35 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd33 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd38 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd36 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd41 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd39 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd44 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd42 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd47 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd45 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd50 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd48 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd53 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX)) && (hCount <= (zombie4HeadX + (10'd75 / ZOMBIE_HEAD_SCALE))))
                           
                                     
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd51 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd56 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd54 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd59 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd57 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd62 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd60 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd65 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd63 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd68 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd66 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd71 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd69 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd74 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd72 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd77 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd75 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd80 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd78 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd83 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd81 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd86 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd84 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd89 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd87 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd92 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd90 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd95 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd93 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd98 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd96 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd101 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombie4HeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombie4HeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
);

assign zombieEye4 = (((vCount >= (zombie4HeadY + 10'd60)) && (vCount <= (zombie4HeadY + 10'd60 + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd3 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd6 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd9 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd14 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd12 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd15 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd20 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd18 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd21 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd26 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
        
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd24 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd29 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd27 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd32 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd30 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd35 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd33 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd38 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd36 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd41 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd39 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd44 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd42 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd47 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd45 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd50 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd48 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd53 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX)) && (hCount <= (zombie4HeadX + (10'd75 / ZOMBIE_EYE_SCALE))))
                           
                                     
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd51 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd56 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd54 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd59 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd57 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd62 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd60 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd65 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd63 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd68 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd66 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd71 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd69 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd74 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd72 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd77 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd75 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd80 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd78 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd83 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd81 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd86 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd84 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd89 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd87 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd92 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd90 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd95 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd93 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd98 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombie4HeadY + 10'd60 + (10'd96 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombie4HeadY + 10'd60 + (10'd101 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombie4HeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombie4HeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
);
        
//    parameter WSCALE = 10'd3;
    parameter displayWHpos = 10'd520;
    parameter displayWVpos = 10'd40; 
    assign displayWalnut = 
	               (
                    (
	               ((vCount >= displayWVpos) && (vCount <= (displayWVpos + (10'd5 / WSCALE))) && (hCount >= (displayWHpos + (10'd27 / WSCALE))) && (hCount <= (displayWHpos + (10'd48 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd3 / WSCALE))) && (vCount <= (displayWVpos + (10'd8 / WSCALE))) && (hCount >= (displayWHpos + (10'd23 / WSCALE))) && (hCount <= (displayWHpos + (10'd52 / WSCALE) / WSCALE)))
	               
	               ||((vCount >= (displayWVpos + (10'd6 / WSCALE))) && (vCount <= (displayWVpos + (10'd11 / WSCALE))) && (hCount >= (displayWHpos + (10'd19 / WSCALE))) && (hCount <= (displayWHpos + (10'd56 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd9 / WSCALE))) && (vCount <= (displayWVpos + (10'd14 / WSCALE))) && (hCount >= (displayWHpos + (10'd17 / WSCALE))) && (hCount <= (displayWHpos + (10'd58 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd12 / WSCALE))) && (vCount <= (displayWVpos + (10'd17 / WSCALE))) && (hCount >= (displayWHpos + (10'd15 / WSCALE))) && (hCount <= (displayWHpos + (10'd60 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd15 / WSCALE))) && (vCount <= (displayWVpos + (10'd20 / WSCALE))) && (hCount >= (displayWHpos + (10'd13 / WSCALE))) && (hCount <= (displayWHpos + (10'd62 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd18 / WSCALE))) && (vCount <= (displayWVpos + (10'd23 / WSCALE))) && (hCount >= (displayWHpos + (10'd11 / WSCALE))) && (hCount <= (displayWHpos + (10'd64 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd21 / WSCALE))) && (vCount <= (displayWVpos + (10'd26 / WSCALE))) && (hCount >= (displayWHpos + (10'd9 / WSCALE))) && (hCount <= (displayWHpos + (10'd66 / WSCALE))))

	               ||((vCount >= (displayWVpos + (10'd24 / WSCALE))) && (vCount <= (displayWVpos + (10'd29 / WSCALE))) && (hCount >= (displayWHpos + (10'd8 / WSCALE))) && (hCount <= (displayWHpos + (10'd67 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd27 / WSCALE))) && (vCount <= (displayWVpos + (10'd32 / WSCALE))) && (hCount >= (displayWHpos + (10'd7 / WSCALE))) && (hCount <= (displayWHpos + (10'd68 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd30 / WSCALE))) && (vCount <= (displayWVpos + (10'd35 / WSCALE))) && (hCount >= (displayWHpos + (10'd6 / WSCALE))) && (hCount <= (displayWHpos + (10'd69 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd33 / WSCALE))) && (vCount <= (displayWVpos + (10'd38 / WSCALE))) && (hCount >= (displayWHpos + (10'd5 / WSCALE))) && (hCount <= (displayWHpos + (10'd70 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd36 / WSCALE))) && (vCount <= (displayWVpos + (10'd41 / WSCALE))) && (hCount >= (displayWHpos + (10'd4 / WSCALE))) && (hCount <= (displayWHpos + (10'd71 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd39 / WSCALE))) && (vCount <= (displayWVpos + (10'd44 / WSCALE))) && (hCount >= (displayWHpos + (10'd3 / WSCALE))) && (hCount <= (displayWHpos + (10'd72 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd42 / WSCALE))) && (vCount <= (displayWVpos + (10'd47 / WSCALE))) && (hCount >= (displayWHpos + (10'd2 / WSCALE))) && (hCount <= (displayWHpos + (10'd73 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd45 / WSCALE))) && (vCount <= (displayWVpos + (10'd50 / WSCALE))) && (hCount >= (displayWHpos + (10'd1 / WSCALE))) && (hCount <= (displayWHpos + (10'd74 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd48 / WSCALE))) && (vCount <= (displayWVpos + (10'd53 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))
	               
	               
	               ||((vCount >= (displayWVpos + (10'd51 / WSCALE))) && (vCount <= (displayWVpos + (10'd56 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd54 / WSCALE))) && (vCount <= (displayWVpos + (10'd59 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd57 / WSCALE))) && (vCount <= (displayWVpos + (10'd62 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd60 / WSCALE))) && (vCount <= (displayWVpos + (10'd65 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd63 / WSCALE))) && (vCount <= (displayWVpos + (10'd68 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd66 / WSCALE))) && (vCount <= (displayWVpos + (10'd71 / WSCALE))) && (hCount >= displayWHpos) && (hCount <= (displayWHpos + (10'd75 / WSCALE))))	  
	                         
	               ||((vCount >= (displayWVpos + (10'd69 / WSCALE))) && (vCount <= (displayWVpos + (10'd74 / WSCALE))) && (hCount >= (displayWHpos + (10'd1 / WSCALE))) && (hCount <= (displayWHpos + (10'd74 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd72 / WSCALE))) && (vCount <= (displayWVpos + (10'd77 / WSCALE))) && (hCount >= (displayWHpos + (10'd2 / WSCALE))) && (hCount <= (displayWHpos + (10'd73 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd75 / WSCALE))) && (vCount <= (displayWVpos + (10'd80 / WSCALE))) && (hCount >= (displayWHpos + (10'd3 / WSCALE))) && (hCount <= (displayWHpos + (10'd72 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd78 / WSCALE))) && (vCount <= (displayWVpos + (10'd83 / WSCALE))) && (hCount >= (displayWHpos + (10'd4 / WSCALE))) && (hCount <= (displayWHpos + (10'd71 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd81 / WSCALE))) && (vCount <= (displayWVpos + (10'd86 / WSCALE))) && (hCount >= (displayWHpos + (10'd5 / WSCALE))) && (hCount <= (displayWHpos + (10'd70 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd84 / WSCALE))) && (vCount <= (displayWVpos + (10'd89 / WSCALE))) && (hCount >= (displayWHpos + (10'd6 / WSCALE))) && (hCount <= (displayWHpos + (10'd69 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd87 / WSCALE))) && (vCount <= (displayWVpos + (10'd92 / WSCALE))) && (hCount >= (displayWHpos + (10'd7 / WSCALE))) && (hCount <= (displayWHpos + (10'd68 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd90 / WSCALE))) && (vCount <= (displayWVpos + (10'd95 / WSCALE))) && (hCount >= (displayWHpos + (10'd8 / WSCALE))) && (hCount <= (displayWHpos + (10'd67 / WSCALE))))
	               
	               ||((vCount >= (displayWVpos + (10'd93 / WSCALE))) && (vCount <= (displayWVpos + (10'd98 / WSCALE))) && (hCount >= (displayWHpos + (10'd9 / WSCALE))) && (hCount <= (displayWHpos + (10'd66 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd96 / WSCALE))) && (vCount <= (displayWVpos + (10'd101 / WSCALE))) && (hCount >= (displayWHpos + (10'd11 / WSCALE))) && (hCount <= (displayWHpos + (10'd64 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd99 / WSCALE))) && (vCount <= (displayWVpos + (10'd104 / WSCALE))) && (hCount >= (displayWHpos + (10'd13 / WSCALE))) && (hCount <= (displayWHpos + (10'd62 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd102 / WSCALE))) && (vCount <= (displayWVpos + (10'd107 / WSCALE))) && (hCount >= (displayWHpos + (10'd15 / WSCALE))) && (hCount <= (displayWHpos + (10'd60 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd105 / WSCALE))) && (vCount <= (displayWVpos + (10'd110 / WSCALE))) && (hCount >= (displayWHpos + (10'd17 / WSCALE))) && (hCount <= (displayWHpos + (10'd58 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd108 / WSCALE))) && (vCount <= (displayWVpos + (10'd113 / WSCALE))) && (hCount >= (displayWHpos + (10'd19 / WSCALE))) && (hCount <= (displayWHpos + (10'd56 / WSCALE))))
	               
	               ||((vCount >= (displayWVpos + (10'd111 / WSCALE))) && (vCount <= (displayWVpos + (10'd116 / WSCALE))) && (hCount >= (displayWHpos + (10'd23 / WSCALE))) && (hCount <= (displayWHpos + (10'd52 / WSCALE))))
	               ||((vCount >= (displayWVpos + (10'd114 / WSCALE))) && (vCount <= (displayWVpos + (10'd119 / WSCALE))) && (hCount >= (displayWHpos + (10'd27 / WSCALE))) && (hCount <= (displayWHpos + (10'd48 / WSCALE))))
                    )
                   ) ? 1 : 0;
    
    assign displayWalnutWhite =   (
                           ( 
	                       ((vCount >= (displayWVpos + (10'd44 / WSCALE))) && (vCount <= (displayWVpos + (10'd70 / WSCALE))) && (hCount >= (displayWHpos + (10'd30 / WSCALE))) && (hCount <= (displayWHpos + (10'd47 / WSCALE))))
	                       ||((vCount >= (displayWVpos + (10'd47 / WSCALE))) && (vCount <= (displayWVpos + (10'd65 / WSCALE))) && (hCount >= (displayWHpos + (10'd55 / WSCALE))) && (hCount <= (displayWHpos + (10'd69 / WSCALE))))
                           )  
                           ) ? 1 : 0;
  
    assign displayWalnutBlack = 
                           ( 
                            (
                           ( 
	                       (((vCount >= (displayWVpos + (10'd49 / WSCALE))) && (vCount <= (displayWVpos + (10'd65 / WSCALE))) && (hCount >= (displayWHpos + (10'd35 / WSCALE))) && (hCount <= (displayWHpos + (10'd45 / WSCALE))))
	                       ||((vCount >= (displayWVpos + (10'd51 / WSCALE))) && (vCount <= (displayWVpos + (10'd63 / WSCALE))) && (hCount >= (displayWHpos + (10'd59 / WSCALE))) && (hCount <= (displayWHpos + (10'd67 / WSCALE)))))
	                       
	                       )
	                       || ((vCount >= (displayWVpos + (10'd74 / WSCALE))) && (vCount <= (displayWVpos + (10'd79 / WSCALE))) && (hCount >= (displayWHpos + (10'd39 / WSCALE))) && (hCount <= (displayWHpos + (10'd44 / WSCALE))))
	                       || ((vCount >= (displayWVpos + (10'd76 / WSCALE))) && (vCount <= (displayWVpos + (10'd81 / WSCALE))) && (hCount >= (displayWHpos + (10'd42 / WSCALE))) && (hCount <= (displayWHpos + (10'd59 / WSCALE))))
	                       || ((vCount >= (displayWVpos + (10'd74 / WSCALE))) && (vCount <= (displayWVpos + (10'd79 / WSCALE))) && (hCount >= (displayWHpos + (10'd57 / WSCALE))) && (hCount <= displayWHpos + (10'd62 / WSCALE)))
                            )
                           ) ? 1 : 0;

//    parameter PSSCALE = 10'd4;
    parameter displaypsHpos = 10'd320;
    parameter displaypsVPos = 10'd0;
    parameter displaypsVPosTemp = 10'd40 + 10'd90;

    assign displayPeashooterHead = (  
	                       (
	                       ((vCount >= (displaypsVPos + 10'd60)) && (vCount <= (displaypsVPos + 10'd60 + (10'd5 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd27 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd48 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd3 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd8 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd23 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd52 / PSSCALE))))
                           
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd6 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd11 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd19 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd56 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd9 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd14 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd17 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd58 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd12 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd17 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd15 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd60 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd15 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd20 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd13 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd62 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd18 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd23 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd11 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd64 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd21 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd26 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd9 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd66 / PSSCALE))))
        
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd24 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd29 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd8 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd67 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd27 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd32 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd7 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd68 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd30 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd35 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd6 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd69 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd33 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd38 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd5 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd70 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd36 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd41 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd4 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd71 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd39 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd44 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd3 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd72 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd42 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd47 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd2 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd73 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd45 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd50 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd1 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd74 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd48 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd53 / PSSCALE))) && (hCount >= (displaypsHpos)) && (hCount <= (displaypsHpos + (10'd75 / PSSCALE))))
                           
                                     
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd51 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd56 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd1 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd74 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd54 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd59 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd2 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd73 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd57 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd62 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd3 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd72 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd60 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd65 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd4 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd71 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd63 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd68 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd5 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd70 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd66 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd71 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd6 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd69 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd69 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd74 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd7 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd68 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd72 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd77 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd8 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd67 / PSSCALE))))
                           
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd75 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd80 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd9 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd66 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd78 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd83 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd11 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd64 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd81 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd86 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd13 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd62 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd84 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd89 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd15 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd60 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd87 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd92 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd17 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd58 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd90 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd95 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd19 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd56 / PSSCALE))))
                           
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd93 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd98 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd23 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd52 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd96 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd101 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd27 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd48 / PSSCALE))))
                           
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd35 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd65 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd68 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd119 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd30 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd70 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd78 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd119 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd25 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd75 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd88 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd119 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd20 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd80 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd98 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd119 / PSSCALE))))
                           ||((vCount >= (displaypsVPos + 10'd60 + (10'd15 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd85 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd108 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd119 / PSSCALE))))
	                        )) ? 1 : 0;
	                       
    assign displayPeashooterBlack = (  ((vCount >= (displaypsVPos + 10'd60 + (10'd35 / PSSCALE))) && (vCount <= (displaypsVPos + 10'd60 + (10'd50 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd45 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd60 / PSSCALE))))) ? 1 : 0;
	/*
	assign displayPeashooterStem = ( 
	                           (
                             ((vCount <= (displaypsVPosTemp + (10'd96 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd86 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd55 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd71 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd91 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd81 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd54 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd70 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd86 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd76 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd53 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd69 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd81 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd71 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd52 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd68 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd76 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd66 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd51 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd67 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd71 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd61 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd50 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd66 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd66 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd56 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd49 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd65 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd61 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd51 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd48 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd64 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd56 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd46 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd47 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd63 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd51 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd41 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd46 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd62 / PSSCALE))))
                             
                             ||((vCount <= (displaypsVPosTemp + (10'd6 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd0 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd37 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd53 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd11 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd1 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd38 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd54 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd16 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd6 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd39 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd55 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd21 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd11 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd40 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd56 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd26 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd16 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd41 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd57 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd31 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd21 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd42 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd58 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd36 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd26 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd43 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd59 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd41 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd31 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd44 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd60 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd46 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd36 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd45 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd61 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd51 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd41 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd46 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd62 / PSSCALE))))
                             
                             ||((vCount <= (displaypsVPosTemp + (10'd96 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd94 / PSSCALE))) && (hCount >= (displaypsHpos - (10'd4 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd60 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd95 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd93 / PSSCALE))) && (hCount >= (displaypsHpos - (10'd3 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd59 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd94 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd92 / PSSCALE))) && (hCount >= (displaypsHpos - (10'd2 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd58 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd93 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd91 / PSSCALE))) && (hCount >= (displaypsHpos - (10'd1 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd57 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd92 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd90 / PSSCALE))) && (hCount >= (displaypsHpos - (10'd0 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd56 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd91 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd89 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd1 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd55 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd90 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd88 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd2 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd54 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd89 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd87 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd3 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd53 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd88 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd86 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd4 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd52 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd87 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd85 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd5 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd51 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd86 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd84 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd6 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd50 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd85 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd83 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd7 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd49 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd84 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd82 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd8 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd48 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd83 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd81 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd9 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd47 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd82 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd80 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd10 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd46 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd81 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd79 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd11 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd45 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd80 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd78 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd12 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd44 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd79 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd77 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd13 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd43 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd78 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd76 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd14 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd42 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd77 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd75 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd15 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd41 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd76 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd74 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd16 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd40 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd75 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd73 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd17 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd39 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd74 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd72 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd18 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd38 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd73 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd71 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd19 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd37 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd72 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd70 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd20 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd36 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd71 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd69 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd21 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd35 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd70 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd68 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd22 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd34 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd69 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd67 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd23 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd33 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd68 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd66 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd24 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd32 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd67 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd65 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd25 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd31 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd66 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd64 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd26 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd30 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd65 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd63 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd27 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd29 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd64 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd62 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd28 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd28 / PSSCALE))))


                             ||((vCount <= (displaypsVPosTemp + (10'd96 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd94 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd124 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd60 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd95 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd93 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd123 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd61 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd94 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd92 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd122 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd62 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd93 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd91 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd120 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd63 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd92 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd90 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd119 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd64 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd91 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd89 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd118 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd65 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd90 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd88 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd117 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd66 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd89 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd87 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd116 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd67 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd88 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd86 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd115 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd68 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd87 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd85 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd114 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd69 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd86 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd84 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd113 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd70 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd85 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd83 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd112 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd71 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd84 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd82 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd111 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd72 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd83 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd81 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd110 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd73 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd82 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd80 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd109 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd74 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd81 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd79 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd108 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd75 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd80 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd78 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd107 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd76 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd79 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd77 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd106 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd77 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd78 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd76 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd105 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd78 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd77 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd75 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd104 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd79 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd76 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd74 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd103 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd80 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd75 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd73 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd102 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd81 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd74 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd72 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd101 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd82 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd73 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd71 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd100 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd83 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd72 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd70 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd99 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd84 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd71 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd69 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd98 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd85 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd70 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd68 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd97 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd86 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd69 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd67 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd96 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd87 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd68 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd66 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd95 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd88 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd67 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd65 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd94 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd89 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd66 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd64 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd93 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd90 / PSSCALE))))
                             ||((vCount <= (displaypsVPosTemp + (10'd65 / PSSCALE))) && (vCount >= (displaypsVPosTemp + (10'd63 / PSSCALE))) && (hCount <= (displaypsHpos + (10'd92 / PSSCALE))) && (hCount >= (displaypsHpos + (10'd91 / PSSCALE))))
                             )) ? 1 : 0;*/
    
    reg [25:0] pSpeed;
    always@ (posedge clk)
	begin
       pSpeed = pSpeed + 26'd1;
	   if (pSpeed >= 26'd1000000)
	   begin
	       pSpeed = 26'd0;
	   end
	end
	
	
    reg [25:0] sfBounceSpeed;
    always@ (posedge clk)
	begin
       sfBounceSpeed = sfBounceSpeed + 26'd1;
	   if (sfBounceSpeed >= 26'd6000000)
	   begin
	       sfBounceSpeed = 26'd0;
	   end
	end

    
    
//    parameter SFSCALE = 10'd4;
    parameter displaysfHpos = 10'd440;
    parameter displaysfVPos = 10'd80;
    parameter displaysfHeadHPos = displaysfHpos;
    parameter displaysfHeadVPos = displaysfVPos;
    parameter displaysfVPosTemp = displaysfVPos + 10'd154;
    assign displaySunflowerOuter = 
	                   ( 
                        ( 
	                   ((vCount >= (displaysfHeadVPos - (10'd13 / SFSCALE)))&& (vCount <= (displaysfHeadVPos)) && (hCount >= (displaysfHeadHPos + (10'd24 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd101 / SFSCALE))))
	                   || ((vCount >= (displaysfHeadVPos - (10'd32 / SFSCALE))) && (vCount <= (displaysfHeadVPos + (10'd14 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd18 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd107 / SFSCALE))))
	               
	                   || ((vCount >= (displaysfHeadVPos - (10'd50 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd32 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd12 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd113 / SFSCALE))))
	                   || ((vCount >= (displaysfHeadVPos - (10'd67 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd50 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd6 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd119 / SFSCALE))))
	                   || ((vCount >= (displaysfHeadVPos - (10'd85 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd68 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd0 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd125 / SFSCALE))))
	               
	                   || ((vCount >= (displaysfHeadVPos - (10'd103 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd86 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd6 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd119 / SFSCALE))))
	                   || ((vCount >= (displaysfHeadVPos - (10'd121 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd104 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd12 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd113 / SFSCALE))))
	                   
	                   || ((vCount >= (displaysfHeadVPos - (10'd139 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd122 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd18 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd107 / SFSCALE))))
	                   || ((vCount >= (displaysfHeadVPos - (10'd154 / SFSCALE))) && (vCount <= (displaysfHeadVPos - (10'd140 / SFSCALE))) && (hCount >= (displaysfHeadHPos + (10'd24 / SFSCALE))) && (hCount <= (displaysfHeadHPos + (10'd101 / SFSCALE))))
                        )
                       ) ? 1 : 0;
	                       	                   
	assign displaySunflowerInner = (  ((vCount < (displaysfHeadVPos - (10'd24 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd124 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd25 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd100 / SFSCALE))))) ? 1 : 0;

    assign displaySunflowerFace = ( 
                            (
                             ((vCount < (displaysfHeadVPos - (10'd89 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd104 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd45 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd55 / SFSCALE))))
                           ||((vCount < (displaysfHeadVPos - (10'd89 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd104 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd70 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd80 / SFSCALE))))
                           
                           ||((vCount < (displaysfHeadVPos - (10'd52 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd64 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd40 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd50 / SFSCALE))))
                           ||((vCount < (displaysfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd45 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd80 / SFSCALE))))
//                           ||((vCount < (10'd340 / SFSCALE))) && (vCount > (10'd328 / SFSCALE))) && (hCount > (10'd280 / SFSCALE))) && (hCount < (10'd295 / SFSCALE))))
//                           ||((vCount < (displaysfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd55 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd65 / SFSCALE))))
//                           ||((vCount < (displaysfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd65 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd75 / SFSCALE))))
                           ||((vCount < (displaysfHeadVPos - (10'd52 / SFSCALE))) && (vCount > (displaysfHeadVPos - (10'd64 / SFSCALE))) && (hCount > (displaysfHeadHPos + (10'd75 / SFSCALE))) && (hCount < (displaysfHeadHPos + (10'd85 / SFSCALE))))
                            )
                           ) ? 1 : 0;
                     
     assign displaySunflowerStem = (
                                (
                               ((vCount <= (displaysfVPosTemp + (10'd6 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd0 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd55 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd71  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd11 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd6 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd54 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd70  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd16 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd11 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd53 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd69  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd21 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd16 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd52 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd68  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd26 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd21 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd51 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd67  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd31 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd26 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd50 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd66  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd36 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd31 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd49 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd65  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd41 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd36 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd48 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd64  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd46 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd41 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd47 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd63  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd51 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd46 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd46 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd62  / SFSCALE))))
                     
                             ||((vCount <= (displaysfVPosTemp + (10'd96 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd91 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd55 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd71  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd91 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd86 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd54 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd70  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd86 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd81 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd53 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd69  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd81 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd76 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd52 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd68  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd76 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd71 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd51 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd67  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd71 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd66 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd50 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd66  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd66 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd61 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd49 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd65  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd61 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd56 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd48 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd64  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd56 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd51 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd47 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd63  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd51 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd46 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd46 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd62  / SFSCALE))))
                             
                             ||((vCount <= (displaysfVPosTemp + (10'd96 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd94 / SFSCALE))) && (hCount >= (displaysfHpos - (10'd4 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd60  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd95 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd93 / SFSCALE))) && (hCount >= (displaysfHpos - (10'd3 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd59  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd94 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd92 / SFSCALE))) && (hCount >= (displaysfHpos - (10'd2 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd58  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd93 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd91 / SFSCALE))) && (hCount >= (displaysfHpos - (10'd1 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd57  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd92 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd90 / SFSCALE))) && (hCount >= (displaysfHpos - (10'd0 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd56  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd91 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd89 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd1 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd55  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd90 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd88 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd2 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd54  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd89 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd87 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd3 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd53  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd88 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd86 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd4 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd52  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd87 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd85 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd5 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd51  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd86 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd84 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd6 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd50  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd85 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd83 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd7 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd49  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd84 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd82 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd8 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd48  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd83 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd81 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd9 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd47  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd82 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd80 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd10 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd46  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd81 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd79 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd11 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd45  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd80 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd78 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd12 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd44  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd79 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd77 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd13 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd43  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd78 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd76 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd14 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd42  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd77 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd75 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd15 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd41  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd76 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd74 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd16 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd40  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd75 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd73 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd17 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd39  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd74 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd72 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd18 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd38  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd73 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd71 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd19 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd37  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd72 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd70 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd20 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd36  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd71 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd69 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd21 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd35  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd70 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd68 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd22 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd34  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd69 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd67 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd23 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd33  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd68 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd66 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd24 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd32  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd67 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd65 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd25 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd31  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd66 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd64 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd26 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd30  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd65 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd63 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd27 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd29  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd64 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd62 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd28 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd28  / SFSCALE))))


                             ||((vCount <= (displaysfVPosTemp + (10'd96 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd94 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd124 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd60  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd95 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd93 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd123 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd61  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd94 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd92 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd122 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd62  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd93 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd91 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd120 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd63  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd92 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd90 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd119 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd64  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd91 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd89 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd118 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd65  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd90 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd88 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd117 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd66  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd89 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd87 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd116 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd67  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd88 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd86 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd115 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd68  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd87 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd85 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd114 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd69  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd86 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd84 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd113 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd70  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd85 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd83 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd112 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd71  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd84 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd82 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd111 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd72  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd83 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd81 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd110 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd73  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd82 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd80 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd109 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd74  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd81 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd79 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd108 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd75  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd80 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd78 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd107 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd76  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd79 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd77 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd106 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd77  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd78 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd76 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd105 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd78  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd77 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd75 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd104 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd79  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd76 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd74 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd103 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd80  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd75 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd73 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd102 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd81  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd74 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd72 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd101 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd82  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd73 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd71 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd100 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd83  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd72 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd70 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd99 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd84  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd71 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd69 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd98 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd85  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd70 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd68 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd97 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd86  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd69 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd67 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd96 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd87  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd68 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd66 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd95 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd88  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd67 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd65 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd94 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd89  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd66 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd64 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd93 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd90  / SFSCALE))))
                             ||((vCount <= (displaysfVPosTemp + (10'd65 / SFSCALE))) && (vCount >= (displaysfVPosTemp + (10'd63 / SFSCALE))) && (hCount <= (displaysfHpos + (10'd92 / SFSCALE))) && (hCount >= (displaysfHpos + (10'd91  / SFSCALE))))
                                )
                           ) ? 1 : 0;
 endmodule