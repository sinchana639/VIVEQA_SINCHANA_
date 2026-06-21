module full_adder_tb();
reg A,B,Cin;
wire Sum,Carry;
integer i;
full_adder dut(.A(A),.B(B),.Cin(Cin),.Sum(Sum),.Carry(Carry));
initial begin
for(i=0;i<8;i=i+1)
{A,B,Cin}=i;
#10;
$finish;
end
endmodule
