module T_using_D_tb();
reg clk;
reg rst;
reg T;
wire Q;

T_using_D dut(.clk(clk),.rst(rst),.T(T),.Q(Q));
always #5 clk = ~clk;
initial
begin
clk = 0;
rst = 1;
 T = 0;
 #10 rst = 0;
 T = 0;
 #20;
T = 1;
 #20;
$finish;
end
endmodule
