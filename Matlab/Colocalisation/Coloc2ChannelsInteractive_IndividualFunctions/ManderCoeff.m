% Statistic related functions
function [M1,M2,M1M2] = ManderCoeff(I,J,IJbw)
% I and J are the two channels to check for coloc
% IJbw is the map of the channels and the coloc
% where channel1=1, channel2=2, coloc=3
    M1	= sum(I(IJbw==3))/sum(sum(I));		% M1: sum intensity of coloc div by sum intensity all ch1
    M2	= sum(J(IJbw==3))/sum(sum(J));		% M2: sum intensity of coloc div by sum intensity all ch2
    M1M2 = [M1 M2];
end
