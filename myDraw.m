function myDraw(Data)
    % Specified for myemo only.
    % Data as Population.objs, shape == (pop_size, obj_dim)

    %% The size of the figure
    set(gca,'Unit','pixels');
    if get(gca,'Position') <= [inf inf 400 300]
        Size = [3 5 .8 8];
    else
        Size = [6 8 2 13];
    end

    %% Draw the figure
    set(gca,'NextPlot','add','Box','on','Fontname','Times New Roman','FontSize',Size(4));

    plot(Data(:,1),Data(:,2),'o','MarkerSize',Size(1));
    xlabel('\it f\rm_1'); ylabel('\it f\rm_2');
    set(gca,'XTickMode','auto','YTickMode','auto','View',[0 90]);
end