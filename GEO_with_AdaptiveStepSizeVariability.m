function [x, fval, ConvergenceCurve] = GEO_with_AdaptiveStepSizeVariability(fun, nvars, lb, ub, options)

PopulationSize = options.PopulationSize;
MaxIterations = options.MaxIterations;
ConvergenceCurve = zeros(1, MaxIterations);

x = lb + rand(PopulationSize, nvars) .* (ub - lb);
FitnessScores = fun(x);

FlockMemoryF = FitnessScores;
FlockMemoryX = x;

% Initialize attack and cruise propensities
AttackPropensity = linspace(options.AttackPropensity(1), options.AttackPropensity(2), MaxIterations);
CruisePropensity = linspace(options.CruisePropensity(1), options.CruisePropensity(2), MaxIterations);

% Parameters for adaptive step size adjustment
NoImprovementCount = 0;
ImprovementCount = 0;
MaxNoImprovementCount = 10;
MaxImprovementCount = 5;
StepSizeIncreaseFactor = 1.1;
StepSizeDecreaseFactor = 0.9;

for CurrentIteration = 1:MaxIterations
    DestinationEagle = randperm(PopulationSize)';

    AttackVectorInitial = FlockMemoryX(DestinationEagle,:) - x;
    Radius = VecNorm(AttackVectorInitial, 2, 2);

    ConvergedEagles = sum(Radius, 2) == 0;
    UnconvergedEagles = ~ConvergedEagles;

    CruiseVectorInitial = 2 .* rand(PopulationSize, nvars) - 1;
    AttackVectorInitial(ConvergedEagles, :) = 0;
    CruiseVectorInitial(ConvergedEagles, :) = 0;

    for i1 = 1:PopulationSize
        if UnconvergedEagles(i1)
            vConstrained = false([1, nvars]);
            idx = datasample(find(AttackVectorInitial(i1, :)), 1, 2);
            vConstrained(idx) = 1;
            vFree = ~vConstrained;
            CruiseVectorInitial(i1, idx) = -sum(AttackVectorInitial(i1, vFree).*CruiseVectorInitial(i1, vFree), 2) ./ (AttackVectorInitial(i1, vConstrained));
        end
    end

    AttackVectorUnit = AttackVectorInitial ./ VecNorm(AttackVectorInitial, 2, 2);
    CruiseVectorUnit = CruiseVectorInitial ./ VecNorm(CruiseVectorInitial, 2, 2);
    AttackVectorUnit(ConvergedEagles,:) = 0;
    CruiseVectorUnit(ConvergedEagles,:) = 0;

    % Adaptive Step Size Adaptation
    if CurrentIteration > 1
        if min(FitnessScores) < min(FlockMemoryF)
            ImprovementCount = ImprovementCount + 1;
            NoImprovementCount = 0;
            if ImprovementCount >= MaxImprovementCount
                % Decrease step size
                AttackPropensity(CurrentIteration) = max(0.1, AttackPropensity(CurrentIteration) * StepSizeDecreaseFactor);
                CruisePropensity(CurrentIteration) = max(0.1, CruisePropensity(CurrentIteration) * StepSizeDecreaseFactor);
                ImprovementCount = 0;
            end
        else
            NoImprovementCount = NoImprovementCount + 1;
            ImprovementCount = 0;
            if NoImprovementCount >= MaxNoImprovementCount
                % Increase step size
                AttackPropensity(CurrentIteration) = min(1, AttackPropensity(CurrentIteration) * StepSizeIncreaseFactor);
                CruisePropensity(CurrentIteration) = min(1, CruisePropensity(CurrentIteration) * StepSizeIncreaseFactor);
                NoImprovementCount = 0;
            end
        end
    end

    % Calculate movement vectors with adaptive step sizes
    AttackVector = rand(PopulationSize, 1) .* AttackPropensity(CurrentIteration) .* Radius .* AttackVectorUnit;
    CruiseVector = rand(PopulationSize, 1) .* CruisePropensity(CurrentIteration) .* Radius .* CruiseVectorUnit;
    StepVector = AttackVector + CruiseVector;

    % Update solutions
    x = x + StepVector;
    x = ApplyBounds(x, lb, ub);
    FitnessScores = fun(x);

    % Update memory
    UpdateMask = FitnessScores < FlockMemoryF;
    FlockMemoryF(UpdateMask) = FitnessScores(UpdateMask);
    FlockMemoryX(UpdateMask,:) = x(UpdateMask,:);

    ConvergenceCurve(CurrentIteration) = min(FlockMemoryF);
end

[fval, fvalIndex] = min(FlockMemoryF);
x = FlockMemoryX(fvalIndex, :);

fprintf('Best solution obtained by GEO with Adaptive Step Variability: %s\n', num2str(x,'%e  '));
fprintf('Best objective function value obtained by GEO with Adaptive Step Variability: %e \n', fval);

end

% Helper function to enforce boundary constraints
function boundedSolution = ApplyBounds(solution, lb, ub)
    % Check and correct lower bound violations
    lbViolated = solution < lb;
    lbViolated = lbViolated & ~isnan(solution); % Ensure indices are within bounds
    lbIndices = find(lbViolated); % Get the indices where lb is violated
    lbIndices = lbIndices(lbIndices <= numel(lb)); % Ensure indices are within bounds
    if ~isempty(lbIndices)
        lbValues = lb(lbIndices); % Get the corresponding lower bound values
        solution(lbIndices) = lbValues; % Correct the violated lower bounds
    end

    % Check and correct upper bound violations
    ubViolated = solution > ub;
    ubViolated = ubViolated & ~isnan(solution); % Ensure indices are within bounds
    ubIndices = find(ubViolated); % Get the indices where ub is violated
    ubIndices = ubIndices(ubIndices <= numel(ub)); % Ensure indices are within bounds
    if ~isempty(ubIndices)
        ubValues = ub(ubIndices); % Get the corresponding upper bound values
        solution(ubIndices) = ubValues; % Correct the violated upper bounds
    end

    boundedSolution = solution;
end

