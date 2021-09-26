source [file join $design_dir/flow "pr_prologue.tcl"]

# routing
route_design

write_checkpoint -force ${dcp_dir}/route.dcp

report_utilization -file ${impl_rpt_dir}/post_route_util.rpt
report_timing_summary -file ${impl_rpt_dir}/post_route_timing.rpt -delay_type max -max_paths 1000

report_route_status -file ${impl_rpt_dir}/post_route_status.rpt

# HW_VAL can be pr_shell or pr_role for partial reconfiguration flow
if {$val == "pr_shell" || $val == "pr_role"} {
    write_checkpoint -cell [get_cells -hierarchical ${pr_inst}] ${dcp_dir}/route-role.dcp -force

    write_bitstream -cell [get_cells -hierarchical ${pr_inst}] ${hw_plat_dir}/role.bit -force
    write_cfgmem -format BIN -interface SMAPx32 -disablebitswap \
        -loadbit "up 0x0 ${hw_plat_dir}/role.bit" -force ${hw_plat_dir}/role.bit.bin

    if {$val == "pr_shell"} {
        update_design -cell [get_cells -hierarchical ${pr_inst}] -black_box 
        lock_design -level routing
        write_checkpoint ${dcp_dir}/route-shell.dcp -force

        read_checkpoint -cell [get_cells -hierarchical ${pr_inst}] ${dcp_dir}/route-role.dcp
    }
}
