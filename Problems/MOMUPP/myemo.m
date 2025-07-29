classdef myemo < PROBLEM
% <multiple><real><expensive><constrained>
    properties(SetAccess = protected)
        initFcn = {};   	% Function for initializing a population
        decFcn  = {};    	% Function for repairing invalid solution
        objFcn  = {};     	% Objective functions
        conFcn  = {};     	% Constraint functions
    end
    properties (SetAccess = private)
        model = [];
        result_3D = [];
    end
    methods
        function obj = myemo()
            obj.Global.M = 2;
            obj.Global.encoding = 'real';
            obj.result_3D = figure(1);
            obj.model = CreateModel(obj.result_3D);
            obj.Global.D = 3 * obj.model.n * obj.model.num;

            % sphere coordinate n by 1 -- (r - psi - phi)
            obj.Global.lower = repmat(reshape([zeros(obj.model.n, 1), -pi/4*ones(obj.model.n, 1), -pi*ones(obj.model.n, 1)], 1, []), 1, obj.model.num);
            obj.Global.upper = [2*norm(obj.model.start(1, :) - obj.model.end(1, :))/obj.model.n*ones(obj.model.n, 1)
                                pi/4*ones(obj.model.n, 1)
                                pi*ones(obj.model.n, 1)
                                2*norm(obj.model.start(2, :) - obj.model.end(2, :))/obj.model.n*ones(obj.model.n, 1)
                                pi/4*ones(obj.model.n, 1)
                                pi*ones(obj.model.n, 1)
                                2*norm(obj.model.start(3, :) - obj.model.end(3, :))/obj.model.n*ones(obj.model.n, 1)
                                pi/4*ones(obj.model.n, 1)
                                pi*ones(obj.model.n, 1)
                                2*norm(obj.model.start(4, :) - obj.model.end(4, :))/obj.model.n*ones(obj.model.n, 1)
                                pi/4*ones(obj.model.n, 1)
                                pi*ones(obj.model.n, 1)]';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            PopObj = zeros(size(PopDec, 1), obj.Global.M);
            nUAV = obj.model.num;
            allPaths = zeros(nUAV, obj.model.n+2, 3);
            for popIdx = 1:size(PopDec, 1)
                allWaypoints = reshape(PopDec(popIdx, :), [], nUAV)';
                for n = 1:nUAV
                    waypoints = reshape(allWaypoints(n, :), [], 3);
                    waypoints = Spherical2Cart(waypoints, obj.model, n);
                    for i = 1:size(waypoints, 1)
                        waypoints(i, 3) = 10*waypoints(i, 3) + 10*obj.model.H(floor(waypoints(i, 2)), floor(waypoints(i, 1)));
                        waypoints(i, 1) = 100*waypoints(i, 1);
                        waypoints(i, 2) = 100*waypoints(i, 2);
                    end
                    starting = 100*obj.model.start(n, :);
                    ending = 100*obj.model.end(n, :);
                    starting(3) = 10*starting(3) + 10*obj.model.H(floor(starting(2)/100), floor(starting(1)/100));
                    ending(3) = 10*ending(3) + 10*obj.model.H(floor(ending(2)/100), floor(ending(1)/100));
                    x = [starting; waypoints; ending];
                    allPaths(n, :, :) = x;
                end

                radars = obj.model.radars;
                radar_num = size(radars, 1);
                P_radar = zeros(radar_num,1);
                threatVal = 0;
                for n = 1:nUAV
                    diffs = zeros(1, obj.model.n-1);
                    x = reshape(allPaths(n, :, :), [], 3);
                    LenCost = 0;
                    for i = 1:size(x, 1)-1
                        diff = norm([x(i+1, 1) - x(i, 1); x(i+1, 2) - x(i, 2); x(i+1, 3) - x(i, 3)]);
                        LenCost = LenCost + diff;
                        diffs(i) = diff;
                    end
                    distVar = var(diffs);

                    % threat cost
                    % subNode = [0.1 0.3 0.5 0.7 0.9];    % interval between waypoints
                    for i = 1:size(x, 1)-1
                        temp_length = norm([x(i+1, 1) - x(i, 1); x(i+1, 2) - x(i, 2); x(i+1, 3) - x(i, 3)]);
                        for j = 1:radar_num
                            radar = radars(j, :);
                            radar_x = 100*radar(1);
                            radar_y = 100*radar(2);
                            radar_z = 10*obj.model.H(floor(radar_y/100), floor(radar_x/100));
                            radar_radius = radar(3)*500;
                            dist_radar = DistP3S([radar_x, radar_y, radar_z], [x(i, 1), x(i, 2), x(i, 3)], [x(i+1, 1), x(i+1, 2), x(i+1, 3)]);
                            if dist_radar > radar_radius || IsInShadow(obj.model.H, [x(i, 1)/100, x(i, 2)/100, x(i, 3)/10], [radar_x/100, radar_y/100, radar_z/10])
                                P_radar(j) = 0;
                            else
                                % RCS calculation
                                tan_ele = (x(i, 3)-radar_z)/((x(i, 1)-radar_x)^2 + (x(i, 2)-radar_y)^2);
                                sin_azi = sin(atan2(radar_y-x(i, 2),radar_x-x(i, 1)));
                                theta = acos(cos(atan2(radar_y-x(i, 2),radar_x-x(i, 1)))*cos(atan(tan_ele)));
                                phi = 0 - atan(tan_ele/sin_azi);
                                a = 0.3172;
                                b = 0.1784;
                                c = 1.003;
                                c1 = 1.01;
                                c2 = 1.25*10^(-18);
                                RCS = (pi*a^2*b^2*c^2)/((a^2*(sin(theta))^2*(cos(phi))^2 + b^2*(sin(theta))^2*(sin(phi))^2 + c^2*(cos(phi))^2)^2);
                                P_radar(j) = 1/(1+(c2*dist_radar^4/RCS)^c1);
                            end
                        end
                        P_total = 1 - prod(1-P_radar);
                        threatVal = threatVal + P_total * temp_length;
                    end
                    PopObj(popIdx, 1) = 0.01*LenCost + 0.0001*distVar + PopObj(popIdx, 1);
                    PopObj(popIdx, 2) = 0.05*threatVal + PopObj(popIdx, 2);
                end
            end
        end

        %% Calculate constraint violations
        function PopCon = CalCon(obj,PopDec)
            PopCon = zeros(size(PopDec, 1), 1);
            nUAV = obj.model.num;
            allPaths = zeros(nUAV, obj.model.n+2, 3);
            for popIdx = 1:size(PopDec, 1)
                allWaypoints = reshape(PopDec(popIdx, :), [], nUAV)';
                for n = 1:nUAV
                    waypoints = reshape(allWaypoints(n, :), [], 3);
                    waypoints = Spherical2Cart(waypoints, obj.model, n);
                    for i = 1:size(waypoints, 1)
                        waypoints(i, 3) = 10*waypoints(i, 3) + 10*obj.model.H(floor(waypoints(i, 2)), floor(waypoints(i, 1)));
                        waypoints(i, 1) = 100*waypoints(i, 1);
                        waypoints(i, 2) = 100*waypoints(i, 2);
                    end
                    starting = 100*obj.model.start(n, :);
                    ending = 100*obj.model.end(n, :);
                    starting(3) = starting(3) + obj.model.H(floor(starting(2)/100), floor(starting(1)/100));
                    ending(3) = ending(3) + obj.model.H(floor(ending(2)/100), floor(ending(1)/100));
                    x = [starting; waypoints; ending];
                    allPaths(n, :, :) = x;
                end
                
                for n = 1:nUAV
                    x = reshape(allPaths(n, :, :), [], 3);
                    % turning
                    C1 = 0;
                    for i = 2:size(x, 1)-1
                        thisPath = [x(i, 1)-x(i-1, 1); x(i, 2)-x(i-1, 2); x(i, 3)-x(i-1, 3)];
                        nextPath = [x(i+1, 1)-x(i, 1); x(i+1, 2)-x(i, 2); x(i+1, 3)-x(i, 3)];
                        turning = abs(atand(norm(cross(thisPath, nextPath))./(transpose(thisPath)*nextPath)));
                        if turning > 60
                            C1 = C1 + 1;
                        end
                    end

                    % climbing
                    C2 = 0;
                    lastDelta = 0;
                    for i = 1:size(x, 1)-1
                        delta = atand((x(i+1, 3)-x(i, 3))./norm([x(i+1, 1)-x(i, 1); x(i+1, 2)-x(i, 2); x(i+1, 3)-x(i, 3)]));
                        if i == 1
                            lastDelta = delta;
                        else
                            thisDelta = delta;
                            climbing = abs(thisDelta - lastDelta);
                            if  climbing > 60
                                C2 = C2 + 1;
                            end
                            lastDelta = thisDelta;
                        end
                    end

                    % height
                    zmin = obj.model.zmin;
                    C3 = 0;
                    C = 1;
                    for i=1:size(x, 1)-1
                        terrain_h = 10*obj.model.H(floor(x(i, 2)/100), floor(x(i, 1)/100));
                        deltaZ = x(i, 3) - terrain_h - zmin*10;                        
                        if deltaZ < 0
                            C3 = C3 + C;
                        end
                    end

                    % multi-agent collision avoidance
                    V = 20;
                    UAV_safe = 100;
                    C5 = 0;
                    t_min = 3;
                    xi = allPaths(n, :, 1);
                    yi = allPaths(n, :, 2);
                    zi = allPaths(n, :, 3);
                    lengthi = 0;
                    for m = n+1:nUAV
                        xj = allPaths(m, :, 1);
                        yj = allPaths(m, :, 2);
                        zj = allPaths(m, :, 3);
                        lengthj = 0;                        
                        for k = 1:obj.model.n
                            if k > 1
                                lengthi = lengthi + norm([xi(k)-xi(k-1);yi(k)-yi(k-1);zi(k)-zi(k-1)]);
                            end
                            tk = lengthi / V;
                            for l = 1:obj.model.n
                                if l > 1
                                    lengthj = lengthj + norm([xj(l)-xj(l-1);yj(l)-yj(l-1);zj(l)-zj(l-1)]);
                                end
                                tl = lengthj / V;
                                distance_ij = norm([xi(k)-xj(l);yi(k)-yj(l);zi(k)-zj(l)]);
                                if (distance_ij < UAV_safe) && (abs(tk-tl) < t_min)
                                    C5 = C5 + 1;
                                end
                            end
                            lengthj = 0;
                        end
                    end
                    PopCon(popIdx, 1) = C1 + C2 + C3 + C5 + PopCon(popIdx, 1);
                end
            end
        end
    end
end
