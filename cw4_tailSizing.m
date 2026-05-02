function tail = cw4_tailSizing(geom, p)
% Tail-volume based tail resizing.

lH = p.fuselage.horizontalTailAC_m - geom.wingAC;
lV = p.fuselage.verticalTailAC_m - geom.wingAC;

% Avoid invalid negative arms if a user changes geometry badly.
lH = max(lH, 5.0);
lV = max(lV, 5.0);

SH = p.tail.VH*geom.MAC*geom.S/lH;
SV = p.tail.VV*geom.b*geom.S/lV;

bH = sqrt(p.tail.ARH*SH);
bV = sqrt(p.tail.ARV*SV);

tail.lH = lH;
tail.lV = lV;
tail.SH = SH;
tail.SV = SV;
tail.totalArea = SH + SV;
tail.bH = bH;
tail.bV = bV;

end
