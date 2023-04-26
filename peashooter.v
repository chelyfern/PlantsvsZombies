`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2023 02:49:07 PM
// Design Name: 
// Module Name: peashooter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module peashooter(
    input clk,
	input [9:0] psVPosGiven,
    input [9:0] psHPosGiven,
    input [9:0] hCount, vCount,
    input enable,
    input penable,
    output peashooterHead,
    output peashooterBlack,
    output peashooterStem,
    output pea, 
    output peaX
    );

    
    parameter PSSCALE = 10'd3;
    reg [9:0] psVPosTemp; 
    reg[49:0] pSpeed;
    reg[9:0] pVPos;
    reg[9:0] pHPos;
    reg[9:0] psVPos;
    reg[9:0] psHPos;
    
    reg [1:0] cnt = 2'd00;
    
    assign peaX = pHPos;

    always@ (*)
    begin
        psVPos = psVPosGiven - 10'd50;
        psHPos = psHPosGiven + 10'd30;
    end
    
//    initial
//    begin
//		pVPos = psVPos + 10'd65;
//		pHPos = psHPos + 10'd115;
//    end

    always@ (*)
    begin
        psVPosTemp = psVPos + 10'd90; 
    end
    
    
    always@ (posedge clk)
	begin
	   if (cnt <= 2'd10)
	       begin
                pVPos = psVPos + 10'd65;
                pHPos = psHPos + 10'd115;
	           cnt = cnt + 1'd1;
	       end
       pSpeed = pSpeed + 50'd1;
	   if (pSpeed >= 50'd1000000)
	   begin
	       pSpeed = 50'd0;
	       pHPos = pHPos + 10'd1;
	       if (pHPos >= 10'd800) 
		      pHPos = psHPos + 10'd50;
	   end
	end

    assign pea = ( (penable == 1'd1) && (enable == 1'd1) && ((vCount >= pVPos) && (vCount <= pVPos + 10'd14) && (hCount >= pHPos) && (hCount <= pHPos + 10'd14))) ? 1 : 0;


	assign peashooterHead = ( (enable == 1'd1) && 
	                       (
	                       ((vCount >= (psVPos + 10'd60)) && (vCount <= (psVPos + 10'd60 + (10'd5 / PSSCALE))) && (hCount >= (psHPos + (10'd27 / PSSCALE))) && (hCount <= (psHPos + (10'd48 / PSSCALE))))
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
	                        )) ? 1 : 0;
	                       
    assign peashooterBlack = ( (enable == 1'd1) && ((vCount >= (psVPos + 10'd60 + (10'd35 / PSSCALE))) && (vCount <= (psVPos + 10'd60 + (10'd50 / PSSCALE))) && (hCount >= (psHPos + (10'd45 / PSSCALE))) && (hCount <= (psHPos + (10'd60 / PSSCALE))))) ? 1 : 0;
	
	assign peashooterStem = ((enable == 1'd1) && 
	                           (
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
                             )) ? 1 : 0;	

endmodule
