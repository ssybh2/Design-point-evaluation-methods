function balance = cw4_balanceModel(geom, tail, mass, p)
% Component moment balance. Stations are tied to the final geometry where needed.

wingStation = geom.LEMAC + 0.18*geom.MAC;
fuelStation = geom.LEMAC + 0.16*geom.MAC;
gearStation = geom.wingAC - 0.24;

m = [mass.fuselageSystems, mass.wingGroup, mass.empennage, mass.landingGear, ...
     mass.propulsion, mass.furnishingsOps, mass.fuel, p.payload_kg, p.crewMass_kg];

x = [p.station.fuselage_m, wingStation, p.station.empennage_m, gearStation, ...
     p.station.propulsion_m, p.station.furnishings_m, fuelStation, p.station.payload_m, p.station.crew_m];

moment = sum(m.*x);
totalMass = sum(m);
xCG = moment/totalMass;
hCG = (xCG - geom.LEMAC)/geom.MAC;
xNP = geom.LEMAC + 0.33*geom.MAC;
staticMargin = 0.33 - hCG;

balance.xCG = xCG;
balance.hCG = hCG;
balance.xNP = xNP;
balance.staticMargin = staticMargin;
balance.moment = moment;
balance.totalMass = totalMass;
balance.wingStation = wingStation;
balance.fuelStation = fuelStation;
balance.gearStation = gearStation;

end
