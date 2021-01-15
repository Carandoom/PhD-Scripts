% Plot fixed data
function [] = ScatterLinearFit(I,J,ax,FirstTime)
    IPixels = reshape(I,[size(I,1)*size(I,2) 1]);
    JPixels = reshape(J,[size(J,1)*size(J,2) 1]);
    if FirstTime == true
        scatter(IPixels,JPixels,'.', 'parent', ax(8));
        [IPixels2,Yfit] = LinearFit(IPixels,JPixels);
        hold on;
        line(IPixels2,Yfit, 'color', 'red', 'LineWidth', 1.5, 'parent', ax(8))
        hold off;
    else
        ScaPlot = findobj(ax(8),'Type','Scatter');
        ScaPlot.XData = IPixels;
        ScaPlot.YData = JPixels;
        LinePlot = findobj(ax(8),'Type','Line');
        delete(LinePlot);
        [IPixels2,Yfit] = LinearFit(IPixels,JPixels);
        hold on;
        line(IPixels2,Yfit, 'color', 'red', 'LineWidth', 1.5, 'parent', ax(8))
        hold off;
    end
end
