function inShadow = IsInShadow(DEM, pt1, pt2)
% Use Bresenham to judge whether pt1--pt2 crossing the DEM height field

x0 = pt1(1);
y0 = pt1(2);
x1 = pt2(1);
y1 = pt2(2);

[pixelX, pixelY] = BresenhamLine(x0, y0, x1, y1);
nPts = length(pixelX);

z0 = pt1(3);
z1 = pt2(3);

dTotal = norm([x1 - x0, y1 - y0]);

inShadow = false;

for i = 2:nPts-1
    x = pixelX(i);
    y = pixelY(i);

    if x < 1 || x > size(DEM, 2) || y < 1 || y > size(DEM, 1)
        continue;
    end

    dNow = norm([x - x0, y - y0]);

    z_line = z0 + (z1 - z0) * (dNow / dTotal);

    z_terrain = DEM(round(y), round(x));

    if z_terrain > z_line
        inShadow = true;
        return;
    end
end

end
