if {$val == "pr_shell" || $val == "pr_role"} {
    set pr_pblock CLOCKREGION_X1Y4
    set pr_mod TLPRBox
    set pr_inst tlpr

    set freedom_file ${design_dir}/../sources/hdl/freedom/freedom.v
    set freedom_blackbox_file ${design_dir}/../sources/intermediate/freedom-blackbox.v

    set hw_plat_dir ${script_dir}/../../hw_plat/${project_name}
}
