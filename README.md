# Dynamic-System-Simulation-Portfolio
A hands-on exploration of dynamic thermal-fluid system modelling projects in Modelica/ Dymola

A collection of first-principles thermal system simulations built in Modelica / Dymola. This self-learning repository explores dynamic heat transfer, mass flow transport, and transient fluid behavior across three practical engineering loops: 
- Closed-Loop Data Center Thermal-Fluid System (In Progress)
- A 25 kW Data Center One-Way Heat Transfer
- A Closed-Loop Solar Thermal System

Project 1: Closed-Loop 25kW Data Center Thermal-Fluid System

An advanced, fully coupled dual-loop (Air & Water) dynamic data center simulation focusing on closed-loop hydraulic integration.

Objective: Building a non-singular closed-loop simulation coupling the air side with the chilled water loop.

Core Physics: Energy and mass conservation coupled across air-side and chilled water circuits, Forward enthalpy propagation preventing circular matrix singularities.

Key Components Built: ServerRacks, Fans, CRAH, PumpSkids, ControlValves, AirCooledChiller


Project 2: A 25 kW Data Center One-Way Cooling Loop

A digital twin simulation of an IT cooling circuit built to study heat transfer from server racks down to an outdoor chiller boundary.

Objective: Understand how varying fluid flow rates and valve positions affect room air and water return temperatures.

Core Physics: Lumped air heat capacity, heat exchanger effectiveness and mass/energy conservation.

Key Components Built: ServerRoom, CRAH, PumpSkid & ControlValve, AirCooledChiller


Project 3: Solar Thermal System Loop

Objective: Observe transient energy storage, fluid volume expansion, and temperature rise in a closed-loop system over time.

Key Components Built: SolarCollector, StorageTank, CirculationPump, Valve, SystemExpansionTank

Key learning takeaways:
- Applied basic mass and energy balance equations directly into Modelica code.
- Practiced structuring custom, simple components with thermal and fluid ports.
- Learned how solver settings and component parameterization impact numerical stability in Dymola.


