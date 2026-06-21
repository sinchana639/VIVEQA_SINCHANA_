module JK_FF_tb();
reg clk;
reg rst;
reg J,K;
wire Q;

JK_FF dut(.clk(clk),.rst(rst),.J(J),.K(K),.Q(Q));
always #5 clk = ~clk;
initial
begin
clk = 0;
rst = 1;
J = 0;
K = 0;
 #10;
 rst = 0;
 J = 1;
 K = 0;
 #10;
 J = 0;
 K = 1;
 #10;
 J = 1;
 K = 1;
 #10;
 $finish;
end
endmodule