function checks = cw4_constraintChecksRealistic(state, p)
% Constraint and real-aircraft benchmark checks.

WS = state.geom.S; %#ok<NASGU>
% Use actual W/S from final aircraft and wing area to preserve closure.
actualWS = state.mass.MTOW*p.g/state.geom.S;
TW = state.propulsion.TW;

% Landing boundary from approach-speed relation.
% The stall-speed equation applies to landing weight. Therefore the
% landing limit is first computed for W_L/S and then converted to the
% take-off wing-loading axis using beta = W_L/W_TO.
VA_kt = sqrt(p.req.LFL_m/0.091);
VS_kt = VA_kt/1.3;
VS_ms = VS_kt*p.kt_to_ms;
WSlandingLimitLandingWeight = 0.5*p.rhoSL*p.highlift.CLmaxL*VS_ms^2;
if isfield(p,'landing') && isfield(p.landing,'applyLandingWeightRelief') && p.landing.applyLandingWeightRelief
    betaLanding = p.landing.betaLanding;
else
    betaLanding = 1.0;
end
WSlandingLimit = WSlandingLimitLandingWeight/betaLanding;
landingMargin = (WSlandingLimit - actualWS)/WSlandingLimit;

% Take-off relation.
TWtakeoffReq = 0.239*actualWS/(p.req.TOFL_m*p.highlift.CLmaxTO);
takeoffMargin = (TW - TWtakeoffReq)/TWtakeoffReq;

% Cruise constraint on sea-level T/W axis.
q = p.mission.qCruise;
TWcruiseAltReq = q*state.aero.CD0/actualWS + state.aero.K*actualWS/q;
TWcruiseReq = TWcruiseAltReq/p.performance.thrustLapseCruise;
cruiseMargin = (TW - TWcruiseReq)/TWcruiseReq;

TWactiveReq = max([TWtakeoffReq, TWcruiseReq, p.performance.TW_OEI]);
thrustMargin = (TW - TWactiveReq)/TWactiveReq;

reasons = strings(0,1);
feasible = true;

if ~state.converged || any(isnan([state.mass.MTOW, state.aero.LDcruise, state.balance.hCG]))
    feasible = false; reasons(end+1) = "not_converged_or_nan";
end
if landingMargin < p.rules.minLandingMargin
    feasible = false; reasons(end+1) = "landing_margin_below_min";
end
if takeoffMargin < p.rules.minTakeoffMargin
    feasible = false; reasons(end+1) = "takeoff_margin_below_min";
end
if thrustMargin < p.rules.minThrustMargin
    feasible = false; reasons(end+1) = "thrust_margin_below_min";
end
if cruiseMargin < p.rules.minCruiseMargin
    feasible = false; reasons(end+1) = "cruise_margin_below_min";
end
if state.balance.staticMargin < p.rules.minStaticMargin || state.balance.staticMargin > p.rules.maxStaticMargin
    feasible = false; reasons(end+1) = "static_margin_out_of_range";
end
if state.balance.hCG < p.rules.minCGmac || state.balance.hCG > p.rules.maxCGmac
    feasible = false; reasons(end+1) = "cg_mac_out_of_range";
end

% Real-aircraft benchmark envelope.
if state.mass.MTOW < p.real.minMTOW_kg || state.mass.MTOW > p.real.maxMTOW_kg
    feasible = false; reasons(end+1) = "mtow_outside_benchmark";
end
if state.geom.b < p.real.minSpan_m || state.geom.b > p.real.maxSpan_m
    feasible = false; reasons(end+1) = "span_outside_benchmark";
end
if state.geom.S < p.real.minWingArea_m2 || state.geom.S > p.real.maxWingArea_m2
    feasible = false; reasons(end+1) = "wing_area_outside_benchmark";
end
if state.propulsion.perEngineThrust_kN < p.real.minPerEngineThrust_kN || state.propulsion.perEngineThrust_kN > p.real.maxPerEngineThrust_kN
    feasible = false; reasons(end+1) = "engine_thrust_outside_benchmark";
end
if state.aero.LDcruise < p.real.minLDcruise || state.aero.LDcruise > p.real.maxLDcruise
    feasible = false; reasons(end+1) = "ld_outside_benchmark";
end
if state.geom.ct < p.real.minTipChord_m
    feasible = false; reasons(end+1) = "tip_chord_too_small";
end
if state.aero.CD0 < p.real.minCD0 || state.aero.CD0 > p.real.maxCD0
    feasible = false; reasons(end+1) = "cd0_outside_benchmark";
end
ratioTail = state.tail.totalArea/state.geom.S;
if ratioTail < p.real.minTailToWingArea || ratioTail > p.real.maxTailToWingArea
    feasible = false; reasons(end+1) = "tail_to_wing_area_outside_benchmark";
end
if state.gear.CGtoMGarm < p.real.minGearArm_m || state.gear.CGtoMGarm > p.real.maxGearArm_m
    feasible = false; reasons(end+1) = "gear_arm_outside_benchmark";
end

if isempty(reasons)
    reasonStr = "OK";
else
    reasonStr = strjoin(reasons, ";");
end

checks.feasible = feasible;
checks.rejectionReason = char(reasonStr);
checks.WSactual = actualWS;
checks.WSlandingLimit = WSlandingLimit;
checks.WSlandingLimitLandingWeight = WSlandingLimitLandingWeight;
checks.betaLanding = betaLanding;
checks.TWtakeoffReq = TWtakeoffReq;
checks.TWcruiseAltReq = TWcruiseAltReq;
checks.TWcruiseReq = TWcruiseReq;
checks.TWactiveReq = TWactiveReq;
checks.landingMargin = landingMargin;
checks.takeoffMargin = takeoffMargin;
checks.cruiseMargin = cruiseMargin;
checks.thrustMargin = thrustMargin;
checks.VA_kt = VA_kt;
checks.VS_ms = VS_ms;

end
