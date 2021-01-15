% MakeNewFigure related functions
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