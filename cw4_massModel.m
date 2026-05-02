function mass = cw4_massModel(mTO_current, geom, tail, propulsion, aero, p)
% cw4_massModel
% CW4 mass closure using the retained CW1 empty-weight regression and the
% updated mission fuel fraction. Component groups are retained only as a
% preliminary allocation for CG / moment-balance purposes.

%% 1. Fuel fraction with reserve
fuelFrac = (1+p.mission.reserveFraction)*(1-aero.Mff);

%% 2. Retained CW1 empty-weight regression
% m_E = a*m_TO + b
emptySlope = p.mass.emptyWeightSlope;
emptyIntercept = p.mass.emptyWeightIntercept_kg;

%% 3. Closed take-off mass
% m_TO = m_E + m_F + m_payload + m_crew
% m_F  = fuelFrac*m_TO
% m_E  = emptySlope*m_TO + emptyIntercept
den = 1 - fuelFrac - emptySlope;

if den <= 0.05
    MTOW = NaN;
    fuel = NaN;
    OEW = NaN;
else
    MTOW = (p.payload_kg + p.crewMass_kg + emptyIntercept)/den;
    fuel = fuelFrac*MTOW;
    OEW = emptySlope*MTOW + emptyIntercept;
end

baseMass = OEW + p.payload_kg + p.crewMass_kg;

%% 4. Component allocation for mass balance
% These provisional component masses are scaled so that their sum matches
% the CW1-style closed empty mass. They are used for CG allocation only,
% not as an independent component-weight derivation.
fuselage0 = p.mass.fuselageSystems_kg;
wing0 = p.mass.wingGroupRef_kg ...
    *(geom.S/p.ref.S_m2)^0.75 ...
    *(geom.b/p.ref.b_m)^0.25;
empennage0 = p.mass.empennageRef_kg ...
    *(tail.totalArea/p.ref.tailArea_m2)^0.85;
landingGear0 = p.mass.landingGearRef_kg ...
    *(max(MTOW,1)/p.ref.MTOW_kg)^0.70;
propulsion0 = p.mass.propulsionRef_kg ...
    *(propulsion.totalThrust_kN/p.ref.totalThrust_kN)^0.80;
furnishings0 = p.mass.furnishingsOps_kg;

provisionalSum = fuselage0 + wing0 + empennage0 + landingGear0 + propulsion0 + furnishings0;

if provisionalSum > 0 && ~isnan(OEW)
    scale = OEW/provisionalSum;
else
    scale = NaN;
end

fuselageSystems = fuselage0*scale;
wingGroup = wing0*scale;
empennage = empennage0*scale;
landingGear = landingGear0*scale;
propulsionMass = propulsion0*scale;
furnishingsOps = furnishings0*scale;

%% 5. Output structure
mass.fuselageSystems = fuselageSystems;
mass.wingGroup = wingGroup;
mass.empennage = empennage;
mass.landingGear = landingGear;
mass.propulsion = propulsionMass;
mass.furnishingsOps = furnishingsOps;

mass.OEW = OEW;
mass.baseMass = baseMass;
mass.MTOW = MTOW;
mass.fuel = fuel;

mass.fuelFractionWithReserve = fuelFrac;
mass.emptyWeightSlope = emptySlope;
mass.emptyWeightIntercept_kg = emptyIntercept;
mass.componentScale = scale;

end