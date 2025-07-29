function PlotModel(model,pic)
    figure(pic);
    mesh(model.X,model.Y,model.H,'FaceColor','flat');
    colormap summer;
    set(gca, 'Position', [0 0 1 1]); % Fill the figure window.
    axis equal;
    shading interp;
    material dull;
    camlight left;                   % Add a light over to the left somewhere.
    lighting gouraud;
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    hold on
    
    % radars
    radars = model.radars;
    radar_num = size(radars,1);
    
    for i=1:radar_num
        radar = radars(i,:);
        radar_x = radar(1);
        radar_y = radar(2);
        radar_z = model.H(radar_y,radar_x);
        radar_radius = radar(3);
        radar_height = radar(4);
        
        [xr,yr,zr]=cylinder;
        zr(zr<0)=0;
        xr = xr*radar_radius+radar_x;
        yr = yr*radar_radius+radar_y;
        zr = zr*1.5*radar_height+radar_z;
        mesh(xr,yr,zr,'FaceAlpha',0.3,'FaceColor','#FF0000','EdgeColor','none');
    end
    hold on

end