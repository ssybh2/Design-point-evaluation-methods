function r = cw4_evaluateCandidateRealistic(WS, TW, p)
% cw4_evaluateCandidateRealistic
% Evaluates one candidate design point by closing the whole aircraft.

state = cw4_aircraftSizingLoop(WS, TW, p);
checks = cw4_constraintChecksRealistic(state, p);
score = cw4_scoreRealistic(state, checks, p);

r = cw4_resultStructTemplate();

% Design point
r.WS_Nm2 = WS;
r.TW = TW;
r.mode = char(p.mode);

% Convergence and feasibility
r.converged = state.converged;
r.iterations = state.iterations;
r.feasible = checks.feasible;
r.rejectionReason = checks.rejectionReason;
r.score = score.total;
r.score_constraintRobustness = score.constraintRobustness;
r.score_aeroPerformance = score.aeroPerformance;
r.score_realAircraftFit = score.realAircraftFit;
r.score_configurationQuality = score.configurationQuality;
r.score_sizePenalty = score.sizePenalty;

% Geometry
r.S_m2 = state.geom.S;
r.b_m = state.geom.b;
r.rootChord_m = state.geom.cr;
r.tipChord_m = state.geom.ct;
r.MAC_m = state.geom.MAC;
r.yMAC_m = state.geom.yMAC;
r.LEMAC_m = state.geom.LEMAC;
r.wingAC_m = state.geom.wingAC;
r.spanFuselageRatio = state.geom.spanFuselageRatio;

% Aero
r.CD0 = state.aero.CD0;
r.K = state.aero.K;
r.CLcruise = state.aero.CLcruise;
r.CDcruise = state.aero.CDcruise;
r.LDcruise = state.aero.LDcruise;
r.Mff = state.aero.Mff;

% Mass
r.MTOW_kg = state.mass.MTOW;
r.OEW_kg = state.mass.OEW;
r.fuel_kg = state.mass.fuel;
r.payload_kg = p.payload_kg;
r.crew_kg = p.crewMass_kg;
r.wingMass_kg = state.mass.wingGroup;
r.tailMass_kg = state.mass.empennage;
r.gearMass_kg = state.mass.landingGear;
r.propulsionMass_kg = state.mass.propulsion;

% Tail
r.SH_m2 = state.tail.SH;
r.SV_m2 = state.tail.SV;
r.tailArea_m2 = state.tail.totalArea;
r.tailToWingArea = state.tail.totalArea/state.geom.S;
r.lH_m = state.tail.lH;
r.lV_m = state.tail.lV;

% Balance and gear
r.xCG_m = state.balance.xCG;
r.hCG = state.balance.hCG;
r.staticMargin = state.balance.staticMargin;
r.xNP_m = state.balance.xNP;
r.xNG_m = state.gear.xNG;
r.xMG_m = state.gear.xMG;
r.CGtoMGarm_m = state.gear.CGtoMGarm;
r.noseToCGarm_m = state.gear.noseToCGarm;
r.noseReaction_kN = state.gear.RNG_kN;
r.mainReaction_kN = state.gear.RMG_kN;
r.noseWheelLoad_kN = state.gear.noseWheelLoad_kN;
r.mainWheelLoad_kN = state.gear.mainWheelLoad_kN;

% Performance / constraints
r.totalThrust_kN = state.propulsion.totalThrust_kN;
r.perEngineThrust_kN = state.propulsion.perEngineThrust_kN;
r.WSlandingLimit_Nm2 = checks.WSlandingLimit;
if isfield(checks,'WSlandingLimitLandingWeight')
    r.WSlandingLimitLandingWeight_Nm2 = checks.WSlandingLimitLandingWeight;
end
if isfield(checks,'betaLanding')
    r.betaLanding = checks.betaLanding;
end
r.TWtakeoffReq = checks.TWtakeoffReq;
r.TWcruiseReq = checks.TWcruiseReq;
r.TWOEIReq = p.performance.TW_OEI;
r.TWactiveReq = checks.TWactiveReq;
r.landingMargin = checks.landingMargin;
r.takeoffMargin = checks.takeoffMargin;
r.thrustMargin = checks.thrustMargin;
r.cruiseMargin = checks.cruiseMargin;

end
