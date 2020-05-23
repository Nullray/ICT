# setting up the project
create_project ${project_name} -force -dir "./${project_name}" -part ${device}
#set_property board_part ${board} [current_project]

# add source files
#add_files ${script_dir}/../sources/hdl/${project_name}.v

# set custom IP repo path
#set_property ip_repo_paths ${ip_repo} [current_fileset]
#update_ip_catalog -rebuild

# setup block design
set bd_design mpsoc
source ${script_dir}/${bd_design}.tcl
		
set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

validate_bd_design
save_bd_design
close_bd_design mpsoc

# setup top module
#set_property "top" ${project_name} [get_filesets sources_1]
	
# add constraints files
#set main_constraints ${script_dir}/../sources/constraints/${project_name}.xdc
#add_files -fileset constrs_1 -norecurse ${main_constraints}

