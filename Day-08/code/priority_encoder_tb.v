module priority_encoder_tb();
reg[7:0]d;
wire[2:0]y;
integer i;
priority_encoder dut(.d(d),.y(y));
initial begin
for(i=0;i<256;i=i+1)
begin 
d=i;
#10;
end
$finish;
end
endmodule
