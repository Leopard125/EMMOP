function pos = Spherical2Cart(x, model, n)
%  pos: x-y-z under cartisian 10 by 3
%  x: r-psi-phi under spherical 10 by 3
    starting = model.start(n, :);
    pos = zeros(model.n, 3);
    pos(1, :) = [x_transform(starting(1), x(1, 1), x(1, 2), x(1, 3)) 
                 y_transform(starting(2), x(1, 1), x(1, 2), x(1, 3))
                 z_transform(starting(3), x(1, 1), x(1, 2), x(1, 3))];
    if pos(1, 1) > model.xmax; pos(1, 1) = model.xmax; end
    if pos(1, 1) < model.xmin; pos(1, 1) = model.xmin; end
    if pos(1, 2) > model.ymax; pos(1, 2) = model.ymax; end
    if pos(1, 2) < model.ymin; pos(1, 2) = model.ymin; end
    if pos(1, 3) > model.zmax; pos(1, 3) = model.zmax; end
    if pos(1, 3) < model.zmin; pos(1, 3) = model.zmin; end
    
    for i = 2:model.n
        pos(i, :) = [x_transform(pos(i-1, 1), x(i, 1), x(i, 2), x(i, 3)) 
                     y_transform(pos(i-1, 2), x(i, 1), x(i, 2), x(i, 3))
                     z_transform(pos(i-1, 3), x(i, 1), x(i, 2), x(i, 3))];
        if pos(i, 1) > model.xmax; pos(i, 1) = model.xmax; end
        if pos(i, 1) < model.xmin; pos(i, 1) = model.xmin; end
        if pos(i, 2) > model.ymax; pos(i, 2) = model.ymax; end
        if pos(i, 2) < model.ymin; pos(i, 2) = model.ymin; end
        if pos(i, 3) > model.zmax; pos(i, 3) = model.zmax; end
        if pos(i, 3) < model.zmin; pos(i, 3) = model.zmin; end
    end
end


function x = x_transform(x_last, r, psi, phi)
    x = x_last + r*cos(psi)*sin(phi);
end

function y = y_transform(y_last, r, psi, phi)
    y = y_last + r*cos(psi)*cos(phi);
end

function z = z_transform(z_last, r, psi, ~)
    z = z_last + r*sin(psi);
end