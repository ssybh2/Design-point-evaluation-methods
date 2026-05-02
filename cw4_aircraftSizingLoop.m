function state = cw4_aircraftSizingLoop(WS, TW, p)
% cw4_aircraftSizingLoop
% Full preliminary aircraft feedback loop driven by W/S and T/W.

mTO = p.ref.MTOW_kg;
LEMAC = 21.00;
xCG_old = 21.97;

converged = false;
lastRelMass = Inf;
lastAbsCG = Inf;

for it = 1:p.iter.maxIter
    geom = cw4_wingGeometry(mTO, WS, LEMAC, p);
    tail = cw4_tailSizing(geom, p);
    propulsion = cw4_propulsion(TW, mTO, p);
    aero = cw4_aeroModel(mTO, WS, geom, tail, propulsion, p);
    mass = cw4_massModel(mTO, geom, tail, propulsion, aero, p);
    balance = cw4_balanceModel(geom, tail, mass, p);
    gear = cw4_landingGear(balance, mass, p);

    % Update MTOW explicitly from mass model
    mTO_new = mass.MTOW;

    % Reposition LEMAC to keep nominal CG close to target MAC fraction.
    LEMAC_target = balance.xCG - p.wing.target_hCG*geom.MAC;
    LEMAC_target = min(max(LEMAC_target, p.wing.minLEMAC_m), p.wing.maxLEMAC_m);
    LEMAC_new = (1-p.iter.LEMACrelax)*LEMAC + p.iter.LEMACrelax*LEMAC_target;

    lastRelMass = abs(mTO_new - mTO)/max(mTO,1);
    lastAbsCG = abs(balance.xCG - xCG_old);

    mTO = mTO_new;
    LEMAC = LEMAC_new;
    xCG_old = balance.xCG;

    if lastRelMass < p.iter.relTolMass && lastAbsCG < p.iter.absTolCG_m
        converged = true;
        break;
    end
end

% Recompute one final time using converged values.
geom = cw4_wingGeometry(mTO, WS, LEMAC, p);
tail = cw4_tailSizing(geom, p);
propulsion = cw4_propulsion(TW, mTO, p);
aero = cw4_aeroModel(mTO, WS, geom, tail, propulsion, p);
mass = cw4_massModel(mTO, geom, tail, propulsion, aero, p);
balance = cw4_balanceModel(geom, tail, mass, p);
gear = cw4_landingGear(balance, mass, p);

state.geom = geom;
state.tail = tail;
state.propulsion = propulsion;
state.aero = aero;
state.mass = mass;
state.balance = balance;
state.gear = gear;
state.converged = converged;
state.iterations = it;
state.lastRelMass = lastRelMass;
state.lastAbsCG = lastAbsCG;

end
