function output = getFilterOutput(params, stimuli, repeats, paramsFcn, modelFcn)
% Takes in:
% params: parameters for the filter function
% stimuli: stimuli with dimensions (time*repeats,cell,dt,parity) where cell
% is left or right cell
% repeats: number of trials to simulate
% paramsFcn: A function that converts the input params into temporal
% filters for use in the model function
% modelFcn: A function that takes in stimuli in the format of (time,trials)
% and temporal filters, and outputs the model response in the format
% (time,trials)
% Outputs the mean response averaged over time and trials with dimensions
% (dt,parity,direction)
    [f1,f2] = paramsFcn(params); 
    [numDatapoints,~,numDts,~] = size(stimuli);
    numTimepoints = numDatapoints/repeats;
    output(numDts,2,2) = 0;
    for direction = 1:2
        s1 = reshape(stimuli(:,1,:,:),numTimepoints,repeats*numDts*2);
        s2 = reshape(stimuli(:,2,:,:),numTimepoints,repeats*numDts*2);
        if direction == 1
            response = modelFcn(f1,f2,s1,s2);
        else
            response = modelFcn(f1,f2,s2,s1);
        end
        responseRS = reshape(response,numTimepoints*repeats,numDts,2);
        output(:,:,direction) = squeeze(mean(responseRS));
    end
end