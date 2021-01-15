% Statistic related functions
function [] = ApplyToAll(I,J,ax,filename1,filename2)
    % get the thresholds from the histograms
    Ithr = findobj(ax(3), 'Tag', 'CBL');
    Ithr = round(Ithr.XData(1));
    Jthr = findobj(ax(6), 'Tag', 'CBL');
    Jthr = round(Jthr.XData(1));
    
    NoIm = get(findobj('Tag', 'uitImage'), 'UserData');
    StatGraph(I{NoIm},J{NoIm},Ithr,Jthr,filename1(NoIm),filename2(NoIm));
end
