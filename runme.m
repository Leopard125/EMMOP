% '-algorithm': Evolutionary Algorithm name in folder 'Algorithm'.

% '-problem': 'myemo' 

% '-evaluation': evaluation times
clear all
close all
clc
evaluation = 120000;
rng(42);    % set up seed

% '-N': number of population
N = 60;
res_HV = [];
res_PD = [];
algs = {@EMMOP};
legends = cellfun(@func2str, algs, 'UniformOutput', false);

final_HV = [];
final_PD = [];
final_S = [];
time_cost = [];
GlobalBests = [];
i = 0;
HV_std_list = [];
PD_std_list = [];
success_rate_list = [];
HV_all = [];
PD_all = [];

for alg = algs
    % final_HV/final_PD: mean of HV/PD at all sampled steps
    % HV_all/PD_all: all sampled values
    i = i + 1;
    HV_list = [];
    PD_list = [];
    [res_HV, res_PD, HV_std, PD_std, GlobalBest, runtime_sum, res_S, success_rate, HV_list, PD_list] = main('-algorithm', alg, '-problem', @myemo, '-evaluation', evaluation, '-N', N, '-run', 1);
    final_HV = [final_HV; res_HV];
    final_PD = [final_PD; res_PD];
    final_S = [final_S; res_S];
    GlobalBests = [GlobalBests GlobalBest];
    time_cost = [time_cost; runtime_sum];
    HV_std_list = [HV_std_list; HV_std];
    PD_std_list = [PD_std_list; PD_std];
    success_rate_list = [success_rate_list; success_rate];
    HV_all(i, :, :) = HV_list;
    PD_all(i, :, :) = PD_list;
end

% last sample time summary
mean_HV = final_HV(:, end);
std_HV = HV_std_list(:, end);
mean_PD = final_PD(:, end);
std_PD = PD_std_list(:, end);

% HV_end.shape = (algs, running_times)
HV_end = reshape(HV_all(:, :, end), [size(HV_all, 1) size(HV_all, 2)]);
PD_end = reshape(PD_all(:, :, end), [size(PD_all, 1) size(PD_all, 2)]);
best_HV = max(HV_end, [], 2);
best_PD = max(PD_end, [], 2);

% output final result
for i = 1:length(mean_HV)
    disp(legends{i});
    disp("Best HV:");
    disp(best_HV(i));
    disp("Best PD:");
    disp(best_PD(i));
    disp("Mean HV:");
    disp(mean_HV(i));
    disp("Mean PD:");
    disp(mean_PD(i));
    disp("Std HV:");
    disp(std_HV(i));
    disp("Std PD:");
    disp(std_PD(i));
    disp("Success rate:");
    disp(success_rate_list(i));
    disp("Run time:");
    disp(time_cost(i));
end

% display best results on HV
for i = 1:length(GlobalBests)
    Global = GlobalBests(i);
    Feasible = find(all(Global.result{end}.cons <= 0, 2));
    NonDominated = NDSort(Global.result{end}(Feasible).objs, 1) == 1;
    % PF
    Population = Global.result{end}(Feasible(NonDominated));
    % flight path
    PlotSolution_end(Population, legends{i});
    hold off
end

figure;
for i = 1:length(GlobalBests)
    Global = GlobalBests(i);
    Feasible = find(all(Global.result{end}.cons <= 0, 2));
    NonDominated = NDSort(Global.result{end}(Feasible).objs, 1) == 1;
    % PF
    Population = Global.result{end}(Feasible(NonDominated));
    % Pareto front pic
    myDraw(Population.objs);
    hold on
end

title("Pareto Front");
legend(legends, 'Location', 'northeast');

% output final result
disp("HV")
for i=1:size(final_HV, 1)
    disp(legends(i));
    disp(final_HV(i, end));
end

disp("PD")
for i=1:size(final_PD, 1)
    disp(legends(i));
    disp(final_PD(i, end));
end
