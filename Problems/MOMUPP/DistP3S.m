function dist = DistP3S(x,a,b)
% Distance from a point to a line
    d_ab = norm(a-b);
    d_ax = norm(a-x);
    d_bx = norm(b-x);
    if d_ab ~= 0 
        if dot(a-b,x-b)*dot(b-a,x-a)>=0
            dist=norm(cross((b-a),(x-b)))/norm(b-a);
        else
            dist = min(d_ax, d_bx);
        end
    else
        dist = d_ax;
    end
end