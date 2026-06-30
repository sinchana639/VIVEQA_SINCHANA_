module frequency_divider(input clk,output reg [3:0]led=4'b0);
always@(posedge clk)begin
led<=led+1;
end
endmodule