function foldername = FoldernameGenV(path,velocity,velSampMode)

% generate several folders together.
switch velSampMode
    case 'Binary'
        nV = length(velocity.value);
        foldername = cell(nV,1);
        s = path.s;
        for vv = 1:1:nV
            strVel = ['V',num2str(velocity.value(vv),'%u')];
            foldername{vv} = [path.data,strVel,s,DateStrGen];
            mkdir(foldername{vv});
            foldername{vv} = [foldername{vv},s];
        end
    case 'Uniform'
        s = path.s;
        % you have to determine the maxvalue of your uniform distribution.
        strMaxVel = ['maxV',num2str(velocity.maxUniform)];
        
        foldername = [path.data,strMaxVel,s,DateStrGen,s];
        if ~exist(foldername,'dir');
            mkdir(foldername);
        end
    case 'Guassian'
        strVelStd = ['stdV',num2str(velocity.std)];
        s = path.s;
        foldername = [path.data,strVelStd,s,DateStrGen,s];
        if ~exist(foldername,'dir');
            mkdir(foldername);
        end
end
end