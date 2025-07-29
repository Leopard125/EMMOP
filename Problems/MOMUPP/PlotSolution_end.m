function PlotSolution_end(Population, name)
    result_fig = figure('NumberTitle', 'off', 'Name', [name, 'Balance']);
    model = CreateModel(result_fig);    
    colors = ['r', 'y', 'b', 'c', 'k'];
    nUAV = model.num;

    % Select knee point
    all_objs = zeros(length(Population), size(Population(1).objs, 2));
    for i = 1:length(Population)
        all_objs(i, :) = Population(i).objs;
    end
    [~, bound_f1_idx] = max(all_objs(:, 1), [], 1);
    [~, bound_f2_idx] = max(all_objs(:, 2), [], 1);
    bound_f1 = Population(bound_f1_idx).objs;
    bound_f2 = Population(bound_f2_idx).objs;
    
    a = -(bound_f1(2) - bound_f2(2))./(bound_f1(1) - bound_f2(1));
    b = 1;
    c = -bound_f2(2) - a * bound_f2(1);
    dnum = sqrt(a.^2 + b.^2);
    dist_list = abs(a * all_objs(:, 1) + b * all_objs(:, 2) + c) ./ dnum;
    [~, knee_idx] = max(dist_list);
    allWaypoints = reshape(Population(knee_idx).dec, [], nUAV)';

    % min distance
    [~, idx_d] = min(all_objs(:, 1), [], 1);  % min distance
    [~, idx_t] = min(all_objs(:, 2), [], 1);    % min threat
    allWaypoints_d = reshape(Population(idx_d).decs, [], nUAV)';
    allWaypoints_t = reshape(Population(idx_t).decs, [], nUAV)';

    Draw(nUAV, allWaypoints, model, colors);
    % hold off;
    % result_fig_d = figure('NumberTitle', 'off', 'Name', [name, 'Least Distance']);
    % CreateModel(result_fig_d);
    % Draw(nUAV, allWaypoints_d, model, colors);
    % hold off
    % result_fig_t = figure('NumberTitle', 'off', 'Name', [name, 'Least Threat']);
    % CreateModel(result_fig_t);
    % Draw(nUAV, allWaypoints_t, model, colors);
end

function Draw(nUAV, allWaypoints, model, colors)
    for n = 1:nUAV
        waypoints = reshape(allWaypoints(n, :), [], 3);
        waypoints = Spherical2Cart(waypoints, model, n);

        for i = 1:size(waypoints, 1)
            waypoints(i, 3) = waypoints(i, 3) + model.H(floor(waypoints(i, 2)), floor(waypoints(i, 1)));
        end
        x_all = [model.start(n, 1); waypoints(:, 1); model.end(n, 1)];
        y_all = [model.start(n, 2); waypoints(:, 2); model.end(n, 2)];
        z_all = [model.start(n, 3) + model.H(floor(model.start(n, 2)), floor(model.start(n, 1))); waypoints(:, 3); model.end(n, 3) + model.H(floor(model.end(n, 2)), floor(model.end(n, 1)))];
        color = colors(n);
        % scatter3(x_all, y_all, z_all, 50, color, "v", "filled")
        % B-spline
        bspline_k=8;
        bspline_n=model.n+1;
        Bik=zeros(bspline_n+1,1);
        node_vector=quasi_uniform(bspline_n,bspline_k-1);
        d_control=transpose([x_all,y_all,z_all]);
        path=[];
        for u=0:0.005:1-0.005
            for j=0:bspline_n
                Bik(j+1,1)=base_function(j,bspline_k-1,u,node_vector);
            end
            p_u=d_control*Bik;
            if p_u(3,1) -  model.H(round(p_u(2,1)), round(p_u(1,1))) < model.zmin
                p_u(3,1) = model.H(round(p_u(2,1)), round(p_u(1,1))) + model.zmin;
            end
            path=[path;[p_u(1,1),p_u(2,1),p_u(3,1)]];
        end
        path = [path; [x_all(end), y_all(end), z_all(end)]];
        
        plot3(path(:,1),path(:,2),path(:,3),color,'LineWidth',2);
        
        % plot start point
        plot3(x_all(1),y_all(1),z_all(1),'ks','MarkerSize',15,'MarkerFaceColor',color);
        % plot target point
        plot3(x_all(end),y_all(end),z_all(end),'ko','MarkerSize',15,'MarkerFaceColor',color);
        hold on;
    end
end