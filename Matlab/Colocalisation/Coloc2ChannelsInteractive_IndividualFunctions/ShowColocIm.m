% Plot fixed data
function [] = ShowColocIm(I,J,ax,FirstTime)
    ImColoc = imfuse(I,J,'colorChannels', [1 2 0]); %%test with RGB convertion
    if FirstTime == true
        imshow(ImColoc,[],'parent',ax(7));
    else
        Im1 = findobj(ax(7),'Type','image');
        Im1.CData = ImColoc;
    end
end
