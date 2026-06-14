module up_down_load_counter_tb();
reg clk;
reg rst;
reg ud;
reg ld;
reg [3:0] load;
wire [3:0] count;

up_down_load_counter uut (.clk(clk),.rst(rst),.ud(ud),.ld(ld),.load(load), .count(count));
always #5 clk = ~clk;
initial
begin
clk = 0;
rst = 1;
ud = 1;
ld = 0;
load = 4'b0000;
#10 rst = 0;
#10 ld = 1;
load = 4'b1001;
 #10 ld = 0;
ud = 1;
 #40 ud = 0;
 #40 ld = 1;
 load = 4'b0011;
 #10 ld = 0;
 ud = 1;
 #30;
  $finish;
end

endmodule