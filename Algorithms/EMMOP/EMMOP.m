function EMMOP(Global)
    %% Population Init
    Population1 = Global.Initialization();
    Zmin1       = min(Population1.objs,[],1);

    Population2 = Global.Initialization();
    Zmin2       = min(Population2.objs,[],1);

    [Population1_temp,Fitness1] = Rank(Population1, true);
    [Population2_temp,Fitness2] = Rank(Population2, true);
    Global.evaluated = Global.evaluated - 2*Global.N;

    % MFF init
    m = round(Global.N / 3);
    lastBestPop1 = Population1_temp(1:m);
    lastBestPop2 = Population2_temp(1:m);

    cons = [Population1.cons;Population2.cons];
    cons(cons<0) = 0;
    VAR0 = max(sum(cons,2));
    if VAR0 == 0
        VAR0 = 1;
    end
    X=0;
    HVlist = [];
    PDlist = [];
    iter = 0;

    lastPhi1 = sum(cons);
    NDIdx1 = NDSort(Population1.objs, 1) == 1;
    lastHV1 = HV(Population1.objs - min(Population1.objs), Population1(NDIdx1).objs - min(Population1(NDIdx1).objs));
    lastObjs1 = Population1.objs;
    lastPhi2 = sum(cons);
    NDIdx2 = NDSort(Population2.objs, 1) == 1;
    lastHV2 = HV(Population2.objs - min(Population2.objs), Population2(NDIdx2).objs - min(Population2(NDIdx2).objs));
    lastObjs2 = Population2.objs;
    r1 = 1.5; r2 = 0.1; r3 = 0.05; r4 = -0.35;

    %% DQN init
    maxIter = Global.evaluation / Global.N;

    % Experience Replay Buffer init
    % ERB{1} = state
    % ERB{2} = action
    % ERB{3} = reward
    % ERB{4} = next state
    ERB1 = {};
    ERB2 = {};

    % score is the sum of reward
    score1 = zeros(1, maxIter);
    score2 = zeros(1, maxIter);
    HV_list_1 = zeros(1, maxIter);
    HV_list_2 = zeros(1, maxIter);
    PD_list_1 = zeros(1, maxIter);
    PD_list_2 = zeros(1, maxIter);

    % action is a bool list determining crossover algorithm to use
    % action(1) = DE_rand_1
    % action(2) = GA
    % action(3) = CSO
    % action(4) = DE_rand_2
    % action(5) = DE_rand_gen_1
    action1 = [1 0 0 0 0]';
    action2 = [1 0 0 0 0]';
    state1 = stateCal(Population1, 0);
    state2 = stateCal(Population2, 0);
    % 48 - 54 - 54 - 48 - 5
    W{1} = randn(48, length(state1));    % 1st hidder layer
    W{2} = randn(54, 48);   % 2nd
    W{3} = randn(54, 54);
    W{4} = randn(48, 54);
    W{5} = randn(length(action1), 48);    % Output layer
    B{1} = randn(48, 1);
    B{2} = randn(54, 1);
    B{3} = randn(54, 1);
    B{4} = randn(48, 1);
    B{5} = randn(length(action2), 1);
    gamma = 0.9;
    lr = 0.001;
    t = 0;
    lambda = 0.4 * maxIter / 2;
    startIter = 0.2 * maxIter / 2;
    maxEpoch = 10;
    b = 128;      % batch amount
    model1.W = W;
    model1.a = {};
    model1.B = B;
    model2.W = W;
    model2.a = {};
    model2.B = B;
    target_model1 = model1;
    target_model2 = model2;
    target_update_rate = 8;
    loss_list_1 = zeros(1, maxIter - startIter);
    loss_list_2 = zeros(1, maxIter - startIter);
    hold off;

    %% Optimization
    while Global.NotTermination(Population1)
        %% Update the epsilon value
        cp=(-log(VAR0)-6)/log(1-0.5);
        VAR = VAR0*(1-X)^cp;

        %% Action Selection & Offspring generation
        t = t + 1;
            action1 = [0 0 0 0 0]';
            action2 = [0 0 0 0 0]';
        if t <= lambda
            % random selection
            action1(randi([1, 5])) = 1;
            action2(randi([1, 5])) = 1;
        else
            % DQN-selection-epsilon-greedy
            [~, actionIdx] = max(forward(state1, model1));
            if rand() < 0.8
                action1(actionIdx) = 1;
            else
                action1(randi([1, length(action1)])) = 1;
            end
            [~, actionIdx] = max(forward(state2, model2));
            if rand() < 0.8
                action2(actionIdx) = 1;
            else
                action2(randi([1, length(action2)])) = 1;
            end
        end

        % generate offspring according to actions selected
        gen = Global.evaluated / Global.N;
        max_gen = Global.evaluation / Global.N;
        Offspring1 = ActionSelection(Population1, action1, Fitness1, Global.N, gen, max_gen);
        Offspring2 = ActionSelection(Population2, action2, Fitness2, Global.N, gen, max_gen);

        %% reward update
        % Main group
        % reward for objectives
        thisObjs1 = Population1.objs;
        d = mean(thisObjs1) - mean(lastObjs1);
        if d(1) * d(2) > 0 && d(1) + d(2) < 0
            r_obj1 = r1;
        elseif d(1) * d(2) < 0 && d(1) + d(2) < 0
            r_obj1 = r2;
        elseif d(1) * d(2) < 0 && d(1) + d(2) > 0
            r_obj1 = r3;
        else
            r_obj1 = r4;
        end
        % proportion of improving individuals "ksi"
        ksi1 = mean(sum(thisObjs1 > lastObjs1)) / size(thisObjs1, 1);
        % constraint violation
        CV1 = Population1.cons;
        thisPhi1 = sum(CV1);
        yta1 = sum(CV1 == 0) / length(CV1);
        % HV index
        NDIdx1 = NDSort(Population1.objs, 1) == 1;
        thisHV1 = HV(Population1.objs - min(Population1.objs), Population1(NDIdx1).objs - min(Population1(NDIdx1).objs));
        % thisHV1 = HV(Population1(NDIdx1).objs, Population1.objs);
        if isnan(thisHV1)
            thisHV1 = lastHV1;
        end
        r_real_cur1 = (1 - yta1) * (lastPhi1 - thisPhi1) / (lastPhi1 + 1) + yta1 * (ksi1 * (thisHV1 - lastHV1) / thisHV1 + (1 - ksi1) * r_obj1);
        lastPhi1 = thisPhi1;
        lastHV1 = thisHV1;
        lastObjs1 = thisObjs1;

        %% Aux group
        % reward for objectives
        thisObjs2 = Population2.objs;
        d = mean(thisObjs2) - mean(lastObjs2);
        if d(1) * d(2) > 0 && d(1) + d(2) < 0
            r_obj2 = r1;
        elseif d(1) * d(2) < 0 && d(1) + d(2) < 0
            r_obj2 = r2;
        elseif d(1) * d(2) < 0 && d(1) + d(2) > 0
            r_obj2 = r3;
        else
            r_obj2 = r4;
        end
        % proportion of improving individuals "ksi"
        ksi2 = mean(sum(thisObjs2 > lastObjs2)) / size(thisObjs2, 1);
        % constraint violation
        CV2 = Population2.cons;
        thisPhi2 = sum(CV2);
        yta2 = sum(CV2 == 0) / length(CV2);
        % HV index
        NDIdx2 = NDSort(Population2.objs, 1) == 1;
        thisHV2 = HV(Population2.objs - min(Population2.objs), Population2(NDIdx2).objs - min(Population2(NDIdx2).objs));
        % thisHV2 = HV(Population2(NDIdx2).objs, Population2.objs);
        if isnan(thisHV2)
            thisHV2 = lastHV2;
        end
        r_real_cur2 = (1 - yta2) * (lastPhi2 - thisPhi2) / (lastPhi2 + 1) + yta2 * (ksi2 * (thisHV2 - lastHV2) / thisHV2 + (1 - ksi2) * r_obj2);
        lastPhi2 = thisPhi2;
        lastHV2 = thisHV2;
        lastObjs2 = thisObjs2;

        % save HV in optimization
        HV_list_1(1, t) = thisHV1;
        HV_list_2(1, t) = thisHV2;
        PD_list_1(1, t) = PD(Population1.objs - min(Population1.objs));
        PD_list_2(1, t) = PD(Population2.objs - min(Population2.objs));

        %% next state calculation
        next_state1 = stateCal(Offspring1, Fitness1);
        next_state2 = stateCal(Offspring2, Fitness2);

        %% ERB storage
        idx = t;
        ERB1{idx, 1} = state1;  % 6 by 1
        ERB1{idx, 2} = action1; % 4 by 1 0-1
        ERB1{idx, 3} = r_real_cur1; % 1 by 1 R
        ERB1{idx, 4} = next_state1; % 6 by 1
        ERB2{idx, 1} = state2;  % 6 by 1
        ERB2{idx, 2} = action2; % 4 by 1 0-1
        ERB2{idx, 3} = r_real_cur2; % 1 by 1 R
        ERB2{idx, 4} = next_state2; % 6 by 1
        if idx == 1
            score1(idx) = r_real_cur1;
            score2(idx) = r_real_cur2;
            if isnan(score1(idx))
                score1(idx) = 0;
            end
            if isnan(score2(idx))
                score2(idx) = 0;
            end
        else
            score1(idx) = score1(idx-1) + r_real_cur1;
            score2(idx) = score2(idx-1) + r_real_cur2;
        end

        %% DQN training
        if t > startIter   
            % train task1 DQN
            [model1, loss1] = trainDQN(ERB1, b, maxEpoch, model1, gamma, r_real_cur1, lr, t, maxIter, target_model1);
            % train task2 DQN
            [model2, loss2] = trainDQN(ERB2, b, maxEpoch, model2, gamma, r_real_cur2, lr, t, maxIter, target_model2);

            % save losses
            loss_list_1(1, t - startIter) = loss1;
            loss_list_2(1, t - startIter) = loss2;

            % target model update
            if mod(t, target_update_rate) == 0
                target_model1 = model1;
                target_model2 = model2;
            end
        end

        Zmin1       = min([Zmin1;Offspring1.objs],[],1);
        Zmin2       = min([Zmin2;Offspring2.objs],[],1);

        %% Environmental selection
        [Population1_temp,Fitness1] = Rank([Population1,Offspring1], true);
        [Population2_temp,Fitness2] = Rank([Population2,Offspring2], true);

        % MFF fusion
        trans12 = [];
        trans21 = [];
        for i = 1:m
            F = [Population1_temp(i).decs - lastBestPop1(i).decs; Population2_temp(i).decs - lastBestPop2(i).decs];
            C = 1 ./ size(F, 2) .* (F * F');
            [P, ~] = eig(C);
            M = P(:, 1);
            trans12 = [trans12 INDIVIDUAL(F(1, :) .* M(1))];
            trans21 = [trans21 INDIVIDUAL(F(2, :) .* M(2))];
            Global.evaluated = Global.evaluated - 2;
        end

        lastBestPop1 = Population1_temp(1:m);
        lastBestPop2 = Population2_temp(1:m);

        [Population1,Fitness1] = Main_task_EnvironmentalSelection([Population1,Offspring1, trans21], Global.N, true);
        [Population2,Fitness2] = Auxiliray_task_EnvironmentalSelection([Population2,Offspring2, trans12], Global.N, VAR);

        X=X+1/(Global.evaluation/Global.N);
        state1 = next_state1;
        state2 = next_state2;

        % HV & PD statistics
        Feasible = find(all(Population1.cons<=0,2));
        NonDominated = NDSort(Population1(Feasible).objs,1) == 1;
        pop = Population1(Feasible(NonDominated));
        if mod(Global.gen, 1) == 0
            PDval = PD(Population1.objs-min(Population1.objs));
            if isempty(pop)
                if isempty(HVlist)
                    HVlist = [HVlist 0];
                else
                    HVlist = [HVlist HVlist(end)];
                end
            else
                HVval = HV(Population1.objs-min(Population1.objs), pop.objs-min(pop.objs));
                if isnan(HVval)
                    if isempty(HVlist)
                        HVlist = [HVlist 0];
                    else
                        HVlist = [HVlist HVlist(end)];
                    end
                else
                    HVlist = [HVlist HVval];
                end
            end
            PDlist = [PDlist PDval];
            Global.LoadData(HVlist, PDlist);
        end
        iter = iter + 1;
    end
end