function C = cw4_buildConstraintGraph(p)
% cw4_buildConstraintGraph
% Builds the final T/W--W/S constraint graph from the current aircraft-level
% assumptions. This module defines the true constraint-design area before the
% full-aircraft sweep is run.

%% Independent variable
WS = (p.constraint.WS_min:p.constraint.WS_step:p.constraint.WS_max)';

%% Landing constraint
% Landing field length relation used in the previous constraint analysis:
% S_LFL = 0.091 V_A^2, where V_A is in knots.  The stall relation is
% V_A = 1.3 V_S and V_S^2 = 2(W/S)/(rho CLmaxL).
VA_kt = sqrt(p.req.LFL_m/0.091);
VS_kt = VA_kt/1.3;
VS_ms = VS_kt*p.kt_to_ms;
WS_landing_weight = 0.5*p.rhoSL*p.highlift.CLmaxL*VS_ms^2;

if isfield(p,'landing') && isfield(p.landing,'applyLandingWeightRelief') && p.landing.applyLandingWeightRelief
    betaLanding = p.landing.betaLanding;
else
    betaLanding = 1.0;
end

% Convert the landing-weight wing-loading limit to the take-off wing-loading
% axis used in the matching chart.
WS_landing_takeoff = WS_landing_weight/betaLanding;

%% Take-off constraint
TW_takeoff = 0.239.*WS./(p.req.TOFL_m*p.highlift.CLmaxTO);

%% Cruise constraint
q = p.mission.qCruise;
CD0 = p.constraint.CD0;
K = p.constraint.K;
TW_cruise_alt = q*CD0./WS + K.*WS./q;
TW_cruise = TW_cruise_alt./p.performance.thrustLapseCruise;

%% OEI / climb constraint
TW_oei = p.performance.TW_OEI*ones(size(WS));

%% Lower envelope of the active thrust constraints
TW_lower = max([TW_takeoff, TW_cruise, TW_oei], [], 2);

%% Feasible design-area mask for the graph limits
inside = (WS <= WS_landing_takeoff) & ...
         (TW_lower <= p.constraint.TW_plot_max);

%% Output structure
C = struct();
C.WS = WS;
C.TW_takeoff = TW_takeoff;
C.TW_cruise_alt = TW_cruise_alt;
C.TW_cruise = TW_cruise;
C.TW_oei = TW_oei;
C.TW_lower = TW_lower;
C.WS_landing_weight = WS_landing_weight;
C.WS_landing_takeoff = WS_landing_takeoff;
C.betaLanding = betaLanding;
C.VA_kt = VA_kt;
C.VS_ms = VS_ms;
C.CD0 = CD0;
C.K = K;
C.insideByWS = inside;
end
