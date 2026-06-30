module buzzer_controller #(
    parameter SIM_MODE   = 0,    
    parameter TONE_FREQ_HZ = 2000 
                                   
)(
    input  wire clk,
    input  wire rst,           
    input  wire buzz_pulse,
    output wire buzzer
);

    localparam BEEP_LEN = SIM_MODE ? 20 : 12_000_000; // ~500 ms on real hardware @ 24MHz

    reg [23:0] buzz_cnt;
    reg        buzz_active;

      localparam TONE_HALF_PERIOD = SIM_MODE ? 2 : (24_000_000 / (2*TONE_FREQ_HZ));

    reg [12:0] tone_cnt;
    reg        tone_bit;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buzz_cnt    <= 0;
            buzz_active <= 1'b0;
            tone_cnt    <= 0;
            tone_bit    <= 1'b0;
        end else if (buzz_pulse) begin
            buzz_cnt    <= 0;
            buzz_active <= 1'b1;
            tone_cnt    <= 0;
            tone_bit    <= 1'b1;
        end else if (buzz_active) begin
            if (buzz_cnt < BEEP_LEN - 1)
                buzz_cnt <= buzz_cnt + 1;
            else
                buzz_active <= 1'b0;

            if (tone_cnt < TONE_HALF_PERIOD - 1) begin
                tone_cnt <= tone_cnt + 1;
            end else begin
                tone_cnt <= 0;
                tone_bit <= ~tone_bit;
            end
        end
    end

    assign buzzer = buzz_active & tone_bit;

endmodule
