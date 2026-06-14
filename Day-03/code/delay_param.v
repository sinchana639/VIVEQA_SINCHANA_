module delay_param#(parameter N=3)(input a,clk,output a_delay);
reg [N-1:0]a_reg;
integer i;
always@(posedge clk)
begin
a_reg[0]<=a;
for(i=1;i<N;i=i+1)
a_reg[i]<=a_reg[i-1];
end
assign a_delay=a_reg[N-1];
endmodule
