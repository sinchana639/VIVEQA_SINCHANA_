module encoder_8_3_tb();
reg [7:0] d;
wire [2:0] y;
encoder_8_3 uut(.d(d),.y(y));
initial begin
d=8'b00000001;
#10;
d=8'b00000010;
#10;
d=8'b00000100;
#10;
d=8'b00001000;
#10;
d=8'b00010000;
#10;
d=8'b00100000;
#10;
d=8'b01000000;
#10;
d=8'b10000000;
#10;
d=8'b00000001;
#10;
$finish;
end
endmodule