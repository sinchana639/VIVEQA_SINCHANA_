module task_1_tb();
reg [31:0]address;
wire parity_reg;
task_1 uut(.address(address),.parity_reg(parity_reg));
initial begin
address=32'b0000;
#10;
address=32'b0001;
#10;
address=32'b0011;
#10;
address=32'b0111;
#10;
$finish;
end
endmodule