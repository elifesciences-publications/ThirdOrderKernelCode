function semMat = CalcRespSEM(snipMat,dimension)

    switch dimension
        case 'ROIs'
            semMat = cell(size(snipMat,1),1);
            
            for ee = 1:size(snipMat,1)
                matForm = cell2mat(snipMat(ee,:));
                semMat{ee} = std(matForm,0,2)/sqrt(size(matForm,2));
            end
        case 'epochs'
            semMat = cell(1,size(snipMat,2));
            
            for ff = 1:size(snipMat,2)
                matForm = cell2mat(snipMat(:,ff));
                semMat{ff} = std(matForm,0,1)/sqrt(size(matForm,1));
            end
        case 'time'
            semMat = cell(size(snipMat));
            
            for ff = 1:size(snipMat,2)
                for ee = 1:size(snipMat,1)
                    semMat{ee,ff} = std(snipMat{ee,ff},0,1)/sqrt(size(snipMat{ee,ff},1));
                end
            end
        case 'trials'
            semMat = cell(size(snipMat));
            
            for ff = 1:size(snipMat,2)
                for ee = 1:size(snipMat,1)
                    semMat{ee,ff} = std(snipMat{ee,ff},0,2)/sqrt(size(snipMat{ee,ff},2));
                end
            end
        case 'Flies'
            
    end
end