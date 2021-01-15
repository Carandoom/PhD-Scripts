% SelectFiles related functions
function [I] = LowPassFilter(I,Gval)
% low pass filter and remove BG
    Ibg	= imgaussfilt(I,Gval);
    I	= imsubtract(I,Ibg);
end
