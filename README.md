# AERO1003 CW4 Design Point Evaluation Tool

MATLAB-based conceptual aircraft design-point evaluation tool for **AERO1003 Coursework 4**.

This repository contains a constraint-area sampling and full-aircraft evaluation workflow used to select a final design point for a **186-seat medium-haul civil transport aircraft**. The tool rebuilds the updated `T/W`--`W/S` constraint graph, searches the feasible design area, evaluates candidate aircraft configurations, and ranks the surviving candidates using a balanced objective score.

> This is a **preliminary conceptual-design tool**.  
> It is not a certification-level performance, stability, structural, or engine-performance model.

---

## What this repository is for

The Coursework 4 design process required the aircraft to be re-iterated after the wing loading, aircraft mass, drag polar, tail sizing, centre-of-gravity position, and landing-gear assumptions had been updated.

The original CW2 design point no longer represented the updated aircraft consistently. This repository was therefore created to make the final design-point selection more systematic and repeatable.

The tool helps answer three questions:

1. Which `W/S` and `T/W` combinations are inside the updated feasible design region?
2. Which feasible points still produce realistic aircraft-level mass, geometry, CG, tail, and landing-gear results?
3. Which candidate gives the best overall preliminary aircraft-level compromise?

---

## Key result figures

### 1. CW2 and CW4 constraint graph overlay

<p align="center">
  <img src="figures/figure/combined.png" alt="CW2 and CW4 constraint graph overlay" width="900">
</p>

This figure compares the earlier **CW2 constraint graph** with the updated **CW4 constraint graph**. It shows why the constraint analysis had to be re-run. The original CW2 point used a much lower wing loading, while the updated CW4 design space moved toward a higher but still landing-limited wing loading.

The important message from this figure is that the final CW4 design point should not simply reuse the old CW2 point. The aircraft geometry, mass and aerodynamic assumptions changed, so the matching chart also had to be updated.

---

### 2. Constraint-filtered full-aircraft design sweep

<p align="center">
  <img src="figures/figure/design%20area.png" alt="Constraint-filtered full-aircraft design sweep" width="900">
</p>

This figure shows the candidate search inside the updated constraint-design region. The grey region represents the raw constraint-design area. Candidate points are then filtered using the full-aircraft sizing model, benchmark limits, configuration checks, and objective-score logic.

The figure is important because it shows that the selected point was not chosen only by eye from the constraint graph. Instead, candidate points were tested as complete preliminary aircraft configurations before the final point was selected.

---

### 3. Objective score map near the selected design point

<p align="center">
  <img src="figures/figure/detail.png" alt="Objective score map near the selected design point" width="900">
</p>

This figure zooms into the useful part of the feasible design region and shows how the objective score changes near the selected design point. Lower score values are better. The lowest-score region is concentrated close to:

```text
W/S = 5050 N/m^2
T/W = 0.335
```

For the final reported design, this was rounded slightly to:

```text
W/S = 5000 N/m^2
T/W = 0.335
```

This rounded value keeps the design close to the MATLAB score-minimum point while giving a slightly more conservative landing margin.

---

## Final design point

The MATLAB sweep identified the local score-minimum candidate as:

```text
Score-minimum candidate:
W/S = 5050 N/m^2
T/W = 0.335
```

The final reported point was selected as:

```text
Final reported design point:
W/S = 5000 N/m^2
T/W = 0.335
```

This final point was used because it remains very close to the numerical optimum but gives a cleaner and slightly more conservative value for report presentation.

Key reported margins at the final point are:

| Quantity | Value |
|---|---:|
| Landing margin | approximately 10.4% |
| Active thrust requirement | approximately 0.293 |
| Thrust margin | approximately 14.4% |

---

## Overall workflow

The current **v9** workflow is:

1. Build the updated `T/W`--`W/S` constraint graph.
2. Define the raw feasible design area using landing, take-off, cruise, and OEI/climb constraints.
3. Generate candidate design points inside the feasible area.
4. Reject points outside the raw constraint-design region.
5. Run an aircraft-level sizing loop for each remaining candidate.
6. Check each candidate against constraint, benchmark, and configuration rules.
7. Rank feasible candidates using a calibrated weighted objective score.
8. Export report-ready figures, CSV tables, and MATLAB result files.

---

## How the selection method works

The repository does not only draw a matching chart. It also connects the constraint graph to a simplified aircraft-level sizing model.

Each candidate point is evaluated through the following logic:

| Step | Purpose |
|---|---|
| Constraint filtering | Removes points outside the updated matching-chart design area. |
| Aircraft sizing | Estimates wing size, thrust, mass, tail sizing, balance, and landing-gear layout for each candidate. |
| Configuration checking | Rejects candidates that produce unrealistic geometry, CG, tail, gear, or benchmark results. |
| Objective scoring | Ranks the surviving candidates using a balanced score. |
| Final selection | Chooses a realistic point near the lowest-score region, then rounds it for report use. |

---

## Objective score meaning

The objective score is a weighted engineering judgement score. It is not a physical aircraft performance coefficient. A lower score means that the candidate is more attractive under the selected preliminary-design assumptions.

The score considers five groups of behaviour:

| Score component | What it represents |
|---|---|
| Constraint quality | Whether the candidate has enough landing, take-off, cruise, and thrust margin. |
| Aerodynamic quality | Whether the candidate gives reasonable cruise lift coefficient, drag level, and lift-to-drag behaviour. |
| Benchmark realism | Whether mass, wing span, wing area, fuel mass, and thrust remain comparable to similar narrow-body aircraft. |
| Configuration quality | Whether CG, static margin, tail area, landing-gear arm, and span-to-fuselage integration remain reasonable. |
| Size efficiency | Whether the design avoids unnecessary growth in wing area, span, thrust, tail size, or MTOW. |

The default `balanced` mode gives the strongest priority to benchmark realism, constraint margin, and aerodynamic quality, while still discouraging unnecessary aircraft growth.

---

## Repository structure

```text
.
├── CW4_realisticConfig.m
├── run_CW4_realistic_design_sweep.m
├── run_single_design_point_realistic.m
├── run_CW4_compare_realistic_modes.m
│
├── cw4_buildConstraintGraph.m
├── cw4_queryConstraintGraph.m
├── cw4_generateConstraintAreaCandidates.m
├── cw4_plotConstraintGraph.m
├── cw4_constraintGraphTable.m
│
├── cw4_aircraftSizingLoop.m
├── cw4_evaluateCandidateRealistic.m
├── cw4_constraintChecksRealistic.m
├── cw4_scoreRealistic.m
│
├── cw4_aeroModel.m
├── cw4_massModel.m
├── cw4_wingGeometry.m
├── cw4_tailSizing.m
├── cw4_balanceModel.m
├── cw4_landingGear.m
├── cw4_propulsion.m
│
├── cw4_exportResultsRealistic.m
├── cw4_makePlotsRealistic.m
├── cw4_resultStructTemplate.m
├── cw4_forceSameFields.m
│
├── A_R.m
├── plot_constraint_graph_CW2_CW4_overlay.m
│
├── figures/
│   └── figure/
│       ├── combined.png
│       ├── design area.png
│       └── detail.png
│
└── results_calibrated_balanced/
```

---

## Main MATLAB files

| File | Purpose |
|---|---|
| `CW4_realisticConfig.m` | Central configuration file for mission requirements, constraint assumptions, benchmark limits, scoring targets, and objective weights. |
| `run_CW4_realistic_design_sweep.m` | Main script for the default balanced-mode design sweep. |
| `run_single_design_point_realistic.m` | Checks one specified design point. The current final point is `W/S = 5000 N/m^2`, `T/W = 0.335`. |
| `run_CW4_compare_realistic_modes.m` | Compares the `minimum_size`, `balanced`, and `robust` design philosophies. |
| `cw4_buildConstraintGraph.m` | Builds the landing, take-off, cruise, OEI/climb, and active-envelope constraint curves. |
| `cw4_generateConstraintAreaCandidates.m` | Samples candidate points inside the non-rectangular raw constraint-design area. |
| `cw4_queryConstraintGraph.m` | Checks whether a candidate point lies inside the raw constraint area. |
| `cw4_aircraftSizingLoop.m` | Runs the mass, geometry, CG, tail, and gear closure loop. |
| `cw4_evaluateCandidateRealistic.m` | Evaluates one candidate and returns geometry, mass, performance, balance, gear, margin, and score data. |
| `cw4_scoreRealistic.m` | Computes the weighted aircraft-level objective score. |
| `cw4_exportResultsRealistic.m` | Exports CSV tables, figures, and MATLAB result files. |
| `cw4_makePlotsRealistic.m` | Generates report-ready candidate maps and objective score maps. |

---

## Quick start

### 1. Open MATLAB

Set the MATLAB current folder to the repository root.

### 2. Run the default balanced sweep

```matlab
run_CW4_realistic_design_sweep
```

This script will:

- rebuild the updated constraint graph;
- generate candidate points inside the feasible design area;
- run the aircraft-level sizing loop;
- score feasible candidates;
- export result tables and plots.

Outputs are written to:

```text
results_calibrated_balanced/
```

---

### 3. Check the final design point

```matlab
run_single_design_point_realistic
```

By default, this checks:

```matlab
WS = 5000;     % N/m^2
TW = 0.335;    % dimensionless
```

---

### 4. Compare design philosophies

```matlab
run_CW4_compare_realistic_modes
```

This compares:

```text
minimum_size
balanced
robust
```

and writes:

```text
realistic_mode_comparison.csv
```

---

## Output files

The main sweep writes its results to:

```text
results_calibrated_balanced/
```

Typical outputs include:

| Output file | Description |
|---|---|
| `constraint_graph_balanced.png` | Updated matching chart with feasible design area and selected point. |
| `constraint_graph_curves_balanced.csv` | Numerical data for the constraint curves and active envelope. |
| `candidate_map_balanced.png` | Candidate map showing feasible, infeasible, and selected points. |
| `objective_score_map_balanced.png` | Objective score distribution inside the feasible design area. |
| `top10_normalized_outcomes_balanced.png` | Comparison of normalized outcomes for top candidates. |
| `all_candidates_balanced.csv` | Full candidate table. |
| `feasible_candidates_balanced.csv` | Feasible candidate table sorted by score. |
| `top20_candidates_balanced.csv` | Top 20 candidates from the feasible set. |
| `report_top_candidates_summary_balanced.csv` | Compact report-ready summary table. |
| `rejection_summary_balanced.csv` | Counts of candidate rejection reasons. |
| `CW4_realistic_results_balanced.mat` | MATLAB result archive containing tables, config, and constraint graph data. |

---

## Design modes

The configuration file supports three scoring philosophies:

| Mode | Purpose |
|---|---|
| `balanced` | Default mode. Balances constraint robustness, aerodynamic performance, aircraft realism, configuration quality, and size. |
| `minimum_size` | Gives stronger weight to size reduction. |
| `robust` | Gives stronger weight to constraint margins and robustness. |

The mode is selected in:

```matlab
CW4_realisticConfig(mode)
```

Example:

```matlab
p = CW4_realisticConfig('balanced');
```

---

## Current v9 update

The v9 version uses a full-scale report matching chart covering:

```text
1000 <= W/S <= 8000 N/m^2
```

The MATLAB candidate sampling range is still focused near the useful design region, but the plotted constraint graph shows the wider aircraft-design context.

Candidate points are filtered using the full constraint graph before the aircraft-level sizing loop is run.

---

## Important assumptions

This tool uses transparent preliminary-design assumptions, including:

- landing weight relief with `betaLanding = 0.85`;
- fixed high-lift targets with `CLmaxTO = 2.4` and `CLmaxL = 3.0`;
- fixed chart-level drag coefficient with `CD0 = 0.0175`;
- aspect ratio `AR = 8.5`;
- Oswald efficiency factor `e = 0.85`;
- preliminary OEI/climb target `T/W = 0.285`;
- cruise thrust-lapse factor `alpha_lap = 0.291`;
- benchmark limits based on comparable 186-seat, Mach 0.8, 3000 nm class narrow-body aircraft.

These assumptions are suitable for conceptual design comparison, but they should not be interpreted as certified aircraft performance data.

---

## Limitations

This tool does **not** perform:

- CFD or wind-tunnel aerodynamic validation;
- detailed high-lift system design;
- certification-level take-off or landing performance calculation;
- full FAR/CS-25 climb-gradient analysis;
- detailed structural sizing;
- detailed engine deck modelling;
- detailed landing-gear tyre, brake, oleo, and retraction design;
- full longitudinal, lateral, or directional stability analysis.

The selected point should therefore be described as the best preliminary candidate under the stated assumptions, constraint definitions, benchmark limits, and scoring policy.

---

## Suggested report wording

A concise report description of this repository is:

> A group-developed MATLAB design-point evaluation method was used after the updated constraint graph had been generated. The code sampled candidate `W/S`--`T/W` points inside the updated feasible region, rebuilt each candidate as an aircraft-level sizing case, rejected candidates that failed the constraint, benchmark, or configuration checks, and ranked the remaining candidates using a weighted objective score.

---

## Author

**Group 7**  
AERO1003 Aircraft Design Project  
Coursework 4
