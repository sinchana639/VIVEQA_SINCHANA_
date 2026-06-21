module decoder_3_8_tb();
reg a,b,c;
wire[7:0]y;
decoder_3_8 dut (.a(a),.b(b),.c(c),.y(y));
integer i;
initial begin
for(i=0;i<8;i=i+1)
{a,b,c}=i;
#10;
$finish;
end
endmodule

   