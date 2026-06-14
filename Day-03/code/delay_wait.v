module delay_wait(input a,clk,output a_delay);
reg[2:0]a_reg=3'b000;
always@(posedge clk)
begin
a_reg[0]<=a;
a_reg[1]<=a_reg[0];
a_reg[2]<=a_reg[1];
end
assign a_delay=a_reg[2];
endmodule
