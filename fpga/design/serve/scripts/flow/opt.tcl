source [file join $design_dir "pr_prologue.tcl"]

# setting Implementation options
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
# the following implementation options will increase runtime, but get the best timing results
set_property strategy Performance_Explore [get_runs impl_1]

# HW_VAL can be pr_shell or pr_role for partial reconfiguration flow
if {$val == "pr_role"} {
    open_checkpoint ${dcp_dir}/route-shell.dcp
    read_checkpoint -cell [get_cells -hierarchical ${pr_inst}] ${dcp_dir}/synth-role.dcp

    opt_design

} else {
    # open checkpoint
    open_checkpoint ${dcp_dir}/synth.dcp

    # setup output logs and reports
    report_timing_summary -file ${synth_rpt_dir}/synth_timing.rpt -delay_type max -max_paths 1000

    if {$val == "pr_shell"} {
        set_property HD.RECONFIGURABLE true [get_cells -hierarchical ${pr_inst}]
        read_checkpoint -cell [get_cells -hierarchical ${pr_inst}] ${dcp_dir}/synth-role.dcp

        create_pblock ${pr_inst}_pblock
        resize_pblock ${pr_inst}_pblock -add ${pr_pblock}
        add_cells_to_pblock ${pr_inst}_pblock [get_cells -hierarchical ${pr_inst}] -clear_locs
    }

    # Design optimization
    opt_design

    # Save debug probe file
    write_debug_probes -force ${out_dir}/debug_nets.ltx
}
