function FindSlope()

close all
clear
clc

[T] = OpenFile();
[f,ax,ylimPlot] = CreateFigure(T);

%   Pause the script until you selected a range to get the slope
waitfor(findobj('Tag','bNxt'));

[T2] = FindPositiveSlope(f,T);


%%  Extract longest slope and fit linear regression
Parameters = zeros(2,size(T,2));
hold on
for i = 2:size(T,2)
    [Parameters] = FindLongestSlope(ax,T,T2,i,Parameters);
end
hold off
ylim([ylimPlot(1) ylimPlot(2)]);


%%  Plot Parameters
% ax(2).Visible = 'on';
% boxplot(Parameters(1,:));
% hold on
% scatter(repmat(1,1,size(T,2)),Parameters(1,:));
% hold off

end


function [T] = OpenFile()
    cd 'C:\Users\henryc\Desktop\GitHub\Matlab find slope'
    T = readtable('DataTest2.txt');
    T = table2array(T);
end

function [f,ax,ylimPlot] = CreateFigure(T)
    f = figure();
    ax(1) = subplot(2,1,1);
    ax(2) = subplot(2,1,2);
    ax(2).Visible = 'off';
    
    [ylimPlot] = PlotAllData(ax,T);
    AddSlider(f,T(1,1),T(end,1));
    CreateValidationButton(f);
end
function [ylimPlot] = PlotAllData(ax,T)
    plot(ax(1),T(:,1),...
        T(:,2:size(T,2)),...
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
        'Value', 40, ...
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
        'Value', 120, ...
        'Units', 'normalized', ...
        'Position', [0.13, 0.3, 0.775, 0.06] ...
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

function [T2] = FindPositiveSlope(f,T)
    [FirstN, LastN] = GetRangeSlope(f,T);
    [dydx] = FirstDerivative(T);
    T2 = T;
    T2(dydx<=0) = 0;
    T2([1:FirstN LastN:end],:) = 0;
end
function [FirstN, LastN] = GetRangeSlope(f,T)
    FirstN = f.UserData(1);
    LastN = f.UserData(2);
    [~, FirstN] = min(abs(T(:,1)-FirstN));
    [~, LastN] = min(abs(T(:,1)-LastN));
end
function [dydx] = FirstDerivative(T)
    dydx = zeros(size(T,1), size(T,2));
    dydx(:,1) = T(:,1);
    for i = 2:size(T,2)
        dydx(:,i) = gradient(T(:,i)) ./ gradient(T(:,1));
    end
end

function [Parameters] = FindLongestSlope(ax,T,T2,i,Parameters)
    zpos = find(~[0 T2(:,i)' 0]);
    [~, grpidx] = max(diff(zpos));
    y = T2(zpos(grpidx):zpos(grpidx+1)-2,i);
    
    [Parameters] = LinearFit(ax,T,zpos,grpidx,i,Parameters);
end
function [Parameters] = LinearFit(ax,T,zpos,grpidx,i,Parameters)
    val1 = zpos(grpidx)-1;
    val2 = zpos(grpidx+1)-1;
    mdl = fitlm(T(val1:val2,1),T(val1:val2,i));
    Parameters(1,i) = mdl.Coefficients.Estimate(2);
    PlotLinearFit(ax,T,val1,val2,i,mdl)
end
function [] = PlotLinearFit(ax,T,val1,val2,i,mdl)
    line(ax(1),T(val1:val2,1),...
        T(val1:val2,i),...
        'Marker','o',...
        'Color','r',...
        'LineStyle','none');
    line(ax(1),T(val1:val2,1),...
        mdl.Coefficients.Estimate(2).*T(val1:val2,1)+mdl.Coefficients.Estimate(1),...
        'Color','k');
end
