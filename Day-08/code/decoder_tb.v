module decoder_tb();
reg a,b;
wire[3:0]y;
decoder dut (.a(a),.b(b),.y(y));
integer i;
initial begin
for(i=0;i<4;i=i+1)
{a,b}=i;
#10;
$finish;
end
endmodule
