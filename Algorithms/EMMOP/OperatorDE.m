function Offspring = OperatorDE(Parent1,Parent2,Parent3,Parameter)
    %% Parameter setting
    if nargin > 3
        [CR,F,proM,disM] = deal(Parameter{:});
    else
        [CR,F,proM,disM] = deal(0.2,0.6,1,20);
    end
    if isa(Parent1(1),'INDIVIDUAL')
        calObj  = true;
        Parent1 = Parent1.decs;
        Parent2 = Parent2.decs;
        Parent3 = Parent3.decs;
    else
        calObj = false;
    end
    [N,D] = size(Parent3);
    Global = GLOBAL.GetObj();

    %% Differental evolution
    Site = rand(N,D) < CR;
    
    if size(Parent1, 1) == 1
        s = randperm(N,1);
        Offspring = Parent3(randperm(N), :);
        Offspring(s) = Offspring(s) + F*(Parent2(s)-Parent3(s));
    else
        Offspring       = Parent1;
        Offspring(Site) = Offspring(Site) + F*(Parent2(Site)-Parent3(Site));
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