### Nexys Video Constraints File for CPU Debug System
### Target Board: Nexys Video (Artix-7 XC7A200T)
### To use it in a project:
### - uncomment the lines corresponding to used pins
### - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##########################################################################################
# Clock Signal
##########################################################################################
# 100MHz system clock
set_property -dict { PACKAGE_PIN R4    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_34 Sch=sysclk
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# Generated clock for 50MHz
create_generated_clock -name clk_50mhz -source [get_ports clk] -divide_by 2 [get_pins clk_50mhz_bufg/O]

# Clock domain crossing false paths
set_false_path -from [get_clocks clk_50mhz] -to [get_clocks sys_clk_pin]
set_false_path -from [get_clocks sys_clk_pin] -to [get_clocks clk_50mhz]

##########################################################################################
# Reset button (CPU_RESET)
##########################################################################################
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS15 } [get_ports { reset_n }]; #IO_L12N_T1_MRCC_35 Sch=cpu_resetn

##########################################################################################
# UART (uart_tx)
##########################################################################################
## UART
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_in }]; #IO_L14P_T2_SRCC_14 Sch=uart_tx_in
set_property -dict { PACKAGE_PIN AA19  IOSTANDARD LVCMOS33 } [get_ports { uart_tx_in }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=uart_rx_out
##########################################################################################
# Push buttons (5-button navigation)
##########################################################################################
# Center button (BTNC)
set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS12 } [get_ports { btn_center }]; #IO_L20N_T3_16 Sch=btnc

# Up button (BTNU)  
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS12 } [get_ports { btn_up }]; #IO_0_16 Sch=btnu

# Down button (BTND)
set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS12 } [get_ports { btn_down }]; #IO_L22N_T3_16 Sch=btnd

# Left button (BTNL)
set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS12 } [get_ports { btn_left }]; #IO_L20P_T3_16 Sch=btnl

# Right button (BTNR)
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS12 } [get_ports { btn_right }]; #IO_L6P_T0_16 Sch=btnr

##########################################################################################
# LEDs
##########################################################################################
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS25 } [get_ports { led[0] }]; #IO_L15P_T2_DQS_13 Sch=led[0]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS25 } [get_ports { led[1] }]; #IO_L15N_T2_DQS_13 Sch=led[1]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS25 } [get_ports { led[2] }]; #IO_L17P_T2_13 Sch=led[2]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS25 } [get_ports { led[3] }]; #IO_L17N_T2_13 Sch=led[3]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS25 } [get_ports { led[4] }]; #IO_L14N_T2_SRCC_13 Sch=led[4]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS25 } [get_ports { led[5] }]; #IO_L16N_T2_13 Sch=led[5]
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS25 } [get_ports { led[6] }]; #IO_L16P_T2_13 Sch=led[6]
set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS25 } [get_ports { led[7] }]; #IO_L5P_T0_13 Sch=led[7]

##########################################################################################
# Timing constraints
##########################################################################################
# Input delay constraints for buttons 
set_input_delay -clock [get_clocks sys_clk_pin] -min 2.000 [get_ports {btn_*}]
set_input_delay -clock [get_clocks sys_clk_pin] -max 8.000 [get_ports {btn_*}]

# Output delay constraints for LEDs only (OLED는 false path로 처리)
set_output_delay -clock [get_clocks sys_clk_pin] -min 2.000 [get_ports {led[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -max 8.000 [get_ports {led[*]}]

# False path constraints
set_false_path -from [get_ports reset_n]
##########################################################################################
# Configuration constraints
##########################################################################################
# Configuration bank voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Bitstream configuration
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]