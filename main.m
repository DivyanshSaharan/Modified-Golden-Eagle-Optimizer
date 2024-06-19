% Initialize arrays to store results
meanX = zeros(1, 30);
meanFval = zeros(1, 30);
varFval = zeros(1, 30);
FunctionNumbers = (1:30)';

for FunctionNumber = 1:30
    fprintf('Function Number: %d\n', FunctionNumber);
    if FunctionNumber == 2
        fprintf('This function is Deleted\n');
        continue; % Assuming this is within a loop
    end

    % Set options and run Golden Eagle Optimizer
    options.PopulationSize = 60;
    options.MaxIterations = 1000;
    options.StoopingParameter = 0.5;

    [fun, nvars, lb, ub] = CEC2017("F"+FunctionNumber);
    options.AttackPropensity = [0.5, 3];
    options.CruisePropensity = [1, 0.5];
    
    % Initialize arrays to store results for each function
    xValues = zeros(50, nvars);
    fvalValues = zeros(1, 50);
    
    for iter = 1:50
        %[x, fval, ConvergenceCurve] = GEO(fun, nvars, lb, ub, options);
        [x, fval, ConvergenceCurve] = GEO_with_AdaptiveStepSizeVariability(fun, nvars, lb, ub, options);
        xValues(iter, :) = x;
        fvalValues(iter) = fval;
    end
    
    % Calculate mean of x and fval for each function
    % meanX(FunctionNumber) = mean(xValues, 1);
    meanFval(FunctionNumber) = mean(fvalValues);
    varFval(FunctionNumber) = var(fvalValues);
    
    % Plot results with unchanged convergence curve code
    % PlotResults(fun, lb, ub, FunctionNumber, ConvergenceCurve);
end

% Display the results in a table
% T = table(meanX', meanFval', 'VariableNames', {'MeanX', 'MeanFval'});
% T = table(meanFval', 'VariableNames', {'MeanFval'});
T = table(FunctionNumbers, meanFval', varFval', 'VariableNames', {'FunctionNumber', 'MeanFval', 'VarFval'});
disp(T);

% Plot table
figure;
uitable('Data', T{:,:}, 'ColumnName', T.Properties.VariableNames, 'RowName', [], 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);

% Set plot title and axis labels
title('Mean and Variance of fval Values for Each Function');
xlabel('Function Number');
ylabel('Mean fval');
