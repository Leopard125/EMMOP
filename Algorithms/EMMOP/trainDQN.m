function [model, loss] = trainDQN(ERB, batch_size, maxEpoch, model, gamma, r_real_cur, lr, t, maxIter, target_model)
    % training iterations
    sampleIdx = randperm(size(ERB, 1));
    dataset = ERB(sampleIdx(1:batch_size), :);
    train_state = cell2mat(dataset(:, 1)'); % 6 by b
    train_action = cell2mat(dataset(:, 2)');% 4 by b
    r_real = cell2mat(dataset(:, 3)');      % 4 by b
    train_next_state = cell2mat(dataset(:, 4)');    % 6 by b
    for epoch = 1:maxEpoch
        % Input: state1/next_state1 6 by b, Output: reward 4 by b, b is sample size
        [r_pred, model] = forward(train_state, model);    % output predicted reward in 4 by b
        r_pred = sum(r_pred .* train_action, 1);
        if t == maxIter
            error = r_real + gamma * max(r_real_cur, [], 1) - r_pred;
        else
            [r_pred_next_best, ~] = max(forward(train_next_state, target_model), [], 1);    % 1 by b
            error = r_real + gamma * r_pred_next_best - r_pred;
        end
        [model.W, model.B] = backprop(model, lr, error, batch_size, train_action);
    end
    loss = sum(error.^2) ./ batch_size;
end