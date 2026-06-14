module delay_param_tb;
parameter N=3;
reg clk,a;
wire a_delay;
delay_param #(N) uut(a,clk,a_delay);
always #10 clk=~clk;
initial begin
clk=0;
a=0;
#20 a=1;
#20 a=0;
#100 $finish;
end
endmodule