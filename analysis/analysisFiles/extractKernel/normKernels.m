function [ normed, sd ] = normKernels( kernels, order)
% scale kernels by standard deviation

allVectors = kernels.allVectors;
% val = 1e-5; % so that if numerator not zero, will be obvious
% val = 1e15; % so goes to zero even if numerator not zero
val = 1;
thresh = 1e-12;

switch order
    case 1
        N = size(allVectors.k1_x,2);
        sd.x = std(allVectors.k1_x,[],2);
        [ sd.x, sd.hitInd_x ] =  dezeroVect( sd.x,val,thresh);
        sd.y = std(allVectors.k1_y,[],2);
        [ sd.y, sd.hitInd_y ] =  dezeroVect( sd.y,val,thresh );
        normed.allVectors.k1_x = allVectors.k1_x ./ repmat(sd.x,[1 N]) * sqrt(N/2);
        normed.allVectors.k1_y = allVectors.k1_y ./ repmat(sd.y,[1 N]) * sqrt(N/2);
        if isfield(allVectors,'k1_sym')
            sd.sym = std(allVectors.k1_sym,[],2);
            [ sd.sym, sd.hitInd_sym ] =  dezeroVect( sd.sym,val,thresh );
            normed.allVectors.k1_sym = allVectors.k1_sym ./ repmat(sd.sym,[1 N]) * sqrt(N/2);
        end       
    case 2
        
        N = size(allVectors.k2_xy,2);
        sd.xy = std(allVectors.k2_xy,[],2);
        [ sd.xy, sd.hitInd_xy ] =  dezeroVect( sd.xy,val,thresh );
        normed.allVectors.k2_xy = allVectors.k2_xy  ./ repmat(sd.xy,[1 N]) * sqrt(N/2);
        if isfield(allVectors,'k2_sym')
            sd.sym = std(allVectors.k2_sym,[],2);
            [ sd.sym, sd.hitInd_sym ] =  dezeroVect( sd.sym,val,thresh );
            normed.allVectors.k2_sym = allVectors.k2_sym ./ repmat(sd.sym,[1 N]) * sqrt(N/2);
        end
        if isfield(allVectors,'k2_xx')
            sd.xx = std(allVectors.k2_xx,[],2);
            [ sd.xx, sd.hitInd_xx ] =  dezeroVect( sd.xx,val,thresh );
            normed.allVectors.k2_xx = allVectors.k2_xx  ./ repmat(sd.xx,[1 N]) * sqrt(N/2);
            sd.yy = std(allVectors.k2_yy,[],2);
            [ sd.yy, sd.hitInd_yy ] =  dezeroVect( sd.yy,val,thresh );
            normed.allVectors.k2_yy = allVectors.k2_yy  ./ repmat(sd.yy,[1 N]) * sqrt(N/2);
        end
        keyboard

    case 3
        N = size(allVectors.k3_xxy,2);
        sd.xxy = std(allVectors.k3_xxy,[],2);
        [ sd.xxy, sd.hitInd_xxy ] =  dezeroVect( sd.xxy,val,thresh );
        normed.allVectors.k3_xxy = allVectors.k3_xxy ./ repmat(sd.xxy,[1 N]) * sqrt(N/2);
        sd.yyx = std(allVectors.k3_yyx,[],2);
        [ sd.yyx, sd.hitInd_yyx ] =  dezeroVect( sd.yyx,val,thresh );
        normed.allVectors.k3_yyx = allVectors.k3_yyx ./ repmat(sd.yyx,[1 N]) * sqrt(N/2);
        if isfield(allVectors,'k3_sym')
            sd.sym = std(allVectors.k3_sym,[],2);
            [ sd.sym, sd.hitInd_sym ] =  dezeroVect( sd.sym,val,thresh );
            normed.allVectors.k3_sym = allVectors.k3_sym ./ repmat(sd.sym,[1 N]) * sqrt(N/2);
        end
        if isfield(allVectors,'k3_xxx')
            sd.xxx = std(allVectors.k3_xxx,[],2);
            [ sd.xxx, sd.hitInd_xxx ] =  dezeroVect( sd.xxx,val,thresh );
            normed.allVectors.k3_xxx = allVectors.k3_xxx ./ repmat(sd.xxx,[1 N]) * sqrt(N/2);
            sd.yyy = std(allVectors.k3_yyy,[],2);
            [ sd.yyy, sd.hitInd_yyy ] =  dezeroVect( sd.yyy,val,thresh );
            normed.allVectors.k3_yyy = allVectors.k3_yyy ./ repmat(sd.yyy,[1 N]) * sqrt(N/2);
        end
        
end


end

