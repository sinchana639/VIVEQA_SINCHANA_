
module mux4to1(input i0,i1,i2,i3,[1:0]s,output y);
wire w1,w2;
mux2to1 m1(.a(i0),.b(i1),.s(s[0]),.y(w1));
mux2to1 m2(.a(i2),.b(i3),.s(s[0]),.y(w2));
mux2to1 m3(.a(w1),.b(w2),.s(s[1]),.y(y));

endmodule