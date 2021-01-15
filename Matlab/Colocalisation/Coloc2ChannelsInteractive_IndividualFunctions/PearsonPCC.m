% Statistic related functions
function [PCC] = PearsonPCC(I,J)
    PCC1 = double(I)-mean(I,'all');
    PCC2 = double(J)-mean(J,'all');
    PCC3 = PCC1.*PCC2;
    PCC4 = sum(PCC3,'all');

    PCC5 = sum(power(PCC1,2),'all');
    PCC6 = sum(power(PCC2,2),'all');
    PCC7 = sqrt(PCC5 * PCC6);

    PCC = PCC4 / PCC7;
end
