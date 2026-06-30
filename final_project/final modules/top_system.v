module top_system #(
    parameter SIM_MODE     = 0,     
    parameter CLKS_PER_BIT = 2500,  
    parameter TONE_FREQ_HZ = 2000   
                                     
)(
    input  wire clk_24mhz,          
    input  wire rst,              
    input  wire esp_tx,              
    output wire esp_rx,              

    output wire [7:0] led,          
    output wire        buzzer,     
    output wire        relay,      

    
    output wire        seg_din,    
    output wire        seg_load,    
   output wire        seg_clk,     

    
    output wire         adc_sck,    
    output wire         adc_mosi,  
    input  wire          adc_miso,  
    output wire         adc_cs,     

    
    output wire          lcd_rs,
    output wire          lcd_rw,    
    output wire          lcd_en,
    output wire [7:0]    lcd_d
);

    
    wire [7:0] rx_data;
    wire       rx_done;

    wire       tx_start;
    wire [7:0] tx_data;
    wire       tx_done;

    wire [7:0] led_code;
    wire       buzz_pulse;
    wire       relay_on_pulse;
    wire       relay_off_pulse;

    wire        adc_start;
    wire        adc_done;
    wire [11:0] adc_value;

    uart_rx #(
        .CLKS_PER_BIT (CLKS_PER_BIT)
    ) u_uart_rx (
        .clk     (clk_24mhz),
        .rst     (rst),
        .rx_pin  (esp_tx),
        .rx_data (rx_data),
        .rx_done (rx_done)
    );

    uart_tx #(
        .CLKS_PER_BIT (CLKS_PER_BIT)
    ) u_uart_tx (
        .clk      (clk_24mhz),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx_line  (esp_rx),
        .tx_done  (tx_done)
    );

    command_decoder u_command_decoder (
        .clk             (clk_24mhz),
        .rst             (rst),
        .rx_done         (rx_done),
        .rx_data         (rx_data),
        .led_code        (led_code),
        .buzz_pulse      (buzz_pulse),
        .relay_on_pulse  (relay_on_pulse),
        .relay_off_pulse (relay_off_pulse)
    );

    led_controller u_led_controller (
        .clk      (clk_24mhz),
        .rst      (rst),
        .led_code (led_code),
        .led      (led)
    );

    buzzer_controller #(
        .SIM_MODE     (SIM_MODE),
        .TONE_FREQ_HZ (TONE_FREQ_HZ)
    ) u_buzzer_controller (
        .clk        (clk_24mhz),
        .rst        (rst),
        .buzz_pulse (buzz_pulse),
        .buzzer     (buzzer)
    );

    relay_controller u_relay_controller (
        .clk             (clk_24mhz),
        .rst             (rst),
        .relay_on_pulse  (relay_on_pulse),
        .relay_off_pulse (relay_off_pulse),
        .relay           (relay)
    );

    response_arbiter u_response_arbiter (
        .clk        (clk_24mhz),
        .rst        (rst),
        .rx_done    (rx_done),
        .rx_data    (rx_data),
        .tx_done    (tx_done),
        .tx_start   (tx_start),
        .tx_data    (tx_data),
        .adc_done   (adc_done),
        .adc_value  (adc_value),
        .adc_start  (adc_start)
    );

    adc_spi_controller #(
        .SIM_MODE (SIM_MODE)
    ) u_adc_spi_controller (
        .clk        (clk_24mhz),
        .rst        (rst),
        .adc_start  (adc_start),
        .adc_done   (adc_done),
        .adc_value  (adc_value),
        .adc_sck    (adc_sck),
        .adc_mosi   (adc_mosi),
        .adc_miso   (adc_miso),
        .adc_cs     (adc_cs)
    );

    max7219_controller #(
        .SIM_MODE (SIM_MODE)
    ) u_max7219_controller (
        .clk      (clk_24mhz),
        .rst      (rst),
        .rx_data  (rx_data),
        .rx_done  (rx_done),
        .seg_din  (seg_din),
        .seg_load (seg_load),
        .seg_clk  (seg_clk)
    );

    lcd_controller #(
        .SIM_MODE (SIM_MODE)
    ) u_lcd_controller (
        .clk      (clk_24mhz),
        .rst      (rst),
        .rx_data  (rx_data),
        .rx_done  (rx_done),
        .lcd_rs   (lcd_rs),
        .lcd_rw   (lcd_rw),
        .lcd_en   (lcd_en),
        .lcd_d    (lcd_d)
    );

endmodule

