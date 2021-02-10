%	
%	Need dot separated numbers in the original txt file
%	add: converter from comma to dot numbers
%   Take the DELTA from the beginning and end of the slope
%   Adjust the slope to not take into account the flat parts
%   Add filter for time section to work in
%   
%   DATA STRUCTURE:
%       Text files is imported, the first column is stored into x and used
%       as x values whereas all the other columns are stored into T and
%       used as y values.
%   


function FindSlope()

close all
clear
clc

[T,x] = OpenFile();
[f,ax,ylimPlot] = CreateFigure(T,x);

waitfor(findobj('Tag','bNxt')); %   Pause until range selected

[T2] = FindPositiveSlope(f,T,x);

%%  Extract longest slope and fit linear regression
Parameters = zeros(2,size(T,2));
for i = 1:size(T,2)
    try
        pause(0.1);
        plot(ax(1),x,T(:,i),'Color', 'b');
        ylimPlot = ylim(ax(1));
        [Parameters] = FindLongestSlope(ax,T,x,T2,i,Parameters);
    catch
    end
        [int2str(i) ' out of ' int2str(size(T,2))]
end
ylim([ylimPlot(1) ylimPlot(2)]);

%%  Plot Parameters
% ax(2).Visible = 'on';
% boxplot(Parameters(1,:));
% hold on
% scatter(repmat(1,1,size(T,2)),Parameters(1,:));
% hold off

%% Write data in txt
fileID = fopen('Slope_2021-02-03.txt','w');
fprintf(fileID,'%f\n',Parameters(1,2:end));
fclose(fileID);

close all
end


function [T,x] = OpenFile()
    cd 'C:\Users\henryc\Desktop\GitHub\Matlab find slope'
    T = readtable('2021-02-03.txt');
    T = table2array(T);
    x = T(:,1);
    T = T(:,2:end);
    [T] = MedSmoothData(T);
end
function [T] = MedSmoothData(T)
    MedLen = 5;
    T = medfilt2(T,[MedLen 1]);
end

function [f,ax,ylimPlot] = CreateFigure(T,x)
    f = figure();
    ax(1) = subplot(2,1,1);
    ax(2) = subplot(2,1,2);
    ax(2).Visible = 'off';
    
    [ylimPlot] = PlotAllData(ax,T,x);
    AddSlider(f,x(1),x(end));
    CreateCheckPosNegSlope(f);
    CreateValidationButton(f);
end
function [ylimPlot] = PlotAllData(ax,T,x)
    plot(ax(1),...
        x,...
        T,...
        'Color', 'b');
    ylimPlot = ylim(ax(1));
end
function [] = AddSlider(f,ValMin,ValMax)
    txt1 = uicontrol(f, ...
        'Style', 'text', ...
        'Tag', 'txt1', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'String', ValMin, ...
        'Units', 'normalized', ...
        'Position', [0.02, 0.3966, 0.1, 0.06] ...
        );
    uit1 = uicontrol(f, ...
        'Style', 'slider', ...
        'Tag', 'uit1', ...
        'Min', ValMin, ...
        'Max', ValMax, ...
        'Value', 50, ...
        'Units', 'normalized', ...
        'Position', [0.13, 0.4, 0.775, 0.06] ...
        );
    txt2 = uicontrol(f, ...
        'Style', 'text', ...
        'Tag', 'txt2', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'String', ValMax, ...
        'Units', 'normalized', ...
        'Position', [0.02, 0.2966, 0.1, 0.06] ...
        );
    uit2 = uicontrol(f, ...
        'Style', 'slider', ...
        'Tag', 'uit2', ...
        'Min', ValMin, ...
        'Max', ValMax, ...
        'Value', 150, ...
        'Units', 'normalized', ...
        'Position', [0.13, 0.3, 0.775, 0.06] ...
        );
end
function [] = CreateCheckPosNegSlope(f)
    CheckBox1 = uicontrol(f, ...
        'Style', 'checkbox', ...
        'Tag', 'CheckBox1', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'String', 'Negative Slope', ...
        'Units', 'normalized', ...
        'Position', [0.42, 0.185, 0.3, 0.08] ...
        );
end
function [] = CreateValidationButton(f)
    bNxt = uicontrol(f,...
        'Style', 'pushbutton', ...
        'String', 'Validate Range', ...
        'FontSize',12, ...
        'Tag', 'bNxt', ...
        'Units', 'normalized', ...
        'Position', [0.36, 0.1, 0.3, 0.08], ...
        'CallBack', @(hObject,event) DeleteElements(f) ...
        );
end
function DeleteElements(f)
    uit1 = findobj('Tag','uit1');
    uit2 = findobj('Tag','uit2');
    txt1 = findobj('Tag','txt1');
    txt2 = findobj('Tag','txt2');
    bNxt = findobj('Tag','bNxt');
    if round(uit1.Value)>round(uit2.Value)
        warndlg('Min value must be lower than Max value','Error range value')
        return
    end
    f.UserData = [round(uit1.Value) round(uit2.Value)];
    uit1.delete
    uit2.delete
    txt1.delete
    txt2.delete
    bNxt.delete
end

function [T2] = FindPositiveSlope(f,T,x)
    [FirstN, LastN] = GetRangeSlope(f,x);
    [dydx] = FirstDerivative(T,x);
    T2 = T;
    NegOrPos = findobj('Tag','CheckBox1');
    if NegOrPos.Value == 1
        T2(dydx<=0) = 0;
    elseif NegOrPos.Value == 0
        T2(dydx>=0) = 0;
    end
    T2([1:FirstN LastN:end],:) = 0;
end
function [FirstN, LastN] = GetRangeSlope(f,x)
    FirstN = f.UserData(1);
    LastN = f.UserData(2);
    [~, FirstN] = min(abs(x-FirstN));
    [~, LastN] = min(abs(x-LastN));
end
function [dydx] = FirstDerivative(T,x)
    dydx = zeros(size(T,1), size(T,2));
    for i = 1:size(T,2)
        dydx(:,i) = gradient(T(:,i)) ./ gradient(x);
    end
end

function [Parameters] = FindLongestSlope(ax,T,x,T2,i,Parameters)
    zpos = find(~[0 T2(:,i)' 0]);
    [~, grpidx] = max(diff(zpos));
    y = T2(zpos(grpidx):zpos(grpidx+1)-2,i);
    
    [Parameters] = LinearFit(ax,T,x,zpos,grpidx,i,Parameters);
end
function [Parameters] = LinearFit(ax,T,x,zpos,grpidx,i,Parameters)
    val1 = zpos(grpidx);
    val2 = zpos(grpidx+1)-2;
    val3 = round((val2-val1)/4);
    try
        mdl = fitlm(x(val1+val3:val2-val3),T(val1+val3:val2-val3,i));
    catch
    end
    Parameters(1,i) = mdl.Coefficients.Estimate(2);
    PlotLinearFit(ax,T,x,val1,val2,val3,i,mdl)
end
function [] = PlotLinearFit(ax,T,x,val1,val2,val3,i,mdl)
    line(ax(1),x(val1+val3:val2-val3),...
        T(val1+val3:val2-val3,i),...
        'Marker','o',...
        'Color','r',...
        'LineStyle','none');
    line(ax(1),x(val1:val2),...
        mdl.Coefficients.Estimate(2).*x(val1:val2)+mdl.Coefficients.Estimate(1),...
        'Color','k');
end
