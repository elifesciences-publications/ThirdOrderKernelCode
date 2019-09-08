function data_batches_symmetrized = performance_evaluation_utils_data_segmentation(data, num_batches)
num_samples = length(data.v2);
rng(0)
index_perm = randperm(num_samples);
batch_size = ceil(num_samples/num_batches);
data_batches = cell(num_batches, 1);
for ii = 1:1:num_batches
   start_ind = (ii-1)*batch_size  + 1;
   end_ind = min(ii * batch_size, num_samples);
   data_batches{ii}.v2 = data.v2(index_perm(start_ind :  end_ind));
   data_batches{ii}.v_real =  data.v_real(index_perm(start_ind :  end_ind));
   if isfield(data, 'v3')
    data_batches{ii}.v3 =  data.v3(index_perm(start_ind :  end_ind));
   end
end
data_batches_symmetrized = cell(num_batches, 1);
for ii = 1:1:num_batches
    data_batches_symmetrized{ii} = Analysis_Utils_GetAllData_EnforceSymmetry(data_batches{ii});
end
end