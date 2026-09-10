# Dynamic-System-Simulation-Portfolio
A hands-on exploration of dynamic thermal-fluid system modelling projects in Modelica/ Dymola

A collection of first-principles thermal system simulations built in Modelica / Dymola. This self-learning repository explores dynamic heat transfer, mass flow transport, and transient fluid behavior across two practical engineering loops: - A 25 kW Data Center Cooling Loop - A Closed-Loop Solar Thermal System


Project 1: A 25 kW Data Center One-Way Cooling Loop

A digital twin simulation of an IT cooling circuit built to study heat transfer from server racks down to an outdoor chiller boundary.

Objective: Understand how varying fluid flow rates and valve positions affect room air and water return temperatures.

Core Physics: Lumped air heat capacity, heat exchanger effectiveness and mass/energy conservation.

Key Components Built: ServerRoom, CRAH, PumpSkid & ControlValve, AirCooledChiller


Project 2: Solar Thermal System Loop

Objective: Observe transient energy storage, fluid volume expansion, and temperature rise in a closed-loop system over time.

Key Components Built: SolarCollector, StorageTank, CirculationPump, Valve, SystemExpansionTank

Key learning takeaways:
- Applied basic mass and energy balance equations directly into Modelica code.
- Practiced structuring custom, simple components with thermal and fluid ports.
- Learned how solver settings and component parameterization impact numerical stability in Dymola.


