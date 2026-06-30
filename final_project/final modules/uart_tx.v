module uart_tx #(
    parameter CLKS_PER_BIT = 2500  
)(
    input  wire       clk,
    input  wire       rst,       
    input  wire       tx_start,    
    input  wire [7:0] tx_data,
    output reg        tx_line,     
    output reg        tx_done      
);

    localparam TXB_IDLE = 2'd0, TXB_START = 2'd1, TXB_DATA = 2'd2, TXB_STOP = 2'd3;

    reg [1:0]  utx_state;
    reg [12:0] utx_clk_cnt;
    reg [2:0]  utx_bit_idx;
    reg [7:0]  utx_shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            utx_state     <= TXB_IDLE;
            tx_line        <= 1'b1;
            tx_done        <= 1'b0;
            utx_clk_cnt   <= 0;
            utx_bit_idx   <= 0;
            utx_shift_reg <= 8'h00;
        end else begin
            tx_done <= 1'b0;
            case (utx_state)
                TXB_IDLE: begin
                    tx_line     <= 1'b1;
                    utx_clk_cnt <= 0;
                    utx_bit_idx <= 0;
                    if (tx_start) begin
                        utx_shift_reg <= tx_data;
                        utx_state     <= TXB_START;
                    end
                end
                TXB_START: begin
                    tx_line <= 1'b0;
                    if (utx_clk_cnt < CLKS_PER_BIT - 1) begin
                        utx_clk_cnt <= utx_clk_cnt + 1;
                    end else begin
                        utx_clk_cnt <= 0;
                        utx_state   <= TXB_DATA;
                    end
                end
                TXB_DATA: begin
                    tx_line <= utx_shift_reg[utx_bit_idx];
                    if (utx_clk_cnt < CLKS_PER_BIT - 1) begin
                        utx_clk_cnt <= utx_clk_cnt + 1;
                    end else begin
                        utx_clk_cnt <= 0;
                        if (utx_bit_idx < 7) begin
                            utx_bit_idx <= utx_bit_idx + 1;
                        end else begin
                            utx_bit_idx <= 0;
                            utx_state   <= TXB_STOP;
                        end
                    end
                end
                TXB_STOP: begin
                    tx_line <= 1'b1;
                    if (utx_clk_cnt < CLKS_PER_BIT - 1) begin
                        utx_clk_cnt <= utx_clk_cnt + 1;
                    end else begin
                        utx_clk_cnt <= 0;
                        tx_done     <= 1'b1;
                        utx_state   <= TXB_IDLE;
                    end
                end
                default: utx_state <= TXB_IDLE;
            endcase
        end
    end
