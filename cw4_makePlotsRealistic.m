function cw4_makePlotsRealistic(T, F, Top20, outDir, mode, p)
% Make figures for design-area sweep results.
% If p is provided, the raw constraint-graph design area is drawn behind the
% candidate points so the user can verify that the sampled points came from
% the matching chart rather than from an arbitrary search box.

if nargin >= 6 && ~isempty(p)
    C = cw4_buildConstraintGraph(p);
else
    C = [];
end

%% Candidate map
fig1 = figure('Color','w','Position',[100 100 1400 800]);
hold on; grid on; box on;

% Constraint-graph design area and curves behind the candidate points.
if ~isempty(C)
    WS = C.WS;
    idx = (WS <= C.WS_landing_takeoff) & (C.TW_lower <= p.constraint.TW_plot_max);
    if any(idx)
        WSf = WS(idx);
        TWlow = C.TW_lower(idx);
        TWtop = p.constraint.TW_plot_max*ones(size(WSf));
        fill([WSf; flipud(WSf)], [TWlow; flipud(TWtop)], ...
            [0.92 0.96 1.00], 'EdgeColor', 'none', 'FaceAlpha', 0.55, ...
            'DisplayName','Raw constraint design area');
    end
    plot(WS, C.TW_takeoff, 'b-', 'LineWidth', 1.4, 'DisplayName','Take-off constraint');
    plot(WS, C.TW_cruise,  'r--', 'LineWidth', 1.4, 'DisplayName','Cruise constraint');
    plot(WS, C.TW_oei,     'g-.', 'LineWidth', 1.4, 'DisplayName','OEI/climb target');
    xline(C.WS_landing_takeoff, 'k-', 'LineWidth', 1.5, 'DisplayName','Landing limit');
end

Tinfeas = T(T.feasible == false, :);
if ~isempty(Tinfeas)
    scatter(Tinfeas.WS_Nm2, Tinfeas.TW, 28, [0.70 0.70 0.70], 'filled', 'DisplayName','Infeasible / not evaluated');
end

if ~isempty(F)
    scatter(F.WS_Nm2, F.TW, 44, F.score, 'filled', 'DisplayName','Feasible full-aircraft candidates');
    best = F(1,:);
    plot(best.WS_Nm2, best.TW, 'p', 'MarkerSize', 20, 'MarkerFaceColor','y', 'MarkerEdgeColor','k', 'DisplayName','Best');
    cb = colorbar;
    cb.Label.String = 'Objective score, lower is better';
end

xlabel('Wing loading  W/S  (N/m^2)');
ylabel('Thrust-to-weight ratio  T/W');
title(sprintf('Constraint-filtered full-aircraft design sweep (%s)', strrep(mode,'_','\_')));
legend('Location','best');
xlim([min(T.WS_Nm2)-25, max(T.WS_Nm2)+25]);
ylim([min(T.TW)-0.0025, max(T.TW)+0.0025]);

saveas(fig1, fullfile(outDir, sprintf('candidate_map_%s.png', mode)));

%% Objective score map
if ~isempty(F) && height(F) > 3
    fig2 = figure('Color','w','Position',[150 130 1400 800]);
    hold on; grid on; box on;

    % Draw the raw design-area outline first when available.
    if ~isempty(C)
        WS = C.WS;
        idx = (WS <= C.WS_landing_takeoff) & (C.TW_lower <= p.constraint.TW_plot_max);
        if any(idx)
            WSf = WS(idx);
            TWlow = C.TW_lower(idx);
            TWtop = p.constraint.TW_plot_max*ones(size(WSf));
            fill([WSf; flipud(WSf)], [TWlow; flipud(TWtop)], ...
                [0.95 0.95 0.95], 'EdgeColor', 'none', 'FaceAlpha', 0.35);
        end
    end

    x = F.WS_Nm2; y = F.TW; z = F.score;
    try
        Finterp = scatteredInterpolant(x, y, z, 'natural', 'none');
        [Xq,Yq] = meshgrid(linspace(min(T.WS_Nm2), max(T.WS_Nm2), 140), linspace(min(T.TW), max(T.TW), 140));
        Zq = Finterp(Xq,Yq);
        contourf(Xq,Yq,Zq,24,'LineStyle','none');
        cb = colorbar;
        cb.Label.String = 'Objective score, lower is better';
    catch
        scatter(x,y,44,z,'filled');
        cb = colorbar;
        cb.Label.String = 'Objective score, lower is better';
    end
    best = F(1,:);
    plot(best.WS_Nm2, best.TW, 'p', 'MarkerSize', 22, 'MarkerFaceColor','c', 'MarkerEdgeColor','k');
    xlabel('Wing loading  W/S  (N/m^2)');
    ylabel('Thrust-to-weight ratio  T/W');
    title(sprintf('Objective score map inside constraint design area (%s)', strrep(mode,'_','\_')));
    xlim([min(T.WS_Nm2)-25, max(T.WS_Nm2)+25]);
    ylim([min(T.TW)-0.0025, max(T.TW)+0.0025]);
    saveas(fig2, fullfile(outDir, sprintf('objective_score_map_%s.png', mode)));
end

%% Normalized top-candidate outcomes
if ~isempty(Top20)
    topN = min(10, height(Top20));
    top = Top20(1:topN,:);
    vars = {'S_m2','b_m','LDcruise','fuel_kg','totalThrust_kN','SH_m2','SV_m2', ...
            'landingMargin','thrustMargin','staticMargin','score'};
    labels = {'S','b','L/D','fuel','thrust','S_H','S_V','landing margin','thrust margin','static margin','score'};
    A = table2array(top(:,vars));

    % Normalize within top candidates; for display only, not scoring.
    Amin = min(A,[],1,'omitnan');
    Amax = max(A,[],1,'omitnan');
    Den = Amax - Amin;
    Den(Den == 0) = 1;
    An = (A - Amin)./Den;

    fig3 = figure('Color','w','Position',[180 160 1500 750]);
    hold on; grid on; box on;
    for i = 1:topN
        plot(1:numel(vars), An(i,:), '-o', 'LineWidth', 1.4, 'DisplayName', sprintf('#%d: W/S %.0f, T/W %.4f', i, top.WS_Nm2(i), top.TW(i)));
    end
    xticks(1:numel(vars));
    xticklabels(labels);
    xtickangle(30);
    ylabel('Normalized value within top candidates');
    title(sprintf('Top feasible candidates: normalized full-aircraft outcomes (%s)', strrep(mode,'_','\_')));
    legend('Location','eastoutside');
    saveas(fig3, fullfile(outDir, sprintf('top10_normalized_outcomes_%s.png', mode)));
end

end
