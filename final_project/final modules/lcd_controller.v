module lcd_controller #(
    parameter SIM_MODE = 0     // 1 = fast timing for simulation, 0 = real hardware
)(
    input  wire       clk,
    input  wire       rst,        // active-high
    input  wire [7:0] rx_data,
    input  wire       rx_done,

    output reg        lcd_rs,
    output wire        lcd_rw,    // tied low: this design only ever writes
    output reg        lcd_en,
    output reg  [7:0] lcd_d
);

    assign lcd_rw = 1'b0;

    localparam LCD_POWERON_WAIT = SIM_MODE ? 20 : 400_000;
    localparam LCD_EN_PULSE     = SIM_MODE ? 2  : 12;
    localparam LCD_BYTE_DELAY   = SIM_MODE ? 10 : 40_000;
    localparam LCD_SETUP_HOLD   = SIM_MODE ? 1  : 4;

    localparam LCD_INIT_LEN = 5;
    reg [8:0] lcd_init_rom [0:LCD_INIT_LEN-1];
    initial begin
        lcd_init_rom[0] = {1'b0, 8'h38};
        lcd_init_rom[1] = {1'b0, 8'h0C};
        lcd_init_rom[2] = {1'b0, 8'h01};
        lcd_init_rom[3] = {1'b0, 8'h06};
        lcd_init_rom[4] = {1'b0, 8'h80};
    end

    localparam LCD_L1_LEN = 16;
    reg [7:0] lcd_line1_msg [0:LCD_L1_LEN-1];
    initial begin
        lcd_line1_msg[0]="U";  lcd_line1_msg[1]="A";  lcd_line1_msg[2]="R";  lcd_line1_msg[3]="T";
        lcd_line1_msg[4]=" ";  lcd_line1_msg[5]="C";  lcd_line1_msg[6]="M";  lcd_line1_msg[7]="D";
        lcd_line1_msg[8]=" ";  lcd_line1_msg[9]="S";  lcd_line1_msg[10]="Y"; lcd_line1_msg[11]="S";
        lcd_line1_msg[12]="T"; lcd_line1_msg[13]="E"; lcd_line1_msg[14]="M"; lcd_line1_msg[15]=" ";
    end

    localparam LCD_L2_LEN = 16;
    reg [7:0] lcd_msg_pattern1 [0:LCD_L2_LEN-1];
    reg [7:0] lcd_msg_pattern2 [0:LCD_L2_LEN-1];
    initial begin
        lcd_msg_pattern1[0]="L";  lcd_msg_pattern1[1]="E";  lcd_msg_pattern1[2]="D";  lcd_msg_pattern1[3]=" ";
        lcd_msg_pattern1[4]="P";  lcd_msg_pattern1[5]="A";  lcd_msg_pattern1[6]="T";  lcd_msg_pattern1[7]="T";
        lcd_msg_pattern1[8]="E";  lcd_msg_pattern1[9]="R";  lcd_msg_pattern1[10]="N"; lcd_msg_pattern1[11]=" ";
        lcd_msg_pattern1[12]="1"; lcd_msg_pattern1[13]=" "; lcd_msg_pattern1[14]=" "; lcd_msg_pattern1[15]=" ";

        lcd_msg_pattern2[0]="L";  lcd_msg_pattern2[1]="E";  lcd_msg_pattern2[2]="D";  lcd_msg_pattern2[3]=" ";
        lcd_msg_pattern2[4]="P";  lcd_msg_pattern2[5]="A";  lcd_msg_pattern2[6]="T";  lcd_msg_pattern2[7]="T";
        lcd_msg_pattern2[8]="E";  lcd_msg_pattern2[9]="R";  lcd_msg_pattern2[10]="N"; lcd_msg_pattern2[11]=" ";
        lcd_msg_pattern2[12]="2"; lcd_msg_pattern2[13]=" "; lcd_msg_pattern2[14]=" "; lcd_msg_pattern2[15]=" ";
    end

    wire lcd_trigger_pulse = rx_done && (rx_data == 8'h31 || rx_data == 8'h32);

    localparam LCD_S_PWRWAIT = 4'd0,
               LCD_S_INIT    = 4'd1,
               LCD_S_L1      = 4'd2,
               LCD_S_READY   = 4'd3,
               LCD_S_L2_ADDR = 4'd4,
               LCD_S_L2      = 4'd5,
               LCD_S_SETUP   = 4'd6,
               LCD_S_PULSE   = 4'd7,
               LCD_S_HOLD    = 4'd8,
               LCD_S_WAIT    = 4'd9;

    reg [3:0]  lcd_state, lcd_ret_state;
    reg [18:0] lcd_delay_cnt;
    reg [4:0]  lcd_idx;
    reg        lcd_use_pattern2;
    reg        lcd_trig_pending;
    reg [7:0]  lcd_trig_cmd_latched;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lcd_trig_pending     <= 1'b0;
            lcd_trig_cmd_latched <= 8'h00;
        end else if (lcd_trigger_pulse) begin
            lcd_trig_pending     <= 1'b1;
            lcd_trig_cmd_latched <= rx_data;
        end else if (lcd_state == LCD_S_L2_ADDR) begin
            lcd_trig_pending <= 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lcd_state        <= LCD_S_PWRWAIT;
            lcd_delay_cnt    <= 0;
            lcd_idx          <= 0;
            lcd_rs           <= 1'b0;
            lcd_en           <= 1'b0;
            lcd_d            <= 8'h00;
            lcd_use_pattern2 <= 1'b0;
        end else begin
            case (lcd_state)
                LCD_S_PWRWAIT: begin
                    if (lcd_delay_cnt < LCD_POWERON_WAIT-1) begin
                        lcd_delay_cnt <= lcd_delay_cnt + 1;
                    end else begin
                        lcd_delay_cnt <= 0;
                        lcd_idx       <= 0;
                        lcd_state     <= LCD_S_INIT;
                    end
                end
                LCD_S_INIT: begin
                    lcd_rs <= lcd_init_rom[lcd_idx][8];
                    lcd_d  <= lcd_init_rom[lcd_idx][7:0];
                    lcd_state <= LCD_S_SETUP;
                    if (lcd_idx == LCD_INIT_LEN-1) begin
                        lcd_ret_state <= LCD_S_L1;
                        lcd_idx       <= 0;
                    end else begin
                        lcd_ret_state <= LCD_S_INIT;
                        lcd_idx       <= lcd_idx + 1;
                    end
                end
                LCD_S_L1: begin
                    lcd_rs <= 1'b1;
                    lcd_d  <= lcd_line1_msg[lcd_idx];
                    lcd_state <= LCD_S_SETUP;
                    if (lcd_idx == LCD_L1_LEN-1) begin
                        lcd_ret_state <= LCD_S_READY;
                        lcd_idx       <= 0;
                    end else begin
                        lcd_ret_state <= LCD_S_L1;
                        lcd_idx       <= lcd_idx + 1;
                    end
                end
                LCD_S_READY: begin
                    if (lcd_trig_pending) begin
                        lcd_use_pattern2 <= (lcd_trig_cmd_latched == 8'h32);
                        lcd_state        <= LCD_S_L2_ADDR;
                    end
                end
                LCD_S_L2_ADDR: begin
                    lcd_rs        <= 1'b0;
                    lcd_d         <= 8'hC0;
                    lcd_ret_state <= LCD_S_L2;
                    lcd_idx       <= 0;
                    lcd_state     <= LCD_S_SETUP;
                end
                LCD_S_L2: begin
                    lcd_rs <= 1'b1;
                    lcd_d  <= lcd_use_pattern2 ? lcd_msg_pattern2[lcd_idx] : lcd_msg_pattern1[lcd_idx];
                    lcd_state <= LCD_S_SETUP;
                    if (lcd_idx == LCD_L2_LEN-1) begin
                        lcd_ret_state <= LCD_S_READY;
                        lcd_idx       <= 0;
                    end else begin
                        lcd_ret_state <= LCD_S_L2;
                        lcd_idx       <= lcd_idx + 1;
                    end
                end
                LCD_S_SETUP: begin
                    if (lcd_delay_cnt < LCD_SETUP_HOLD-1) begin
                        lcd_delay_cnt <= lcd_delay_cnt + 1;
                    end else begin
                        lcd_delay_cnt <= 0;
                        lcd_en        <= 1'b1;
                        lcd_state     <= LCD_S_PULSE;
                    end
                end
                LCD_S_PULSE: begin
                    if (lcd_delay_cnt < LCD_EN_PULSE-1) begin
                        lcd_delay_cnt <= lcd_delay_cnt + 1;
                    end else begin
                        lcd_delay_cnt <= 0;
                        lcd_en        <= 1'b0;
                        lcd_state     <= LCD_S_HOLD;
                    end
                end
                LCD_S_HOLD: begin
                    if (lcd_delay_cnt < LCD_SETUP_HOLD-1) begin
                        lcd_delay_cnt <= lcd_delay_cnt + 1;
                    end else begin
                        lcd_delay_cnt <= 0;
                        lcd_state     <= LCD_S_WAIT;
                    end
                end
                LCD_S_WAIT: begin
                    if (lcd_delay_cnt < LCD_BYTE_DELAY-1) begin
                        lcd_delay_cnt <= lcd_delay_cnt + 1;
                    end else begin
                        lcd_delay_cnt <= 0;
                        lcd_state     <= lcd_ret_state;
                    end
                end
                default: lcd_state <= LCD_S_PWRWAIT;
            endcase
        end
    end
endmodule