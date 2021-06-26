# setting Implementation options
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
# the following implementation options will increase runtime, but get the best timing results
set_property strategy Performance_Explore [get_runs impl_1]

# open shell checkpoint
open_checkpoint ${dcp_dir}/synth.dcp

# setup output logs and reports
report_timing_summary -file ${synth_rpt_dir}/synth_timing.rpt -delay_type max -max_paths 1000

# Design optimization
opt_design

# Save debug probe file
write_debug_probes -force ${out_dir}/debug_nets.ltx
