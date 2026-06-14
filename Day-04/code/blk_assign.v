module blk_assign();
reg a,b,c,d;
initial begin
a=1'b1;
b=1'b0;
c=1'b1;
d=1'b0;
c=#5b;
d=#10a;
b=d;
end
endmodule
