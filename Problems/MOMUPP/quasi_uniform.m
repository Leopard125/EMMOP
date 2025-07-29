function node_vector=quasi_uniform(n,k)
% Node vector calculation for B-Spline
node_vector=zeros(1,n+k+2);
piecewise=n-k+1;
if piecewise == 1
    for i=n+2:n+k+2
        node_vector(1,i)=1;
    end
else
    flag=1;
    while flag~=piecewise
        node_vector(1,k+1+flag)=node_vector(1,k+flag)+1/piecewise;
        flag=flag+1;
    end
    node_vector(1,n+2:n+k+2)=1;
end
end
    
