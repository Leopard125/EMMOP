function [x, y] = BresenhamLine(x0, y0, x1, y1)
% Bresenham's Line Algorithm for integer grid traversal
x0 = round(x0); y0 = round(y0);
x1 = round(x1); y1 = round(y1);

dx = abs(x1 - x0);
dy = abs(y1 - y0);

sx = sign(x1 - x0);
sy = sign(y1 - y0);

x = [];
y = [];

if dy <= dx
    err = dx / 2;
    ycurr = y0;
    for xcurr = x0:sx:x1
        x(end+1) = xcurr;
        y(end+1) = ycurr;
        err = err - dy;
        if err < 0
            ycurr = ycurr + sy;
            err = err + dx;
        end
    end
else
    err = dy / 2;
    xcurr = x0;
    for ycurr = y0:sy:y1
        x(end+1) = xcurr;
        y(end+1) = ycurr;
        err = err - dx;
        if err < 0
            xcurr = xcurr + sx;
            err = err + dy;
        end
    end
end
end
