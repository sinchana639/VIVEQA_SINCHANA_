module encoder_8_3(input[7:0]d,output[2:0]y);
wire y2,y1,y0;
assign y2 = d[4] | d[5] | d[6] | d[7];
assign y1 = d[6] | d[7] | ((~d[7]) & (~d[6]) & (~d[5]) & (~d[4]) & (d[2] | d[3]));

assign y0 = d[7] |((~d[7]) & (~d[6]) & d[5]) | ((~d[7]) & (~d[6]) & (~d[5]) & (~d[4]) & d[3]) |((~d[7]) & (~d[6]) & (~d[5]) & (~d[4]) & (~d[3]) & (~d[2]) & d[1]);

assign y = {y2,y1,y0};
endmodule