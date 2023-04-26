
module zombie_face(
    input clk,
    input[9:0] zombieHeadX,
    input [9:0] zombieHeadY,
    input [9:0] hCount,
    input [9:0] vCount,
    output zombieHead,
    output zombieEye
);

parameter ZOMBIE_HEAD_SCALE = 10'd2;
parameter ZOMBIE_EYE_SCALE = 10'd4;

assign zombieHead = (((vCount >= (zombieHeadY + 10'd60)) && (vCount <= (zombieHeadY + 10'd60 + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd3 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd6 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd9 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd14 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd12 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd15 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd20 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd18 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd21 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd26 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
        
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd24 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd29 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd27 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd32 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd30 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd35 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd33 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd38 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd36 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd41 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd39 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd44 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd42 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd47 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd45 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd50 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd48 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd53 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX)) && (hCount <= (zombieHeadX + (10'd75 / ZOMBIE_HEAD_SCALE))))
                           
                                     
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd51 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd56 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd1 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd74 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd54 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd59 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd2 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd73 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd57 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd62 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd3 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd72 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd60 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd65 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd4 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd71 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd63 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd68 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd5 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd70 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd66 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd71 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd6 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd69 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd69 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd74 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd7 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd68 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd72 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd77 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd8 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd67 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd75 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd80 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd9 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd66 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd78 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd83 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd11 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd64 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd81 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd86 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd13 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd62 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd84 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd89 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd15 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd60 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd87 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd92 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd17 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd58 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd90 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd95 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd19 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd56 / ZOMBIE_HEAD_SCALE))))
                           
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd93 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd98 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd23 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd52 / ZOMBIE_HEAD_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd96 / ZOMBIE_HEAD_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd101 / ZOMBIE_HEAD_SCALE))) && (hCount >= (zombieHeadX + (10'd27 / ZOMBIE_HEAD_SCALE))) && (hCount <= (zombieHeadX + (10'd48 / ZOMBIE_HEAD_SCALE))))
);

assign zombieEye = (((vCount >= (zombieHeadY + 10'd60)) && (vCount <= (zombieHeadY + 10'd60 + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd3 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd6 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd9 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd14 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd12 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd15 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd20 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd18 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd21 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd26 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
        
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd24 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd29 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd27 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd32 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd30 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd35 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd33 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd38 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd36 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd41 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd39 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd44 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd42 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd47 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd45 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd50 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd48 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd53 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX)) && (hCount <= (zombieHeadX + (10'd75 / ZOMBIE_EYE_SCALE))))
                           
                                     
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd51 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd56 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd1 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd74 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd54 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd59 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd2 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd73 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd57 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd62 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd3 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd72 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd60 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd65 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd4 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd71 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd63 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd68 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd5 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd70 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd66 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd71 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd6 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd69 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd69 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd74 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd7 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd68 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd72 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd77 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd8 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd67 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd75 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd80 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd9 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd66 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd78 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd83 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd11 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd64 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd81 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd86 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd13 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd62 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd84 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd89 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd15 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd60 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd87 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd92 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd17 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd58 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd90 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd95 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd19 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd56 / ZOMBIE_EYE_SCALE))))
                           
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd93 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd98 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd23 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd52 / ZOMBIE_EYE_SCALE))))
                           ||((vCount >= (zombieHeadY + 10'd60 + (10'd96 / ZOMBIE_EYE_SCALE))) && (vCount <= (zombieHeadY + 10'd60 + (10'd101 / ZOMBIE_EYE_SCALE))) && (hCount >= (zombieHeadX + (10'd27 / ZOMBIE_EYE_SCALE))) && (hCount <= (zombieHeadX + (10'd48 / ZOMBIE_EYE_SCALE))))
);



endmodule
