module led_controller (
    input  wire       clk,
    input  wire       rst,        
    input  wire [7:0] led_code,
    output wire [7:0] led
);

    reg [1:0]  led_pattern_sel;
    localparam [7:0] PATTERN1_CODE = 8'h55;
    localparam [7:0] PATTERN2_CODE = 8'hAA;

    always @(*) begin
        case (led_code)
            PATTERN1_CODE: led_pattern_sel = 2'b01;
            PATTERN2_CODE: led_pattern_sel = 2'b10;
            default:        led_pattern_sel = 2'b00;
        endcase
    end

    localparam LED_DIV_MAX = 24'd5_999_999; 

    reg [23:0] led_div_cnt;
    reg        led_blink_state;
    reg [2:0]  led_chase_idx;
    reg [7:0]  led_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_div_cnt     <= 0;
            led_blink_state <= 1'b0;
            led_chase_idx   <= 0;
        end else if (led_div_cnt == LED_DIV_MAX) begin
            led_div_cnt     <= 0;
            led_blink_state <= ~led_blink_state;
            led_chase_idx   <= led_chase_idx + 1;
        end else begin
            led_div_cnt <= led_div_cnt + 1;
        end
    end

    always @(*) begin
        case (led_pattern_sel)
            2'b01:   led_out = led_blink_state ? 8'h55 : 8'hAA;
            2'b10:   led_out = (8'h01 << led_chase_idx);
            default: led_out = 8'h00;
        endcase
    end

    assign led = led_out;

endmodule

