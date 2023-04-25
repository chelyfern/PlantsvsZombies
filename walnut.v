`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2023 02:57:10 PM
// Design Name: 
// Module Name: walnut
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


module walnut(
	input [9:0] wVPos,
    input [9:0] wHPos,
    input [9:0] hCount, vCount,
    input blink,
    input enable,
    output walnut,
    output walnutBlack,
    output walnutWhite);

    parameter WSCALE = 10'd2;
    assign walnut = 
	               ((enable == 1'd1) &&
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
                    )
                   ) ? 1 : 0;
    
    assign walnutWhite =   (
                           ( 
	                       ((vCount >= (wVPos + (10'd44 / WSCALE))) && (vCount <= (wVPos + (10'd70 / WSCALE))) && (hCount >= (wHPos + (10'd30 / WSCALE))) && (hCount <= (wHPos + (10'd47 / WSCALE))))
	                       ||((vCount >= (wVPos + (10'd47 / WSCALE))) && (vCount <= (wVPos + (10'd65 / WSCALE))) && (hCount >= (wHPos + (10'd55 / WSCALE))) && (hCount <= (wHPos + (10'd69 / WSCALE))))
                           ) && (enable == 1'd1) && (blink == 1'd0) 
                           ) ? 1 : 0;
  
    assign walnutBlack = 
                           ( (enable == 1'd1) &&
                            (
                           ( 
	                       (((vCount >= (wVPos + (10'd49 / WSCALE))) && (vCount <= (wVPos + (10'd65 / WSCALE))) && (hCount >= (wHPos + (10'd35 / WSCALE))) && (hCount <= (wHPos + (10'd45 / WSCALE))))
	                       ||((vCount >= (wVPos + (10'd51 / WSCALE))) && (vCount <= (wVPos + (10'd63 / WSCALE))) && (hCount >= (wHPos + (10'd59 / WSCALE))) && (hCount <= (wHPos + (10'd67 / WSCALE)))))
	                       && (blink == 1'd0)
	                       )
	                       || ((vCount >= (wVPos + (10'd74 / WSCALE))) && (vCount <= (wVPos + (10'd79 / WSCALE))) && (hCount >= (wHPos + (10'd39 / WSCALE))) && (hCount <= (wHPos + (10'd44 / WSCALE))))
	                       || ((vCount >= (wVPos + (10'd76 / WSCALE))) && (vCount <= (wVPos + (10'd81 / WSCALE))) && (hCount >= (wHPos + (10'd42 / WSCALE))) && (hCount <= (wHPos + (10'd59 / WSCALE))))
	                       || ((vCount >= (wVPos + (10'd74 / WSCALE))) && (vCount <= (wVPos + (10'd79 / WSCALE))) && (hCount >= (wHPos + (10'd57 / WSCALE))) && (hCount <= wHPos + (10'd62 / WSCALE)))
                            )
                           ) ? 1 : 0;

endmodule


