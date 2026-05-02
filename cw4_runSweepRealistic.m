function results = cw4_runSweepRealistic(p)
% cw4_runSweepRealistic
% Builds the constraint graph first, generates candidate design points from
% the actual non-rectangular raw design area, and evaluates those points with
% the full-aircraft feedback model.

C = cw4_buildConstraintGraph(p);

useConstraintAreaSampler = isfield(p.grid,'samplingMode') && strcmpi(string(p.grid.samplingMode),'constraint_area');

if useConstraintAreaSampler
    [WS_list, TW_list, Q, meta] = cw4_generateConstraintAreaCandidates(C, p);
    fprintf('Constraint-area sampler enabled.\n');
    fprintf('  W/S stations used: %d\n', meta.WS_station_count);
    fprintf('  Candidate points generated inside raw design area: %d\n', meta.candidate_count);
else
    % Legacy rectangular sampling followed by constraint filtering.
    [WSgrid, TWgrid] = meshgrid(p.grid.WS_values, p.grid.TW_values);
    WS_all = WSgrid(:);
    TW_all = TWgrid(:);
    Qall = cw4_queryConstraintGraph(C, WS_all, TW_all);
    keep = Qall.inside;
    WS_list = WS_all(keep);
    TW_list = TW_all(keep);
    Q = cw4_queryConstraintGraph(C, WS_list, TW_list);
    fprintf('Legacy rectangular sampler enabled.\n');
    fprintf('  Raw rectangular grid points: %d\n', numel(WS_all));
    fprintf('  Points inside constraint-graph design area: %d\n', numel(WS_list));
end

N = numel(WS_list);
if N == 0
    results = repmat(cw4_resultStructTemplate(), 0, 1);
    return;
end

resultsCell = cell(N,1);

for i = 1:N
    ri = cw4_evaluateCandidateRealistic(WS_list(i), TW_list(i), p);

    % Store raw constraint-graph values for traceability.
    ri.insideConstraintDesignArea = true;
    ri.TWconstraintRequired = Q.TW_lower(i);
    ri.TWconstraintTakeoff = Q.TW_takeoff(i);
    ri.TWconstraintCruise = Q.TW_cruise(i);
    ri.TWconstraintOEI = Q.TW_oei(i);
    ri.WSconstraintLandingLimit_Nm2 = Q.WS_landing_takeoff(i);
    ri.WSconstraintLandingWeightLimit_Nm2 = Q.WS_landing_weight(i);

    resultsCell{i} = ri;

    if mod(i, max(1,round(N/20))) == 0 || i == N
        fprintf('  %5d / %5d constraint-area candidates processed\n', i, N);
    end
end

template = resultsCell{1};
results = repmat(template, N, 1);
for i = 1:N
    results(i) = cw4_forceSameFields(resultsCell{i}, template);
end

end
