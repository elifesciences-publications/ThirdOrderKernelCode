function data_subgroup = put_data_in_the_same_subgroup_together(data, ind_use)
data_subgroup.v2 = data.v2(ind_use);
data_subgroup.v3 = data.v3(ind_use);
data_subgroup.v_real = data.v_real (ind_use);
end