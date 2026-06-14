module delay_100_tb;
reg a,clk;
wire a_delay;
delay_100 dut(.a(a),.clk(clk),.a_delay(a_delay));
always #5 clk=~clk;
initial begin
clk=0;
a=0;
#10;
a=1;
#10;
a=0;
#1200;
$finish;
end
endmodule

