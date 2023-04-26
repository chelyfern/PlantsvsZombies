`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2023 02:58:59 PM
// Design Name: 
// Module Name: sunflower
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


module sunflower(
    input clk,
	input [9:0] sfVPosGiven,
    input [9:0] sfHPosGiven,
    input [9:0] hCount, vCount,
    input enable,
    input [24:0] sfBounceSpeed,
    output sunflowerOuter,
    output sunflowerInner,
    output sunflowerFace, 
    output sunflowerStem, 
    output reg blink);

    parameter SFSCALE = 10'd3;
    reg [9:0] sfVPosTemp; 
    
    reg [9:0] sfHeadVPos;
    reg [9:0] sfHeadHPos;
    reg [9:0] sfVPos;
    reg [9:0] sfHPos;
    
//    reg[24:0] sfBounceSpeed;
    reg sfHeadFlag;
    reg [1:0] cnt = 2'd00;
    
    always@ (*)
    begin
        sfVPos = sfVPosGiven - 10'd100;
        sfHPos = sfHPosGiven + 10'd35;
    end
    
    always@ (*)
    begin
        sfVPosTemp = sfVPos + 10'd154;
    end

//    initial
//    begin
//		sfHeadHPos = sfHPos;
//		sfHeadVPos = sfVPos + 10'd154;
//    end
    
    always@ (posedge clk)
	begin
	   if (cnt <= 2'd10)
	       begin
               sfHeadHPos = sfHPos;
               sfHeadVPos = sfVPos + 10'd154;
	           cnt = cnt + 1'd1;
	       end
//	   sfBounceSpeed = sfBounceSpeed + 50'd1;
	   if (sfBounceSpeed >= 26'd5999995)
	   begin
//	       sfBounceSpeed = 50'd0;	       
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
	end
    
	//sunflower visualization (to be made relative to the top left corner location, need to add stem + movement / WSCALE
	assign sunflowerOuter = 
	                   ( (enable == 1'd1) &&
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
                        )
                       ) ? 1 : 0;
	                       	                   
	assign sunflowerInner = ( (enable == 1'd1) && ((vCount < (sfHeadVPos - (10'd24 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd124 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd25 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd100 / SFSCALE))))) ? 1 : 0;

    assign sunflowerFace = ( (enable == 1'd1) &&
                            (
                             ((vCount < (sfHeadVPos - (10'd89 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd104 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd45 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd55 / SFSCALE))))
                           ||((vCount < (sfHeadVPos - (10'd89 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd104 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd70 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd80 / SFSCALE))))
                           
                           ||((vCount < (sfHeadVPos - (10'd52 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd64 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd40 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd50 / SFSCALE))))
                           ||((vCount < (sfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd45 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd80 / SFSCALE))))
//                           ||((vCount < (10'd340 / SFSCALE))) && (vCount > (10'd328 / SFSCALE))) && (hCount > (10'd280 / SFSCALE))) && (hCount < (10'd295 / SFSCALE))))
//                           ||((vCount < (sfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd55 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd65 / SFSCALE))))
//                           ||((vCount < (sfHeadVPos - (10'd42 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd56 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd65 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd75 / SFSCALE))))
                           ||((vCount < (sfHeadVPos - (10'd52 / SFSCALE))) && (vCount > (sfHeadVPos - (10'd64 / SFSCALE))) && (hCount > (sfHeadHPos + (10'd75 / SFSCALE))) && (hCount < (sfHeadHPos + (10'd85 / SFSCALE))))
                            )
                           ) ? 1 : 0;
                     
     assign sunflowerStem = ((enable == 1'd1) &&
                                (
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
                                )
                           ) ? 1 : 0;

endmodule

