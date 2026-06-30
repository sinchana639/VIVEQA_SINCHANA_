module relay_controller (
    input  wire clk,
    input  wire rst,            
    input  wire relay_on_pulse,
    input  wire relay_off_pulse,
    output reg  relay
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            relay <= 1'b0;          
        else if (relay_on_pulse)
            relay <= 1'b1;
        else if (relay_off_pulse)
            relay <= 1'b0;
    end

endmodule
