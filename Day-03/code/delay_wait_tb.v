module delay_wait_tb;
reg clk=0,a=0;
wire a_delay;
delay_wait dut(a,clk,a_delay);
always begin
#10;
clk=~clk;
end
initial begin
a=0;
wait(clk==1);
a=1;
wait(clk==0);
wait(clk==1);
a=0;
#100;
$finish;
end
endmodule

