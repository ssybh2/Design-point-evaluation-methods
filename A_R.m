%% AR_tradeoff_Group7.m
% Aspect-ratio trade-off for Group 7 final aircraft-level iteration

clear; clc; close all;

%% 1. Fixed aircraft inputs
g       = 9.81;              % m/s^2
mTO     = 88546;             % kg, final iterated take-off mass
WTO     = mTO * g;           % N
WS      = 5000;              % N/m^2, selected final wing loading
S       = WTO / WS;          % m^2, wing reference area

% Cruise condition
rho     = 0.3796;            % kg/m^3, ISA density near 35,000 ft
V       = 237.3;             % m/s, approximate Mach 0.8 at 35,000 ft
q       = 0.5 * rho * V^2;   % dynamic pressure

% Aerodynamic assumptions
CD0     = 0.0175;            % final preliminary zero-lift drag coefficient
e       = 0.85;              % representative Oswald efficiency factor
lambda  = 0.325;             % taper ratio retained from wing design

% Constraint values
TW_final = 0.335;            % selected final thrust-to-weight ratio
TW_OEI   = 0.285;            % OEI / climb requirement
STO      = 1700;             % m
CLmaxTO  = 2.4;              % take-off high-lift target
alpha_lap = 0.291;           % thrust lapse factor

%% 2. AR sweep range
% For the final local iteration, use 8.0 to 9.0.
% This checks whether reducing from the inherited AR=9.0 is worthwhile.
AR = (8.0:0.01:9.0)';

%% 3. Geometry calculation
b  = sqrt(AR .* S);                                      % span
cr = 2*S ./ (b .* (1 + lambda));                         % root chord
ct = lambda .* cr;                                       % tip chord
MAC = (2/3).*cr.*((1 + lambda + lambda^2)/(1 + lambda)); % mean aerodynamic chord

%% 4. Drag and cruise efficiency
K  = 1 ./ (pi .* e .* AR);       % induced-drag factor
CL = WS / q;                     % cruise lift coefficient, because CL = (W/S)/q
CD = CD0 + K .* CL.^2;           % drag polar
LD = CL ./ CD;                   % lift-to-drag ratio

% Cruise thrust-to-weight requirement, scaled by thrust lapse
TW_cruise = (CD ./ CL) ./ alpha_lap;

% Take-off thrust-to-weight requirement
TW_TO = 0.239 * WS / (STO * CLmaxTO);

% Active thrust requirement
TW_req = max([TW_TO*ones(size(AR)), TW_cruise, TW_OEI*ones(size(AR))], [], 2);

% Thrust margin at each AR
TW_margin = (TW_final - TW_req) ./ TW_req;

%% 5. Structural and size proxies
% First-order wing-root bending moment proxy:
% total lift WTO, each half wing carries WTO/2, resultant roughly at b/4
Mroot = WTO .* b / 8;     % N m

% Wing structural weight proxy.
% This is not a final wing-weight formula; it is only a normalized preliminary penalty.
Wwing_proxy = (Mroot ./ Mroot(AR == 8.5)).^0.6;

%% 6. Normalize penalties
% Lower penalty is better.
P_aero   = normalize01(1 ./ LD);      % lower 1/(L/D) is better
P_span   = normalize01(b);            % lower span is better
P_struct = normalize01(Mroot);        % lower root bending moment is better
P_TW     = normalize01(TW_req);       % lower required T/W is better

%% 7. Weighted objective score
% Balanced medium-haul transport:
% 50% aerodynamic/fuel efficiency, 25% span, 25% structure.
w_aero   = 0.50;
w_span   = 0.25;
w_struct = 0.25;
w_TW     = 0.00;

Score = w_aero*P_aero + w_span*P_span + w_struct*P_struct + w_TW*P_TW;

% Optional feasibility check:
% Require positive thrust margin. Add more constraints here if needed.
feasible = TW_margin > 0;

Score(~feasible) = inf;

%% 8. Select best AR
[bestScore, idx] = min(Score);

AR_best      = AR(idx);
b_best       = b(idx);
K_best       = K(idx);
LD_best      = LD(idx);
Mroot_best   = Mroot(idx);
TWcr_best    = TW_cruise(idx);
TWreq_best   = TW_req(idx);
margin_best  = TW_margin(idx);

fprintf('\n===== AR Trade-off Result =====\n');
fprintf('Best AR              = %.2f\n', AR_best);
fprintf('Wing area S          = %.2f m^2\n', S);
fprintf('Span b               = %.2f m\n', b_best);
fprintf('MAC                  = %.2f m\n', MAC(idx));
fprintf('Induced drag factor K= %.5f\n', K_best);
fprintf('Cruise L/D           = %.2f\n', LD_best);
fprintf('Cruise T/W required  = %.3f\n', TWcr_best);
fprintf('Active T/W required  = %.3f\n', TWreq_best);
fprintf('T/W margin           = %.1f %%\n', margin_best*100);
fprintf('Root bending proxy   = %.2f MN m\n', Mroot_best/1e6);
fprintf('Objective score      = %.4f\n', bestScore);

%% 9. Output table for report
T = table(AR, b, cr, ct, MAC, K, LD, TW_cruise, TW_req, TW_margin, Mroot/1e6, Score, ...
    'VariableNames', {'AR','Span_m','RootChord_m','TipChord_m','MAC_m', ...
    'K','L_over_D','TW_cruise','TW_req','TW_margin','Mroot_MNm','Score'});

writetable(T, 'AR_tradeoff_results.csv');

%% 10. Plot results
figure('Color','w');
tiledlayout(2,2);

nexttile;
plot(AR, b, 'LineWidth', 1.5); hold on;
xline(AR_best, '--', 'Best AR');
xlabel('Aspect ratio AR');
ylabel('Span b (m)');
grid on;

nexttile;
plot(AR, K, 'LineWidth', 1.5); hold on;
xline(AR_best, '--', 'Best AR');
xlabel('Aspect ratio AR');
ylabel('Induced-drag factor K');
grid on;

nexttile;
plot(AR, LD, 'LineWidth', 1.5); hold on;
xline(AR_best, '--', 'Best AR');
xlabel('Aspect ratio AR');
ylabel('Cruise L/D');
grid on;

nexttile;
plot(AR, Score, 'LineWidth', 1.5); hold on;
xline(AR_best, '--', 'Best AR');
xlabel('Aspect ratio AR');
ylabel('Objective score J');
grid on;

exportgraphics(gcf, 'AR_tradeoff_plot.png', 'Resolution', 300);

%% Local function
function y = normalize01(x)
    y = (x - min(x)) ./ (max(x) - min(x) + eps);
end