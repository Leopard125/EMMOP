function Offspring = ActionSelection(Population, action, Fitness, N, gen, max_gen)
    if action(1) == 1
        % DE_rand_1
        randIdx1 = randperm(N);
        randIdx2 = randperm(N);
        Offspring = OperatorDE(Population, Population(randIdx1), Population(randIdx2));
    elseif action(2) == 1
        % GA
        MatingPool1 = TournamentSelection(2, N, Fitness);
        Offspring = GA(Population(MatingPool1));
    elseif action(3) == 1
        % CSO
        Rank = randperm(length(Population),floor(length(Population)/2)*2);
        Loser  = Rank(1:end/2);
        Winner = Rank(end/2+1:end);
        Change = Fitness(Loser) <= Fitness(Winner);
        Temp = Winner(Change);
        Winner(Change) = Loser(Change);
        Loser(Change)  = Temp;
        Offspring = CompetitiveOperator(Population(Loser),Population(Winner),10);
    elseif action(4) == 1
        % DE_rand_2, using centroid
        randIdx1 = randperm(N);
        randIdx2 = randperm(N);
        randIdx3 = randperm(N);
        Offspring = OperatorDE_2(Population, Population(randIdx1), Population(randIdx2), Population(randIdx3));
    elseif action(5) == 1
        % DE_rand_gen_1
        randIdx1 = randperm(N);
        randIdx2 = randperm(N);
        Offspring = OperatorDE_gen(Population, Population(randIdx1), Population(randIdx2), gen, max_gen);

        % DE_rand_2, using random parent 1
        % randIdx1 = randperm(N);
        % randIdx2 = randperm(N);
        % randIdx3 = randperm(N);
        % Offspring = OperatorDE_2_rand(Population, Population(randIdx1), Population(randIdx2), Population(randIdx3));
    end
end