module mod12(input clk, rst,load,input  [3:0] data_in,output reg [3:0] count);
always @(posedge clk) begin
 if (rst)
 count <= 4'd0;
  else if (load) begin      
 if (data_in < 4'd12)
  count <= data_in;
  else
 count <= 4'd0;
 end
 else if (count == 4'd11)
 count <= 4'd0;
 else
count <= count + 1'b1;
end
endmodule
