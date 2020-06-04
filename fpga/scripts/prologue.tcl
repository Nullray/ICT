# source directories
set ip_repo ${script_dir}/../ip_repo

# project name
set project_name ${prj}_${board}
set prj_file ${project_name}/${project_name}.xpr

# output directories
set vivado_out ${script_dir}/../vivado_out
set target_prj ${vivado_out}/${project_name}

set synth_rpt_dir ${target_prj}/synth_rpt
set impl_rpt_dir ${target_prj}/impl_rpt
set dcp_dir ${target_prj}/dcp

