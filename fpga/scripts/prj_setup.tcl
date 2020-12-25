# setting up the project
create_project ${project_name} -force -dir "./${project_name}" -part ${device}

if {${bd_part} != ""} {
  set_property board_part ${bd_part} [current_project]
}

# set custom IP repo path
set_property ip_repo_paths ${ip_repo} [current_fileset]
update_ip_catalog -rebuild

