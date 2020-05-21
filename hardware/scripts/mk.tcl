#========================================================
# Vivado project auto run script for mpsoc_kvs_platform
# Based on Vivado 2019.1
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 19/05/2020
#========================================================

# parsing argument
if {$argc != 3} {
	puts "Error: The argument should be hw_act val output_dir"
	exit
} else {
	set act [lindex $argv 0]
	set val [lindex $argv 1]
	set out_dir [lindex $argv 2]
}

set script_dir [file dirname [info script]]

set project_name mpsoc_nf_platform
set bd_name mpsoc
set prj_file ${project_name}/${project_name}.xpr

set device xczu19eg-ffvc1760-2-e
#set board nf_card:none:part0:2.0

set ip_repo ${script_dir}/../sources/ip_repo
set main_constraints ${script_dir}/../sources/constraints/${project_name}.xdc

set synth_rpt_dir ${script_dir}/../vivado_out/synth_rpt
set impl_rpt_dir ${script_dir}/../vivado_out/impl_rpt
set dcp_dir ${script_dir}/../vivado_out/dcp

#========================================================
# process for create block design
#========================================================
proc create_bd { bd_design } {

	set_property synth_checkpoint_mode None [get_files ./${::project_name}/${::project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
	generate_target all [get_files ./${::project_name}/${::project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]

	make_wrapper -files [get_files ./${::project_name}/${::project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
	import_files -force -norecurse -fileset sources_1 ./${::project_name}/${::project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v
	
	validate_bd_design
	save_bd_design
	close_bd_design ${bd_design}
}

#========================================================
# Main flow
#========================================================

if {$act == "run_syn"} {
	open_project ${prj_file}

	#synth_ip [get_ips axi_interconnect_ip]
	#synth_ip [get_ips axi_datamover_0]
	synth_design -top ${bd_name}_wrapper -part ${device}

	# setup output logs and reports
	write_checkpoint -force ${dcp_dir}/synth.dcp

	report_utilization -hierarchical -file ${synth_rpt_dir}/synth_util_hier.rpt
	report_utilization -file ${synth_rpt_dir}/synth_util.rpt
	report_timing_summary -file ${synth_rpt_dir}/synth_timing.rpt -delay_type max -max_paths 1000

	close_project

} elseif {$act == "dcp_chk"} {
	if {$val != "synth" && $val != "place" && $val != "route"} {
		puts "Error: Please specify the name of .dcp file to be opened"
		exit
	}
	open_checkpoint ${dcp_dir}/${val}.dcp

} elseif {$act == "bit_gen"} {
	# Open post-synthesis checkpoint	
	open_checkpoint ${dcp_dir}/synth.dcp

	# Save debug probe file
	write_debug_probes -force ${out_dir}/debug_nets.ltx

	# Design optimization
	opt_design

	# Placement
	place_design

	report_clock_utilization -file ${impl_rpt_dir}/clock_util.rpt

	# Physical design optimization
	phys_opt_design
		
	write_checkpoint -force ${dcp_dir}/place.dcp

	report_utilization -file ${impl_rpt_dir}/post_place_util.rpt
	report_timing_summary -file ${impl_rpt_dir}/post_place_timing.rpt -delay_type max -max_paths 1000

	# routing
	route_design

	write_checkpoint -force ${dcp_dir}/route.dcp

	report_utilization -file ${impl_rpt_dir}/post_route_util.rpt
	report_timing_summary -file ${impl_rpt_dir}/post_route_timing.rpt -delay_type max -max_paths 1000

	report_route_status -file ${impl_rpt_dir}/post_route_status.rpt

	# bitstream generation
	write_bitstream -force ${out_dir}/system.bit

} elseif {$act == "prj_gen"} {
	# create a new project
	# set up the project
	create_project ${project_name} -force -dir "./${project_name}" -part ${device}
	#set_property board_part ${board} [current_project]

	# set custom IP repo path
	set_property ip_repo_paths ${ip_repo} [current_fileset]
	update_ip_catalog -rebuild
	
	# create block design
	source ${script_dir}/mpsoc.tcl
	create_bd ${bd_name}

	# add and set top module for FPGA flow
	#add_files ${script_dir}/../sources/hdl/${project_name}.v

	#set_property "top" ${project_name} [get_filesets sources_1]
	
	# constraints files
	#add_files -fileset constrs_1 -norecurse ${main_constraints}
	
	# setting Synthesis options
	set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
	# keep module port names in the netlist
	set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]
	
	# setting Implementation options
	set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
	# the following implementation options will increase runtime, but get the best timing results
	set_property strategy Performance_Explore [get_runs impl_1]

	# Generate HDF
	write_hwdef -force -file ${out_dir}/system.hdf

	close_project

} else {
	puts "No specified action command for Vivado project"
	exit
}
