function Coloc2ChannelsInteractive()

    close all
    clear
    clc
    
    % select files and ROI
    [I,filename1] = SelectFiles();
    [J,filename2] = SelectFiles();
    if size(I,3) ~= size(J,3)
       beep
       warning('You need to select the same number of files for each channel')
        return
    end
	NoIm = 1;
    
    % create the layout of the figure
    [ax] = MakeNewFigure(3,3,I,J,filename1,filename2,NoIm);
    
    % plot data for 1st image
    ShowOriginalIm(I{NoIm},J{NoIm},ax,true);
    ShowColocIm(I{NoIm},J{NoIm},ax,true);
    ScatterLinearFit(I{NoIm},J{NoIm},ax,true);
    CreateHisto(I{NoIm},J{NoIm},ax);
    UpdateBw(I{NoIm},1,ax(2),true);
    UpdateBw(J{NoIm},1,ax(5),true);
    SetGraphPosition(ax);
end
