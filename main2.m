FunctionNumber = 4; % 1-23

options.PopulationSize = 50;
options.MaxIterations = 1000;

%% Run Multi-Objective Golden Eagle Optimizer 
%funccall='F'+FunctionNumber;
[nDim, LB, UB, Vio, GloMin, Obj] = ProbInfo(FunctionNumber)
%[fun, nvars, lb, ub] = Func_eng('ThreeBarTruss');
%[fun, nvars, lb, ub] = GetFunctionDetails(FunctionNumber);
options.AttackPropensity = [0.5, 2];
options.CruisePropensity = [1, 0.5];

options.LowerBound = LB;  % Add this line to specify lower bound
options.UpperBound = UB;  % Add this line to specify upper bound

%[x, fval, ConvergenceCurve] = GEO(fun, nvars, lb, ub, options);
[x, fval, ConvergenceCurve] = GEO_with_AdaptiveStepSizeVariability(fun, nvars, lb, ub, options);
%% Plot results 

PlotResults(fun, LB, UB, FunctionNumber, ConvergenceCurve)
