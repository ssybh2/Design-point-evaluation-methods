%% plot_constraint_graph_CW2_CW4_overlay.m
% Constraint graph overlay for CW2 original design point and CW4 MATLAB
% score-minimum point.
%
% The figure contains 8 constraint lines:
%   CW2: landing, take-off, cruise, OEI/climb
%   CW4: landing, take-off, cruise, OEI/climb
%
% and 2 design points:
%   CW2 original point:              W/S = 2260 N/m^2, T/W = 0.300
%   CW4 MATLAB score-minimum point:  W/S = 5050 N/m^2, T/W = 0.335
%
% Note:
% The final reported design point in the report was rounded from
% W/S = 5050 N/m^2 down to W/S = 5000 N/m^2 to recover approximately
% 10% landing margin. This graph shows the MATLAB score-minimum point.

clear; close all; clc;

%% Axis range
WS = linspace(1000, 6500, 1200);     % wing loading axis, N/m^2
yLim = [0.05 0.70];

%% Common requirements
S_TO  = 1700;                        % take-off field length, m
S_LFL = 1500;                        % landing field length, m
rho0  = 1.225;                       % sea-level density, kg/m^3

% Cruise condition used in the current report
q_cr      = 10660.900;               % dynamic pressure at 35,000 ft, N/m^2
alphaLap = 0.291;                   % cruise thrust lapse factor

%% ------------------------------------------------------------------------
%  CW2 ORIGINAL CONSTRAINT SET
%  Values taken from the previous constraint-analysis basis.
%% ------------------------------------------------------------------------

old.WS_point = 2260;                 % N/m^2
old.TW_point = 0.300;

old.CLmax_TO = 1.8;
old.CLmax_L  = 2.2;
old.CD0      = 0.015;
old.AR       = 9.0;
old.e        = 0.85;
old.K        = 1/(pi*old.e*old.AR);

% CW2 OEI/climb target from the earlier constraint chart.
old.TW_OEI = 0.261;

% CW2 plotted landing boundary for the old CLmax,L = 2.2 case.
% This is kept as the original CW2 landing line rather than recalculating it
% with the final CW4 landing-weight fraction.
old.WS_Landing = 4216;               % N/m^2

% CW2 take-off, cruise and OEI/climb lines
old.TW_TO     = 0.239.*WS./(S_TO*old.CLmax_TO);
old.TW_cruise = (1/alphaLap).*(q_cr*old.CD0./WS + old.K.*WS./q_cr);
old.TW_OEI_ln = old.TW_OEI.*ones(size(WS));

%% ------------------------------------------------------------------------
%  FINAL CW4 UPDATED CONSTRAINT SET
%% ------------------------------------------------------------------------

% This is the MATLAB score-minimum point, not the rounded final reported
% point. The report later rounded W/S down to 5000 N/m^2.
final.WS_point = 5050;               % N/m^2, MATLAB score-minimum point
final.TW_point = 0.335;

final.CLmax_TO = 2.4;
final.CLmax_L  = 3.0;
final.CD0      = 0.0175;
final.K        = 0.0441;
final.beta_L   = 0.850;
final.TW_OEI   = 0.285;

% Final landing boundary calculation
VA_kt = sqrt(S_LFL/0.091);           % approach speed in knots
VS_kt = VA_kt/1.3;                   % stall speed in knots
VS_ms = VS_kt/1.94384;               % convert knots to m/s

WS_Landing_final_weight = 0.5*rho0*final.CLmax_L*VS_ms^2;
final.WS_Landing = WS_Landing_final_weight/final.beta_L;

% Final take-off, cruise and OEI/climb lines
final.TW_TO     = 0.239.*WS./(S_TO*final.CLmax_TO);
final.TW_cruise = (1/alphaLap).*(q_cr*final.CD0./WS + final.K.*WS./q_cr);
final.TW_OEI_ln = final.TW_OEI.*ones(size(WS));

%% Useful margin values
landingMargin_5050 = (final.WS_Landing - 5050)/final.WS_Landing;
landingMargin_5000 = (final.WS_Landing - 5000)/final.WS_Landing;

activeTW_5050 = max([
    interp1(WS, final.TW_TO, final.WS_point), ...
    interp1(WS, final.TW_cruise, final.WS_point), ...
    final.TW_OEI]);

thrustMargin_5050 = (final.TW_point - activeTW_5050)/activeTW_5050;

%% Plot
fig = figure('Color','w','Position',[100 100 1100 720]);
hold on; grid on; box on;

% ---------------- CW2 original lines: dashed ----------------
h1 = plot([old.WS_Landing old.WS_Landing], yLim, '--', ...
    'LineWidth',1.8, 'Color',[0.45 0.45 0.45]);

h2 = plot(WS, old.TW_TO, '--', ...
    'LineWidth',1.8, 'Color',[0.00 0.25 0.85]);

h3 = plot(WS, old.TW_cruise, '--', ...
    'LineWidth',1.8, 'Color',[0.85 0.10 0.10]);

h4 = plot(WS, old.TW_OEI_ln, '--', ...
    'LineWidth',1.8, 'Color',[0.00 0.55 0.00]);

% ---------------- Final CW4 lines: solid ----------------
h5 = plot([final.WS_Landing final.WS_Landing], yLim, '-', ...
    'LineWidth',2.2, 'Color',[0.10 0.10 0.10]);

h6 = plot(WS, final.TW_TO, '-', ...
    'LineWidth',2.2, 'Color',[0.00 0.25 0.85]);

h7 = plot(WS, final.TW_cruise, '-', ...
    'LineWidth',2.2, 'Color',[0.85 0.10 0.10]);

h8 = plot(WS, final.TW_OEI_ln, '-', ...
    'LineWidth',2.2, 'Color',[0.00 0.55 0.00]);

% ---------------- Design points ----------------
p1 = plot(old.WS_point, old.TW_point, 'o', ...
    'MarkerSize',9, ...
    'MarkerFaceColor',[1.00 1.00 1.00], ...
    'MarkerEdgeColor',[0.00 0.00 0.00], ...
    'LineWidth',1.8);

p2 = plot(final.WS_point, final.TW_point, 'p', ...
    'MarkerSize',16, ...
    'MarkerFaceColor',[1.00 0.90 0.00], ...
    'MarkerEdgeColor',[0.00 0.00 0.00], ...
    'LineWidth',1.5);

% Point labels
text(old.WS_point+90, old.TW_point+0.015, ...
    'CW2 point: 2260, 0.300', ...
    'FontSize',10, 'FontWeight','bold');

text(final.WS_point+90, final.TW_point+0.015, ...
    'CW4 score-minimum: 5050, 0.335', ...
    'FontSize',10, 'FontWeight','bold');

% Landing boundary labels
text(old.WS_Landing-880, 0.63, ...
    sprintf('CW2 landing limit: %.0f N/m^2', old.WS_Landing), ...
    'FontSize',9, 'Color',[0.25 0.25 0.25]);

text(final.WS_Landing-940, 0.59, ...
    sprintf('Final landing limit: %.0f N/m^2', final.WS_Landing), ...
    'FontSize',9, 'Color',[0.10 0.10 0.10]);

% Optional note explaining why the report rounded to 5000

%% Formatting
xlabel('Wing loading  W/S  (N/m^2)', 'FontSize',12);
ylabel('Thrust-to-weight ratio  T/W', 'FontSize',12);
title('CW2 and CW4 Constraint Graph Overlay', ...
    'FontSize',13, 'FontWeight','bold');

xlim([1000 6500]);
ylim(yLim);

legend([h1 h2 h3 h4 h5 h6 h7 h8 p1 p2], ...
    {'CW2 landing limit', ...
     'CW2 take-off constraint', ...
     'CW2 cruise constraint', ...
     'CW2 OEI/climb target', ...
     'Final landing limit', ...
     'Final take-off constraint', ...
     'Final cruise constraint', ...
     'Final OEI/climb target', ...
     'CW2 design point', ...
     'CW4 MATLAB score-minimum point'}, ...
     'Location','eastoutside', ...
     'FontSize',9);

set(gca,'FontSize',11);
set(gca,'LineWidth',1.0);

%% Print useful values to command window
fprintf('\n--- CW2 original constraint set ---\n');
fprintf('CW2 landing limit = %.0f N/m^2\n', old.WS_Landing);
fprintf('CW2 T/W_TO at W/S = 2260 = %.3f\n', ...
    interp1(WS, old.TW_TO, old.WS_point));
fprintf('CW2 T/W_cruise at W/S = 2260 = %.3f\n', ...
    interp1(WS, old.TW_cruise, old.WS_point));
fprintf('CW2 T/W_OEI = %.3f\n', old.TW_OEI);
fprintf('CW2 design point = (%.0f, %.3f)\n', ...
    old.WS_point, old.TW_point);

fprintf('\n--- Final CW4 constraint set ---\n');
fprintf('Final landing limit = %.0f N/m^2\n', final.WS_Landing);
fprintf('Final T/W_TO at W/S = 5050 = %.3f\n', ...
    interp1(WS, final.TW_TO, final.WS_point));
fprintf('Final T/W_cruise at W/S = 5050 = %.3f\n', ...
    interp1(WS, final.TW_cruise, final.WS_point));
fprintf('Final T/W_OEI = %.3f\n', final.TW_OEI);
fprintf('Active T/W requirement at W/S = 5050 = %.3f\n', activeTW_5050);
fprintf('CW4 MATLAB score-minimum point = (%.0f, %.3f)\n', ...
    final.WS_point, final.TW_point);
fprintf('Landing margin at W/S = 5050 = %.1f%%\n', ...
    100*landingMargin_5050);
fprintf('Landing margin after report rounding to W/S = 5000 = %.1f%%\n', ...
    100*landingMargin_5000);
fprintf('Thrust margin at W/S = 5050, T/W = 0.335 = %.1f%%\n', ...
    100*thrustMargin_5050);

%% Save figure
% Save output into a figures folder located in the same folder as this script.
% If the script path cannot be detected, save into the current MATLAB folder.

thisFile = mfilename('fullpath');

if isempty(thisFile)
    scriptDir = pwd;
else
    scriptDir = fileparts(thisFile);
end

outDir = fullfile(scriptDir, 'figures');

if ~isfolder(outDir)
    [status, msg] = mkdir(outDir);
    if ~status
        warning('Could not create figures folder: %s', msg);
        outDir = scriptDir;   % fall back to script folder
    end
end

pngName = fullfile(outDir, 'constraint_graph_CW2_CW4_overlay.png');
pdfName = fullfile(outDir, 'constraint_graph_CW2_CW4_overlay.pdf');

try
    exportgraphics(fig, pngName, 'Resolution', 300);
    exportgraphics(fig, pdfName, 'ContentType', 'vector');
catch
    saveas(fig, pngName);
    saveas(fig, pdfName);
end

fprintf('\nFigure saved as:\n%s\n%s\n', pngName, pdfName);