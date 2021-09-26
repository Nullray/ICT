# setting Synthesis options
set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
# keep module port names in the netlist
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]

# synthesize shell
set_property top mpsoc_wrapper [current_fileset]
update_compile_order -fileset [current_fileset]
synth_design -top mpsoc_wrapper -part ${device}

# setup output logs and reports
report_utilization -hierarchical -file ${synth_rpt_dir}/synth_util_hier.rpt
report_utilization -file ${synth_rpt_dir}/synth_util.rpt

# write checkpoint
write_checkpoint -force ${dcp_dir}/synth_shell.dcp

# synthesize role
set_property top role_wrapper [current_fileset]
update_compile_order -fileset [current_fileset]
synth_design -top role_wrapper -part ${device} -mode out_of_context

# write checkpoint
write_checkpoint -force ${dcp_dir}/synth_role.dcp