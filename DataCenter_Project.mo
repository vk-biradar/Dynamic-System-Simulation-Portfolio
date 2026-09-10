within ;
package DataCenter_Project

  connector Heatconnector
    flow Modelica.Units.SI.HeatFlowRate Qflow;
         Modelica.Units.SI.Temperature T;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Ellipse(
            extent={{-80,80},{80,-80}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}),
                                           Diagram(coordinateSystem(
            preserveAspectRatio=false)));
  end Heatconnector;

  model ServerRacks_HeatSource

    parameter Real Q_room = 25e3;   // total heat dissipation W
    parameter Real Cp_air = 1e3;    // specific heat capacity of air J/(kg.K)
    parameter Real d_air = 1.2;     // density of air kg/m3
    parameter Real V_room = 50;     // volume of the room m3

    Modelica.Units.SI.Temperature T_room( start = 297.15, fixed=true);
          // Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b port_air;      // Air heat output port

    Heatconnector port_out annotation (Placement(transformation(extent={{50,42},{70,
              62}}), iconTransformation(extent={{50,42},{70,62}})));

  equation

      V_room * d_air * Cp_air * der(T_room) = Q_room + port_out.Qflow;          // energy balance = heatin - heatout
      port_out.T = T_room;                                                      // set port temp to room air temp

  // initial equation
     // T_room = 273.15 + 22;                         // celsius conversion

    annotation (

                Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Rectangle(
            extent={{-60,80},{60,-80}},
            lineColor={0,0,0}),
          Rectangle(extent={{-40,60},{40,50}}, lineColor={0,0,0},
            fillPattern=FillPattern.Solid,
            fillColor={255,255,255}),
          Line(points={{-18,36}}, color={0,0,0}),
          Rectangle(extent={{-40,26},{40,16}}, lineColor={0,0,0},
            fillPattern=FillPattern.Solid,
            fillColor={255,255,255}),
          Rectangle(extent={{-40,-14},{40,-24}},
                                               lineColor={0,0,0},
            fillPattern=FillPattern.Solid,
            fillColor={255,255,255}),
          Rectangle(extent={{-40,-50},{40,-60}},
                                               lineColor={0,0,0},
            fillPattern=FillPattern.Solid,
            fillColor={255,255,255})}),                            Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end ServerRacks_HeatSource;

  model Crah_room

  parameter Real Ua = 2000;                // thermal conductance of coil W/K -> U-value =50 W/(m2.K), A= 40m2
  parameter Real m_flow_fluid = 0.6;        // chilled water mass flow rate kg/s
  parameter Real Cp_fluid = 4184;        // specific heat capacity of fluid J/(kg.K)
  parameter Modelica.Units.SI.Temperature T_water_in = 285.15;      // chilled water inlet temp K

  Modelica.Units.SI.HeatFlowRate Q_flow;            // heat flow rate across the coil W

    Heatconnector port_in_A annotation (Placement(transformation(extent={{-90,20},
              {-70,40}}), iconTransformation(extent={{-90,20},{-70,40}})));
    Heatconnector port_out_W annotation (Placement(transformation(extent={{38,-70},
              {58,-50}}), iconTransformation(extent={{38,-70},{58,-50}})));

  equation
    Q_flow = Ua * (port_in_A.T - port_out_W.T);    // heat transfer from air to water across coil W
    port_in_A.Qflow =  Q_flow;                  // heat flow entering from air side W
    port_out_W.Qflow = - Q_flow;              //  heat flow leaving to water side W

      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Rectangle(
            extent={{-80,60},{80,-60}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-56,42},{-26,24}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Line(points={{20,40},{20,-40}}, color={0,0,0}),
          Line(points={{-58,-20},{-6,-20}}, color={0,0,0}),
          Line(points={{-58,-30},{-6,-30}}, color={0,0,0}),
          Line(points={{60,40},{60,-40}}, color={0,0,0})}), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end Crah_room;

  model PumpSkid

    parameter Real m_flow = 0.6;               // water mass flow rate kg/s
    parameter Real Cp_fluid = 4184;            // specific heat capacity of fluid J/(kg.K)
    parameter Real P_elec = 400;               // pump motor electrical power consumption W

    // Real Q_pump;                  // thermal energy flow rate by pump W
    // Modelica.Units.SI.Temperature T_out;             // fluid outlet temp K

    Modelica.Units.NonSI.Temperature_degC T_out_degC;        // fluid outlet temp degC

    Heatconnector port_in annotation (Placement(transformation(extent={{90,-10},
              {110,10}}), iconTransformation(extent={{90,-10},{110,10}})));
    Heatconnector port_out annotation (Placement(transformation(extent={{90,-10},
              {110,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
  equation

    // Q_pump = m_flow * Cp_fluid * (port_in.T - 273.15);       // heat passing through pump

    P_elec = m_flow * Cp_fluid * (port_out.T - port_in.T);         // temperature rise across pump due to electrical motor heat addition
    port_out.Qflow = -(port_in.Qflow + P_elec);                // heate flow at the outlet

    T_out_degC = port_out.T - 273.15;           // celsius conversion

   annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid), Polygon(
            points={{60,80},{60,-80},{-100,0},{60,80}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.None)}),                       Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end PumpSkid;

  model ControlValve
    parameter Real m_flow_max = 0.6;        // max flow rate at 100% open
    parameter Real Cp_fluid = 4184;         // specific heat capacity of water J/(kg.K)
    parameter Real valve_opening = 1.0;     // 0.0 = closed, 1.0 open

              Real m_flow;          // mass flow rate of the fluid

    Heatconnector port_in annotation (Placement(transformation(extent={{-110,-10},
              {-90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
    Heatconnector port_out annotation (Placement(transformation(extent={{90,-8},{110,
              12}}), iconTransformation(extent={{90,-8},{110,12}})));
  equation

     m_flow = valve_opening * m_flow_max;       // effective mass flow rate on valve opening
     port_in.T = port_out.T;                  // temperature at inlet
     port_out.Qflow + port_in.Qflow = 0;      // heat flow balance

     annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Polygon(points={{-100,100},{0,0},{-100,-100},{-100,100}}, lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
            Polygon(points={{100,100},{0,0},{100,-100},{100,100}},    lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}),                       Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end ControlValve;

  model AirCooledChiller
    parameter Modelica.Units.NonSI.Temperature_degC T_chilled = 12;    // target supply chilled water temp degC
    parameter Real m_flow = 0.6;               // water mass flow rate kg/s
    parameter Real cp_fluid = 4184;            // specific heat capacity of fluid J/(kg.K)
        // parameter Real COP = 3.5;         //   chiller coefficient of performance

  Modelica.Units.SI.Temperature T_supply;      // leaving supply chilled water K
  Modelica.Units.SI.HeatFlowRate Q_rejected;  // total heat rejected to ambient air W

    Heatconnector port_in annotation (Placement(transformation(extent={{-10,-78},{
              10,-58}}), iconTransformation(extent={{-10,-78},{10,-58}})));

  equation

    port_in.T = T_supply;
    T_supply = 273.15 + T_chilled;    // constant chilled water temperature setpoint
    Q_rejected = port_in.Qflow;      // heat rejected by chiller

    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Polygon(
            points={{-80,72},{80,72},{80,32},{40,-68},{-40,-68},{-80,32},{-80,72}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.None), Ellipse(
            extent={{-35,48},{35,-20}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.None),
          Line(points={{-20,42},{32,26}}, color={0,0,0}),
          Line(points={{10,46}}, color={0,0,0}),
          Line(points={{-20,-12},{32,0}},color={0,0,0})}),         Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end AirCooledChiller;

  model DataCenterCoolingSystem
    ServerRacks_HeatSource serverRacks_HeatSource
      annotation (Placement(transformation(extent={{-90,8},{-28,82}})));
    Crah_room crah_room
      annotation (Placement(transformation(extent={{0,2},{86,72}})));
    PumpSkid pumpSkid
      annotation (Placement(transformation(extent={{30,-70},{50,-50}})));
    ControlValve controlValve
      annotation (Placement(transformation(extent={{-10,-70},{10,-50}})));
    AirCooledChiller airCooledChiller
      annotation (Placement(transformation(extent={{-82,-68},{-40,-20}})));
  equation
    connect(serverRacks_HeatSource.port_out, crah_room.port_in_A) annotation (
        Line(
        points={{-40.4,64.24},{-16,64.24},{-16,47.5},{8.6,47.5}},
        color={244,125,35},
        thickness=0.5));
    connect(controlValve.port_in, airCooledChiller.port_in) annotation (Line(
        points={{-10,-60},{-34,-60},{-34,-72},{-61,-72},{-61,-60.32}},
        color={244,125,35},
        thickness=0.5));
    connect(crah_room.port_out_W, pumpSkid.port_in) annotation (Line(
        points={{63.64,16},{64,16},{64,-60},{50,-60}},
        color={244,125,35},
        thickness=0.5));
    connect(pumpSkid.port_out, controlValve.port_out) annotation (Line(
        points={{30,-60},{28,-59.8},{10,-59.8}},
        color={244,125,35},
        thickness=0.5));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false), graphics={Rectangle(
            extent={{-88,88},{86,4}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            pattern=LinePattern.Dash), Text(
            extent={{46,92},{88,96}},
            textColor={0,0,0},
            textString="White Space")}));
  end DataCenterCoolingSystem;

  annotation (uses(Modelica(version="4.0.0")));
end DataCenter_Project;
