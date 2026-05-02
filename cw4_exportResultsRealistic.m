function T = cw4_exportResultsRealistic(results, p, outDir, mode)
% Exports CSV tables and figures for the realistic design sweep.

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Export the regenerated constraint graph and its curve data for report
% traceability.  This is the matching chart that defines the design area
% before the full-aircraft iteration is run.
C = cw4_buildConstraintGraph(p);
writetable(cw4_constraintGraphTable(C), fullfile(outDir, sprintf('constraint_graph_curves_%s.csv', mode)));

T = struct2table(results);
T = sortrows(T, {'feasible','score'}, {'descend','ascend'});

writetable(T, fullfile(outDir, sprintf('all_candidates_%s.csv', mode)));

F = T(T.feasible == true, :);
F = sortrows(F, 'score', 'ascend');
writetable(F, fullfile(outDir, sprintf('feasible_candidates_%s.csv', mode)));

nTop = min(20, height(F));
if nTop > 0
    Top20 = F(1:nTop,:);
else
    Top20 = F;
end
writetable(Top20, fullfile(outDir, sprintf('top20_candidates_%s.csv', mode)));

% Report-ready compact table.
summaryVars = {'WS_Nm2','TW','score','insideConstraintDesignArea','TWconstraintRequired', ...
    'MTOW_kg','fuel_kg','S_m2','b_m','MAC_m','betaLanding', ...
    'CD0','CLcruise','LDcruise','totalThrust_kN','perEngineThrust_kN', ...
    'SH_m2','SV_m2','xCG_m','hCG','staticMargin','xMG_m', ...
    'landingMargin','takeoffMargin','thrustMargin','cruiseMargin'};
if nTop > 0
    Summary = Top20(:, summaryVars);
else
    Summary = Top20;
end
writetable(Summary, fullfile(outDir, sprintf('report_top_candidates_summary_%s.csv', mode)));

% Plot the actual constraint graph used to define the MATLAB sampling region.
if nTop > 0
    bestPoint = struct('WS', Top20.WS_Nm2(1), 'TW', Top20.TW(1));
else
    bestPoint = [];
end
cw4_plotConstraintGraph(C, p, bestPoint, fullfile(outDir, sprintf('constraint_graph_%s.png', mode)));

% Rejection summary.
if height(T) > height(F)
    infeasible = T(T.feasible == false, :);
    reasons = string(infeasible.rejectionReason);
    [uReasons, ~, idx] = unique(reasons);
    counts = accumarray(idx, 1);
    R = table(uReasons, counts, 'VariableNames', {'rejectionReason','count'});
else
    R = table(strings(0,1), zeros(0,1), 'VariableNames', {'rejectionReason','count'});
end
writetable(R, fullfile(outDir, sprintf('rejection_summary_%s.csv', mode)));

save(fullfile(outDir, sprintf('CW4_realistic_results_%s.mat', mode)), 'T', 'F', 'Top20', 'Summary', 'R', 'p', 'C');

cw4_makePlotsRealistic(T, F, Top20, outDir, mode, p);

if ~isempty(F)
    fprintf('\nBest candidate for mode %s:\n', mode);
    disp(F(1, summaryVars));
else
    fprintf('\nNo feasible candidates found for mode %s. Check hard constraints.\n', mode);
end

end
