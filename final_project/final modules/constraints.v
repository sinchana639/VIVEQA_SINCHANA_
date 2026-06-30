-create_clock -period 41.667 -name sys_clk [get_ports clk_24mhz]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk_24mhz]

set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports rst]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports esp_tx]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports esp_rx]

## User LEDs L1-L8
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

## Buzzer
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports buzzer]

## Relay -- on-board relay K1 (SANYOU SRD Form-C), 
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports relay]

## 7-Segment Display (MAX7219 SPI)
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports seg_din]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports seg_load]
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33} [get_ports seg_clk]

## On-board ADC (MCP3202, CH1 = potentiometer RV2)
set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS33} [get_ports adc_sck]
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS33} [get_ports adc_mosi]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports adc_miso]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports adc_cs]

## LCD (16x2, 8-bit mode)
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports lcd_rw]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports lcd_en]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[1]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[3]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[6]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[7]}]
