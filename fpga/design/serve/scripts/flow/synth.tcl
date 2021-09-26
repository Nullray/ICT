source [file join $design_dir "pr_prologue.tcl"]

# setting Synthesis options
set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
# keep module port names in the netlist
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]

# HW_VAL can be pr_shell or pr_role for partial reconfiguration flow
if {$val == "pr_shell" || $val == "pr_role"} {
    # synthesize role design
    synth_design -top ${pr_mod} -part ${device} -mode out_of_context
    write_checkpoint ${dcp_dir}/synth-role.dcp -force

    if {$val == "pr_shell"} {
        # add blackbox attribute to pr module
        remove_files ${freedom_file}
        exec sed -e "s/module ${pr_mod}/(*BLACK_BOX*)&/" ${freedom_file} > ${freedom_blackbox_file}
        add_files ${freedom_blackbox_file}

        # synthesize top design
        synth_design -top serve -part ${device}

        # restore original file
        remove_files ${freedom_blackbox_file}
        add_files ${freedom_file}
    }

} else {
    # synthesize top design
    synth_design -top serve -part ${device}
}

# setup output logs and reports
report_utilization -hierarchical -file ${synth_rpt_dir}/synth_util_hier.rpt
report_utilization -file ${synth_rpt_dir}/synth_util.rpt

# write checkpoint
write_checkpoint -force ${dcp_dir}/synth.dcp

