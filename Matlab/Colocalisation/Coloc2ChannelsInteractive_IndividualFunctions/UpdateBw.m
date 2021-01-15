% Callback from histo
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
