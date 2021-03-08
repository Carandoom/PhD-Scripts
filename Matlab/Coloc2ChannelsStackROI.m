function ColocStack()
    % Script to get colocalization statistics
    % Made to work with stack of still images with 2 channels
    % You need to select all the images of the first stack
    %   then all of the second stack
    % They will be paired by alphabetical order
    % You will be asked to create a region of interest (ROI)
    %   where the analysis will be restricted in for all the stack
    % You can set the threshold for each channel and it will be applied to
    %   all the images of this channel in the stack
    % 
    % Guidelines:
    %   1) For a given stack, select all the images from channel 1
    %   2) To the corresponding stack, select all images from channel 2
    %   3) Using the slider, select the image to draw a ROI on
    %   4) Press the "Ready to draw" button
    %   5) Draw the ROI, you can modify it afterward
    %   6) Once satisfied, press the "Validate ROI" button
    %   7) Both channels of the selected image are displayed, use the
    %       histograms to set the thresholds
    %   8) Press the "Apply to all" button
    %   9) You can copy paste the values generated in the table
    %   10) You can close the program or press on the "Next stack" button
    %       to open a new stack and repeat the script
    %   
    %   Christopher HENRY, July 2020, UNIGE
    
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
    [mask, NoIm] = SelectROI(I);
    
    % Restric the images to the ROI
    I = RestrictWithinROI(I,mask);
    J = RestrictWithinROI(J,mask);
    
    % create the layout of the figure
    [ax] = MakeNewFigure(3,3,I,J,filename1,filename2,NoIm);
    
    % plot data for 1st image
    ShowOriginalIm(I(:,:,NoIm),J(:,:,NoIm),ax,true);
    ShowColocIm(I(:,:,NoIm),J(:,:,NoIm),ax,true);
    ScatterLinearFit(I(:,:,NoIm),J(:,:,NoIm),ax,true);
    CreateHisto(I(:,:,NoIm),J(:,:,NoIm),ax);
    UpdateBw(I(:,:,NoIm),1,ax(2),true);
    UpdateBw(J(:,:,NoIm),1,ax(5),true);
    SetGraphPosition(ax);
end


%% Functions

% MakeNewFigure related functions
function [ax] = MakeNewFigure(nbRow,nbColumn,I,J,filename1,filename2,NoIm)
	f = figure('WindowState','maximized');
	for i=1:(nbRow*nbColumn)
		ax(i) = subplot(nbRow,nbColumn,i);
    end
    linkaxes([ax(1) ax(2) ax(4) ax(5) ax(7)]);
    delete(ax(9));
    
    CreateButtons(f,ax,I,J,filename1,filename2);    % create buttons
    CreateTables(f);                                % create tables
    [CkBx] = CreateCheckBox(f);                     % create check box to use thr or not
    CreateSlider(f,ax,CkBx,I,J,NoIm);                    % create slider for image switch
end
function [] = CreateButtons(f,ax,I,J,filename1,filename2)
    % button next
    bNxt = uicontrol(f,'Style', 'pushbutton', ...
        'String', 'Next stack', ...
        'Tag', 'bNxt', ...
        'Units', 'normalized', ...
        'Position', [0.43,0.1,0.07,0.03], ...
        'CallBack', @(hObject,event) ColocStack() ...
        );
    % button apply all
    bAll = uicontrol(f,'Style', 'pushbutton', ...
        'String', 'Apply to all', ...
        'Tag', 'bAll', ...
        'Units', 'normalized', ...
        'Position', [0.43,0.25,0.07,0.03], ...
        'CallBack', @(hObject,event) ApplyToAll(I,J,ax,filename1,filename2)...
        );
end
function [] = CreateTables(f)
    % table current data
    ColNames = {'ch1' 'ch2' 'PCC' 'M1' 'M2' '% ch1 in ch2' '% ch2 in ch1' 'Thr ch1' 'Thr ch2'};
    ColData = [];
    % table all data
    uit = uitable(f, ...
        'Tag', 'uitAll', ...
        'Data', ColData, ...
        'ColumnName', ColNames, ...
        'Units', 'normalized', ...
        'Position', [0.54,0.058,0.33,0.26] ...
        );
end
function [CkBx] = CreateCheckBox(f)
    CkBx = uicontrol(f, ...
        'Style', 'checkbox', ...
        'String', 'Threshold on coloc & scatter', ...
        'Units', 'normalized', ...
        'Position', [0.415,0.04,0.1,0.03] ...
        );
end
function [] = CreateSlider(f,ax,CkBx,I,J,NoIm)
    txt = uicontrol(f, ...
        'Style', 'text', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'String', 'Image n ' + string(NoIm), ...
        'Units', 'normalized', ...
        'Position', [0.405,0.15,0.12,0.05] ...
        );
    if size(I,3) == 1
        return
    end
    uit = uicontrol(f, ...
        'Style', 'slider', ...
        'Min', 1, ...
        'Max', size(I,3), ...
        'Value', NoIm, ...
        'UserData', 1, ...
        'Units', 'normalized', ...
        'Position', [0.54,0.01,0.33,0.03] ...
        );
    addlistener(uit,'ContinuousValueChange', ...
        @(hObject,event) UpdateFromSlider(hObject,event,uit,txt,ax,CkBx,I,J) ...
        );
end
function [] = UpdateFromSlider(hObject,event,uit,txt,ax,CkBx,I,J)
    NoIm = round(hObject.Value);
    if NoIm == uit.UserData
        return
    end
    uit.UserData = NoIm;
    txt.String = 'Image n ' + string(NoIm);
    
    try
        CBLI = findobj(ax(3), 'Tag', 'CBL');
        CBLIDataX = CBLI.XData;
    catch
        CBLIDataX = [1 0 0 0];
    end
    try
        CBLJ = findobj(ax(6), 'Tag', 'CBL');
        CBLJDataX = CBLJ.XData;
    catch
        CBLJDataX = [1 0 0 0];
    end
    
    ShowOriginalIm(I(:,:,NoIm),J(:,:,NoIm),ax,false);
    ShowColocIm(I(:,:,NoIm),J(:,:,NoIm),ax,false);
    ScatterLinearFit(I(:,:,NoIm),J(:,:,NoIm),ax,false);
    UpdateBw(I(:,:,NoIm),CBLIDataX(1),ax(2),false);
    UpdateBw(J(:,:,NoIm),CBLJDataX(1),ax(5),false);
    CreateHisto(I(:,:,NoIm),J(:,:,NoIm),ax);
    
    CreatePatch(ax(3),CBLIDataX);
    CreatePatch(ax(6),CBLJDataX);
end
function [] = CreateHisto(I,J,ax)
    histogram(I,'parent',ax(3),'PickablePart','none');
    histogram(J,'parent',ax(6),'PickablePart','none');
    set(ax(3),'YScale','log', ...
        'Units', 'normalized', ...
        'Position', [0.5,0.71,0.37,0.23], ...
        'PickablePart','visible', ...
        'HitTest','on', ...
        'ButtonDownFcn', @(hObject,event) mouseClick(I,ax(3),ax(2),1) ...
        )
    set(ax(6),'YScale','log', ...
        'Units', 'normalized', ...
        'Position', [0.5,0.39,0.37,0.23], ...
        'PickablePart','visible', ...
        'HitTest','on', ...
        'ButtonDownFcn',@(hObject,event) mouseClick(J,ax(6),ax(5),2)...
        )
end
function [] = CreatePatch(axHisto,CBLDataX)
    xL = get(axHisto,'Xlim');
    yL = get(axHisto,'Ylim');
    CBL = patch(axHisto, ...
        [CBLDataX(1) xL(2) xL(2) CBLDataX(1)], ...
        [yL(1) yL(1) yL(2) yL(2)], ...
        'yellow', ...
        'FaceAlpha', 0.5, ...
        'Tag', 'CBL', ...
        'PickableParts', 'none' ...
        );
    try
        delete(findobj(axHisto,'Tag','LGD'));
    catch
    end
    lgdLine = line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
    lgd = legend(axHisto,lgdLine,int2str(CBLDataX(1)), ...
        'Color', 'none', ...
        'TextColor', 'red', ...
        'Box', 'off', ...
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'Tag', 'LGD' ...
        );
end
function [] = SetGraphPosition(ax)
    set(ax(1),'Position', [0,0.68,0.28,0.28]);
    ax(1).Title.String = 'Channel 1';
    set(ax(2),'Position', [0.18,0.68,0.28,0.28]);
    ax(2).Title.String = 'Threshold ch1';
    set(ax(3),'Position', [0.5,0.71,0.37,0.23]);
    ax(3).Title.String = 'histogram pixel intensity ch1';
    
    set(ax(4),'Position', [0,0.36,0.28,0.28]);
    ax(4).Title.String = 'Channel 2';
    set(ax(5),'Position', [0.18,0.36,0.28,0.28]);
    ax(5).Title.String = 'Threshold ch2';
    set(ax(6),'Position', [0.5,0.39,0.37,0.23]);
    ax(6).Title.String = 'histogram pixel intensity ch2';
    
    set(ax(7),'Position', [0,0.04,0.28,0.28]);
    ax(7).Title.String = 'Overlay';
    
    fTxtG = text(ax(7));
    fTxtG.String = 'ch1';
    fTxtG.FontWeight = 'bold';
    fTxtG.Units = 'normalized';
    fTxtG.Position = [0.05 0.95];
    fTxtG.Color = 'green';
    
    fTxtR = text(ax(7));
    fTxtR.String = 'ch2';
    fTxtR.FontWeight = 'bold';
    fTxtR.Units = 'normalized';
    fTxtR.Position = [0.85 0.95];
    fTxtR.Color = 'red';
    
    set(ax(8),'Position', [0.25,0.075,0.14,0.23]);
end

% SelectFiles related functions
function [I,filename] = SelectFiles()
    [filename, path] = uigetfile('*.*', ...
        'defname', 'C:\Users\henryc\Desktop\Matlab-Coloc-Test\', ...
        'MultiSelect', 'on');
    if isa(filename,'char')
        filename = cellstr(filename);
    end
    for i = 1:length(filename)
        CurrentIm = imread(strcat(path,string(filename(i))));
        try
            CurrentIm = rgb2gray(CurrentIm);
        catch
        end
        I(:,:,i) = CurrentIm;
        I(:,:,i) = LowPassFilter(I(:,:,i),25);
    end
end
function [I] = LowPassFilter(I,Gval)
% low pass filter and remove BG
    Ibg	= imgaussfilt(I,Gval);
    I	= imsubtract(I,Ibg);
end

% SelectROI related functions
function [mask, NoIm] = SelectROI(I)
    % select ROI to work within
    fDraw = figure('WindowState','maximized');
    axfDraw = subplot(1,1,1);
    set(axfDraw,'Position',[0.2 0.25 0.6 0.6]);
    ImFig = imshow(I(:,:,1),[],'parent',axfDraw(1));
    axfDraw.Title.String = 'Image n°1';
    
    % add a button to validate selection
    uit1 = uicontrol(fDraw, ...
        'Style', 'pushbutton', ...
        'String', 'Ready to draw', ...
        'Units', 'normalized', ...
        'Position', [0.3,0.1,0.15,0.05], ...
        'Callback', @(hObject,event) uiresume(fDraw)...
        );
    uit2 = uicontrol(fDraw, ...
        'Style', 'pushbutton', ...
        'String', 'Validate ROI', ...
        'Units', 'normalized', ...
        'Position', [0.54,0.1,0.15,0.05], ...
        'Callback', @(hObject,event) uiresume(fDraw)...
        );
    if size(I,3) ~= 1
        % add slider to change the displayed image
        uit3 = uicontrol(fDraw, ...
            'Style', 'slider', ...
            'Min', 1, ...
            'Max', size(I,3), ...
            'Value', 1, ...
            'Units', 'normalized', ...
            'Position', [0.24,0.01,0.5,0.03] ...
            );
        addlistener(uit3,'ContinuousValueChange',@(hObject,event) SliderROI(hObject,event,axfDraw,ImFig,I));
    end
    % get ROI
    uiwait(fDraw);
    if size(I,3) ~= 1
        NoIm = round(get(uit3,'Value'));
        delete(uit3);
    else
        NoIm = 1;
    end
    delete(uit1);
    ROI = drawpolygon();
    uiwait(fDraw);
    if length(ROI.Position) == 0
        mask = ones(size(I,1),size(I,2));
    else
        mask = createMask(ROI);
    end
    close(fDraw);
end
function [I] = RestrictWithinROI(I,mask)
    mask = repmat(mask,1,1,size(I,3));
    I(mask==0) = 0;
end
function [] = SliderROI(hObject,event,axfDraw,ImFig,I)
    ImFig.CData = I(:,:,round(hObject.Value));
    axfDraw.Title.String = "Image n°" + string(round(hObject.Value));
end

% Plot fixed data
function [] = ShowOriginalIm(I,J,ax,FirstTime)
    if FirstTime == true
        imshow(I,[],'parent',ax(1));
        imshow(J,[],'parent',ax(4));
    else
        Im1 = findobj(ax(1),'Type','image');
        Im1.CData = I;
        Im2 = findobj(ax(4),'Type','image');
        Im2.CData = J;
    end
end
function [] = ShowColocIm(I,J,ax,FirstTime)
    ImColoc = imfuse(I,J,'colorChannels', [1 2 0]); %%test with RGB convertion
    if FirstTime == true
        imshow(ImColoc,[],'parent',ax(7));
    else
        Im1 = findobj(ax(7),'Type','image');
        Im1.CData = ImColoc;
    end
end
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
function [IPixels2,Yfit] = LinearFit(IPixels,JPixels)
    IPixels2 = double(IPixels);
    JPixels2 = double(JPixels);
    
    IPixels2(IPixels==0 | JPixels==0) = [];
    JPixels2(IPixels==0 | JPixels==0) = [];
    
    Po = polyfit(IPixels2,JPixels2,1);
    Yfit = Po(1)*IPixels2+Po(2);
end

% Callback from histo
function [] = mouseClick(I,axHisto,axImBw,CaseImage)
    try
        CBL2 = findobj(axHisto, 'Tag', 'CBL');
        delete(CBL2);
    catch
    end
    pointCoord = get(gca,'CurrentPoint');
    x = pointCoord(1,1);
    y = pointCoord(1,2);
    xL = get(gca,'Xlim');
    yL = get(gca,'Ylim');
    Xcoord = [x xL(2) xL(2) x];
    Ycoord = [yL(1) yL(1) yL(2) yL(2)];
    CBL = patch(Xcoord,Ycoord, ...
        'yellow', ...
        'FaceAlpha', 0.5, ...
        'Tag', 'CBL', ...
        'PickableParts', 'none' ...
        );
	
	if CaseImage == 1
		UpdateBw(I,x,axImBw,false);
        axImBw.Title.String = 'Threshold ch1';
	elseif CaseImage == 2
		UpdateBw(I,x,axImBw,false);
        axImBw.Title.String = 'Threshold ch2';
    end
    lgdLine = line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
    lgd = legend(lgdLine,int2str(x), ...
        'Color', 'none', ...
        'TextColor', 'red', ...
        'Box', 'off', ...
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'Tag', 'LGD' ...
        );
end
function [Ibw] = UpdateBw(I,x,axImBw,FirstTime)
    Ibw = I >= x;
    Ibw	= double(Ibw);
    if (axImBw ~= 0 && FirstTime == true)
        imshow(Ibw,[],'parent',axImBw);
    elseif (axImBw ~= 0 && FirstTime ~= true)
        Im1 = findobj(axImBw,'Type','image');
        Im1.CData = Ibw;
    end
end

% Statistic related functions
function [] = ApplyToAll(I,J,ax,filename1,filename2)
    % get the thresholds from the histograms
    Ithr = findobj(ax(3), 'Tag', 'CBL');
    Ithr = round(Ithr.XData(1));
    Jthr = findobj(ax(6), 'Tag', 'CBL');
    Jthr = round(Jthr.XData(1));
    
    for i=1:size(I,3)
        StatGraph(I(:,:,i),J(:,:,i),Ithr,Jthr,filename1(i),filename2(i));
    end
end
function [] = StatGraph(I,J,Ithr,Jthr,filename1,filename2)
	
    % calcul of IJbw
    Ibw = UpdateBw(I,Ithr,0);
    Jbw = UpdateBw(J,Jthr,0);
    Jbw(Jbw == 1) = 2;
    IJbw = imadd(Ibw,Jbw);
    
    % stats
    [PCC]			= PearsonPCC(I,J);		% independant of the threshold
	[M1,M2]			= ManderCoeff(I,J,IJbw);
	[M1Pix,M2Pix]	= PercentagePix(IJbw);
    
    % add stats values into the table
    uit = findobj('Tag', 'uitAll');
    uitOld = get(uit, 'Data');
    ColData = [filename1 filename2 PCC M1 M2 M1Pix M2Pix Ithr Jthr];	% see how to index it to not use PCC
    uit.Data = [uitOld; ColData];
end
function [PCC] = PearsonPCC(I,J)
    PCC1 = double(I)-mean(I,'all');
    PCC2 = double(J)-mean(J,'all');
    PCC3 = PCC1.*PCC2;
    PCC4 = sum(PCC3,'all');

    PCC5 = sum(power(PCC1,2),'all');
    PCC6 = sum(power(PCC2,2),'all');
    PCC7 = sqrt(PCC5 * PCC6);

    PCC = PCC4 / PCC7;
end
function [M1,M2,M1M2] = ManderCoeff(I,J,IJbw)
% I and J are the two channels to check for coloc
% IJbw is the map of the channels and the coloc
% where channel1=1, channel2=2, coloc=3
    M1	= sum(I(IJbw==3))/sum(sum(I));		% M1: sum intensity of coloc div by sum intensity all ch1
    M2	= sum(J(IJbw==3))/sum(sum(J));		% M2: sum intensity of coloc div by sum intensity all ch2
    M1M2 = [M1 M2];
end
function [M1Pix,M2Pix] = PercentagePix(IJbw)
    % get number of pixels for each specific mask
    [N, ~]  = histcounts(IJbw);
    try
        PxI     = N(2);		% pixels = 1
        PxJ		= N(3);		% pixels = 2
        PxIJ	= N(4);     % pixels = 3
        % calculate % of coloc for each channel (intensity independant)
        M1Pix = PxIJ/(PxI+PxIJ);		% M1: percentage of I in J (as pixel number)
        M2Pix = PxIJ/(PxJ+PxIJ);		% M2: percentage of J in I (as pixel number)
    catch
        disp(['ERROR: At least 1 of the channel does not have values above threshold.' ...
            '   Assigning a value of 0'])
        M1Pix = 0;
        M2Pix = 0;
    end
end
