
################################################################
# BRAM subsystem leveraged as a shared buffer 
# between ZynqMP and RISC-V
#
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 06/10/2020
################################################################

namespace eval bram_bd_val {
	set design_name bram
	set bd_prefix ${bram_bd_val::design_name}_
}

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${bram_bd_val::design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne ${bram_bd_val::design_name} } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <${bram_bd_val::design_name}> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq ${bram_bd_val::design_name} } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <${bram_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${bram_bd_val::design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <${bram_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <${bram_bd_val::design_name}> in project, so creating one..."

   create_bd_design ${bram_bd_val::design_name}

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <${bram_bd_val::design_name}> as current_bd_design."
   current_bd_design ${bram_bd_val::design_name}

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"${bram_bd_val::design_name}\"."

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

  # Create interconnect
  set bram_axi_ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 bram_axi_ic ]
  set_property -dict [list CONFIG.NUM_MI {1} \
				CONFIG.NUM_SI {2} ] $bram_axi_ic

#=============================================
# Clock ports
#=============================================
  # PS FCLK0 output
  create_bd_port -dir I -type clk FCLK_CLK0
  set_property -dict [ list CONFIG.FREQ_HZ {133332001} ] [get_bd_ports FCLK_CLK0]

#==============================================
# Reset ports
#==============================================
  #PL system reset using PS-PL user_reset_n signal
  create_bd_port -dir I -from 0 -to 0 -type rst FCLK_RESET0_N
  create_bd_port -dir I -from 0 -to 0 -type rst FCLK_IC_RESET0_N

  set_property CONFIG.ASSOCIATED_RESET {FCLK_RESET0_N:FCLK_IC_RESET0_N} [get_bd_ports FCLK_CLK0]

#==============================================
# AXI Slaves
#==============================================

  # axi_bram_ctrl used to control blk_mem_shared
  set axi_bram_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl ]
  set_property -dict [ list \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
  ] $axi_bram_ctrl

  # blk_mem_shared used as RV-ARM shared buffer
  set blk_ram_shared [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_shared ]

#==============================================
# Export AXI Interface
#==============================================

  # mem_axi used to access PS DDR memory
  set bram_axi_ps [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 bram_axi_ps]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {32} \
				CONFIG.NUM_READ_OUTSTANDING {8} \
				CONFIG.NUM_WRITE_OUTSTANDING {8} \
        CONFIG.ARUSER_WIDTH {16} \
        CONFIG.AWUSER_WIDTH {16} \
				CONFIG.ID_WIDTH {16} \
        CONFIG.HAS_REGION {0} ] $bram_axi_ps

  set bram_axi_rv [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 bram_axi_rv]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4} \
				CONFIG.ADDR_WIDTH {32} \
				CONFIG.DATA_WIDTH {32} \
				CONFIG.NUM_READ_OUTSTANDING {2} \
				CONFIG.NUM_WRITE_OUTSTANDING {2} \
				CONFIG.ID_WIDTH {0} \
        CONFIG.HAS_REGION {0} ] $bram_axi_rv

  set_property CONFIG.ASSOCIATED_BUSIF {bram_axi_ps:bram_axi_rv} [get_bd_ports FCLK_CLK0]

#=============================================
# System clock connection
#=============================================

  connect_bd_net -net armv8_ps_fclk_0 [get_bd_pins FCLK_CLK0] \
			[get_bd_pins axi_bram_ctrl/s_axi_aclk] \
			[get_bd_pins bram_axi_ic/*ACLK]

#=============================================
# System reset connection
#=============================================

  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn \
			[get_bd_pins FCLK_RESET0_N] \
			[get_bd_pins axi_bram_ctrl/s_axi_aresetn] \
			[get_bd_pins bram_axi_ic/*_ARESETN]

  connect_bd_net -net proc_sys_reset_0_ic_aresetn \
			[get_bd_pins FCLK_IC_RESET0_N] \
			[get_bd_pins bram_axi_ic/ARESETN]

#==============================================
# AXI Interface Connection
#==============================================
  connect_bd_intf_net -intf_net bram_ps [get_bd_intf_ports bram_axi_ps] \
			[get_bd_intf_pins bram_axi_ic/S00_AXI]

  connect_bd_intf_net -intf_net bram_rv [get_bd_intf_ports bram_axi_rv] \
			[get_bd_intf_pins bram_axi_ic/S01_AXI]

  connect_bd_intf_net -intf_net bram_axi [get_bd_intf_pins bram_axi_ic/M00_AXI] \
			[get_bd_intf_pins axi_bram_ctrl/S_AXI]

#=============================================
# Other ports
#=============================================
  connect_bd_intf_net -intf_net bram_port [get_bd_intf_pins axi_bram_ctrl/BRAM_PORTA] \
      [get_bd_intf_pins blk_mem_shared/BRAM_PORTA]

#=============================================
# Create address segments
#=============================================

  create_bd_addr_seg -range 0x00001000 -offset 0x80000000 [get_bd_addr_spaces bram_axi_ps] [get_bd_addr_segs axi_bram_ctrl/S_AXI/Mem0] SEG_axi_bram_arm
  create_bd_addr_seg -range 0x00001000 -offset 0x80000000 [get_bd_addr_spaces bram_axi_rv] [get_bd_addr_segs axi_bram_ctrl/S_AXI/Mem0] SEG_axi_bram_rv

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

