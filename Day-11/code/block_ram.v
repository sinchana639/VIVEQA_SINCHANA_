module block_ram(input clk,[9:0]w_addr,[9:0]r_addr,we,re,[31:0]write_data,output reg [31:0]read_data);
reg[31:0]mem[0:1023];//reg[width]mem[depth]
always@(posedge clk)begin
if(we)
mem[w_addr]<=write_data;
end
always@(posedge clk)begin
if(re)
read_data<=mem[r_addr];
end
endmodule

