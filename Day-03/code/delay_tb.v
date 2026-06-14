module delay_tb;
reg clk=0,a=1;
wire a_delay;
delay uut(a,clk,a_delay);
always
begin
a=1;#15;
a=0;
end
always
begin
clk=~clk;
#10;
end
endmodule