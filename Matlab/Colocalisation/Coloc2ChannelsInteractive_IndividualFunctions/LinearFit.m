% Plot fixed data
function [IPixels2,Yfit] = LinearFit(IPixels,JPixels)
    IPixels2 = double(IPixels);
    JPixels2 = double(JPixels);
    
    IPixels2(IPixels==0 | JPixels==0) = [];
    JPixels2(IPixels==0 | JPixels==0) = [];
    
    Po = polyfit(IPixels2,JPixels2,1);
    Yfit = Po(1)*IPixels2+Po(2);
end
