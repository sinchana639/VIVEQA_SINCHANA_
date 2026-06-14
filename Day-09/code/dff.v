module dff(input clk,rst,D,output reg Q,Qb);
always@ (posedge clk)begin
if(rst)begin 
Q<=1'b0;
Qb<=1'b1;
end 
else begin
Q<=D;
Qb<=~D;
end
end
endmodule
