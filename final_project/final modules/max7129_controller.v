module max7219_controller #(
    parameter SIM_MODE = 0  
)(
    input  wire       clk,
    input  wire       rst,        
    input  wire [7:0] rx_data,
    input  wire       rx_done,

    output reg        seg_din,
    output reg        seg_load,
    output reg        seg_clk
);

    localparam SEG_HALF_BIT = SIM_MODE ? 1 : 4;
    localparam SEG_SETTLE   = SIM_MODE ? 1 : 4;

    localparam SEG_INIT_LEN = 5;
    reg [11:0] seg_init_rom [0:SEG_INIT_LEN-1];
    initial begin
        seg_init_rom[0] = {4'hC, 8'h01}; 
        seg_init_rom[1] = {4'hF, 8'h00}; 
        seg_init_rom[2] = {4'h9, 8'hFF}; 
        seg_init_rom[3] = {4'hB, 8'h03};
        seg_init_rom[4] = {4'hA, 8'h08}; 
    end

    wire [3:0] seg_d_ones = rx_data % 10;
    wire [3:0] seg_d_tens = (rx_data / 10) % 10;
    wire [3:0] seg_d_hund = (rx_data / 100) % 10;

    localparam SEG_S_INIT      = 4'd0,
               SEG_S_DIGITS    = 4'd1,
               SEG_S_READY     = 4'd2,
               SEG_S_LOAD_WORD = 4'd3,
               SEG_S_BIT_SETUP = 4'd4,
               SEG_S_BIT_HIGH  = 4'd5,
               SEG_S_BIT_LOW   = 4'd6,
               SEG_S_LATCH     = 4'd7;

    reg [3:0]  seg_state, seg_ret_state;
    reg [3:0]  seg_init_idx;
    reg [2:0]  seg_digit_idx;
    reg [15:0] seg_shift_reg;
    reg [4:0]  seg_bit_idx;
    reg [4:0]  seg_delay_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_state     <= SEG_S_INIT;
            seg_din       <= 1'b0;
            seg_clk       <= 1'b0;
            seg_load      <= 1'b1;
            seg_init_idx  <= 0;
            seg_digit_idx <= 0;
            seg_bit_idx   <= 0;
            seg_delay_cnt <= 0;
        end else begin
            case (seg_state)
                SEG_S_INIT: begin
                    seg_shift_reg <= {4'b0, seg_init_rom[seg_init_idx][11:8], seg_init_rom[seg_init_idx][7:0]};
                    seg_bit_idx   <= 15;
                    seg_state     <= SEG_S_LOAD_WORD;
                    if (seg_init_idx == SEG_INIT_LEN-1) begin
                        seg_ret_state <= SEG_S_DIGITS;
                        seg_digit_idx <= 0;
                        seg_init_idx  <= 0;
                    end else begin
                        seg_ret_state <= SEG_S_INIT;
                        seg_init_idx  <= seg_init_idx + 1;
                    end
                end
                SEG_S_DIGITS: begin
                    case (seg_digit_idx)
                        3'd0: seg_shift_reg <= {4'b0, 4'h1, 4'h0, seg_d_hund};
                        3'd1: seg_shift_reg <= {4'b0, 4'h2, 4'h0, seg_d_tens};
                        3'd2: seg_shift_reg <= {4'b0, 4'h3, 4'h0, seg_d_ones};
                        default: seg_shift_reg <= {4'b0, 4'h4, 8'h0F}; // blank
                    endcase
                    seg_bit_idx <= 15;
                    seg_state   <= SEG_S_LOAD_WORD;
                    if (seg_digit_idx == 3) begin
                        seg_ret_state <= SEG_S_READY;
                        seg_digit_idx <= 0;
                    end else begin
                        seg_ret_state <= SEG_S_DIGITS;
                        seg_digit_idx <= seg_digit_idx + 1;
                    end
                end
                SEG_S_READY: begin
                    if (rx_done) begin
                        seg_digit_idx <= 0;
                        seg_state     <= SEG_S_DIGITS;
                    end
                end
                SEG_S_LOAD_WORD: begin
                    seg_load      <= 1'b0;
                    seg_delay_cnt <= 0;
                    seg_state     <= SEG_S_BIT_SETUP;
                end
                SEG_S_BIT_SETUP: begin
                    seg_din <= seg_shift_reg[seg_bit_idx];
                    seg_clk <= 1'b0;
                    if (seg_delay_cnt < SEG_SETTLE-1) begin
                        seg_delay_cnt <= seg_delay_cnt + 1;
                    end else begin
                        seg_delay_cnt <= 0;
                        seg_state     <= SEG_S_BIT_HIGH;
                    end
                end
                SEG_S_BIT_HIGH: begin
                    seg_clk <= 1'b1;
                    if (seg_delay_cnt < SEG_HALF_BIT-1) begin
                        seg_delay_cnt <= seg_delay_cnt + 1;
                    end else begin
                        seg_delay_cnt <= 0;
                        seg_state     <= SEG_S_BIT_LOW;
                    end
                end
                SEG_S_BIT_LOW: begin
                    seg_clk <= 1'b0;
                    if (seg_delay_cnt < SEG_HALF_BIT-1) begin
                        seg_delay_cnt <= seg_delay_cnt + 1;
                    end else begin
                        seg_delay_cnt <= 0;
                        if (seg_bit_idx == 0) begin
                            seg_state <= SEG_S_LATCH;
                        end else begin
                            seg_bit_idx <= seg_bit_idx - 1;
                            seg_state   <= SEG_S_BIT_SETUP;
                        end
                    end
                end
                SEG_S_LATCH: begin
                    seg_load <= 1'b1;
                    if (seg_delay_cnt < SEG_SETTLE-1) begin
                        seg_delay_cnt <= seg_delay_cnt + 1;
                    end else begin
                        seg_delay_cnt <= 0;
                        seg_state     <= seg_ret_state;
                    end
                end
                default: seg_state <= SEG_S_INIT;
            endcase
        end
    end
endmodule
