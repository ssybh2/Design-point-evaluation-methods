% run_CW4_compare_realistic_modes
% Compare minimum-size, balanced, and robust design philosophies.

clear; clc; close all;

modes = {'minimum_size','balanced','robust'};
summary = table();

for k = 1:numel(modes)
    mode = modes{k};
    p = CW4_realisticConfig(mode);
    fprintf('\nRunning mode: %s\n', mode);
    results = cw4_runSweepRealistic(p);
    outDir = sprintf('results_realistic_%s', mode);
    T = cw4_exportResultsRealistic(results, p, outDir, mode);

    F = T(T.feasible == true, :);
    F = sortrows(F, 'score', 'ascend');
    if ~isempty(F)
        best = F(1,:);
        row = table(string(mode), best.WS_Nm2, best.TW, best.score, best.MTOW_kg, ...
            best.S_m2, best.b_m, best.LDcruise, best.fuel_kg, best.totalThrust_kN, ...
            best.landingMargin, best.thrustMargin, best.staticMargin, ...
            'VariableNames', {'mode','WS_Nm2','TW','score','MTOW_kg','S_m2','b_m','LDcruise','fuel_kg','totalThrust_kN','landingMargin','thrustMargin','staticMargin'});
        summary = [summary; row]; %#ok<AGROW>
    end
end

writetable(summary, 'realistic_mode_comparison.csv');
disp(summary);
fprintf('\nMode comparison written to realistic_mode_comparison.csv\n');
