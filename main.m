function [HV_, PD_, HV_std, PD_std, GlobalBest, runtime_sum, res_S, success_rate, HV_all, PD_all] = main(varargin)
%main - The interface of PlatEMO.
%
%   main() displays the GUI of PlatEMO.
%
%   main('-Name',Value,'-Name',Value,...) runs one algorithm on a problem
%   with the specified parameter setting.
%
% All the acceptable properties:
%   '-N'            <positive integer>  population size
%   '-M'            <positive integer>  number of objectives
%   '-D'            <positive integer>  number of variables
%	'-algorithm'    <function handle>   algorithm function
%	'-problem'      <function handle>   problem function
%	'-evaluation'   <positive integer>  maximum number of evaluations
%   '-run'          <positive integer>  run number
%   '-save'         <integer>           number of saved populations
%   '-outputFcn'	<function handle>   function invoked after each generation
%
%   Example:
%       main()
%
%   displays the GUI of PlatEMO.
%
%       main('-algorithm',@ARMOEA,'-problem',@DTLZ2,'-N',200,'-M',10)
%
%   runs AR-MOEA on 10-objective DTLZ2 with a population size of 200.
%
%       main('-algorithm',{@KnEA,0.4},'-problem',{@WFG4,6})
%
%   runs KnEA on WFG4, and sets the parameters in KnEA and WFG4.
%
%       for i = 1 : 10
%           main('-algorithm',@RVEA,'-problem',@LSMOP1,'-run',i,'-save',5)
%       end
%
%   runs RVEA on LSMOP1 for 10 times, and each time saves 5 populations to
%   a file in PlatEMO/Data/RVEA.

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    cd(fileparts(mfilename('fullpath')));
    addpath(genpath(cd));
    if isempty(varargin)
        if verLessThan('matlab','8.4')
            errordlg('Fail to establish the GUI of PlatEMO, since the version of MATLAB is lower than 8.4 (R2014b). You can run PlatEMO without GUI by invoking main() with parameters.','Error','modal');
        else
            GUI();
        end
    else
        if verLessThan('matlab','7.14')
            error('Fail to execute PlatEMO, since the version of MATLAB is lower than 7.14 (R2012a). Please update the version of your MATLAB software.');
        else
            Global = GLOBAL(varargin{:});
            res_HV = [];
            res_PD = [];
            res_S = [];
            Globals = [];
            HV_all = [];
            PD_all = [];
            failed_times = 0;
            for i = 1:Global.run
                Global.Start();
                % Feasible = find(all(Global.result{end}.cons <= 0, 2));
                % NonDominated = NDSort(Global.result{end}(Feasible).objs, 1) == 1;
                % Population = Global.result{end}(Feasible(NonDominated)); 
                % pop = Global.result{end}(Feasible);
                % objVal = pop.objs - min(pop.objs);
                % PFVal = Population.objs - min(Population.objs);
                % objVal = pop.objs;
                % HVval = HV(objVal, PFVal);
                % Reference = max(Global.result{end}.objs, [], 1);
                % HVval = HV(PFVal, objVal);
                % PDVal = PD(objVal);

                % HV/PD final result: res.shape = (runtime, samples)
                res_HV = [res_HV; Global.HV];
                res_PD = [res_PD; Global.PD];
                % S index
                Population = Global.result{end};
                Objs = Population.objs;
                DistMat = pdist2(Objs, Objs);
                DistMat(DistMat == 0) = inf;
                res_S = [res_S; std(min(DistMat, [], 2))];  % scalar
                Feasible = find(all(Global.result{end}.cons <= 0, 2), 1);
                if isempty(Feasible)
                    failed_times = failed_times + 1;
                end
                Globals = [Globals Global];
                hold off
                Global = GLOBAL(varargin{:});
            end
            % return value: shape == (, opt_iter)
          %  res_HV(:, 1) = 0;
            HV_all = res_HV;
            PD_all = res_PD;
            HV_ = mean(res_HV, 1);
            PD_ = mean(res_PD, 1);
            HV_std = std(res_HV, 0, 1);
            PD_std = std(res_PD, 0, 1);
            [~, idx] = max(res_HV(:, end));
            GlobalBest = Globals(idx);
            runtime_sum = sum([Globals.runtime]);
            success_rate = 1 - failed_times / Global.run;

            % HV_mean = mean(res_HV);
            % HV_std = std(res_HV);
            % PD_mean = mean(res_PD);
            % PD_std = std(res_PD);
            % disp(['Average HV: ', num2str(HV_mean)]);
            % disp(['Std HV: ', num2str(HV_std)]);
            % disp(['Average PD: ', num2str(PD_mean)]);
            % disp(['Std PD: ', num2str(PD_std)]);
        end
    end
end