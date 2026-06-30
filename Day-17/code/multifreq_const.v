set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 5 [get_ports clk]

# LEDs L1-L8
set_property PACKAGE_PIN T2 [get_ports {led[0]}]
set_property PACKAGE_PIN T3 [get_ports {led[1]}]
set_property PACKAGE_PIN M1 [get_ports {led[2]}]
set_property PACKAGE_PIN P1 [get_ports {led[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

