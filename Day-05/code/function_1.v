module function_1(input[31:0]address,output reg parity_reg);
function parity_cal;
input[31:0]data;
begin
parity_cal=~^data;
end
endfunction
always@(address)
parity_reg=parity_cal(address);
endmodule
