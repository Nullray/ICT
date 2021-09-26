
if {${board} == "nf" || ${board} == "fidus"} {
	set serve i
} elseif {${board} == "ultraz"} {
	set serve s
} elseif {${board} == "pynq"} {
	set serve r
} elseif {${board} == "serve_d"} {
	set serve d
}

# add common HDL source files of rocketchip
add_files ${script_dir}/../design/${prj}/sources/hdl/freedom/

# add top module 
add_files ${script_dir}/../design/${prj}/sources/hdl/serve_top/serve_${serve}.v

if {${serve} == "i"} {
	source [file join ${design_dir}/serve_setup "serve_i.tcl"]
} else {
	source [file join ${design_dir}/serve_setup "serve.tcl"]
}

