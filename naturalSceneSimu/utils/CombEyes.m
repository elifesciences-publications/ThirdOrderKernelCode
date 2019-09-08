function leftEye = CombEyes(leftEye,rightEye,p,f)
    hzFrame = f*p.framesPerUp-(p.framesPerUp-1):f*p.framesPerUp;
    
    if isfield(p,'eyeDist')
        eyeDist = p.eyeDist;
    else
        eyeDist = 0;
    end
    
    if isfield(p,'stripType')
        stripType = p.stripType;
    else
        stripType = 0;
    end
    
    %both eyes should be same size
    sizeMap = size(leftEye);
    %convert degStrip to halfStrip
    halfStrip = sizeMap(2)*eyeDist/360/2;
    
    leftEyeEnd = floor(sizeMap(2)/2-halfStrip);
    rightEyeBegin = ceil(sizeMap(2)/2+halfStrip)+1;
    
    leftEye(:,rightEyeBegin:end,:) = rightEye(:,rightEyeBegin:end,:);
    
    if halfStrip > 0
        for cc = 1:p.framesPerUp
            switch stripType
                case 0
                    strip = 0.5;
                case 1
                    strip = square(2*pi*hzFrame(cc)/(2*p.framesPerUp));
            end

            leftEye(:,leftEyeEnd+1:rightEyeBegin-1,cc) = strip;
        end
    end
end