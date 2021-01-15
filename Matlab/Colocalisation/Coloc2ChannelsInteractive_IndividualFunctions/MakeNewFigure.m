% MakeNewFigure related functions
function [ax] = MakeNewFigure(nbRow,nbColumn,I,J,filename1,filename2,NoIm)
	f = figure('WindowState','maximized');
	for i=1:(nbRow*nbColumn)
		ax(i) = subplot(nbRow,nbColumn,i);
    end
    linkaxes([ax(1) ax(2) ax(4) ax(5) ax(7)]);
    delete(ax(9));
    
    CreateButtons(f,ax,I,J,filename1,filename2);    % create buttons
    CreateTables(f);                                % create tables
    [CkBx] = CreateCheckBox(f);                     % create check box to use thr or not
    CreateSlider(f,ax,CkBx,I,J,NoIm);               % create slider for image switch
end
