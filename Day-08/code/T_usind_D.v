module T_using_D(input clk, rst, T,output reg Q);
wire D;

assign D = T ^ Q;   
always @(posedge clk or posedge rst)
begin
 if (rst)
 Q <= 1'b0;
 else
Q <= D;
end
endmodule
