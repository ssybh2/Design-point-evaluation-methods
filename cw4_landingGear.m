function gear = cw4_landingGear(balance, mass, p)
% Static tricycle landing gear placement and load check.

xNG = p.fuselage.noseGearStation_m;
kNose = 0.10;
xMG = (balance.xCG - kNose*xNG)/(1-kNose);

W_kN = mass.MTOW*p.g/1000;
RNG_kN = kNose*W_kN;
RMG_kN = (1-kNose)*W_kN;

gear.xNG = xNG;
gear.xMG = xMG;
gear.CGtoMGarm = xMG - balance.xCG;
gear.noseToCGarm = balance.xCG - xNG;
gear.W_kN = W_kN;
gear.RNG_kN = RNG_kN;
gear.RMG_kN = RMG_kN;
gear.noseWheelLoad_kN = RNG_kN/2;
gear.mainWheelLoad_kN = RMG_kN/4;
gear.mainSideLoad_kN = RMG_kN/2;

end
