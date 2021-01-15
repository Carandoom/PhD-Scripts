	%	
	%	Script to get colocalization statistics
	%	Made to work in batch mode using still images of 2 channels
	%	You need to select all the images of the first channel
	%	then all of the second channel. They will be paired by alphabetical order
	%	You can set the threshold for each channel and apply it
	%	A potential issue is the image treatment done withing the script,
	%	it might reduce a lot the signal, if it does so, you will need
	%	to change/remove the image processing part of the script
	%	
	%	Guidelines:
	%		1) For a given series of images, select all the images from channel 1
	%		2) To the corresponding series, select all images from channel 2
	%		3) Both channels of the selected image are displayed, use the
	%			histograms to set the thresholds
	%		4) Press the "Apply" button
	%		5) You can copy paste the values generated in the table
	%		6) You can close the program or press on the "Next series" button
	%			to open a new series and repeat the script
	%   
	%   Christopher HENRY - V1 - 2020-08-13
	%

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
