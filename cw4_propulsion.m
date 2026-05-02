function prop = cw4_propulsion(TW, mTO, p)
% Installed thrust from selected thrust-to-weight ratio.

totalThrust_kN = TW*mTO*p.g/1000;
perEngineThrust_kN = totalThrust_kN/p.nEngines;

prop.TW = TW;
prop.totalThrust_kN = totalThrust_kN;
prop.perEngineThrust_kN = perEngineThrust_kN;

end
