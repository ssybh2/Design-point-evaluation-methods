function aero = cw4_aeroModel(mTO, WS, geom, tail, propulsion, p)
% Preliminary aerodynamic model tied to geometry and thrust installation.
% This is a transparent proxy model for design sweep ranking.

fuselageWet = pi*p.fuselage.diameter_m*p.fuselage.length_m;
wingWet = p.aero.wingWetFactor*geom.S;
tailWet = p.aero.tailWetFactor*tail.totalArea;
nacelleWet = p.aero.nacelleWetRef_m2*(max(propulsion.totalThrust_kN,1)/p.ref.totalThrust_kN)^p.aero.nacelleWetExp;
Swet = fuselageWet + wingWet + tailWet + nacelleWet;

CD0 = p.aero.Cfe*(Swet/geom.S) + p.aero.excrescenceDrag;
K = 1/(pi*p.aero.e*geom.AR);
CLcruise = p.mission.cruiseWeightFraction*WS/p.mission.qCruise;
CDcruise = CD0 + K*CLcruise^2 + p.aero.waveDragCruise;
LDcruise = CLcruise/CDcruise;

% CW4 mission fuel fraction.
% Non-cruise fractions are retained from CW1. The cruise fraction is the
% updated CW4 value used in the final mass reconciliation.
cruiseFrac = p.mission.ff_cruise;
loiterFrac = p.mission.ff_loiter;

Mff = p.mission.ff_start ...
    * p.mission.ff_taxi ...
    * p.mission.ff_takeoff ...
    * p.mission.ff_climb ...
    * cruiseFrac ...
    * loiterFrac ...
    * p.mission.ff_descent ...
    * p.mission.ff_landing;

% Ideal L/D from parabolic polar for reference.
LDmaxIdeal = 1/(2*sqrt(max(K*CD0,1e-9)));

aero.fuselageWet = fuselageWet;
aero.wingWet = wingWet;
aero.tailWet = tailWet;
aero.nacelleWet = nacelleWet;
aero.Swet = Swet;
aero.CD0 = CD0;
aero.K = K;
aero.CLcruise = CLcruise;
aero.CDcruise = CDcruise;
aero.LDcruise = LDcruise;
aero.LDmaxIdeal = LDmaxIdeal;
aero.Mff = Mff;
aero.cruiseFrac = cruiseFrac;
aero.loiterFrac = loiterFrac;

end
