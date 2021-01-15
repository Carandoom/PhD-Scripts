% Statistic related functions
function [] = StatGraph(I,J,Ithr,Jthr,filename1,filename2)
	
    % calcul of IJbw
    Ibw = UpdateBw(I,Ithr,0);
    Jbw = UpdateBw(J,Jthr,0);
    Jbw(Jbw == 1) = 2;
    IJbw = imadd(Ibw,Jbw);
    
    % stats
    [PCC]			= PearsonPCC(I,J);		% independant of the threshold
	[M1,M2]			= ManderCoeff(I,J,IJbw);
	[M1Pix,M2Pix]	= PercentagePix(IJbw);
    
    % add stats values into the table
    uit = findobj('Tag', 'uitAll');
    uitOld = get(uit, 'Data');
    ColData = [filename1 filename2 PCC M1 M2 M1Pix M2Pix Ithr Jthr];	% see how to index it to not use PCC
    uit.Data = [uitOld; ColData];
end
