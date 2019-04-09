function PlotFTResponse(resp,omegaBank,lambdaBank)
% there would be several response.
    nLambda = length(lambdaBank);
    legendStr = cell(nLambda,1);
    
    for jj = 1:1:nLambda;
        legendStr{jj} = ['\lambda:',num2str(lambdaBank(jj))];
        plot(omegaBank,resp(:,jj));
        hold on
    end
    legend(legendStr);
    xlabel('f[Hz]');
    ylabel('response');
    hold on
    plot(omegaBank,zeros(length(omegaBank),1),'k--');
    ax = gca;
    plot([0,0],ax.YLim,'k--');
    hold off
    % plot
end