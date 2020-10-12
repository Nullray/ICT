# add source files
add_files ${script_dir}/../design/${prj}/sources/hdl/

# setup block design
set bd_design mpsoc
source ${script_dir}/../design/${prj}/scripts/${bd_design}.tcl
		
set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

validate_bd_design
save_bd_design
close_bd_design ${bd_design}

set bd_design bram
source ${script_dir}/../design/${prj}/scripts/${bd_design}.tcl
		
set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

validate_bd_design
save_bd_design
close_bd_design ${bd_design}

# setup top module
set_property "top" serve [get_filesets sources_1]

# add constraints files
#set main_constraints ${script_dir}/../design/${prj}/constraints/${board}/top.xdc
#add_files -fileset constrs_1 -norecurse ${main_constraints}
