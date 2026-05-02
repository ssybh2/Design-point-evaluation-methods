function p = CW4_realisticConfig(mode)
% CW4_realisticConfig
% Configuration for a full-aircraft design-point sweep with real-aircraft
% benchmark checks. The default mode is 'balanced'.
%
% The code intentionally uses transparent preliminary-design models rather
% than claiming detailed certification-level performance.

if nargin < 1 || isempty(mode)
    mode = 'balanced';
end
p.mode = string(mode);

%% Mission and constants
p.g = 9.81;
p.rhoSL = 1.225;
p.kt_to_ms = 0.514444;
p.mps_to_kt = 1.94384;
p.nEngines = 2;

p.mission.range_nm = 3000;
p.mission.range_m = p.mission.range_nm * 1852;
p.mission.cruiseMach = 0.8;
p.mission.cruiseAltitude_ft = 35000;
p.mission.Vcruise = 237.0;       % m/s, representative at M0.8 and 35,000 ft
p.mission.rhoCruise = 0.3796;     % kg/m^3, ISA close to 35,000 ft
p.mission.qCruise = 0.5*p.mission.rhoCruise*p.mission.Vcruise^2;
p.mission.TSFC = 12.0e-6;        % kg/(N*s), calibrated preliminary jet TSFC
p.mission.loiter_s = 3600;
p.mission.reserveFraction = 0.05;
p.mission.cruiseWeightFraction = 0.86; % average cruise weight / MTOW used in cruise CL estimate
% CW4 mass-closure fuel-fraction inputs.
% Non-cruise fractions are retained from CW1; cruise fraction is updated
% from the final aerodynamic closure used in CW4.
p.mission.ff_start = 0.990;
p.mission.ff_taxi = 0.990;
p.mission.ff_takeoff = 0.995;
p.mission.ff_climb = 0.980;
p.mission.ff_cruise = 0.8483;
p.mission.ff_loiter = 0.971;
p.mission.ff_descent = 0.990;
p.mission.ff_landing = 0.992;
%% Top-level aircraft requirements
p.req.passengers = 186;
p.req.crew = 8;
p.req.massPerPassenger_kg = 120;
p.req.massPerCrew_kg = 120;
p.req.TOFL_m = 1700;
p.req.LFL_m = 1500;

% Landing design check uses landing weight rather than MTOW.
% betaLanding = W_L/W_TO converts the landing constraint back onto the
% take-off wing-loading axis. This prevents artificial wing oversizing.
p.landing.betaLanding = 0.85;
p.landing.applyLandingWeightRelief = true;

p.payload_kg = p.req.passengers*p.req.massPerPassenger_kg;
p.crewMass_kg = p.req.crew*p.req.massPerCrew_kg;

%% Grid definition: constraint-area sampling
% The design-point candidates are now generated from the non-rectangular
% constraint-graph feasible area, not from a manually chosen local rectangle.
% For each W/S station, the code computes the active lower thrust envelope
% max(T/W_takeoff, T/W_cruise, T/W_OEI) and samples only T/W values above it
% and left of the landing-limit line.
p.grid.samplingMode = 'constraint_area';
p.grid.WS_values = 1000:25:5600;       % N/m^2, covers the raw design area up to the landing limit
p.grid.TW_step = 0.0025;               % dimensionless T/W increment inside the design area
p.grid.TW_upper = 0.700;               % upper plotted design-area limit; not a physical optimum target
p.grid.TW_lower_floor = 0.000;         % lower floor before applying the active constraint envelope

% Compatibility vector used only by legacy plotting / report code. It does
% not define a rectangular candidate set when samplingMode='constraint_area'.
p.grid.TW_values = 0.285:p.grid.TW_step:p.grid.TW_upper;

%% Fixed / baseline geometry
p.fuselage.length_m = 47.60;
p.fuselage.diameter_m = 4.00;
p.fuselage.noseGearStation_m = 0.10*p.fuselage.length_m;
p.fuselage.horizontalTailAC_m = 45.00;
p.fuselage.verticalTailAC_m = 44.50;

p.wing.AR = 8.5;  % calibrated to reduce span while remaining inside the 7--11 jet-transport range
p.wing.taper = 0.325;
p.wing.target_hCG = 0.20;
p.wing.minLEMAC_m = 19.0;
p.wing.maxLEMAC_m = 22.5;

p.tail.VH = 1.00;
p.tail.VV = 0.08;
p.tail.ARH = 4.5;
p.tail.ARV = 1.5;

p.highlift.CLmaxTO = 2.4;
p.highlift.CLmaxL = 3.0;

p.performance.TW_OEI = 0.285;          % preliminary OEI/climb target
p.performance.thrustLapseCruise = 0.291; % used to compare cruise req. on SL T/W axis

%% Reference values from the updated CW4 mass closure
% These are reference / target scaling values, not independent outputs.
p.ref.MTOW_kg = 90606;
p.ref.OEW_kg = 45740;
p.ref.fuel_kg = 21586;
p.ref.S_m2 = p.ref.MTOW_kg*p.g/5000;       % 177.77 m^2 if W/S = 5000
p.ref.b_m = sqrt(p.wing.AR*p.ref.S_m2);    % 38.87 m if AR = 8.5
p.ref.MAC_m = 4.97;
p.ref.totalThrust_kN = 0.335*p.ref.MTOW_kg*p.g/1000;
p.ref.perEngineThrust_kN = p.ref.totalThrust_kN/2;
p.ref.tailArea_m2 = 38.5 + 24.6;           % approximate updated tail-area scale
p.ref.CD0 = 0.0175;
p.ref.LD = 16.4;

%% Component mass references used by the preliminary build-up
p.mass.fuselageSystems_kg = 15300;
p.mass.wingGroupRef_kg = 10850;
p.mass.empennageRef_kg = 2750;
p.mass.landingGearRef_kg = 3700;
p.mass.propulsionRef_kg = 9300;
p.mass.furnishingsOps_kg = 3030;
% CW1 empty-weight regression retained for CW4 mass closure:
% m_E = a*m_TO + b
p.mass.emptyWeightSlope = 0.3056;
p.mass.emptyWeightIntercept_kg = 18050.0932;
%% Component station model
p.station.fuselage_m = 21.50;
p.station.empennage_m = 43.50;
p.station.propulsion_m = 18.50;
p.station.furnishings_m = 20.50;
p.station.payload_m = 21.80;
p.station.crew_m = 14.00;

%% Iteration controls
p.iter.maxIter = 80;
p.iter.relTolMass = 2e-4;
p.iter.absTolCG_m = 2e-3;
p.iter.LEMACrelax = 0.45;

%% Aerodynamic preliminary model
p.aero.Cfe = 0.00255;  % calibrated wetted-area proxy; keeps CD0 near the report's 0.019 value
p.aero.excrescenceDrag = 0.0008;
p.aero.waveDragCruise = 0.0001;
p.aero.e = 0.85;
p.aero.wingWetFactor = 2.00;
p.aero.tailWetFactor = 2.00;
p.aero.nacelleWetRef_m2 = 55.0;
p.aero.nacelleWetExp = 0.65;

%% Constraint graph / matching-chart settings
% These settings regenerate the final constraint graph before the aircraft-level
% sweep.  The constraint graph is intentionally wider than the MATLAB search
% window so that the full matching-chart shape is visible in the report.
% Candidate points are still taken from p.grid.WS_values and p.grid.TW_values,
% then filtered using the full constraint graph.
p.constraint.WS_min = 1000;            % report-scale matching-chart axis
p.constraint.WS_max = 8000;            % report-scale matching-chart axis
p.constraint.WS_step = 10;             % smooth curve resolution for plots and interpolation
p.constraint.TW_plot_min = 0.05;       % show cruise curve and low-thrust region
p.constraint.TW_plot_max = 0.70;       % show high take-off / low-WS cruise requirements
p.constraint.TW_step = p.grid.TW_step;
p.constraint.sampleWS_min = min(p.grid.WS_values);
p.constraint.sampleWS_max = max(p.grid.WS_values);
p.constraint.sampleTW_min = min(p.grid.TW_values);
p.constraint.sampleTW_max = max(p.grid.TW_values);
% Fixed aerodynamic inputs used by the constraint graph. The full-aircraft
% sweep still computes candidate-specific CD0 and L/D later.
p.constraint.CD0 = 0.0175;
p.constraint.e = p.aero.e;
p.constraint.AR = p.wing.AR;
p.constraint.K = 1/(pi*p.constraint.e*p.constraint.AR);

%% Margin and real-aircraft benchmark rules
% Hard reject values: if violated, the candidate is infeasible.
p.rules.minLandingMargin = 0.04;
p.rules.minTakeoffMargin = 0.10;
p.rules.minThrustMargin  = 0.12;
p.rules.minCruiseMargin  = 0.08;
p.rules.minStaticMargin  = 0.05;
p.rules.maxStaticMargin  = 0.18;
p.rules.minCGmac = 0.10;
p.rules.maxCGmac = 0.30;

% Real-aircraft benchmark envelope for a 186-seat, Mach 0.8, 3000 nm class
% twin-underwing narrow-body / long narrow-body aircraft.
p.real.minMTOW_kg = 80000;
p.real.maxMTOW_kg = 98000;
p.real.minSpan_m = 34.0;
p.real.maxSpan_m = 41.5;
p.real.minWingArea_m2 = 155.0;
p.real.maxWingArea_m2 = 190.0;
p.real.minPerEngineThrust_kN = 120.0;
p.real.maxPerEngineThrust_kN = 165.0;
p.real.minLDcruise = 15.8;
p.real.maxLDcruise = 19.5;
p.real.minTipChord_m = 1.80;
p.real.maxCD0 = 0.024;
p.real.minCD0 = 0.016;
p.real.maxTailToWingArea = 0.55;
p.real.minTailToWingArea = 0.25;
p.real.minGearArm_m = 1.2;
p.real.maxGearArm_m = 2.8;

%% Target values for scoring, not hard constraints
p.target.MTOW_kg = 90606;
p.target.MTOW_tol = 6000;
p.target.fuel_kg = 21586;
p.target.fuel_tol = 5000;
p.target.S_m2 = 177.8;
p.target.S_tol = 18.0;
p.target.b_m = 38.9;
p.target.b_tol = 2.5;
p.target.spanFuselageRatio = 0.86;
p.target.spanFuselageRatio_tol = 0.10;
p.target.perEngineThrust_kN = 148.9;
p.target.perEngineThrust_tol = 18.0;
p.target.LDcruise = 16.4;
p.target.LDcruise_tol = 1.2;
p.target.CD0 = 0.019;
p.target.CD0_tol = 0.003;
p.target.CLcruise = 0.42;
p.target.CLcruise_tol = 0.08;
p.target.hCG = 0.20;
p.target.hCG_tol = 0.06;
p.target.staticMargin = 0.11;
p.target.staticMargin_tol = 0.05;
p.target.gearArm_m = 1.90;
p.target.gearArm_tol = 0.55;
p.target.tailToWingArea = 0.36;
p.target.tailToWingArea_tol = 0.12;
p.target.landingMargin = 0.05;
p.target.landingMargin_tol = 0.03;
p.target.takeoffMargin = 0.12;
p.target.takeoffMargin_tol = 0.06;
p.target.thrustMargin = 0.13;
p.target.thrustMargin_tol = 0.05;
p.target.cruiseMargin = 0.10;
p.target.cruiseMargin_tol = 0.08;

%% Objective-function weights by design philosophy
switch lower(string(mode))
    case "minimum_size"
        p.weight.constraintRobustness = 0.16;
        p.weight.aeroPerformance      = 0.16;
        p.weight.realAircraftFit      = 0.20;
        p.weight.configurationQuality = 0.14;
        p.weight.sizePenalty          = 0.34;
    case "robust"
        p.weight.constraintRobustness = 0.34;
        p.weight.aeroPerformance      = 0.20;
        p.weight.realAircraftFit      = 0.22;
        p.weight.configurationQuality = 0.16;
        p.weight.sizePenalty          = 0.08;
    otherwise % balanced
        p.weight.constraintRobustness = 0.24;
        p.weight.aeroPerformance      = 0.24;
        p.weight.realAircraftFit      = 0.28;
        p.weight.configurationQuality = 0.14;
        p.weight.sizePenalty          = 0.10;
end

end
