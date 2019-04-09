function relativeTimeMat = roiAnalysis_AverageFirstKernel_alignTrace_relativeTimeMat(trace)
nRoi = length(trace);
relativeTimeMat = zeros(nRoi,nRoi);

for ii = 1:1:nRoi
    for jj = ii+1:1:nRoi
        xab = MyXCorr_RelativePos(trace{ii},trace{jj});
        relativeTimeMat(ii,jj) = xab;
        relativeTimeMat(jj,ii) = - xab;
%         % do you want a debgging function? 
%         % plot the trace together according to your xab;
%         if jj == 20
%         MakeFigure;
%         subplot(2,1,1);
%         plot(trace{ii});hold on; plot(trace{jj});hold off
%         subplot(2,1,2);
%         if xab > 0
%             shiftN = abs(xab);
%             shiftedTraceA = trace{ii}(shiftN:end); 
%             shiftedTraceB = trace{jj}(1:end - shiftN + 1);
%         elseif xab < 0
%             shiftN = abs(xab);
%             shiftedTraceA = trace{ii}(1:end - shiftN + 1);
%             shiftedTraceB = trace{jj}(shiftN:end); 
%         else
%             shiftN = abs(xab);
%             shiftedTraceA = trace{ii};
%             shiftedTraceB = trace{jj}; 
%         end
%         plot(shiftedTraceA);hold on;plot(shiftedTraceB);
% %         
%         end
    end
end

end