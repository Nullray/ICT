# source directories
#set ip_repo ${script_dir}/../sources/ip_repo

# output directories
set vivado_out ${script_dir}/../vivado_out
set synth_rpt_dir ${vivado_out}/synth_rpt
set impl_rpt_dir ${vivado_out}/impl_rpt
set dcp_dir ${vivado_out}/dcp

# project name
set project_name mpsoc_nf
set prj_file ${project_name}/${project_name}.xpr

# top-module name
set top_module mpsoc_wrapper

# device and board
set device xczu19eg-ffvc1760-2-e
#set board nf_card:none:part0:2.0

