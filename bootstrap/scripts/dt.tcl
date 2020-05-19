#=======================================================
# FSBL auto generation and compiling script running in 
# the Vivado 2016.4 SDK HSI environment
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 13/11/2017
#========================================================

set hdf_file [lindex $argv 0]

set prj_dir [lindex $argv 1]

set repo_dir [lindex $argv 2] 

# Step 1: open hardware definition file
set hw_design [ open_hw_design ${hdf_file} ]

# Step 2: setup Device Tree repository
set_repo_path ${repo_dir}

# Step 3: automatic generation of software design for device tree
set sw_design [ create_sw_design zynqmp_dts -os device_tree -proc psu_cortexa53_0 ]

# Step 4: generate output dts
generate_target -dir ${prj_dir} 


