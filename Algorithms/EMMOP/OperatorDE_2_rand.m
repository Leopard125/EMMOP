function Offspring = OperatorDE_2_rand(Parent1,Parent2,Parent3,Parent4)
    %% Parameter setting
    [CR,F,K,proM,disM] = deal(0.2,0.8,0.5,1,20);
    if isa(Parent1(1),'INDIVIDUAL')
        calObj  = true;
        Parent1 = Parent1.decs;
        Parent2 = Parent2.decs;
        Parent3 = Parent3.decs;
        Parent4 = Parent4.decs;
    else
        calObj = false;
    end
    [N,D]  = size(Parent1);
    Global = GLOBAL.GetObj();

    %% Differental evolution
    % Parent4 for individual in K
    Site = rand(N,D) < CR;
    Offspring       = Parent1;
    if size(Parent4, 1) == 1
        % best individual
        temp_par4 = repmat(Parent4, N, 1);
        if size(Parent3, 1) == 1
            temp_par3 = repmat(Parent3, N, 1);
            Offspring(Site) = Offspring(Site) + F*(Parent2(Site)-temp_par3(Site)) + K*(temp_par4(Site)-Offspring(Site));
        else
            a = F*(Parent2(Site)-Parent3(Site)) + K*(temp_par4(Site)-Offspring(Site));
            Offspring(Site) = Offspring(Site) + a;
        end
    else
        % random individual
        Parent2_temp = repmat(mean(Parent2), N, 1);
        RandOffspring = Parent1(randperm(N), :);
        Offspring(Site) = RandOffspring(Site) + F*(Parent4(Site)-Parent3(Site)) + K*(Parent2_temp(Site)-Offspring(Site));
    end

    %% Polynomial mutation
    Lower = repmat(Global.lower,N,1);
    Upper = repmat(Global.upper,N,1);
    Site  = rand(N,D) < proM/D;
    mu    = rand(N,D);
    temp  = Site & mu<=0.5;
    Offspring       = min(max(Offspring,Lower),Upper);
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                        (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
    temp = Site & mu>0.5; 
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                        (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
    if calObj
        Offspring = INDIVIDUAL(Offspring);
    end
end