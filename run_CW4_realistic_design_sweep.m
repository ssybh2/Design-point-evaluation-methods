% run_CW4_realistic_design_sweep
% Default balanced full-aircraft design-area sweep.

clear; clc; close all;

mode = 'balanced';
p = CW4_realisticConfig(mode);

fprintf('Running realistic benchmark full-aircraft design sweep (%s)...\n', mode);
results = cw4_runSweepRealistic(p);

outDir = sprintf('results_calibrated_%s', mode);
if exist(outDir,'dir')
    delete(fullfile(outDir,'*.csv'));
    delete(fullfile(outDir,'*.png'));
    delete(fullfile(outDir,'*.mat'));
end
cw4_exportResultsRealistic(results, p, outDir, mode);

fprintf('\nFinished. Results written to: %s\n', outDir);
