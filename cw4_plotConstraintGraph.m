function cw4_plotConstraintGraph(C, p, bestPoint, savePath)
% cw4_plotConstraintGraph
% Plots the final constraint graph, the raw feasible design area, the MATLAB
% sampling window, and the selected design point if available.
%
% The x-axis is deliberately the full matching-chart scale, not only the
% local optimisation window.  This makes the report figure comparable with a
% conventional CW2-style constraint diagram.

fig = figure('Color','w','Position',[80 80 1450 820]);
hold on; grid on; box on;

WS = C.WS;
idx = (WS <= C.WS_landing_takeoff) & (C.TW_lower <= p.constraint.TW_plot_max);

% Raw feasible region: above the active thrust envelope and left of landing
% limit, truncated at the plot upper T/W bound.
if any(idx)
    WSf = WS(idx);
    TWlow = C.TW_lower(idx);
    TWtop = p.constraint.TW_plot_max*ones(size(WSf));
    fill([WSf; flipud(WSf)], [TWlow; flipud(TWtop)], ...
        [0.90 0.95 1.00], 'EdgeColor', 'none', 'FaceAlpha', 0.70, ...
        'DisplayName', 'Raw feasible design area');
end

% Show how MATLAB candidates were generated.  In constraint-area mode the
% candidates are not sampled from a rectangular box; they are generated directly
% from the shaded non-rectangular design area.  A rectangle is only shown for
% the legacy local-window mode.
useConstraintAreaSampler = isfield(p.grid,'samplingMode') && strcmpi(string(p.grid.samplingMode),'constraint_area');
if ~useConstraintAreaSampler
    if isfield(p.constraint,'sampleWS_min')
        xS1 = p.constraint.sampleWS_min;
        xS2 = p.constraint.sampleWS_max;
        yS1 = p.constraint.sampleTW_min;
        yS2 = p.constraint.sampleTW_max;
    else
        xS1 = min(p.grid.WS_values); xS2 = max(p.grid.WS_values);
        yS1 = min(p.grid.TW_values); yS2 = max(p.grid.TW_values);
    end
    patch([xS1 xS2 xS2 xS1], [yS1 yS1 yS2 yS2], ...
          [1.00 0.96 0.80], 'FaceAlpha', 0.18, 'EdgeColor', [0.60 0.45 0.00], ...
          'LineStyle','--', 'LineWidth', 1.3, 'DisplayName','MATLAB rectangular sampling window');
end

% Constraint curves.
plot(WS, C.TW_takeoff, 'b-', 'LineWidth', 2.0, 'DisplayName', 'Take-off constraint');
plot(WS, C.TW_cruise,  'r--', 'LineWidth', 2.0, 'DisplayName', 'Cruise constraint');
plot(WS, C.TW_oei,     'g-.', 'LineWidth', 2.0, 'DisplayName', 'OEI / climb target');
plot(WS, C.TW_lower,   'k-', 'LineWidth', 1.5, 'DisplayName', 'Active thrust envelope');

xline(C.WS_landing_takeoff, 'k-', 'LineWidth', 2.0, ...
      'DisplayName', 'Landing limit on T/O W/S axis');

% Optional selected design point.
if nargin >= 3 && ~isempty(bestPoint)
    plot(bestPoint.WS, bestPoint.TW, 'p', 'MarkerSize', 22, ...
        'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', ...
        'DisplayName', 'Selected design point');
end

xlabel('Wing loading  W/S  (N/m^2)');
ylabel('Thrust-to-weight ratio  T/W');
title('Final constraint graph and MATLAB-sampled design area');
xlim([p.constraint.WS_min, p.constraint.WS_max]);
ylim([p.constraint.TW_plot_min, p.constraint.TW_plot_max]);
legend('Location','northeastoutside');

annotationText = sprintf('Landing limit on take-off W/S axis: %.0f N/m^2  (beta_L = %.2f)', ...
    C.WS_landing_takeoff, C.betaLanding);
text(p.constraint.WS_min + 0.03*(p.constraint.WS_max-p.constraint.WS_min), ...
     p.constraint.TW_plot_max - 0.08*(p.constraint.TW_plot_max-p.constraint.TW_plot_min), ...
     annotationText, 'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', [0.75 0.75 0.75]);

if useConstraintAreaSampler
    sampleText = sprintf('MATLAB samples the non-rectangular area: T/W >= active envelope, W/S <= %.0f', C.WS_landing_takeoff);
    text(p.constraint.WS_min + 0.03*(p.constraint.WS_max-p.constraint.WS_min), ...
         p.constraint.TW_plot_min + 0.08*(p.constraint.TW_plot_max-p.constraint.TW_plot_min), ...
         sampleText, 'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', [0.85 0.85 0.85]);
else
    sampleText = sprintf('MATLAB sampled window: W/S %.0f--%.0f, T/W %.3f--%.3f', xS1, xS2, yS1, yS2);
    text(xS1, max(yS1 - 0.04*(p.constraint.TW_plot_max-p.constraint.TW_plot_min), p.constraint.TW_plot_min+0.01), ...
         sampleText, 'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', [0.85 0.85 0.85]);
end

if nargin >= 4 && ~isempty(savePath)
    saveas(fig, savePath);
end
end
