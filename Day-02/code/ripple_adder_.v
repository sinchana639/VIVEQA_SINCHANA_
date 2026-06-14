module ripple_adder_tb();
reg[3:0] a,b;
 reg cin;
wire [3:0]sum;
wire cout;
integer i;
ripple_adder dut(.a(a),.b(b),.cin(cin),.sum(sum),.cout(cout));
initial begin
cin=0;
for(i=0;i<16;i=i+1)
begin
a=i;
b=i;
#10;
end
$finish;
end
endmodule