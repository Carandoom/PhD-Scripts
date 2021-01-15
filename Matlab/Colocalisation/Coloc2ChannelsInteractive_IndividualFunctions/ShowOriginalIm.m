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
