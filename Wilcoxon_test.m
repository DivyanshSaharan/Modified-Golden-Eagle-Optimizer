options.PopulationSize = 60;
options.MaxIterations = 1000;
options.AttackPropensity = [0.5, 3];
options.CruisePropensity = [1, 0.5];

alpha = 0.05; % Significance level

wilcoxon_results = zeros(30, 3); % Initialize array to store results

for FunctionNumber = 1:30
    % Get function details
    if FunctionNumber == 2
        fprintf('This function is Deleted\n');
       continue; % Assuming this is within a loop
    end
    [fun, nvars, lb, ub] = CEC2017("F"+FunctionNumber);
    options.LowerBound = lb;
    options.UpperBound = ub;
    
    % Run both algorithms and collect objective function values
    [~, ~, ConvergenceCurve1] = GEO(fun, nvars, lb, ub, options);
    [~, ~, ConvergenceCurve2] = GEO_with_AdaptiveStepSizeVariability(fun, nvars, lb, ub, options);
    
    % Collect the objective function values from both algorithms
    objective_values1 = ConvergenceCurve1;
    objective_values2 = ConvergenceCurve2;

    % Perform Wilcoxon signed-rank test
    [p_value, ~, stats] = ranksum(objective_values1, objective_values2);

    % Store results
    wilcoxon_results(FunctionNumber, :) = [FunctionNumber, p_value, stats.zval];

    % Display the p-value and Z-value
    fprintf('Function %d - P-value from Wilcoxon signed-rank test: %f\n', FunctionNumber, p_value);
    fprintf('Function %d - Z-value from Wilcoxon signed-rank test: %f\n', FunctionNumber, stats.zval);

    % Check if the test is significant
    if p_value < alpha
        fprintf('There is a significant difference between the algorithms for Function %d.\n', FunctionNumber);
    else
        fprintf('There is no significant difference between the algorithms for Function %d.\n', FunctionNumber);
    end
end

% Display Wilcoxon results in a table
wilcoxon_table = array2table(wilcoxon_results, 'VariableNames', {'FunctionNumber', 'PValue', 'ZValue'});
disp(wilcoxon_table);

% Plot table
figure;
uitable('Data', wilcoxon_table{:,:}, 'ColumnName', wilcoxon_table.Properties.VariableNames, 'RowName', [], 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);

% Set plot title and axis labels
title('Wilcoxon Results for Each Function');
xlabel('Function Number');
ylabel('P-value / Z-value');
