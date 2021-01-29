function FindSlopeArray()

    T = readtable('DataTest2.txt');
    T = table2array(T);

    dydx = zeros(size(T,1), size(T,2));
    for i = 2:size(T,2)
        dydx(:,i) = gradient(T(:,i)) ./ gradient(T(:,1));
    end

    %   Plot all data
    plot(T(:,1),...
        T(:,2:end),...
        'Color', 'b');

    %   Find positive slope
    T2 = T;
    T2(dydx<=0) = 0;

    hold on
    for i = 2:size(T2,2)
        zpos = find(~[0 T2(:,i)' 0]);
        [~, grpidx] = max(diff(zpos));
        y = T2(zpos(grpidx):zpos(grpidx+1)-2,i);

        T2(1:zpos(grpidx)-1,i) = 0;
        T2(zpos(grpidx+1)-1:end,i) = 0;

        val1 = find(T(:,i)==min(y));
        val2 = find(T(:,i)==max(y));
        mdl = fitlm(T(val1:val2,1),T(val1:val2,i));

        plot(T(val1:val2,1),...
            T(val1:val2,i),...
            'Marker','o',...
            'Color','r',...
            'LineStyle','none');



        plot(T(:,1),...
            mdl.Coefficients.Estimate(2).*T(:,1)+mdl.Coefficients.Estimate(1),...
            'Color','k');
    end
    hold off
    
end
