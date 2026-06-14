module up_down_load_counter (input clk,rst,ud,ld,[3:0] load,output reg [3:0] count);
always @(posedge clk)
begin
if (rst)
count <= 4'b0000;
else if (ld)
count <= load;
else if (ud)
count <= count + 1'b1;
else
count <= count - 1'b1;
end
endmodule