module check_nonblock();
reg a,b,c,d,i ,clk;
initial begin
a <= 1;
b <= 1;
c <= 1;
d <= 1;
i  <= 1;
end
initial begin
i<=#51'b0;
i<=#51'b1;
end
endmodule