% Statistic related functions
function [M1Pix,M2Pix] = PercentagePix(IJbw)
    % get number of pixels for each specific mask
    [N, ~]  = histcounts(IJbw);
    try
        PxI     = N(2);		% pixels = 1
        PxJ		= N(3);		% pixels = 2
        PxIJ	= N(4);     % pixels = 3
        % calculate % of coloc for each channel (intensity independant)
        M1Pix = PxIJ/(PxI+PxIJ);		% M1: percentage of I in J (as pixel number)
        M2Pix = PxIJ/(PxJ+PxIJ);		% M2: percentage of J in I (as pixel number)
    catch
        disp(['ERROR: At least 1 of the channel does not have values above threshold.' ...
            '   Assigning a value of 0'])
        M1Pix = 0;
        M2Pix = 0;
    end
end
