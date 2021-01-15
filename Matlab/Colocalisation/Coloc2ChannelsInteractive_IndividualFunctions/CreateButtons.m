% MakeNewFigure related functions
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
        'String', 'Apply', ...
        'Tag', 'bAll', ...
        'Units', 'normalized', ...
        'Position', [0.43,0.25,0.07,0.03], ...
        'CallBack', @(hObject,event) ApplyToAll(I,J,ax,filename1,filename2)...
        );
end