
################################################################
# Vivado BD design auto script for SERVE.r platform
#
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 25/12/2019
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}

# CHANGE DESIGN NAME HERE
variable design_name
set design_name ${::prj_name}_system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

#=============================================
# Create IP blocks
#=============================================

  # Create instance: Zynq MPSoC
  set zynq_mpsoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_mpsoc ]
  apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1"} $zynq_mpsoc

  set_property -dict [ list CONFIG.PSU__USE__S_AXI_GP2 {1} \
					CONFIG.PSU__USE__S_AXI_GP3 {1} \
					CONFIG.PSU__USE__S_AXI_GP4 {1} \
					CONFIG.PSU__USE__S_AXI_GP5 {1} \
					CONFIG.PSU__USE__S_AXI_GP6 {1} \
					CONFIG.PSU__USE__M_AXI_GP0 {1} \
					CONFIG.PSU__USE__M_AXI_GP1 {1} \
					CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
					CONFIG.PSU__MAXIGP1__DATA_WIDTH {128} \
					CONFIG.PSU__MAXIGP2__DATA_WIDTH {32} \
					CONFIG.PSU__SAXIGP2__DATA_WIDTH {64} \
					CONFIG.PSU__SAXIGP3__DATA_WIDTH {64} \
					CONFIG.PSU__SAXIGP4__DATA_WIDTH {64} \
					CONFIG.PSU__SAXIGP5__DATA_WIDTH {64} \
					CONFIG.PSU__SAXIGP6__DATA_WIDTH {64} \
					CONFIG.PSU__IRQ_P2F_UART0__INT {1} \
					CONFIG.PSU__IRQ_P2F_SDIO1__INT {1} \
					CONFIG.PSU__IRQ_P2F_ENT3__INT {1} \
					CONFIG.PSU__EXPAND__LOWER_LPS_SLAVES {1} \
					CONFIG.PSU__EXPAND__UPPER_LPS_SLAVES {1} \
					CONFIG.PSU__EXPAND__GIC {1} \
					CONFIG.PSU__EXPAND__FPD_SLAVES {1} \
					CONFIG.PSU__DDR_SW_REFRESH_ENABLED {0} \
					CONFIG.PSU__GEN_IPI_7__MASTER {S_AXI_LPD} \
					CONFIG.PSU__GEN_IPI_8__MASTER {S_AXI_LPD} \
					CONFIG.PSU__GEN_IPI_9__MASTER {S_AXI_LPD} \
					CONFIG.PSU__GEN_IPI_10__MASTER {S_AXI_LPD} \
					] $zynq_mpsoc

  # Create instance: rst_zynq_mpsoc_99M, and set properties
  set rst_zynq_mpsoc_99M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_zynq_mpsoc_99M ]

  # Create interconnect
  set io_ps_axi_ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 io_ps_axi_ic ]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $io_ps_axi_ic

  set io_front_0_axi_ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 io_front_0_axi_ic ]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $io_front_0_axi_ic

  set io_front_1_axi_ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 io_front_1_axi_ic ]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $io_front_1_axi_ic

#=============================================
# Clock ports
#=============================================
  # PS FCLK0 output
  create_bd_port -dir O -type clk FCLK_CLK0

#==============================================
# Reset ports
#==============================================
  #PL system reset using PS-PL user_reset_n signal
  create_bd_port -dir O -from 0 -to 0 -type rst FCLK_RESET0_N
  create_bd_port -dir O -from 0 -to 0 -type rst soc_reset

  set_property CONFIG.ASSOCIATED_RESET {FCLK_RESET0_N:soc_reset} [get_bd_ports FCLK_CLK0]

  # soc_reset_reg used to generate reset signal for RISC-V SoC
  set soc_reset_reg [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 soc_reset_reg ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_DOUT_DEFAULT {0x00000001} \
   CONFIG.C_GPIO_WIDTH {1} \
  ] $soc_reset_reg

#==============================================
# Export AXI Interface
#==============================================
  # io_front used to access RISC-V cache coherent interface for DMA engines in PS
  set io_front_axi_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 io_front_axi_0]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.NUM_READ_OUTSTANDING {8} \
				CONFIG.NUM_WRITE_OUTSTANDING {8} \
				CONFIG.ADDR_WIDTH {36} \
				CONFIG.DATA_WIDTH {64} ] $io_front_axi_0

  set io_front_axi_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 io_front_axi_1]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.NUM_READ_OUTSTANDING {8} \
				CONFIG.NUM_WRITE_OUTSTANDING {8} \
				CONFIG.ADDR_WIDTH {36} \
				CONFIG.DATA_WIDTH {64} ] $io_front_axi_1

  # mem_axi used to access PS DDR memory
  set mem_axi_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mem_axi_0]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {64} \
				CONFIG.ID_WIDTH {4} ] $mem_axi_0

  set mem_axi_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mem_axi_1]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {64} \
				CONFIG.ID_WIDTH {4} ] $mem_axi_1

  # mmio_axi used to access I/O periphral controllers
  set mmio_axi_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mmio_axi_0 ]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {64} \
				CONFIG.ID_WIDTH {4} ] $mmio_axi_0

  set mmio_axi_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mmio_axi_1 ]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {64} \
				CONFIG.ID_WIDTH {4} ] $mmio_axi_1

  set mmio_axi_2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mmio_axi_2 ]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {64} \
				CONFIG.ID_WIDTH {4} ] $mmio_axi_2

  set_property CONFIG.ASSOCIATED_BUSIF {io_front_axi_0:io_front_axi_1:mem_axi_0:mem_axi_1:mmio_axi_0:mmio_axi_1:mmio_axi_2} [get_bd_ports FCLK_CLK0]

#=============================================
# System clock connection
#=============================================
  connect_bd_net -net armv8_ps_fclk_0 [get_bd_pin zynq_mpsoc/pl_clk0] \
			[get_bd_pins FCLK_CLK0] \
			[get_bd_pins zynq_mpsoc/maxihpm0_lpd_aclk] \
			[get_bd_pins zynq_mpsoc/maxihpm0_fpd_aclk] \
			[get_bd_pins zynq_mpsoc/maxihpm1_fpd_aclk] \
			[get_bd_pins zynq_mpsoc/saxihp0_fpd_aclk] \
			[get_bd_pins zynq_mpsoc/saxihp1_fpd_aclk] \
			[get_bd_pins zynq_mpsoc/saxihp2_fpd_aclk] \
			[get_bd_pins zynq_mpsoc/saxihp3_fpd_aclk] \
			[get_bd_pins zynq_mpsoc/saxi_lpd_aclk] \
			[get_bd_pins soc_reset_reg/s_axi_aclk] \
			[get_bd_pins io_front_0_axi_ic/*ACLK] \
			[get_bd_pins io_front_1_axi_ic/*ACLK] \
			[get_bd_pins io_ps_axi_ic/*ACLK] \
			[get_bd_pins rst_zynq_mpsoc_99M/slowest_sync_clk]

#=============================================
# System reset connection
#=============================================
  connect_bd_net -net ps_user_reset_n [get_bd_pins zynq_mpsoc/pl_resetn0] \
			[get_bd_pins rst_zynq_mpsoc_99M/ext_reset_in]

  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn \
			[get_bd_pins rst_zynq_mpsoc_99M/peripheral_aresetn] \
			[get_bd_pins FCLK_RESET0_N] \
			[get_bd_pins soc_reset_reg/s_axi_aresetn] \
			[get_bd_pins io_front_0_axi_ic/*_ARESETN] \
			[get_bd_pins io_front_1_axi_ic/*_ARESETN] \
			[get_bd_pins io_ps_axi_ic/*_ARESETN]

  connect_bd_net -net proc_sys_reset_0_ic_aresetn \
			[get_bd_pins rst_zynq_mpsoc_99M/interconnect_aresetn] \
			[get_bd_pins io_front_0_axi_ic/ARESETN] \
			[get_bd_pins io_front_1_axi_ic/ARESETN] \
			[get_bd_pins io_ps_axi_ic/ARESETN]

#==============================================
# AXI Interface Connection
#==============================================
  connect_bd_intf_net -intf_net soc_reset_reg_s [get_bd_intf_pins soc_reset_reg/S_AXI] \
			[get_bd_intf_pins io_ps_axi_ic/M00_AXI] 

  connect_bd_intf_net -intf_net armv8_ps_io_axi_s [get_bd_intf_pins io_ps_axi_ic/S00_AXI] \
			[get_bd_intf_pins zynq_mpsoc/M_AXI_HPM0_LPD] 

  connect_bd_intf_net -intf_net io_front_0_axi_m [get_bd_intf_ports io_front_axi_0] \
			[get_bd_intf_pins io_front_0_axi_ic/M00_AXI] 

  connect_bd_intf_net -intf_net io_front_0_axi_s [get_bd_intf_pins io_front_0_axi_ic/S00_AXI] \
			[get_bd_intf_pins zynq_mpsoc/M_AXI_HPM1_FPD] 

  connect_bd_intf_net -intf_net io_front_1_axi_m [get_bd_intf_ports io_front_axi_1] \
			[get_bd_intf_pins io_front_1_axi_ic/M00_AXI] 

  connect_bd_intf_net -intf_net io_front_1_axi_s [get_bd_intf_pins io_front_1_axi_ic/S00_AXI] \
			[get_bd_intf_pins zynq_mpsoc/M_AXI_HPM0_FPD] 

  connect_bd_intf_net -intf_net mem_axi_0 [get_bd_intf_ports mem_axi_0] \
			[get_bd_intf_pins zynq_mpsoc/S_AXI_HP0_FPD] 

  connect_bd_intf_net -intf_net mem_axi_1 [get_bd_intf_ports mem_axi_1] \
			[get_bd_intf_pins zynq_mpsoc/S_AXI_HP1_FPD] 

  connect_bd_intf_net -intf_net mmio_axi_1 [get_bd_intf_ports mmio_axi_1] \
			[get_bd_intf_pins zynq_mpsoc/S_AXI_HP2_FPD] 

  connect_bd_intf_net -intf_net mmio_axi_2 [get_bd_intf_ports mmio_axi_2] \
			[get_bd_intf_pins zynq_mpsoc/S_AXI_HP3_FPD] 

  connect_bd_intf_net -intf_net mmio_axi_0 [get_bd_intf_ports mmio_axi_0] \
			[get_bd_intf_pins zynq_mpsoc/S_AXI_LPD] 

#=============================================
# Other ports
#=============================================
  connect_bd_net [get_bd_pins soc_reset_reg/gpio_io_o] [get_bd_pins soc_reset]
  make_bd_pins_external [get_bd_pins zynq_mpsoc/ps_pl_irq_enet3]
  make_bd_pins_external [get_bd_pins zynq_mpsoc/ps_pl_irq_uart0]
  make_bd_pins_external [get_bd_pins zynq_mpsoc/ps_pl_irq_sdio1]

#=============================================
# Create address segments
#=============================================

  create_bd_addr_seg -range 0x00001000 -offset 0x83C00000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs soc_reset_reg/S_AXI/Reg] SEG_axi_gpio_0_Reg

  create_bd_addr_seg -range 0x10000000 -offset 0xB0000000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs io_front_axi_0/Reg] SEG_front_0_M_AXI_Reg
  create_bd_addr_seg -range 0x40000000 -offset 0x400000000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs io_front_axi_1/Reg] SEG_front_1_M_AXI_Reg

  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces mem_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP2/HP0_DDR_LOW] SEG_HP0_DDR_LOW
  create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces mem_axi_1] [get_bd_addr_segs zynq_mpsoc/SAXIGP3/HP1_DDR_LOW] SEG_HP1_DDR_LOW
  
  create_bd_addr_seg -range 0x1000000 -offset 0xFD000000 [get_bd_addr_spaces mmio_axi_1] [get_bd_addr_segs zynq_mpsoc/SAXIGP4/HP2_FPD_SLAVES] SEG_FPD_MMIO_1
  create_bd_addr_seg -range 0x1000 -offset 0x0FF00000 [get_bd_addr_spaces mmio_axi_1] [get_bd_addr_segs zynq_mpsoc/SAXIGP4/HP2_DDR_LOW] SEG_FPD_APU_RR_1

  create_bd_addr_seg -range 0x10000000 -offset 0xE0000000 [get_bd_addr_spaces mmio_axi_2] [get_bd_addr_segs zynq_mpsoc/SAXIGP5/HP3_PCIE_LOW] SEG_FPD_MMIO_2

  create_bd_addr_seg -range 0x10000 -offset 0xFF000000 [get_bd_addr_spaces mmio_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP6/LPD_UART0] SEG_LPD_UART0
  create_bd_addr_seg -range 0x10000 -offset 0xFF170000 [get_bd_addr_spaces mmio_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP6/LPD_SD1] SEG_LPD_SD1
  create_bd_addr_seg -range 0x10000 -offset 0xFF0E0000 [get_bd_addr_spaces mmio_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP6/LPD_GEM3] SEG_LPD_GEM3
  create_bd_addr_seg -range 0x10000 -offset 0xFF990000 [get_bd_addr_spaces mmio_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP6/LPD_IPI_BUFFERS] SEG_LPD_IPI_BUF
  create_bd_addr_seg -range 0x100000 -offset 0xFF300000 [get_bd_addr_spaces mmio_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP6/LPD_IPI] SEG_LPD_IPI
  create_bd_addr_seg -range 0x100000 -offset 0xFF500000 [get_bd_addr_spaces mmio_axi_0] [get_bd_addr_segs zynq_mpsoc/SAXIGP6/LPD_CRL_APB] SEG_LPD_CRL_APB

#=============================================
# Finish BD creation 
#=============================================

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

