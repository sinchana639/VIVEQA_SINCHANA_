module top_system_tb;

    localparam CLK_PERIOD_NS   = 41.667;          // 24 MHz
    localparam TB_CLKS_PER_BIT = 8;               // small => fast simulation
    localparam BIT_PERIOD_NS   = CLK_PERIOD_NS * TB_CLKS_PER_BIT;

    reg  clk = 0;
    reg  rst = 1;
    reg  esp_tx_drive = 1'b1;   // idle high
    wire esp_rx;
    wire [7:0] led;
    wire buzzer;
    wire relay;                 // NEW
    wire seg_din, seg_load, seg_clk;
    wire adc_sck, adc_mosi, adc_cs;
    reg  adc_miso_drive = 1'b0;
    wire adc_miso = adc_miso_drive;
    wire lcd_rs, lcd_rw, lcd_en;
    wire [7:0] lcd_d;

    always #(CLK_PERIOD_NS/2) clk = ~clk;

    top_system #(
        .SIM_MODE     (1),
        .CLKS_PER_BIT (TB_CLKS_PER_BIT)
    ) dut (
        .clk_24mhz (clk),
        .rst       (rst),
        .esp_tx    (esp_tx_drive),
        .esp_rx    (esp_rx),
        .led       (led),
        .buzzer    (buzzer),
        .relay     (relay),     // NEW
        .seg_din   (seg_din),
        .seg_load  (seg_load),
        .seg_clk   (seg_clk),
        .adc_sck   (adc_sck),
        .adc_mosi  (adc_mosi),
        .adc_miso  (adc_miso),
        .adc_cs    (adc_cs),
        .lcd_rs    (lcd_rs),
        .lcd_rw    (lcd_rw),
        .lcd_en    (lcd_en),
        .lcd_d     (lcd_d)
    );

    // ---- Send one byte (8N1) into esp_tx, as if it came from the ESP32 ----
    task send_byte(input [7:0] b);
        integer i;
        begin
            esp_tx_drive = 1'b0;             // start bit
            #(BIT_PERIOD_NS);
            for (i = 0; i < 8; i = i + 1) begin
                esp_tx_drive = b[i];
                #(BIT_PERIOD_NS);
            end
            esp_tx_drive = 1'b1;             // stop bit
            #(BIT_PERIOD_NS);
        end
    endtask

    // ---- Decode bytes the DUT echoes/reports back out on esp_rx ----
    reg [7:0] rx_byte;
    task watch_echo;
        integer i;
        begin
            @(negedge esp_rx);
            #(BIT_PERIOD_NS * 1.5);          // align to middle of bit 0
            for (i = 0; i < 8; i = i + 1) begin
                rx_byte[i] = esp_rx;
                #(BIT_PERIOD_NS);
            end
            $display("[%0t ns] esp_rx byte: 0x%02h (%c)", $time, rx_byte, rx_byte);
        end
    endtask

    initial forever watch_echo;

    // ---- Fake MCP3202: shift out a fixed test value on adc_miso whenever
    // the DUT starts a conversion, timed to the DUT's own SCK edges ----
    task drive_fake_adc(input [11:0] fake_value);
        integer i;
        begin
            adc_miso_drive = 1'b0;
            @(negedge adc_cs);
            repeat (6) @(posedge adc_sck);      // skip 4 config + sample + null bits
            for (i = 11; i >= 0; i = i - 1) begin
                @(negedge adc_sck);
                adc_miso_drive = fake_value[i];
            end
            @(posedge adc_cs);
            adc_miso_drive = 1'b0;
        end
    endtask

    initial forever drive_fake_adc(12'd2048); // arbitrary mid-scale test reading

    initial begin
        $dumpfile("top_system_tb.vcd");
        $dumpvars(0, top_system_tb);

        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
        repeat (5) @(posedge clk);

        // ---- existing tests ----
        $display("[%0t ns] Sending '1' -> expect LED pattern 0x55", $time);
        send_byte("1");
        #(BIT_PERIOD_NS * 12);
        $display("    led = 0x%02h", led);

        $display("[%0t ns] Sending '2' -> expect LED pattern 0xAA", $time);
        send_byte("2");
        #(BIT_PERIOD_NS * 12);
        $display("    led = 0x%02h", led);

        $display("[%0t ns] Sending '0' -> expect LEDs off", $time);
        send_byte("0");
        #(BIT_PERIOD_NS * 12);
        $display("    led = 0x%02h", led);

        $display("[%0t ns] Sending 'B' -> expect buzzer pulse (SIM_MODE shortens it)", $time);
        send_byte("B");
        #(BIT_PERIOD_NS * 12);
        $display("    buzzer = %b", buzzer);

        // ---- NEW: relay tests ----
        $display("[%0t ns] Checking relay defaults OFF after reset", $time);
        if (relay !== 1'b0)
            $display("    *** FAIL: relay = %b, expected 0 ***", relay);
        else
            $display("    OK: relay = %b", relay);

        $display("[%0t ns] Sending 'R' -> expect relay ON", $time);
        send_byte("R");
        #(BIT_PERIOD_NS * 12);
        if (relay !== 1'b1)
            $display("    *** FAIL: relay = %b, expected 1 ***", relay);
        else
            $display("    OK: relay = %b", relay);

        $display("[%0t ns] Sending 'b' (lowercase) -> buzzer again, relay must stay ON", $time);
        send_byte("b");
        #(BIT_PERIOD_NS * 12);
        if (relay !== 1'b1)
            $display("    *** FAIL: relay = %b, expected to stay 1 ***", relay);
        else
            $display("    OK: relay still = %b (unaffected by buzzer command)", relay);

        $display("[%0t ns] Sending 'x' (lowercase) -> expect relay OFF", $time);
        send_byte("x");
        #(BIT_PERIOD_NS * 12);
        if (relay !== 1'b0)
            $display("    *** FAIL: relay = %b, expected 0 ***", relay);
        else
            $display("    OK: relay = %b", relay);

        // ---- existing ADC test ----
        $display("[%0t ns] Sending 'S' -> expect ADC read + decimal report \"2048\\r\\n\"", $time);
        send_byte("S");
        #(BIT_PERIOD_NS * 120); // ADC conversion + 6-byte UART report takes a while

        #(BIT_PERIOD_NS * 20);
        $display("[%0t ns] Simulation complete.", $time);
        $finish;
    end