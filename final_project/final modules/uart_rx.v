module uart_rx #(
    parameter CLKS_PER_BIT = 2500  
)(
    input  wire       clk,
    input  wire       rst,      
    input  wire       rx_pin,     
    output reg  [7:0] rx_data,    
    output reg        rx_done     
);

    localparam RX_IDLE  = 2'd0, RX_START = 2'd1, RX_DATA = 2'd2, RX_STOP = 2'd3;

    reg [1:0]  rx_state;
    reg [12:0] rx_clk_cnt;
    reg [2:0]  rx_bit_idx;
    reg [7:0]  rx_shift_reg;

    reg rx_d1, rx_d2;        
    always @(posedge clk) begin
        rx_d1 <= rx_pin;
        rx_d2 <= rx_d1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_state   <= RX_IDLE;
            rx_clk_cnt <= 0;
            rx_bit_idx <= 0;
            rx_done    <= 1'b0;
            rx_data    <= 8'h00;
        end else begin
            rx_done <= 1'b0;
            case (rx_state)
                RX_IDLE: begin
                    rx_clk_cnt <= 0;
                    rx_bit_idx <= 0;
                    if (rx_d2 == 1'b0)
                        rx_state <= RX_START;
                end
                RX_START: begin
                    if (rx_clk_cnt == (CLKS_PER_BIT/2)) begin
                        if (rx_d2 == 1'b0) begin
                            rx_clk_cnt <= 0;
                            rx_state   <= RX_DATA;
                        end else begin
                            rx_state <= RX_IDLE; 
                        end
                    end else begin
                        rx_clk_cnt <= rx_clk_cnt + 1;
                    end
                end
                RX_DATA: begin
                    if (rx_clk_cnt < CLKS_PER_BIT - 1) begin
                        rx_clk_cnt <= rx_clk_cnt + 1;
                    end else begin
                        rx_clk_cnt <= 0;
                        rx_shift_reg[rx_bit_idx] <= rx_d2;
                        if (rx_bit_idx < 7) begin
                            rx_bit_idx <= rx_bit_idx + 1;
                        end else begin
                            rx_bit_idx <= 0;
                            rx_state   <= RX_STOP;
                        end
                    end
                end
                RX_STOP: begin
                    if (rx_clk_cnt < CLKS_PER_BIT - 1) begin
                        rx_clk_cnt <= rx_clk_cnt + 1;
                    end else begin
                        rx_clk_cnt <= 0;
                        rx_data    <= rx_shift_reg;
                        rx_done    <= 1'b1;
                        rx_state   <= RX_IDLE;
                    end
                end
                default: rx_state <= RX_IDLE;
            endcase
        end