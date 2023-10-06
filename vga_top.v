`timescale 1ns / 1ps

module vga_top(
	input ClkPort,
	input BtnC,
	input BtnU,
	input BtnD,
	input BtnL,
	input BtnR,
    input Sw4, Sw3, Sw2, Sw1, Sw0,

	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS
	);

	wire [7:0] state;
	
	//Local parameters for state
	parameter I = 8'b1000_0000, L1 = 8'b0100_0000, NL2 = 8'b0010_0000, L2 = 8'b0001_0000, NL3 = 8'b0000_1000, L3 = 8'b0000_0100, DoneL = 8'b0000_0010, DoneW = 8'b0000_0001;

	wire Select_Button_Pulse;
    
	wire [4:0] switches;
    assign switches = {Sw4, Sw3, Sw2, Sw1, Sw0};
	
	wire bright;
	wire[9:0] hc, vc;
	wire[15:0] zombiesKilled;
	wire[15:0] numSuns;
	
	wire Select_Button_Pulse;
    
	wire [4:0] switches;
    assign switches = {Sw4, Sw3, Sw2, Sw1, Sw0};
	
	wire [6:0] ssdOut;
	wire [3:0] anode;
	wire [11:0] rgb;
	
	ee354_debouncer #(.N_dc(28)) ee354_debouncer_2 
        (.CLK(ClkPort), .RESET(), .PB(BtnC), .DPB( ), 
		.SCEN(Select_Button_Pulse), .MCEN( ), .CCEN( ));

	display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	
	bright(bright), .upButton(BtnU), .downButton(BtnD), .leftButton(BtnL), .rightButton(BtnR), .selectButton(Select_Button_Pulse), 
	                   .hCount(hc), .vCount(vc), .rgb(rgb), .zombies_killed(zombiesKilled), .numSuns(numSuns), .switches(switches));
		
    counter cnt(.clk(ClkPort), .displayNumber(numSuns), .anode(anode), .ssdOut(ssdOut));
	
	assign Dp = 1;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = ssdOut[6 : 0];
    assign {An7, An6, An5, An4, An3, An2, An1, An0} = {4'b1111, anode};

	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
	
	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

	reg doneL_reg;

	initial begin
		doneL_reg = 1'b0;
	end
	
	always@ (posedge ClkPort)
	begin
	if(state == DoneL)
	begin
	doneL_reg = 1'b1;
	end
	end
	
	assign rgb = (doneL_reg != 1'b1) ? temp_vga_rgb: temp_donel_rgb;
endmodule