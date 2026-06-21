module full_adder(input A,B, Cin,output Sum,Carry);
assign Sum= A^B^Cin;
assign Carry=(A&B)|(B&Cin)|(A&Cin);
endmodule