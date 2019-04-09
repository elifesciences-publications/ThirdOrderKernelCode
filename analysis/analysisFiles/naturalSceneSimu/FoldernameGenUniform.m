function foldername = FoldernameGenUniform(path)
% generate several folders together.
s = path.s;
foldername = [path.data,s,DateStrGen,s];
if ~exist(foldername,'dir');
    mkdir(foldername);
end
end