
##Switches

set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L7N_T1_AD2N_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L7P_T1_AD2P_35 Sch=sw[1]

##Buttons

set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L4P_T0_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L4N_T0_35 Sch=btn[1]
set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L9N_T1_DQS_AD3N_35 Sch=btn[2]
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L9P_T1_DQS_AD3P_35 Sch=btn[3]

##RISC-V JTAG

set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33    PULLUP TRUE } [get_ports { jtag_tck }];
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33    PULLUP TRUE } [get_ports { jtag_tms }];
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33    PULLUP TRUE } [get_ports { jtag_tdo }];
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33    PULLUP TRUE } [get_ports { jtag_tdi }];
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_IBUF];
