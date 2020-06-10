#========================================================
# Vivado BD design auto run script for mpsoc
# Based on Vivado 2019.1
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 09/06/2020
#========================================================

namespace eval mpsoc_bd_val {
	set design_name mpsoc
	set bd_prefix ${mpsoc_bd_val::design_name}_

	set mig_csv fidus_pl_ddr4_sodimm.csv

	set mig_csv_src ${::script_dir}/../sources/ip_catalog/ddr4_mig/${mig_csv}
	set mig_csv_dest ./${::project_name}/${::project_name}.srcs/sources_1/bd/${mpsoc_bd_val::design_name}/ip/${mpsoc_bd_val::bd_prefix}ddr4_mig_0/${mig_csv}
}


# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${mpsoc_bd_val::design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne ${mpsoc_bd_val::design_name} } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <${mpsoc_bd_val::design_name}> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq ${mpsoc_bd_val::design_name} } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <${mpsoc_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${mpsoc_bd_val::design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <${mpsoc_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <${mpsoc_bd_val::design_name}> in project, so creating one..."

   create_bd_design ${mpsoc_bd_val::design_name}

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <${mpsoc_bd_val::design_name}> as current_bd_design."
   current_bd_design ${mpsoc_bd_val::design_name}

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"${mpsoc_bd_val::design_name}\"."

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
  set_property -dict [ list CONFIG.PSU__USE__M_AXI_GP0 {1} \
				CONFIG.PSU__USE__M_AXI_GP2 {1} \
				CONFIG.PSU__USE__S_AXI_GP2 {1} \
				CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {125} \
				CONFIG.PSU__FPGA_PL1_ENABLE {1} \
				CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {250} \
				CONFIG.PSU__USE__IRQ0 {1} \
				CONFIG.PSU__HIGH_ADDRESS__ENABLE {1} \
				CONFIG.PSU__EXPAND__LOWER_LPS_SLAVES {1} ] $zynq_mpsoc

if {${::board} == "fidus"} {
  # Create instance: AXI PCIe Root Complex
  set xdma_rp_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_rp_0 ]
  set_property -dict [ list CONFIG.mode_selection {Advanced} \
				CONFIG.device_port_type {Root_Port_of_PCI_Express_Root_Complex} \
        			CONFIG.functional_mode {AXI Bridge} \
        			CONFIG.dma_reset_source_sel {Phy_Ready} \
				CONFIG.en_gt_selection {true} \
				CONFIG.select_quad {GTY_Quad_128} \
				CONFIG.pl_link_cap_max_link_width {X4} \
				CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
				CONFIG.axi_addr_width {40} \
				CONFIG.pf0_class_code_sub {04} \
				CONFIG.pf0_bar0_enabled {false} \
				CONFIG.axibar2pciebar_0 {0x00000000A0000000} \
				CONFIG.c_s_axi_supports_narrow_burst {false} \
				CONFIG.plltype {QPLL1} \
				CONFIG.BASEADDR {0x00000000} \
				CONFIG.HIGHADDR {0x007FFFFF} ] $xdma_rp_0

  # Create instance: AXI PCIe Root Complex
  set xdma_rp_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_rp_1 ]
  set_property -dict [ list CONFIG.mode_selection {Advanced} \
				CONFIG.device_port_type {Root_Port_of_PCI_Express_Root_Complex} \
        			CONFIG.functional_mode {AXI Bridge} \
        			CONFIG.dma_reset_source_sel {Phy_Ready} \
				CONFIG.en_gt_selection {true} \
				CONFIG.select_quad {GTY_Quad_129} \
				CONFIG.pl_link_cap_max_link_width {X4} \
				CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
				CONFIG.axi_addr_width {40} \
				CONFIG.pf0_class_code_sub {04} \
				CONFIG.pf0_bar0_enabled {false} \
				CONFIG.axibar2pciebar_0 {0x00000000A0100000} \
				CONFIG.c_s_axi_supports_narrow_burst {false} \
				CONFIG.plltype {QPLL1} \
				CONFIG.BASEADDR {0x00000000} \
				CONFIG.HIGHADDR {0x007FFFFF} ] $xdma_rp_1

} else {
  # Create instance: AXI PCIe Root Complex
  set xdma_rp_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_rp_0 ]
  set_property -dict [ list CONFIG.mode_selection {Advanced} \
				CONFIG.device_port_type {Root_Port_of_PCI_Express_Root_Complex} \
        			CONFIG.functional_mode {AXI Bridge} \
        			CONFIG.dma_reset_source_sel {Phy_Ready} \
				CONFIG.en_gt_selection {true} \
   				CONFIG.pcie_blk_locn {X1Y2} \
				CONFIG.select_quad {GTH_Quad_228} \
				CONFIG.pl_link_cap_max_link_width {X2} \
				CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
				CONFIG.axi_addr_width {40} \
				CONFIG.pf0_class_code_sub {04} \
				CONFIG.pf0_bar0_enabled {false} \
				CONFIG.axibar2pciebar_0 {0x00000000A0000000} \
				CONFIG.c_s_axi_supports_narrow_burst {false} \
				CONFIG.plltype {QPLL1} \
				CONFIG.BASEADDR {0x00000000} \
				CONFIG.HIGHADDR {0x007FFFFF} ] $xdma_rp_0

  # Create instance: AXI PCIe Root Complex
  set xdma_rp_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_rp_1 ]
  set_property -dict [ list CONFIG.mode_selection {Advanced} \
				CONFIG.device_port_type {Root_Port_of_PCI_Express_Root_Complex} \
        			CONFIG.functional_mode {AXI Bridge} \
        			CONFIG.dma_reset_source_sel {Phy_Ready} \
				CONFIG.en_gt_selection {true} \
   				CONFIG.pcie_blk_locn {X1Y2} \
				CONFIG.select_quad {GTH_Quad_229} \
				CONFIG.pl_link_cap_max_link_width {X2} \
				CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
				CONFIG.axi_addr_width {40} \
				CONFIG.pf0_class_code_sub {04} \
				CONFIG.pf0_bar0_enabled {false} \
				CONFIG.axibar2pciebar_0 {0x00000000A0100000} \
				CONFIG.c_s_axi_supports_narrow_burst {false} \
				CONFIG.plltype {QPLL1} \
				CONFIG.BASEADDR {0x00000000} \
				CONFIG.HIGHADDR {0x007FFFFF} ] $xdma_rp_1
}
  # Create instance: Concat
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [list CONFIG.NUM_PORTS {1} CONFIG.IN0_WIDTH {23}] $xlconcat_0

  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [list CONFIG.NUM_PORTS {1} CONFIG.IN0_WIDTH {23}] $xlconcat_1

  # Create instance: AXI IC for AXI-Lite slave instance of PCIe RC
  set axi_ic_pcie_rc_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_pcie_rc_dma ]
  set_property -dict [ list CONFIG.NUM_MI {1} \
				CONFIG.NUM_SI {2} ] $axi_ic_pcie_rc_dma

  set axi_ic_pcie_rc_bar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_pcie_rc_bar ]
  set_property -dict [ list CONFIG.NUM_MI {2} \
				CONFIG.NUM_SI {1} ] $axi_ic_pcie_rc_bar

  set axi_ic_mmio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_mmio ]
  set_property -dict [ list CONFIG.NUM_MI {2} \
				CONFIG.NUM_SI {1} ] $axi_ic_mmio

  # Create instance: IBUFDS_GTE for PCIe RP #0 reference clock
  set pcie_rc_ref_clk_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 pcie_rc_ref_clk_buf_0 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $pcie_rc_ref_clk_buf_0

  # Create instance: IBUFDS_GTE for PCIe RP #1 reference clock
  set pcie_rc_ref_clk_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 pcie_rc_ref_clk_buf_1 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $pcie_rc_ref_clk_buf_1

  # Create instance: system reset for pl_clock0 and PCIe RC 
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 pl_clk_sys_reset

  # Create instance: dcm_locked_gen 
  set dcm_locked_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 dcm_locked_gen ]
  set_property -dict [list CONFIG.C_SIZE {1}] $dcm_locked_gen

#=============================================
# Clock ports
#=============================================

  # gt differential reference clock for pcie rp #0
  set pcie_rc_gt_ref_clk_0 [ create_bd_intf_port -mode slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_rc_gt_ref_clk_0 ]
  set_property -dict [ list config.freq_hz {100000000} ] $pcie_rc_gt_ref_clk_0

  # gt differential reference clock for pcie rp #1
  set pcie_rc_gt_ref_clk_1 [ create_bd_intf_port -mode slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_rc_gt_ref_clk_1 ]
  set_property -dict [ list config.freq_hz {100000000} ] $pcie_rc_gt_ref_clk_1

#=============================================
# Reset ports
#=============================================

  # PCIe RC perst
  create_bd_port -dir O -type rst pcie_rc_perstn_0
  create_bd_port -dir O -type rst pcie_rc_perstn_1

#=============================================
# GT ports
#=============================================

  # PCIe Slot
  create_bd_port -dir I -from 3 -to 0 pcie_exp_rxn_0
  create_bd_port -dir I -from 3 -to 0 pcie_exp_rxp_0
  create_bd_port -dir O -from 3 -to 0 pcie_exp_txn_0
  create_bd_port -dir O -from 3 -to 0 pcie_exp_txp_0

  create_bd_port -dir I -from 3 -to 0 pcie_exp_rxn_1
  create_bd_port -dir I -from 3 -to 0 pcie_exp_rxp_1
  create_bd_port -dir O -from 3 -to 0 pcie_exp_txn_1
  create_bd_port -dir O -from 3 -to 0 pcie_exp_txp_1

#=============================================
# MISC ports
#=============================================

  create_bd_port -dir O pcie_rc_user_link_up_0
  create_bd_port -dir O pcie_rc_user_link_up_1

#=============================================
# System clock connection
#=============================================

  # PCIe RP #0 reference clock
  connect_bd_intf_net -intf_net pcie_rc_gt_ref_clk_0 \
      [get_bd_intf_pins pcie_rc_gt_ref_clk_0] \
      [get_bd_intf_pins pcie_rc_ref_clk_buf_0/CLK_IN_D]

  connect_bd_net -net pcie_rc_ref_clk_0 \
      [get_bd_pins pcie_rc_ref_clk_buf_0/IBUF_DS_ODIV2] \
      [get_bd_pins xdma_rp_0/sys_clk]

  connect_bd_net -net pcie_rc_sys_clk_0 \
      [get_bd_pins pcie_rc_ref_clk_buf_0/IBUF_OUT] \
      [get_bd_pins xdma_rp_0/sys_clk_gt]

  # PCIe RP #1 reference clock
  connect_bd_intf_net -intf_net pcie_rc_gt_ref_clk_1 \
      [get_bd_intf_pins pcie_rc_gt_ref_clk_1] \
      [get_bd_intf_pins pcie_rc_ref_clk_buf_1/CLK_IN_D]

  connect_bd_net -net pcie_rc_ref_clk_1 \
      [get_bd_pins pcie_rc_ref_clk_buf_1/IBUF_DS_ODIV2] \
      [get_bd_pins xdma_rp_1/sys_clk]

  connect_bd_net -net pcie_rc_sys_clk_1 \
      [get_bd_pins pcie_rc_ref_clk_buf_1/IBUF_OUT] \
      [get_bd_pins xdma_rp_1/sys_clk_gt]

  # PCIe RP #0 AXI clock
  connect_bd_net -net pcie_axi_clk [get_bd_pins xdma_rp_0/axi_aclk] \
				[get_bd_pins axi_ic_pcie_rc_dma/S00_ACLK] \
				[get_bd_pins axi_ic_pcie_rc_bar/M00_ACLK] \
				[get_bd_pins axi_ic_mmio/M00_ACLK]

  # PCIe RP #1 AXI clock
  connect_bd_net -net pcie_axi_clk1 [get_bd_pins xdma_rp_1/axi_aclk] \
				[get_bd_pins axi_ic_pcie_rc_dma/S01_ACLK] \
				[get_bd_pins axi_ic_pcie_rc_bar/M01_ACLK] \
				[get_bd_pins axi_ic_mmio/M01_ACLK]

  # MPSoC pl_clk1 for PCIe RC S_AXI and M_AXI related interfaces
  connect_bd_net -net pl_clk1_out [get_bd_pins zynq_mpsoc/pl_clk1] \
				[get_bd_pins axi_ic_pcie_rc_dma/ACLK] \
				[get_bd_pins axi_ic_pcie_rc_dma/M00_ACLK] \
				[get_bd_pins axi_ic_pcie_rc_bar/ACLK] \
				[get_bd_pins axi_ic_pcie_rc_bar/S00_ACLK] \
				[get_bd_pins zynq_mpsoc/maxihpm0_fpd_aclk] \
				[get_bd_pins zynq_mpsoc/saxihp0_fpd_aclk]

  # MMIO AXI IC clock
  connect_bd_net -net pl_clk0_out [get_bd_pins zynq_mpsoc/pl_clk0] \
				[get_bd_pins zynq_mpsoc/maxihpm0_lpd_aclk] \
				[get_bd_pins axi_ic_mmio/ACLK] \
				[get_bd_pins axi_ic_mmio/S00_ACLK] \
				[get_bd_pins pl_clk_sys_reset/slowest_sync_clk]

#=============================================
# System reset connection
#=============================================

  # System reset for AXI PCIe RC bridge
  connect_bd_net -net pl_resetn0 [get_bd_pins zynq_mpsoc/pl_resetn0] \
				[get_bd_pins xdma_rp_0/sys_rst_n] \
				[get_bd_pins xdma_rp_1/sys_rst_n] \
				[get_bd_pins pl_clk_sys_reset/ext_reset_in]

  # Reset for AXI interface of PCIe RP #0
  connect_bd_net -net pcie_rp_0_axi_aresetn [get_bd_pins xdma_rp_0/axi_aresetn] \
				[get_bd_pins axi_ic_pcie_rc_dma/S00_ARESETN] \
				[get_bd_pins axi_ic_pcie_rc_bar/M00_ARESETN] 

  connect_bd_net -net pcie_rp_0_axi_ctl_aresetn [get_bd_pins xdma_rp_0/axi_ctl_aresetn] \
				[get_bd_pins axi_ic_mmio/M00_ARESETN] \
				[get_bd_pins dcm_locked_gen/Op1]

  # Reset for AXI interface of PCIe RP #1
  connect_bd_net -net pcie_rp_1_axi_aresetn [get_bd_pins xdma_rp_1/axi_aresetn] \
				[get_bd_pins axi_ic_pcie_rc_dma/S01_ARESETN] \
				[get_bd_pins axi_ic_pcie_rc_bar/M01_ARESETN] 

  connect_bd_net -net pcie_rp_1_axi_ctl_aresetn [get_bd_pins xdma_rp_1/axi_ctl_aresetn] \
				[get_bd_pins axi_ic_mmio/M01_ARESETN] \
				[get_bd_pins dcm_locked_gen/Op2]

  # Reset for AXI MMIO IC
  connect_bd_net [get_bd_pins dcm_locked_gen/Res] \
        [get_bd_pins pl_clk_sys_reset/dcm_locked]

  connect_bd_net -net axi_mmio_ic_reset_n [get_bd_pins pl_clk_sys_reset/peripheral_aresetn] \
				[get_bd_pins axi_ic_mmio/S00_ARESETN] \
				[get_bd_pins axi_ic_pcie_rc_bar/S00_ARESETN] \
				[get_bd_pins axi_ic_pcie_rc_dma/M00_ARESETN] \
				[get_bd_ports pcie_rc_perstn_0] \
				[get_bd_ports pcie_rc_perstn_1]

  connect_bd_net -net axi_dma_ic_reset [get_bd_pins pl_clk_sys_reset/interconnect_aresetn] \
				[get_bd_pins axi_ic_pcie_rc_dma/ARESETN] \
				[get_bd_pins axi_ic_mmio/ARESETN] \
				[get_bd_pins axi_ic_pcie_rc_bar/ARESETN] \

#=============================================
# AXI interface connection
#=============================================

  # MPSoC HPM0_FPD 
  connect_bd_intf_net -intf_net HPM0_FPD [get_bd_intf_pins zynq_mpsoc/M_AXI_HPM0_FPD] \
				[get_bd_intf_pins axi_ic_pcie_rc_bar/S00_AXI]

  connect_bd_intf_net -intf_net PCIE_RP_0_BAR [get_bd_intf_pins xdma_rp_0/S_AXI_B] \
				[get_bd_intf_pins axi_ic_pcie_rc_bar/M00_AXI]

  connect_bd_intf_net -intf_net PCIE_RP_1_BAR [get_bd_intf_pins xdma_rp_1/S_AXI_B] \
				[get_bd_intf_pins axi_ic_pcie_rc_bar/M01_AXI]

  # MPSoC HPM0_LPD
  connect_bd_intf_net -intf_net HPM0_LPD [get_bd_intf_pins zynq_mpsoc/M_AXI_HPM0_LPD] \
				[get_bd_intf_pins axi_ic_mmio/S00_AXI]

  connect_bd_intf_net -intf_net PCIE_RP_0_MMIO [get_bd_intf_pins xdma_rp_0/S_AXI_LITE] \
				[get_bd_intf_pins axi_ic_mmio/M00_AXI]

  connect_bd_intf_net -intf_net PCIE_RP_1_MMIO [get_bd_intf_pins xdma_rp_1/S_AXI_LITE] \
				[get_bd_intf_pins axi_ic_mmio/M01_AXI]

  connect_bd_net [get_bd_pins axi_ic_mmio/M01_AXI_araddr] [get_bd_pins xlconcat_0/In0]
  connect_bd_net [get_bd_pins axi_ic_mmio/M01_AXI_awaddr] [get_bd_pins xlconcat_1/In0]

  connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins xdma_rp_1/s_axil_araddr]
  connect_bd_net [get_bd_pins xlconcat_1/dout] [get_bd_pins xdma_rp_1/s_axil_awaddr]

  # MPSoC HP0_FPD
  connect_bd_intf_net -intf_net HP0_FPD [get_bd_intf_pins zynq_mpsoc/S_AXI_HP0_FPD] \
				[get_bd_intf_pins axi_ic_pcie_rc_dma/M00_AXI]

  connect_bd_intf_net -intf_net PCIE_RP_0_DMA [get_bd_intf_pins xdma_rp_0/M_AXI_B] \
				[get_bd_intf_pins axi_ic_pcie_rc_dma/S00_AXI]

  connect_bd_intf_net -intf_net PCIE_RP_1_DMA [get_bd_intf_pins xdma_rp_1/M_AXI_B] \
				[get_bd_intf_pins axi_ic_pcie_rc_dma/S01_AXI]

#==============================================
# GT Port connection
#==============================================

  # PCIe #0 slot
  connect_bd_net [get_bd_ports pcie_exp_rxn_0] [get_bd_pins xdma_rp_0/pci_exp_rxn]
  connect_bd_net [get_bd_ports pcie_exp_rxp_0] [get_bd_pins xdma_rp_0/pci_exp_rxp]
  connect_bd_net [get_bd_ports pcie_exp_txn_0] [get_bd_pins xdma_rp_0/pci_exp_txn]
  connect_bd_net [get_bd_ports pcie_exp_txp_0] [get_bd_pins xdma_rp_0/pci_exp_txp]

  # PCIe #1 slot
  connect_bd_net [get_bd_ports pcie_exp_rxn_1] [get_bd_pins xdma_rp_1/pci_exp_rxn]
  connect_bd_net [get_bd_ports pcie_exp_rxp_1] [get_bd_pins xdma_rp_1/pci_exp_rxp]
  connect_bd_net [get_bd_ports pcie_exp_txn_1] [get_bd_pins xdma_rp_1/pci_exp_txn]
  connect_bd_net [get_bd_ports pcie_exp_txp_1] [get_bd_pins xdma_rp_1/pci_exp_txp]

#=============================================
# Interrupt signal connection
#=============================================

  # Create instance: concat_intr, and set properties
  set concat_intr [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_intr ]
  set_property -dict [ list CONFIG.NUM_PORTS {2} ] $concat_intr
	  
  connect_bd_net [get_bd_pins xdma_rp_0/interrupt_out] [get_bd_pins concat_intr/In0]
  connect_bd_net [get_bd_pins xdma_rp_1/interrupt_out] [get_bd_pins concat_intr/In1]
  connect_bd_net [get_bd_pins concat_intr/dout] [get_bd_pins zynq_mpsoc/pl_ps_irq0]

#=============================================
# MISC port connection
#=============================================

  connect_bd_net [get_bd_ports pcie_rc_user_link_up_0] [get_bd_pins xdma_rp_0/user_lnk_up]
  connect_bd_net [get_bd_ports pcie_rc_user_link_up_1] [get_bd_pins xdma_rp_1/user_lnk_up]

#=============================================
# Address segments
#=============================================
  
  # AXI PCIe RP #0 M_AXI
  create_bd_addr_seg -range 0x80000000 -offset 0x0 [get_bd_addr_spaces xdma_rp_0/M_AXI_B] [get_bd_addr_segs zynq_mpsoc/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW_0
  create_bd_addr_seg -range 0x400000000 -offset 0x800000000 [get_bd_addr_spaces xdma_rp_0/M_AXI_B] [get_bd_addr_segs zynq_mpsoc/SAXIGP2/HP0_DDR_HIGH] HP0_DDR_HIGH_0

  # AXI PCIe RP #1 M_AXI
  create_bd_addr_seg -range 0x80000000 -offset 0x0 [get_bd_addr_spaces xdma_rp_1/M_AXI_B] [get_bd_addr_segs zynq_mpsoc/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW_1
  create_bd_addr_seg -range 0x400000000 -offset 0x800000000 [get_bd_addr_spaces xdma_rp_1/M_AXI_B] [get_bd_addr_segs zynq_mpsoc/SAXIGP2/HP0_DDR_HIGH] HP0_DDR_HIGH_1

  # Zynq MPSoC
  create_bd_addr_seg -range 0x800000 -offset 0x80000000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs xdma_rp_0/S_AXI_LITE/CTL0] PCIE_RC_CTL_0
  create_bd_addr_seg -range 0x800000 -offset 0x80800000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs xdma_rp_1/S_AXI_LITE/CTL0] PCIE_RC_CTL_1

  create_bd_addr_seg -range 0x00100000 -offset 0xA0000000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs xdma_rp_0/S_AXI_B/BAR0] PCIE_RC_BAR0_0
  create_bd_addr_seg -range 0x00100000 -offset 0xA0100000 [get_bd_addr_spaces zynq_mpsoc/Data] [get_bd_addr_segs xdma_rp_1/S_AXI_B/BAR0] PCIE_RC_BAR0_1

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

