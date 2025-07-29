function [Population, Fitness] = Rank(Population, isOrigin)
    %% Calculate the fitness of each solution
    if isOrigin 
        Fitness = CalFitness(Population.objs,Population.cons);
    else
        Fitness = CalFitness(Population.objs);
    end

    [~,rank] = sort(Fitness);
    Population = Population(rank);
end