function state = stateCal(Population, Fitness)
    % Calculate state for population
    % state = [fmax fmin favg fmed CVmean yta].T
    state = zeros(8, 1);
    objVal = Population.objs;
    consVal = Population.cons;
    decsVal = Population.decs;
    consVal(consVal < 0) = 0;
    N = length(Population);
    if Fitness ~= 0
        Off_Fitness = CalFitness(Population.objs, Population.cons);
        Off_Fitness = (Off_Fitness - min(Fitness)) ./ (max(Fitness) - min(Fitness));
        Fitness = (Fitness - min(Fitness)) ./ (max(Fitness) - min(Fitness));
        delta_fitness = min(Fitness) - min(Off_Fitness);
        if delta_fitness <= 0
            stag = 1;
        else
            stag = 0;
        end
    else
        delta_fitness = 1e-3;
        stag = 0;
    end
    
    % normalization
    objVal = (objVal - mean(objVal)) ./ std(objVal);
    if sum(consVal == 0) == N
        consVal = zeros(size(Population));
    else
        consVal = (consVal - mean(consVal)) ./ std(consVal);
    end
    Zref = min(objVal);

    state(1:2) = max(objVal, [], 1)';
    state(3:4) = min(objVal, [], 1)';
    state(5:6) = mean(objVal)';
    state(7) = mean(consVal);
    state(8) = sum(consVal == 0) / N;
    % std of individuals
    DistMat = pdist2(objVal, objVal);
    DistMat(logical(eye(length(DistMat)))) = inf;
    DistMat = sort(DistMat, 2);
    MinDist = DistMat(:, 1);
    AvgDist = mean(MinDist);
    SP = sqrt(sum(MinDist - AvgDist).^2 / (length(MinDist) - 1));
    state(9) = SP;
    % average Euclidean distance between all individuals
    DistDec = 0;
    for i = 1:N-1
        for j = i+1:N
            DistDec = DistDec + norm(decsVal(i, :) - decsVal(j, :));
        end
    end
    DistDec = DistDec / (N * (N-1) / 2);
    state(10) = DistDec;
end