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

source [file join $script_dir "flow/prologue.tcl"]

#====================
# Main flow
#====================
if {$act == "prj_gen"} {
	# project setup
	source [file join $script_dir "flow/prj_setup.tcl"]
	
	# Generate HDF
	write_hwdef -force -file ${out_dir}/system.hdf
	
	close_project

} elseif {$act == "run_syn"} {
	open_project ${prj_file}

	source [file join $script_dir "flow/synth.tcl"]

	close_project

} elseif {$act == "bit_gen"} {
	open_project ${prj_file}
	# Design optimization
	source [file join $script_dir "flow/opt.tcl"]
	# Placement
	source [file join $script_dir "flow/place.tcl"]
	# routing
	source [file join $script_dir "flow/route.tcl"]
	# bitstream generation
	write_bitstream -force ${out_dir}/system.bit

} elseif {$act == "dcp_chk"} {
	if {$val != "synth" && $val != "place" && $val != "route"} {
		puts "Error: Please specify the name of .dcp file to be opened"
		exit
	}
	open_checkpoint ${dcp_dir}/${val}.dcp

} else {
	puts "No specified action command for Vivado project"
	exit
}
