function x = Cart2Spherical(pos, model, n)
%myFun - Description
%
% Syntax: x = Cart2Spherical(pos, model)
%
%  x: r-psi-phi under spherical 10 by 3
%  pos: x-y-z under cartisian 10 by 3
    starting = model.start(n, :);
    pos = [starting; pos];
    x = zeros(model.n, 3);
    for i = 2:model.n+1
        x(i-1, :) = [r_transform(pos(i-1, 1), pos(i-1, 2), pos(i-1, 3), pos(i, 1), pos(i, 2), pos(i, 3)) 
                    psi_transform(pos(i-1, 1), pos(i-1, 2), pos(i-1, 3), pos(i, 1), pos(i, 2), pos(i, 3))
                    phi_transform(pos(i-1, 1), pos(i-1, 2), pos(i-1, 3), pos(i, 1), pos(i, 2), pos(i, 3))];
    end
end

function r = r_transform(x_, y_, z_, x, y, z)
    r = sqrt((x - x_)^2 + (y - y_)^2 + (z - z_)^2);
end

function psi = psi_transform(x_, y_, z_, x, y, z)
    psi = atan2(sqrt((x - x_)^2 + (y - y_)^2), (z - z_));
end

function phi = phi_transform(x_, y_, ~, x, y, ~)
    phi = atan2(y - y_, x - x_);
end
    