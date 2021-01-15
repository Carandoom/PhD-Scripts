% MakeNewFigure related functions
function [] = SetGraphPosition(ax)
    set(ax(1),'Position', [0,0.68,0.28,0.28]);
    ax(1).Title.String = 'Channel 1';
    set(ax(2),'Position', [0.18,0.68,0.28,0.28]);
    ax(2).Title.String = 'Threshold ch1';
    set(ax(3),'Position', [0.5,0.71,0.37,0.23]);
    ax(3).Title.String = 'histogram pixel intensity ch1';
    
    set(ax(4),'Position', [0,0.36,0.28,0.28]);
    ax(4).Title.String = 'Channel 2';
    set(ax(5),'Position', [0.18,0.36,0.28,0.28]);
    ax(5).Title.String = 'Threshold ch2';
    set(ax(6),'Position', [0.5,0.39,0.37,0.23]);
    ax(6).Title.String = 'histogram pixel intensity ch2';
    
    set(ax(7),'Position', [0,0.04,0.28,0.28]);
    ax(7).Title.String = 'Overlay';
    
    fTxtG = text(ax(7));
    fTxtG.String = 'ch1';
    fTxtG.FontWeight = 'bold';
    fTxtG.Units = 'normalized';
    fTxtG.Position = [0.05 0.95];
    fTxtG.Color = 'green';
    
    fTxtR = text(ax(7));
    fTxtR.String = 'ch2';
    fTxtR.FontWeight = 'bold';
    fTxtR.Units = 'normalized';
    fTxtR.Position = [0.85 0.95];
    fTxtR.Color = 'red';
    
    set(ax(8),'Position', [0.25,0.075,0.14,0.23]);
end
