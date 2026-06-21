module mux4to1_tb();
reg i0,i1,i2,i3;
reg [1:0]s;
wire y;
mux4to1 dut(.i0(i0),.i1(i1),.i2(i2),.i3(i3),.s(s),.y(y));
integer i;
initial begin
for(i=0;i<63;i=i+1)
begin
{i0,i1,i2,i3}=i;
#10;
end
$finish;
end
endmodule
