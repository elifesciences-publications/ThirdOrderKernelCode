function foldername = FoldernameGen(path,velocity)
strVel = ['VelStd',num2str(velocity.std,'%u')];
foldername = [path.data,strVel,'\',DateStrGen];
mkdir(foldername);
foldername = [foldername,'\'];
end