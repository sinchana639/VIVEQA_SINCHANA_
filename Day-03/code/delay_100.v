module delay_100(input a,clk,output a_delay);
reg[99:0]a_reg;
integer i;
always @(posedge clk)
begin
a_reg[0]<= a;
for(i=0;i<100;i=i+1)
a_reg[i]<=a_reg[i-1];
end
assign a_delay=a_reg[99];
endmodule