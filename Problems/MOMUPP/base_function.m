function Nik_u = base_function(i, k , u, node_vector)
% Calculate base function for B-Spline
if k == 0
    if (u >= node_vector(i+1)) && (u < node_vector(i+2))
        Nik_u = 1.0;
    else
        Nik_u = 0.0;
    end
else
    Length1 = node_vector(i+k+1) - node_vector(i+1);
    Length2 = node_vector(i+k+2) - node_vector(i+2);
    if Length1 == 0.0
       Length1 = 1.0;
    end
    if Length2 == 0.0
         Length2 = 1.0;
    end
    Nik_u = (u - node_vector(i+1)) / Length1 * base_function(i, k-1, u, node_vector) ...
         + (node_vector(i+k+2) - u) / Length2 * base_function(i+1, k-1, u, node_vector);
end
end
