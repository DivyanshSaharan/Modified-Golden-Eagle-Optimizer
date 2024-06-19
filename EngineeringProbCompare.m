options.PopulationSize = 50;
options.MaxIterations = 1000;
options.AttackPropensity = [0.5, 2];
options.CruisePropensity = [1, 0.5];
num_runs = 30; % Number of runs for each algorithm

% Initialize array to store mean results for each function
mean_results = zeros(13, 1);

for j = 1:13 % Iterate over each function
    % Initialize array to store results for this function
    func_results = zeros(num_runs, 1);
    
    for i = 1:num_runs
        % Get problem details for the current function
        [out, D, lb, ub, Vio] = Func_eng(j); % Assuming the dimension is 10
        
        % Set options
        options.LowerBound = lb;
        options.UpperBound = ub;

        % Run GEO with constraint handling
        %[~, fval, ~] = GEO_with_ConstraintHandling(out, D, lb, ub, Vio, options);
        [~, fval, ~] = GEO_with_AdaptiveStepSizeVariability_vio(out, D, lb, ub, Vio, options);
        % Display iteration results
        fprintf('Function %d, Run %d - Objective function value: %f\n', j, i, fval);

        % Store the objective function value obtained in this run
        func_results(i) = fval;
    end
    
    % Calculate average objective function value for this function
    mean_results(j) = mean(func_results);
    
    % Display results
    fprintf('Function %d - Average objective function value over %d runs: %f\n', j, num_runs, mean_results(j));
end

% Display mean results for all functions
disp('Mean Results for Each Function:');
disp(mean_results);
