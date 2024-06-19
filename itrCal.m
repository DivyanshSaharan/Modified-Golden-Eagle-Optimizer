meanX = zeros(1, 30);
meanFval = zeros(1, 30);
varFval = zeros(1, 30);
FunctionNumbers = (1:30)';

% Create a cell array to store fval values for each function
fvalCell = cell(30, 52); % 30 functions, 50 iterations + 1 for mean, 1 for variance

for FunctionNumber = 1:30
    fprintf('Function Number: %d\n', FunctionNumber);
    %if FunctionNumber == 2
    %    fprintf('This function is Deleted\n');
    %    continue; % Assuming this is within a loop
    %end

    % Set options and run Golden Eagle Optimizer
    options.PopulationSize = 60;
    options.MaxIterations = 1000;
    options.StoopingParameter = 0.5;

    [fun, nvars, lb, ub] = CEC2014("F"+FunctionNumber);
    options.AttackPropensity = [0.5, 3];
    options.CruisePropensity = [1, 0.5];
    
    % Initialize arrays to store results for each function
    xValues = zeros(50, nvars);
    fvalValues = zeros(50, 1);
    
    for iter = 1:50
        % Assuming the function call and result retrieval here
        [x, fval, ConvergenceCurve] = GEO_with_AdaptiveStepSizeVariability(fun, nvars, lb, ub, options);
        %[x, fval, ConvergenceCurve] = GEO(fun, nvars, lb, ub, options);
        xValues(iter, :) = x;
        fvalValues(iter) = fval;
    end
    
    % Store fval values for this function
    fvalCell{FunctionNumber, 1} = FunctionNumber;
    for i = 1:50
        fvalCell{FunctionNumber, i+1} = fvalValues(i);
    end
    
    % Calculate mean of fval for each function
    meanFval(FunctionNumber) = mean(fvalValues);
    varFval(FunctionNumber) = var(fvalValues);
    
    % Store mean and variance in the last two columns
    fvalCell{FunctionNumber, end-1} = meanFval(FunctionNumber);
    fvalCell{FunctionNumber, end} = varFval(FunctionNumber);
end

% Display the results in a table
fvalHeader = {'FunctionNumber'};
for i = 1:50
    fvalHeader{end+1} = num2str(i);
end
fvalHeader{end+1} = 'MeanFval';
fvalHeader{end+1} = 'VarFval';

disp('Function-wise fval values:');
disp(fvalCell);

% Plot table
figure;
uitable('Data', fvalCell, 'ColumnName', fvalHeader, 'RowName', [], 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);

% Set plot title and axis labels
title('fval Values for Each Function');
xlabel('Function Number');
