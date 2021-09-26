set_property -dict { PACKAGE_PIN W13  IOSTANDARD LVCMOS18 } [get_ports { r_debug }];
set_property -dict { PACKAGE_PIN AE11 IOSTANDARD LVCMOS18 } [get_ports { jtag_tck }];
set_property -dict { PACKAGE_PIN AF12 IOSTANDARD LVCMOS18 } [get_ports { jtag_tms }];
set_property -dict { PACKAGE_PIN AD11 IOSTANDARD LVCMOS18 } [get_ports { jtag_tdo }];
set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVCMOS18 } [get_ports { jtag_tdi }];
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_IBUF];
