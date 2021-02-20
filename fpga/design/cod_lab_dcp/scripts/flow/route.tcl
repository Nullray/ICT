# routing
route_design

write_checkpoint -force ${dcp_dir}/route.dcp
write_checkpoint -cell [get_cells mpsoc_i/role_cell/inst] -force ${dcp_dir}/route_role.dcp

update_design -cell [get_cells mpsoc_i/role_cell/inst] -black_box
lock_design -level routing
write_checkpoint -force ${dcp_dir}/route_shell.dcp

read_checkpoint -cell [get_cells mpsoc_i/role_cell/inst] ${dcp_dir}/route_role.dcp

report_utilization -file ${impl_rpt_dir}/post_route_util.rpt
report_timing_summary -file ${impl_rpt_dir}/post_route_timing.rpt -delay_type max -max_paths 1000

report_route_status -file ${impl_rpt_dir}/post_route_status.rpt