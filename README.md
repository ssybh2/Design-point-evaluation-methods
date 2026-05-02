# CW4 calibrated normal-geometry sweep tool v7

This version extends the calibrated v6 tool by adding an explicit constraint-graph module before the full-aircraft design sweep.

The workflow is now:

1. Regenerate the final T/W--W/S constraint graph from the current inputs.
2. Build the raw design area from the landing, take-off, cruise and OEI/climb constraints.
3. Uniformly sample the W/S--T/W search window.
4. Reject points outside the raw constraint-graph design area before running the full-aircraft iteration.
5. Run the aircraft-level feedback loop only for candidates inside the design area.
6. Rank the resulting aircraft using the calibrated full-aircraft objective score.

Main features:

- `cw4_buildConstraintGraph.m`: computes landing, take-off, cruise and OEI/climb constraint curves.
- `cw4_plotConstraintGraph.m`: plots the final constraint graph and selected point.
- `cw4_queryConstraintGraph.m`: checks whether candidate points are inside the raw design area.
- `constraint_graph_balanced.png`: report-ready matching chart with feasible design area and selected point.
- `constraint_graph_curves_balanced.csv`: traceable numerical curve data.
- `candidate_map_balanced.png`: full sweep map with infeasible points, feasible points and selected point.

The design sweep still includes the calibrated v6 updates:

- landing-weight relief with `betaLanding = 0.85`;
- expanded W/S search range from 4500 to 5400 N/m^2;
- calibrated drag proxy to keep CD0 and L/D in a realistic preliminary range;
- strengthened geometry realism targets for wing area, span, MTOW, fuel and L/D.

Run:

```matlab
run_CW4_realistic_design_sweep
```

Single point check:

```matlab
run_single_design_point_realistic
```

Outputs go to `results_calibrated_balanced`.

Important: this remains a preliminary conceptual-design tool, not a certification model. Any selected point should be described as the best candidate under the stated assumptions, constraint definitions, benchmark limits and scoring policy.


## v9 update: full-scale constraint graph
The constraint graph now uses a report-scale W/S axis from 1000 to 8000 N/m^2, rather than only the local optimisation window. The MATLAB sampling window is shown as a dashed box inside the wider matching chart. Candidate points are still filtered by the full constraint graph before the full-aircraft iteration is run.
