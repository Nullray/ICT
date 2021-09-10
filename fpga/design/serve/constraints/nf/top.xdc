set_property -dict {PACKAGE_PIN H21 IOSTANDARD LVCMOS18} [get_ports {TDO}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS18} [get_ports {TMS}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS18} [get_ports {TCK}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS18} [get_ports {TDI}]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS18} [get_ports {MODE}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {TCK_IBUF_inst/O}]
