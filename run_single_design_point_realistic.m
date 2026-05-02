% run_single_design_point_realistic
% Test one candidate design point and print its full-aircraft result.

clear; clc; close all;

mode = 'balanced';
p = CW4_realisticConfig(mode);

WS = 5000;   % N/m^2
TW = 0.335;  % dimensionless

r = cw4_evaluateCandidateRealistic(WS, TW, p);
disp(struct2table(r));

fprintf('\nCandidate W/S = %.0f N/m^2, T/W = %.4f\n', r.WS_Nm2, r.TW);
fprintf('Feasible: %d\n', r.feasible);
fprintf('Rejection reason: %s\n', r.rejectionReason);
fprintf('Score: %.5f\n', r.score);
fprintf('MTOW: %.1f kg, fuel: %.1f kg, OEW: %.1f kg\n', r.MTOW_kg, r.fuel_kg, r.OEW_kg);
fprintf('S: %.2f m^2, b: %.2f m, MAC: %.2f m\n', r.S_m2, r.b_m, r.MAC_m);
fprintf('CD0: %.5f, CLcruise: %.3f, LDcruise: %.2f\n', r.CD0, r.CLcruise, r.LDcruise);
fprintf('CG: %.2f m, hCG: %.1f %% MAC, SM: %.1f %% MAC\n', r.xCG_m, 100*r.hCG, 100*r.staticMargin);
fprintf('SH: %.2f m^2, SV: %.2f m^2, xMG: %.2f m\n', r.SH_m2, r.SV_m2, r.xMG_m);
fprintf('Margins: landing %.2f%%, takeoff %.2f%%, thrust %.2f%%, cruise %.2f%%\n', ...
    100*r.landingMargin, 100*r.takeoffMargin, 100*r.thrustMargin, 100*r.cruiseMargin);
