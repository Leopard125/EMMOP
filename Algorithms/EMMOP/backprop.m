function [W, B] = backprop(model, lr, error, b, action)
    % back propagation using GD
    % L = (Q_target - Q_pred).^2 in RL settings so W = W + dL/dW
    W = model.W;    % 32 by 6; 64 by 32; 64 by 64; 32 by 64; 3 by 32
    a = model.a;
    B = model.B;
    W1 = cell2mat(W(1));
    W2 = cell2mat(W(2));
    W3 = cell2mat(W(3));
    W4 = cell2mat(W(4));
    W5 = cell2mat(W(5));
    B5 = cell2mat(B(5));
    B4 = cell2mat(B(4));
    B3 = cell2mat(B(3));
    B2 = cell2mat(B(2));
    B1 = cell2mat(B(1));
    a1 = cell2mat(a(1));
    a2 = cell2mat(a(2));
    a3 = cell2mat(a(3));
    a4 = cell2mat(a(4));

    dZ5 = action.*error;  % 3 by b
    dW5 = 1/b * dZ5 * a4';  % 3 by b * b by 32
    db5 = 1/b * sum(dZ5, 2);
    dZ4 = W5' * dZ5 .* (1 - a4).*(a4);
    dW4 = 1/b * dZ4 * a3';
    db4 = 1/b * sum(dZ4, 2);
    dZ3 = W4' * dZ4 .* (1 - a3).*(a3);
    dW3 = 1/b * dZ3 * a2';
    db3 = 1/b * sum(dZ3, 2);
    dZ2 = W3' * dZ3 .* (1 - a2).*(a2);
    dW2 = 1/b * dZ2 * a1';
    db2 = 1/b * sum(dZ2, 2);
    dZ1 = W2' * dZ2 .* (1 - a1).*(a1);
    dW1 = 1/b * dZ1 * (model.x)';
    db1 = 1/b * sum(dZ1, 2);

    W5 = W5 + lr * dW5;
    B5 = B5 + lr * db5;
    W4 = W4 + lr * dW4;
    B4 = B4 + lr * db4;
    W3 = W3 + lr * dW3;
    B3 = B3 + lr * db3;
    W2 = W2 + lr * dW2;
    B2 = B2 + lr * db2;
    W1 = W1 + lr * dW1;
    B1 = B1 + lr * db1;
    W = {W1, W2, W3, W4, W5};
    B = {B1, B2, B3, B4, B5};
end