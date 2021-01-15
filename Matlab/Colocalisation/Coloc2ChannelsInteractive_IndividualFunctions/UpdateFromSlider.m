% MakeNewFigure related functions
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
    
    ShowOriginalIm(I{NoIm},J{NoIm},ax,false);
    ShowColocIm(I{NoIm},J{NoIm},ax,false);
    ScatterLinearFit(I{NoIm},J{NoIm},ax,false);
    UpdateBw(I{NoIm},CBLIDataX(1),ax(2),false);
    UpdateBw(J{NoIm},CBLJDataX(1),ax(5),false);
    CreateHisto(I{NoIm},J{NoIm},ax);
    
    CreatePatch(ax(3),CBLIDataX);
    CreatePatch(ax(6),CBLJDataX);
end
