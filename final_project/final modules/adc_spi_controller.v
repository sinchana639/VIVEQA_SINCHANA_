module adc_spi_controller #(
    parameter SIM_MODE = 0     
)(
    input  wire        clk,
    input  wire        rst,     
    input  wire        adc_start,
    output reg         adc_done,
    output reg  [11:0] adc_value,

    output reg          adc_sck,
    output reg          adc_mosi,
    input  wire          adc_miso,
    output reg          adc_cs       
);

    localparam ADC_HALF_BIT   = SIM_MODE ? 1 : 14;
    localparam ADC_TOTAL_BITS = 18;              

    localparam ADC_IDLE      = 3'd0,
               ADC_CS_LOW    = 3'd1,
               ADC_BIT_SETUP = 3'd2,
               ADC_BIT_HIGH  = 3'd3,
               ADC_BIT_LOW   = 3'd4,
               ADC_CS_HIGH   = 3'd5;

    reg [2:0]  adc_state;
    reg [4:0]  adc_bit_cnt;
    reg [4:0]  adc_delay_cnt;
    reg [3:0]  adc_cfg_word;   
    reg [11:0] adc_shift_in;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            adc_state     <= ADC_IDLE;
            adc_cs        <= 1'b1;
            adc_sck       <= 1'b0;
            adc_mosi      <= 1'b0;
            adc_done      <= 1'b0;
            adc_value     <= 12'h000;
            adc_bit_cnt   <= 0;
        end else begin
            adc_done <= 1'b0;
            case (adc_state)
                ADC_IDLE: begin
                    adc_cs  <= 1'b1;
                    adc_sck <= 1'b0;
                    if (adc_start) begin
                        adc_cfg_word <= 4'b1111;                        
                        adc_bit_cnt  <= 0;
                        adc_state    <= ADC_CS_LOW;
                    end
                end
                ADC_CS_LOW: begin
                    adc_cs        <= 1'b0;
                    adc_delay_cnt <= 0;
                    adc_state     <= ADC_BIT_SETUP;
                end
                ADC_BIT_SETUP: begin
                    adc_mosi <= (adc_bit_cnt < 4) ? adc_cfg_word[3-adc_bit_cnt] : 1'b0;
                    adc_sck  <= 1'b0;
                    if (adc_delay_cnt < ADC_HALF_BIT-1) begin
                        adc_delay_cnt <= adc_delay_cnt + 1;
                    end else begin
                        adc_delay_cnt <= 0;
                        adc_state     <= ADC_BIT_HIGH;
                    end
                end
                ADC_BIT_HIGH: begin
                    adc_sck <= 1'b1; // rising edge: ADC samples MOSI / drives valid DOUT
                    if (adc_bit_cnt >= 6)
                        adc_shift_in <= {adc_shift_in[10:0], adc_miso};
                    if (adc_delay_cnt < ADC_HALF_BIT-1) begin
                        adc_delay_cnt <= adc_delay_cnt + 1;
                    end else begin
                        adc_delay_cnt <= 0;
                        adc_state     <= ADC_BIT_LOW;
                    end
                end
                ADC_BIT_LOW: begin
                    adc_sck <= 1'b0;
                    if (adc_delay_cnt < ADC_HALF_BIT-1) begin
                        adc_delay_cnt <= adc_delay_cnt + 1;
                    end else begin
                        adc_delay_cnt <= 0;
                        if (adc_bit_cnt == ADC_TOTAL_BITS-1) begin
                            adc_state <= ADC_CS_HIGH;
                        end else begin
                            adc_bit_cnt <= adc_bit_cnt + 1;
                            adc_state   <= ADC_BIT_SETUP;
                        end
                    end
                end
                ADC_CS_HIGH: begin
                    adc_cs    <= 1'b1;
                    adc_value <= adc_shift_in;
                    adc_done  <= 1'b1;
                    adc_state <= ADC_IDLE;
                end
                default: adc_state <= ADC_IDLE;
            endcase
        end
end
endmodule