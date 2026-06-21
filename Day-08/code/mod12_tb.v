module mod12_tb();
reg clk;
reg rst;
reg load;
reg [3:0] data_in;
wire [3:0] count;
mod12 dut(.clk(clk),.rst(rst),.load(load),.data_in(data_in),.count(count));
always #5 clk = ~clk;
initial begin
 clk = 0;
 rst = 1;
 load = 0;
data_in = 4'd0;
 #10;
 rst = 0;
 #80;
 load = 1;
 data_in = 4'd8;
 #10;
load = 0;
#60;
 load = 1;
 data_in = 4'd11;
 #10;
load = 0;
#30;
load = 1;
 data_in = 4'd14;
 #10;
 load = 0;
 #40;
 rst = 1;
 #10;
 rst = 0;
 #40;
 $finish;
end
endmodule
