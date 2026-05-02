function Q = cw4_queryConstraintGraph(C, WS_query, TW_query)
% cw4_queryConstraintGraph
% Interpolates the constraint curves at candidate W/S values and determines
% whether the candidate point lies inside the raw constraint design area.

WS_query = WS_query(:);
TW_query = TW_query(:);

TW_takeoff = interp1(C.WS, C.TW_takeoff, WS_query, 'linear', 'extrap');
TW_cruise  = interp1(C.WS, C.TW_cruise,  WS_query, 'linear', 'extrap');
TW_oei     = interp1(C.WS, C.TW_oei,     WS_query, 'linear', 'extrap');
TW_lower   = max([TW_takeoff, TW_cruise, TW_oei], [], 2);

inside = (WS_query <= C.WS_landing_takeoff) & (TW_query >= TW_lower);

Q = struct();
Q.TW_takeoff = TW_takeoff;
Q.TW_cruise = TW_cruise;
Q.TW_oei = TW_oei;
Q.TW_lower = TW_lower;
Q.inside = inside;
Q.WS_landing_takeoff = C.WS_landing_takeoff*ones(size(WS_query));
Q.WS_landing_weight = C.WS_landing_weight*ones(size(WS_query));
end
