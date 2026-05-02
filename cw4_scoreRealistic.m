function score = cw4_scoreRealistic(state, checks, p)
% cw4_scoreRealistic
% Full-aircraft score. Lower is better.
% It combines constraint robustness, aerodynamic performance,
% real-aircraft similarity, configuration quality and size penalties.

% Helper penalties: quadratic target-window penalty.
pen = @(value,target,tol) ((value-target)./tol).^2;
shortfall = @(value,target,tol) (max(0, target-value)./tol).^2;
excess = @(value,target,tol) (max(0, value-target)./tol).^2;

%% 1. Constraint robustness
landingPen = shortfall(checks.landingMargin, p.target.landingMargin, p.target.landingMargin_tol);
takeoffPen = shortfall(checks.takeoffMargin, p.target.takeoffMargin, p.target.takeoffMargin_tol);
thrustPen = shortfall(checks.thrustMargin, p.target.thrustMargin, p.target.thrustMargin_tol);
cruisePen = shortfall(checks.cruiseMargin, p.target.cruiseMargin, p.target.cruiseMargin_tol);

constraintRobustness = 0.35*landingPen + 0.20*takeoffPen + 0.30*thrustPen + 0.15*cruisePen;

%% 2. Aerodynamic performance and lift/drag realism
LDpen = pen(state.aero.LDcruise, p.target.LDcruise, p.target.LDcruise_tol);
CD0pen = pen(state.aero.CD0, p.target.CD0, p.target.CD0_tol);
CLpen = pen(state.aero.CLcruise, p.target.CLcruise, p.target.CLcruise_tol);

aeroPerformance = 0.45*LDpen + 0.30*CD0pen + 0.25*CLpen;

%% 3. Similarity to real aircraft of the same class
MTOWpen = pen(state.mass.MTOW, p.target.MTOW_kg, p.target.MTOW_tol);
Spanpen = pen(state.geom.b, p.target.b_m, p.target.b_tol);
Spen = pen(state.geom.S, p.target.S_m2, p.target.S_tol);
Enginepen = pen(state.propulsion.perEngineThrust_kN, p.target.perEngineThrust_kN, p.target.perEngineThrust_tol);
Fuelpen = pen(state.mass.fuel, p.target.fuel_kg, p.target.fuel_tol);

realAircraftFit = 0.25*MTOWpen + 0.20*Spanpen + 0.20*Spen + 0.20*Enginepen + 0.15*Fuelpen;

%% 4. Configuration quality: CG, stability, tail and gear integration
hCGpen = pen(state.balance.hCG, p.target.hCG, p.target.hCG_tol);
SMpen = pen(state.balance.staticMargin, p.target.staticMargin, p.target.staticMargin_tol);
gearPen = pen(state.gear.CGtoMGarm, p.target.gearArm_m, p.target.gearArm_tol);
tailRatio = state.tail.totalArea/state.geom.S;
tailPen = pen(tailRatio, p.target.tailToWingArea, p.target.tailToWingArea_tol);
spanFusPen = pen(state.geom.spanFuselageRatio, p.target.spanFuselageRatio, p.target.spanFuselageRatio_tol);

configurationQuality = 0.25*hCGpen + 0.25*SMpen + 0.20*gearPen + 0.20*tailPen + 0.10*spanFusPen;

%% 5. Size penalty: only penalizes unnecessary growth beyond target values.
% This prevents the algorithm from treating tiny margins as automatically best.
sizePenalty = 0.30*excess(state.geom.S, p.target.S_m2, p.target.S_tol) + ...
              0.20*excess(state.geom.b, p.target.b_m, p.target.b_tol) + ...
              0.25*excess(state.propulsion.totalThrust_kN, p.ref.totalThrust_kN, 45) + ...
              0.15*excess(state.tail.totalArea, p.ref.tailArea_m2, 18) + ...
              0.10*excess(state.mass.MTOW, p.target.MTOW_kg, p.target.MTOW_tol);

base = p.weight.constraintRobustness*constraintRobustness + ...
       p.weight.aeroPerformance*aeroPerformance + ...
       p.weight.realAircraftFit*realAircraftFit + ...
       p.weight.configurationQuality*configurationQuality + ...
       p.weight.sizePenalty*sizePenalty;

if checks.feasible
    total = base;
else
    total = base + 1e6;
end

score.total = total;
score.constraintRobustness = constraintRobustness;
score.aeroPerformance = aeroPerformance;
score.realAircraftFit = realAircraftFit;
score.configurationQuality = configurationQuality;
score.sizePenalty = sizePenalty;

end
