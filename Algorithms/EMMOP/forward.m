function [r_pred, model] = forward(x, model)
    % forward propagation
    % input: x, W; x.shape = (6, b)
    % output: r_pred; r_pred.shape = (3, b)
    W = model.W;
    b = model.B;
    W1 = cell2mat(W(1));
    W2 = cell2mat(W(2));
    W3 = cell2mat(W(3));
    W4 = cell2mat(W(4));
    W5 = cell2mat(W(5));
    b1 = cell2mat(b(1));
    b2 = cell2mat(b(2));
    b3 = cell2mat(b(3));
    b4 = cell2mat(b(4));
    b5 = cell2mat(b(5));

    y1 = W1 * x + b1;
    a1 = sigmoid(y1);
    y2 = W2 * a1 + b2;
    a2 = sigmoid(y2);
    y3 = W3 * a2 + b3;
    a3 = sigmoid(y3);
    y4 = W4 * a3 + b4;
    a4 = sigmoid(y4);
    y5 = W5 * a4 + b5;
    r_pred = y5;     % linear output

    % save intermediate variables
    model.x = x;
    a{1} = a1;
    a{2} = a2;
    a{3} = a3;
    a{4} = a4;
    model.a = a;
end

function a = sigmoid(y)
    a = 1 ./ (1 + exp(-y));
end