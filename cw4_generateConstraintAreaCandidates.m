function [WS_list, TW_list, Q, meta] = cw4_generateConstraintAreaCandidates(C, p)
% cw4_generateConstraintAreaCandidates
% Generates candidate design points directly from the non-rectangular raw
% constraint-design area.  This avoids the earlier rectangular-window logic.
%
% A point is generated only if it satisfies the matching-chart constraints:
%   W/S <= landing limit on the take-off W/S axis
%   T/W >= max(T/W_takeoff, T/W_cruise, T/W_OEI)
%
% The upper T/W bound is the plotting / sampling cap. It is not treated as an
% aircraft performance optimum; high-T/W candidates can still be rejected or
% penalised later by the full-aircraft objective function.

WS_grid = p.grid.WS_values(:);

if isfield(p.grid,'TW_step')
    dTW = p.grid.TW_step;
else
    dTW = p.grid.TW_values(2) - p.grid.TW_values(1);
end

if isfield(p.grid,'TW_upper')
    TW_upper = p.grid.TW_upper;
else
    TW_upper = max(p.grid.TW_values);
end

if isfield(p.grid,'TW_lower_floor')
    TW_floor = p.grid.TW_lower_floor;
else
    TW_floor = min(p.grid.TW_values);
end

% Only W/S stations up to the landing limit can be inside the raw design area.
WS_grid = WS_grid(WS_grid >= min(C.WS) & WS_grid <= min(max(C.WS), C.WS_landing_takeoff));

WS_cell = cell(numel(WS_grid),1);
TW_cell = cell(numel(WS_grid),1);
activeLower = nan(numel(WS_grid),1);
numByStation = zeros(numel(WS_grid),1);

for i = 1:numel(WS_grid)
    WS_i = WS_grid(i);

    TW_to = interp1(C.WS, C.TW_takeoff, WS_i, 'linear', 'extrap');
    TW_cr = interp1(C.WS, C.TW_cruise,  WS_i, 'linear', 'extrap');
    TW_oe = interp1(C.WS, C.TW_oei,     WS_i, 'linear', 'extrap');
    TW_low = max([TW_to, TW_cr, TW_oe, TW_floor]);
    activeLower(i) = TW_low;

    % Snap upward to the nearest sampling grid so every generated point is
    % strictly inside/on the active lower envelope.
    TW_start = ceil((TW_low - 1e-12)/dTW)*dTW;

    if TW_start <= TW_upper
        TW_vals = (TW_start:dTW:TW_upper)';
        WS_vals = WS_i*ones(size(TW_vals));
        WS_cell{i} = WS_vals;
        TW_cell{i} = TW_vals;
        numByStation(i) = numel(TW_vals);
    else
        WS_cell{i} = zeros(0,1);
        TW_cell{i} = zeros(0,1);
    end
end

WS_list = vertcat(WS_cell{:});
TW_list = vertcat(TW_cell{:});

% Query again for traceability and as a safety check.
Q = cw4_queryConstraintGraph(C, WS_list, TW_list);
inside = Q.inside;
WS_list = WS_list(inside);
TW_list = TW_list(inside);

% Re-query after removing any numerical edge cases.
Q = cw4_queryConstraintGraph(C, WS_list, TW_list);

meta = struct();
meta.samplingMode = 'constraint_area';
meta.WS_station_count = numel(WS_grid);
meta.candidate_count = numel(WS_list);
meta.TW_step = dTW;
meta.TW_upper = TW_upper;
meta.WS_min = min(WS_grid);
meta.WS_max = max(WS_grid);
meta.activeLowerByStation = activeLower;
meta.numCandidatesByStation = numByStation;
end
