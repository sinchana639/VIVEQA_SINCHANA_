module command_decoder (
    input  wire       clk,
    input  wire       rst,           
    input  wire       rx_done,
    input  wire [7:0] rx_data,

    output reg  [7:0] led_code,
    output reg        buzz_pulse,
    output reg        relay_on_pulse,
    output reg        relay_off_pulse
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_code        <= 8'h00;
            buzz_pulse       <= 1'b0;
            relay_on_pulse   <= 1'b0;
            relay_off_pulse  <= 1'b0;
        end else begin
            buzz_pulse      <= 1'b0;
            relay_on_pulse  <= 1'b0;
            relay_off_pulse <= 1'b0;
            if (rx_done) begin
                case (rx_data)
                    "0"     : led_code <= 8'h00;
                    "1"     : led_code <= 8'h55;
                    "2"     : led_code <= 8'hAA;
                    "B","b" : buzz_pulse      <= 1'b1;
                    "R","r" : relay_on_pulse  <= 1'b1;
                    "X","x" : relay_off_pulse <= 1'b1;
                    default : ;
                endcase
            end
        end
    end

endmodule