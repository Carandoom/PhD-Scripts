%	
%	Need dot separated numbers in the original txt file
%	add: converter from comma to dot numbers
%	
%	

function FindSlope()

clear
clc

%	Get data: f(x)=y
%	Get first derivative: f'(x)=y'
%	Get positive part of the first derivative: f'(x) = positive
%	Extract f(x)=y for x when f'(x) = positive
%	Display f(x)=y and highlight selected x limits
%	Fit linear regression on f(x)=y in range and get slope

fid = fopen('DataTest.txt');
a = textscan(fid,'%f %f');
fclose(fid);

dydx = gradient(a{1,2}) ./ gradient(a{1,1});
[row,col] = find(dydx>0);

%   Find longest portion of positive slope
x = a;
x{1,1}(dydx<=0,1) = 0;
zpos = find(~[0 x{1,1}' 0]);
[~, grpidx] = max(diff(zpos));
y = x{1,1}(zpos(grpidx):zpos(grpidx+1)-2,1);

%   Need to get the y in x only
x{1,1}(x{1,1}<min(y),1) = 0;
x{1,1}(x{1,1}>max(y),1) = 0;
x{1,2}(x{1,1}<min(y),1) = 0;
x{1,2}(x{1,1}>max(y),1) = 0;

%   fit linear model to the data
val1 = find(a{1,1}==min(y));
val2 = find(a{1,1}==max(y));
mdl = fitlm(a{1,1}(val1:val2,1),a{1,2}(val1:val2,1));

%   plot data
plot(a{1,1},...
a{1,2},...
'Color','b');
ylimPlot = ylim;
hold on
plot(x{1,1}(row,1),...
    x{1,2}(row,1),...
    'Marker','o',...
    'Color','r',...
    'LineStyle','none');
plot(a{1,1}, ...
    (mdl.Coefficients.Estimate(2).*a{1,1}+mdl.Coefficients.Estimate(1)));
hold off
ylim([ylimPlot(1) ylimPlot(2)]);



end

function FindSlopeTable()


T = readtable('DataTest2.txt');
dydx = zeros(size(T,1), size(T,2)-1);
for i = 2:size(T,2)
    dydx(:,i) = gradient(T{:,i}) ./ gradient(T{:,1});
end

%   plot data and the positive points from the first derivative
hold on
for i = 2:size(T,2)
    plot(table2array(T(:,1)),dydx(:,i))
end
hold off

%   Find longest portion of positive slope
T2 = table2array(T);
T2(dydx>0) = 0;
% check that the T2 value is well taken
for i = 1:size(T2,2)
    zpos = find(~[0 T2(:,i)' 0]);
    [~, grpidx] = max(diff(zpos));
    % check that we take the proper value for y
    y = T2(zpos(grpidx):zpos(grpidx+1)-2);
    T2(1:min(y),i) = 0;
    T2(max(y):end,i) = 0;
end



hold on
plot(table2array(T(row,1)),...
dydx(row,1),...
'Marker','o',...
'Color','r',...
'LineStyle','none');
hold off
end

function FindSlopeArray()
T = readtable('DataTest2.txt');
T = table2array(T);






end


































