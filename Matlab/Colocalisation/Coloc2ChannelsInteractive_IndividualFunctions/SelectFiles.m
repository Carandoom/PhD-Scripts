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
        I{i} = CurrentIm;
        I{i} = LowPassFilter(I{i},25);
    end
end
