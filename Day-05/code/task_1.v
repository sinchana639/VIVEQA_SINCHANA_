module task_1(input[31:0]address,output reg parity_reg);
task parity_cal;
input[31:0] data;
output parity;
begin
 parity =~^data;
end
endtask
always@(address)
begin
parity_cal(address,parity_reg);
end
endmodule
