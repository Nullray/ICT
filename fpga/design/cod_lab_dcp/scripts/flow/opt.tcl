# setting Implementation options
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
# the following implementation options will increase runtime, but get the best timing results
set_property strategy Performance_Explore [get_runs impl_1]

# open shell checkpoint
open_checkpoint ${dcp_dir}/synth_shell.dcp

# set PR blackbox module
set_property HD.RECONFIGURABLE true [get_cells mpsoc_i/role_cell/inst]

read_checkpoint -cell [get_cells mpsoc_i/role_cell/inst] ${dcp_dir}/synth_role.dcp

# create PBLOCK
create_pblock role_pblk
resize_pblock role_pblk -add { \
    SLICE_X0Y180:SLICE_X40Y300 \
    DSP48E2_X0Y72:DSP48E2_X5Y119 \
    RAMB18_X0Y72:RAMB18_X3Y119 \
    RAMB36_X0Y36:RAMB36_X3Y59 \
    URAM288_X0Y0:URAM288_X0Y31}

add_cells_to_pblock role_pblk [get_cells [list mpsoc_i/role_cell/inst]] -clear_locs

# setup output logs and reports
report_timing_summary -file ${synth_rpt_dir}/synth_timing.rpt -delay_type max -max_paths 1000

# Design optimization
opt_design

# Save debug probe file
write_debug_probes -force ${out_dir}/debug_nets.ltx

