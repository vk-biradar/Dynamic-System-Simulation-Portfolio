within ;






































































































package Datacenter_Example

  import Air = Modelica.Media.Air.SimpleAir.BaseProperties;

  import Water = Modelica.Media.Water.ConstantPropertyLiquidWater.BaseProperties;

  connector Fluidconnector
    //flow Modelica.Units.SI.HeatFlowRate Qflow;
       //  Modelica.Units.SI.Temperature T;
      flow Modelica.Units.SI.MassFlowRate mflow;
           Modelica.Units.SI.Pressure p;
    stream Modelica.Units.SI.SpecificEnthalpy hOut;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Ellipse(
            extent={{-80,80},{80,-80}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}),
                                           Diagram(coordinateSystem(
            preserveAspectRatio=false)));
  end Fluidconnector;

  model ServerRacks_HeatSource
    import Modelica.Units.SI;


    parameter Real Q_room = 25e3                  "W";           // total heat dissipation
    parameter Real U_con = 3500                   "W/K";         // thermal conductance from servers to air
    parameter Real C_room = 50e3                  "J/K";         // lumped thermal mass, heat capacity
    parameter Real Cp_air = 1e3                   "J/(kg.K)";    // specific heat capacity of air
    parameter Real m_flow_air_nom = 1.8           "kg/s";        // nominal mass flow rate
    parameter Real dp_nom = 50                    "Pa";          // pressure drop nominal across servers
      // parameter Real V_room = 50               "m3";          // volume of the room
      // parameter Real d_air = 1.2               "kg/m3";       // density of air


    Modelica.Units.SI.Temperature T_room(start = 316.15, fixed=true);          // lumped temperature of servers

    Modelica.Units.SI.SpecificEnthalpy h_air_out;                              // explicit specific enthapy
    Modelica.Units.SI.HeatFlowRate Q_flow;                                     // heat transfer from servers to air
    Modelica.Units.SI.Temperature T_air_in;
    Modelica.Units.SI.Temperature T_air_out;

    Fluidconnector port_air_out annotation (Placement(transformation(extent={{50,24},
              {70,44}}), iconTransformation(extent={{50,24},{70,44}})));
    Fluidconnector port_air_in annotation (Placement(transformation(extent={{50,42},
              {70,62}}), iconTransformation(extent={{50,-46},{70,-26}})));

  equation

    port_air_in.mflow + port_air_out.mflow = 0;                                                 // mass flow balance
    port_air_in.p - port_air_out.p = dp_nom * (port_air_in.mflow/m_flow_air_nom) * abs( port_air_in.mflow/ m_flow_air_nom);         // pressure drop across servers ports
        // port_air_out.p = port_air_in.p


    T_air_in = inStream(port_air_in.hOut)/Cp_air;
    T_air_out = h_air_out/Cp_air;

    h_air_out = inStream(port_air_in.hOut)+ Q_flow / max((port_air_in.mflow), 1e-3);

    port_air_in.hOut =  inStream(port_air_out.hOut);                                           // enthalpy balance across air ports
    port_air_out.hOut =  h_air_out;           //    // inStream(port_air_in.hOut);

    Q_flow = U_con * (T_room - (inStream(port_air_out.hOut)/Cp_air));                          // heat transfer to air stream
    C_room * der(T_room) = Q_room - Q_flow;                                                    // thermal energy balance


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

  model Crah_room_ACL
    import Modelica.Units.SI;

    parameter Real Ua = 4400                        "W/K";               // thermal conductance of coil
    parameter Real C_coil = 40e3                    "J/K";               // lumped thermal mass, heat capacity
    parameter Real Cp_air = 1e3                     "J/(kg.K)";          // specific heat capacity of air
    parameter Real Cp_water = 4184                  "J/(kg.K)";          // specific heat capacity of water
    parameter Real m_flow_air_nom = 1.8             "kg/s";              // nominal air mass flow rate
    parameter Real m_flow_water_nom = 1.2           "kg/s";              // nominal water mass flow rate
    parameter Real dp_air_nom = 150                 "Pa";                // pressure drop air-side nominal across coil
    parameter Real T_amb = 297.15                   "K";                 // ambient air temp K


    Modelica.Units.SI.Temperature T_coil(start = 297.15, fixed=true);                  // lumped temperature of coil

    Modelica.Units.SI.SpecificEnthalpy h_air_out;                                      // explicit specific enthapy
    Modelica.Units.SI.HeatFlowRate Q_flow_air_to_coil;                                 // heat flow rate from air stream to coil
    Modelica.Units.SI.HeatFlowRate Q_flow_coil_to_ambient;                             // heat flow rate from coil to ambient
    Modelica.Units.SI.Temperature T_air_in;
    Modelica.Units.SI.Temperature T_air_out;

    Fluidconnector port_air_in annotation (Placement(transformation(extent={{38,-70},
              {58,-50}}), iconTransformation(extent={{-90,24},{-70,44}})));
    Fluidconnector port_air_out annotation (Placement(transformation(extent={{18,-70},
              {38,-50}}), iconTransformation(extent={{-90,-24},{-70,-4}})));

  equation

    port_air_in.mflow + port_air_out.mflow = 0;                                                   // mass flow balance

    port_air_in.p - port_air_out.p  = dp_air_nom * (port_air_in.mflow/m_flow_air_nom) * abs(port_air_in.mflow/ m_flow_air_nom);               // pressure drop across air ports

    T_air_in = inStream(port_air_in.hOut)/Cp_air;
    T_air_out = h_air_out/Cp_air;

    h_air_out = inStream(port_air_in.hOut)- Q_flow_coil_to_ambient / max(abs(port_air_in.mflow), 1e-3);

    port_air_in.hOut = inStream(port_air_out.hOut);                                               // enthalpy balance across air ports
    port_air_out.hOut = h_air_out;                   // inStream(port_air_in.hOut);

    Q_flow_air_to_coil = 1 * Ua * (((((T_air_in + T_air_out)/2)))- T_coil);                       // heat transfer from air to coil
    Q_flow_coil_to_ambient = 1 * Ua * (T_coil - T_amb);                                           // heat transfer from coil to ambient

    C_coil * der(T_coil) = Q_flow_air_to_coil - Q_flow_coil_to_ambient;                           // thermal energy balance


    annotation(Icon(graphics={Rectangle(extent={{-80,70},{80,-60}}, lineColor={0,0,
                0}), Rectangle(extent={{-52,38},{54,14}})}));
  end Crah_room_ACL;

  model Crah_room_LCL
    import Modelica.Units.SI;

    parameter Real Q_added = 25e3                   "W";                 // heat added to water
    parameter Real Ua = 4400                        "W/K";               // thermal conductance of coil
    parameter Real C_coil = 60e3                    "J/K";               // lumped thermal mass, heat capacity
    parameter Real Cp_water = 4184                  "J/(kg.K)";          // specific heat capacity of water
    parameter Real m_flow_water_nom = 1.2           "kg/s";              // nominal water mass flow rate
    parameter Real dp_water_nom = 30000             "Pa";                // pressure drop water-side across coil
      // parameter Real V_water = 0.02              "m3";                // volume of water in coil (20 L)
      // parameter Real d_water = 1000              "kg/m3";             // density of water

    Modelica.Units.SI.Temperature T_coil(start = 297.15, fixed=true);                       // lumped temperature of coil

    Modelica.Units.SI.SpecificEnthalpy h_water_out;                                         // explicit specific enthalpy
        // Modelica.Units.SI.HeatFlowRate Q_flow_coil_to_ambient;                           // heat flow rate from coil to ambient
    Modelica.Units.SI.HeatFlowRate Q_flow_coil_to_water;                                    // heat flow rate from coil to water
    Modelica.Units.SI.Temperature T_water_in;
    Modelica.Units.SI.Temperature T_water_out;

    Fluidconnector port_water_in annotation (Placement(transformation(extent={{60,
              -44},{80,-24}}), iconTransformation(extent={{-40,-70},{-20,-50}})));
    Fluidconnector port_water_out annotation (Placement(transformation(extent={{60,
              30},{80,50}}), iconTransformation(extent={{22,-70},{42,-50}})));

  equation

    port_water_in.mflow + port_water_out.mflow = 0;                                               // mass flow balance

    port_water_in.p - port_water_out.p = dp_water_nom*(port_water_in.mflow/m_flow_water_nom)* abs(port_water_in.mflow/ m_flow_water_nom);        // pressure drop across water ports                                                                    // pressure drop water-side

    T_water_in = inStream(port_water_in.hOut)/Cp_water;
    T_water_out = h_water_out/Cp_water;

    h_water_out = inStream(port_water_in.hOut)+ Q_flow_coil_to_water / max(abs(port_water_in.mflow), 1e-3);

    port_water_in.hOut = inStream(port_water_out.hOut);                                           // enthalpy balance across water ports
    port_water_out.hOut = h_water_out;               // inStream(port_water_in.hOut);

    Q_flow_coil_to_water = 1 * Ua * (T_coil - ((T_water_in + T_water_out)/2));                    // heat transfer from coil to water

    C_coil * der(T_coil) = Q_added - Q_flow_coil_to_water;                                        // thermal energy balance

    annotation(Icon(graphics={Rectangle(extent={{-80,70},{80,-60}}, lineColor={0,0,
                0}), Rectangle(extent={{-52,40},{54,16}})}));
  end Crah_room_LCL;

  model Crah_room_Both
    import Modelica.Units.SI;

    parameter Real Ua =4400                         "W/K";               // thermal conductance of coil
    parameter Real C_coil = 100e3                   "J/K";               // lumped thermal mass, heat capacity
    parameter Real Cp_air = 1e3                     "J/(kg.K)";          // specific heat capacity of air
    parameter Real Cp_water = 4184                  "J/(kg.K)";          // specific heat capacity of water
    parameter Real m_flow_air_nom = 1.8             "kg/s";              // anominal air mass flow rate
    parameter Real m_flow_water_nom = 1.2           "kg/s";              // nominal water mass flow rate
    parameter Real dp_air_nom = 150                 "Pa";                // pressure drop air-side nominal across coil
    parameter Real dp_water_nom = 30000             "Pa";                // pressure drop water-side nominal across coil
      // parameter Real V_air = 5                   "m3";                // volume of air in casing
      // parameter Real V_water = 0.02              "m3";                // volume of water in coil
      // parameter Real d_air = 1.2                 "kg/m3";             // density of air
      // parameter Real d_water = 1000              "kg/m3";             // density of water

    Modelica.Units.SI.Temperature T_coil(start = 294.00, fixed=true);                // lumped temperature of coil

    Modelica.Units.SI.SpecificEnthalpy h_air_out;                                    // explicit specific enthalpy of air
    Modelica.Units.SI.SpecificEnthalpy h_water_out;                                  // explicit specific enthalpy of water
    Modelica.Units.SI.HeatFlowRate Q_flow_air_to_coil;                               // heat flow rate from air to coil
        // Modelica.Units.SI.HeatFlowRate Q_flow_coil_to_ambient;                    // heat flow rate from coil to ambient
    Modelica.Units.SI.HeatFlowRate Q_flow_coil_to_water;                             // heat flow rate from coil to water
    Modelica.Units.SI.Temperature T_air_in;
    Modelica.Units.SI.Temperature T_air_out;
    Modelica.Units.SI.Temperature T_water_in;
    Modelica.Units.SI.Temperature T_water_out;

    Fluidconnector port_air_in annotation (Placement(transformation(extent={{38,-70},
              {58,-50}}), iconTransformation(extent={{-90,24},{-70,44}})));
    Fluidconnector port_air_out annotation (Placement(transformation(extent={{18,-70},
              {38,-50}}), iconTransformation(extent={{-90,-28},{-70,-8}})));
    Fluidconnector port_water_in annotation (Placement(transformation(extent={{38,
              -70},{58,-50}}), iconTransformation(extent={{-26,-70},{-6,-50}})));
    Fluidconnector port_water_out annotation (Placement(transformation(extent={{18,
              -70},{38,-50}}), iconTransformation(extent={{38,-70},{58,-50}})));
  equation

    port_air_in.mflow + port_air_out.mflow = 0;                                                          // mass flow balance air-side

    port_water_in.mflow + port_water_out.mflow = 0;                                                      // mass flow balance water-side

    port_air_in.p - port_air_out.p  = dp_air_nom * (port_air_in.mflow/m_flow_air_nom) * abs(port_air_in.mflow/ m_flow_air_nom);              // pressure drop across air ports
    port_water_in.p - port_water_out.p = dp_water_nom*(port_water_in.mflow/m_flow_water_nom)* abs(port_water_in.mflow/ m_flow_water_nom);    // pressure drop across water ports

    T_air_in = inStream(port_air_in.hOut)/Cp_air;
    T_air_out = h_air_out/Cp_air;
    T_water_in = inStream(port_water_in.hOut)/Cp_water;
    T_water_out = h_water_out/Cp_water;

    h_air_out = inStream(port_air_in.hOut) - Q_flow_air_to_coil / max((port_air_in.mflow), 1e-2);
    port_air_in.hOut = inStream(port_air_out.hOut);                                                      // enthalpy balance across air ports
    port_air_out.hOut = h_air_out;                     // inStream(port_air_in.hOut);

    h_water_out = inStream(port_water_in.hOut) + Q_flow_coil_to_water / max((port_water_in.mflow), 1e-2);
    port_water_in.hOut = inStream(port_water_out.hOut);                                                  // enthalpy balance across water ports
    port_water_out.hOut = h_water_out;                 // inStream(port_water_in.hOut);

    Q_flow_air_to_coil =  Ua * ((((T_air_in + T_air_out)/2)) - T_coil);                                  // heat transfer from air to coil
    Q_flow_coil_to_water = Ua * (T_coil - ((T_water_in + T_water_out)/2));                               // heat transfer from coil to water

    C_coil * der(T_coil) = Q_flow_air_to_coil - Q_flow_coil_to_water;                                    // thermal energy balance


    annotation(Icon(graphics={Rectangle(extent={{-80,70},{80,-60}}, lineColor={0,0,
                0}), Rectangle(extent={{-52,36},{54,12}})}));
  end Crah_room_Both;

  model AirFan
    import Modelica.Units.SI;

    parameter Real m_flow_air_nom = 1.8            "kg/s";                 // nominal air mass flow rate
    parameter Real dp_nom= 200                     "Pa";                   // nominal fan static pressure  (200 Pa)
    parameter Real Cp_air = 1e3                    "J/(kg.K)";             // specific heat capacity of air
    parameter Real eta_fan = 0.8                   "%";                    // fan efficiency

    Modelica.Units.SI.SpecificEnthalpy h_air_out;                  // explicit specific enthalpy
    Modelica.Units.SI.Temperature T_air_in;
    Modelica.Units.SI.Temperature T_air_out;

    Fluidconnector port_air_in annotation (Placement(transformation(extent={{-110,
              -10},{-90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
    Fluidconnector port_air_out annotation (Placement(transformation(extent={{-110,
              -10},{-90,10}}), iconTransformation(extent={{90,-10},{110,10}})));

  equation

    port_air_in.mflow + port_air_out.mflow = 0;                                                 // mass flow balance
    // port_air_in.mflow = m_flow_air_nom;

    port_air_out.p - port_air_in.p = dp_nom * (port_air_in.mflow/m_flow_air_nom) * abs( port_air_in.mflow/ m_flow_air_nom);             // pressure rise across fan

    T_air_in = inStream(port_air_in.hOut)/Cp_air;
    T_air_out = h_air_out/Cp_air;

    h_air_out =inStream(port_air_in.hOut);

    port_air_in.hOut = inStream(port_air_out.hOut);                                             // enthalpy balance across fan ports
    port_air_out.hOut = inStream(port_air_in.hOut);    //h_air_out;

    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Rectangle(extent={{-10,80},{10,-80}}, lineColor={0,0,0}),
          Rectangle(
            extent={{-10,80},{10,-80}},
            lineColor={0,0,0},
            rotation=90),
          Ellipse(
            extent={{-20,20},{20,-20}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
            preserveAspectRatio=false)));
  end AirFan;

  model PumpSkid
    import Modelica.Units.SI;

    parameter Real m_flow_water_nom = 1.2     "kg/s";                  // nominal water mass flow rate
    parameter Real Cp_water = 4184            "J/(kg.K)";              // specific heat capacity of fluid
    parameter Real eta_pump = 0.85            "%";                     // overall pump efficiency
    parameter Real dp_pump_nom = 100000       "Pa";                    // pressure rise nominal pump
    parameter Real signal_pump = 1.0;                                  // pump speed signal 0 - 100% open

    Modelica.Units.SI.Pressure p_pump;                        // static pressure of pump
    Modelica.Units.SI.SpecificEnthalpy h_water_out;           // explicit specific enthalpy
    Modelica.Units.SI.Temperature T_water_in;
    Modelica.Units.SI.Temperature T_water_out;

    Fluidconnector port_water_in annotation (Placement(transformation(extent={{90,
              -10},{110,10}}), iconTransformation(extent={{90,-10},{110,10}})));
    Fluidconnector port_water_out annotation (Placement(transformation(extent={{90,
              -10},{110,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));

  equation
    port_water_in.mflow + port_water_out.mflow = 0;                                  // mass flow balance

    port_water_out.p - port_water_in.p = p_pump;                                     // pressure rise across pump

    p_pump =dp_pump_nom*(1 - abs(port_water_in.mflow)*port_water_in.mflow/m_flow_water_nom^2);
            // p_pump = dp_pump_nom * (signal_pump^2) - 0.1 * dp_pump_nom * (m_flow_water/m_flow_water_nom)^2;

    T_water_in = inStream(port_water_in.hOut)/Cp_water;
    T_water_out = h_water_out/Cp_water;

    h_water_out =inStream(port_water_in.hOut); //

    port_water_in.hOut = inStream(port_water_out.hOut);                              // enthalpy balance across fan ports
    port_water_out.hOut = inStream(port_water_in.hOut);      // h_water_out;

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
    import Modelica.Units.SI;

    parameter Real m_flow_water_nom = 1.2        "kg/s";           // nominal max flow rate
    parameter Real Cp_water = 4184               "J/(kg.K)";       // specific heat capacity of water
    parameter Real dp_water_nom = 25000          "Pa";             // pressure drop nominal across valve
    parameter Real valve_open = 1;                                 // opening of the valve 0.0 - 1.0, 0 - 100% open

    Modelica.Units.SI.SpecificEnthalpy h_water_out;                // explicit specific enthalpy of water
    Modelica.Units.SI.Temperature T_water_in;
    Modelica.Units.SI.Temperature T_water_out;

    Fluidconnector port_water_in annotation (Placement(transformation(extent={{-110,
              -10},{-90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
    Fluidconnector port_water_out annotation (Placement(transformation(extent={{90,
              -8},{110,12}}), iconTransformation(extent={{90,-8},{110,12}})));

  equation

    port_water_in.mflow + port_water_out.mflow = 0;                                                                     // mass flow balance

    port_water_in.p - port_water_out.p = (dp_water_nom/(valve_open^2)*(port_water_in.mflow/m_flow_water_nom));          // pressure drop across valve                                                              // quadratic pressure drop

    T_water_in = inStream(port_water_in.hOut)/Cp_water;
    T_water_out = h_water_out/Cp_water;

    h_water_out =inStream(port_water_in.hOut);

    port_water_in.hOut = inStream(port_water_out.hOut);                                                                 // enthalpy balance across fan ports
    port_water_out.hOut = inStream(port_water_in.hOut);

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
    import Modelica.Units.SI;

    parameter Real Ua = 25000                     "W/K";           // thermal conductance of coil
    parameter Real C_cooler = 500e3               "J/K";           // lumped thermal mass, heat capacity
    parameter Real Cp_water = 4184                "J/(kg.K)";      // specific heat capacity of water
    parameter Real m_flow_water_nom = 1.2         "kg/s";          // nominal water mass flow rate
    parameter Real dp_evap_nom = 40000            "Pa";            // pressure drop evaporator nominal across chiller
    parameter Real T_amb = 297.15                 "K";             // ambient water temp
    parameter Real T_chilled = 285.15             "K";             // return chilled water temp
    parameter Real COP_chiller = 3.2              "";              // refrigeration coefficient of performance


    Modelica.Units.SI.SpecificEnthalpy h_water_out;                         // explicit specific enthapy of water
    Modelica.Units.SI.HeatFlowRate Q_evap;                                  // regrigeration cooling
    Modelica.Units.SI.HeatFlowRate P_elec;                                  // compressor electric power
    Modelica.Units.SI.Temperature T_water_in;
    Modelica.Units.SI.Temperature T_water_out;

    Fluidconnector port_water_in "water inlet from CRAH" annotation (Placement(
          transformation(extent={{38,-58},{58,-38}}), iconTransformation(extent={{38,-58},
              {58,-38}})));
    Fluidconnector port_water_out "Cold water outlet to CRAH" annotation (Placement(
          transformation(extent={{-10,-78},{10,-58}}), iconTransformation(extent={{58,-10},
              {78,10}})));

  equation

    port_water_in.mflow + port_water_out.mflow = 0;                                                   // mass flow balance

    port_water_in.p - port_water_out.p = dp_evap_nom * (port_water_in.mflow/m_flow_water_nom) * abs(port_water_in.mflow/ m_flow_water_nom);      // pressure drop across chiller ports                                                                // * abs(port_water_in.mflow / m_flow_water_nom);     // pressure drop water-side

    T_water_in = inStream(port_water_in.hOut)/Cp_water;
    T_water_out = h_water_out/Cp_water;

    h_water_out = Cp_water * T_chilled;                   // inStream(port_water_in.hOut)

    port_water_in.hOut = inStream(port_water_out.hOut);                                              // enthalpy balance across chiller ports
    port_water_out.hOut = h_water_out;                    // inStream(port_water_in.hOut);

    Q_evap = port_water_in.mflow * (inStream(port_water_in.hOut) - h_water_out);                     // heat transfer from CRAH warm water
    P_elec = Q_evap /COP_chiller;                                                                    // electrical power drawn by chiller compressor


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

  model Boundary

   parameter Real p_set = 1e5           "Pa";            // static pressure
   parameter Real T_set = 293.15        "K";             // reference fluid temperature
   parameter Real Cp_air = 1e3          "J/(kg.K)";      // specific heat capacity

    Fluidconnector port_in annotation (Placement(transformation(extent={{-10,-10},
              {10,10}}), iconTransformation(extent={{-10,-10},{10,10}})));

  equation
    port_in.p = p_set;
    port_in.hOut = Cp_air * T_set;

    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(extent={{-62,26},{62,0}},   lineColor={0,0,0})}), Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end Boundary;

  model WaterBoundary

   parameter Real p_set = 2e5           "Pa";            // static pressure
   parameter Real T_set = 293.15        "K";             // reference fluid temperature
   parameter Real Cp_water = 4e3          "J/(kg.K)";      // specific heat capacity

    Fluidconnector port_in annotation (Placement(transformation(extent={{-10,-10},
              {10,10}}), iconTransformation(extent={{-10,-10},{10,10}})));

  equation
    port_in.p = p_set;
    port_in.hOut = Cp_water * T_set;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(extent={{-62,26},{62,0}},   lineColor={0,0,0})}), Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end WaterBoundary;

  model System_ACL

    ServerRacks_HeatSource serverRacks_HeatSource(Q_room=5e3, dp_nom=1e5) annotation (Placement(transformation(extent={{-94,6},
              {-34,72}})));
    AirFan airFan_HA(dp_nom=1e5, eta_fan=1) annotation (Placement(transformation(extent={{-22,34},
              {-10,46}})));
    AirFan airFan_CA(dp_nom=1e5, eta_fan=1) annotation (Placement(
          transformation(
          extent={{-6,-6},{6,6}},
          rotation=180,
          origin={16,-8})));
    Crah_room_ACL crah_room_ACL annotation (Placement(transformation(extent={{32,-32},{86,22}})));
    Boundary boundary_1 annotation (Placement(transformation(extent={{28,46},{48,66}})));

  equation

    connect(serverRacks_HeatSource.port_air_out, airFan_HA.port_air_in)
      annotation (Line(
        points={{-46,50.22},{-31.2,50.22},{-31.2,40},{-22,40}},
        color={244,125,35},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(serverRacks_HeatSource.port_air_in, airFan_CA.port_air_out)
      annotation (Line(
        points={{-46,27.12},{-28,27.12},{-28,-8},{10,-8}},
        color={28,108,200},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(airFan_CA.port_air_in, crah_room_ACL.port_air_out) annotation (Line(
        points={{22,-8},{24,-8},{24,-8.78},{37.4,-8.78}},
        color={28,108,200},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(airFan_HA.port_air_out, crah_room_ACL.port_air_in) annotation (Line(
        points={{-10,40},{24,40},{24,4.18},{37.4,4.18}},
        color={244,125,35},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(boundary_1.port_in, crah_room_ACL.port_air_in) annotation (Line(
        points={{38,56},{38,34},{24,34},{24,4.18},{37.4,4.18}},
        color={244,125,35},
        pattern=LinePattern.Dash,
        thickness=0.5));
     annotation (

                Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false), graphics={
                                       Text(
            extent={{46,84},{88,88}},
            textColor={0,0,0},
            textString="White Space"), Text(
            extent={{-84,4},{-42,8}},
            textColor={0,0,0},
            textString="Servers"),     Text(
            extent={{38,-30},{80,-26}},
            textColor={0,0,0},
            textString="Cooling Unit"),Text(
            extent={{-22,16},{20,20}},
            textColor={0,0,0},
            textString="ACL",
            textStyle={TextStyle.Bold}),
          Rectangle(
            extent={{-92,80},{90,-40}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash),
          Line(
            points={{182,-12}},
            color={244,125,35},
            pattern=LinePattern.DashDot,
            thickness=0.5),            Text(
            extent={{-36,50},{6,54}},
            textColor={0,0,0},
            textString="Fan"),         Text(
            extent={{-8,-24},{34,-20}},
            textColor={0,0,0},
            textString="Fan"),         Text(
            extent={{18,64},{60,68}},
            textColor={0,0,0},
            textString="Boundary"),
          Line(
            points={{0,11},{0,-11}},
            color={238,46,47},
            thickness=0.5,
            pattern=LinePattern.Dash,
            origin={74,19},
            rotation=180),
          Line(
            points={{-5,-2},{0,5},{5,-2}},
            color={238,46,47},
            thickness=0.5,
            pattern=LinePattern.Dash,
            origin={74,25},
            rotation=360)}));
  end System_ACL;

  model System_LCL

    PumpSkid pumpSkid_1 annotation (Placement(transformation(
          extent={{-6,-6},{6,6}},
          rotation=180,
          origin={6,-28})));
    AirCooledChiller airCooledChiller_1 annotation (Placement(transformation(extent={{-90,-74},{-44,-22}})));
    Crah_room_LCL crah_room_LCL_1 annotation (Placement(transformation(extent={{34,10},{90,66}})));
    ControlValve controlValve_2 annotation (Placement(
          transformation(
          extent={{-6,-5},{6,5}},
          rotation=0,
          origin={-24,-29})));
    Boundary boundary_1  annotation (Placement(transformation(extent={{20,-16},{40,4}})));
    ControlValve controlValve_1 annotation (Placement(
          transformation(
          extent={{-6,-5},{6,5}},
          rotation=180,
          origin={50,-65})));
    PumpSkid pumpSkid_2 annotation (Placement(transformation(
          extent={{-6,-6},{6,6}},
          rotation=0,
          origin={10,-66})));
  equation

    connect(pumpSkid_1.port_water_in, controlValve_2.port_water_out)
      annotation (Line(points={{0,-28},{0,-28.9},{-18,-28.9}},
                                                           color={28,108,200},
        thickness=0.5));
    connect(pumpSkid_1.port_water_out, crah_room_LCL_1.port_water_in)
      annotation (Line(points={{12,-28},{53.6,-28},{53.6,21.2}},
          color={28,108,200},
        thickness=0.5));
    connect(airCooledChiller_1.port_water_out, controlValve_2.port_water_in)
      annotation (Line(points={{-51.36,-48},{-40,-48},{-40,-29},{-30,-29}},
          color={28,108,200},
        thickness=0.5));
    connect(boundary_1.port_in, crah_room_LCL_1.port_water_in) annotation (Line(
          points={{30,-6},{30,-14},{53.6,-14},{53.6,21.2}}, color={28,108,200},
        thickness=0.5));
    connect(airCooledChiller_1.port_water_in, pumpSkid_2.port_water_out)
      annotation (Line(
        points={{-55.96,-60.48},{-32,-60.48},{-32,-66},{4,-66}},
        color={244,125,35},
        thickness=0.5));
    connect(pumpSkid_2.port_water_in, controlValve_1.port_water_out)
      annotation (Line(
        points={{16,-66},{16,-65.1},{44,-65.1}},
        color={244,125,35},
        thickness=0.5));
    connect(controlValve_1.port_water_in, crah_room_LCL_1.port_water_out)
      annotation (Line(
        points={{56,-65},{70.96,-65},{70.96,21.2}},
        color={244,125,35},
        thickness=0.5));
     annotation (

                Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false), graphics={
                                       Text(
            extent={{46,84},{88,88}},
            textColor={0,0,0},
            textString="White Space"), Text(
            extent={{-12,-50},{30,-46}},
            textColor={0,0,0},
            textStyle={TextStyle.Bold},
            textString="LCL"),
          Rectangle(
            extent={{-92,80},{90,16}},
            lineColor={0,0,0},
            pattern=LinePattern.Dash),
          Line(
            points={{182,-12}},
            color={244,125,35},
            pattern=LinePattern.DashDot,
            thickness=0.5),            Text(
            extent={{-44,-18},{-2,-14}},
            textColor={0,0,0},
            textString="Valve"),       Text(
            extent={{-14,-16},{28,-12}},
            textColor={0,0,0},
            textString="Pump"),        Text(
            extent={{10,2},{52,6}},
            textColor={0,0,0},
            textString="Boundary"),
          Line(
            points={{0,11},{0,-11}},
            color={238,46,47},
            thickness=0.5,
            pattern=LinePattern.Dash,
            origin={-78,-27},
            rotation=180),
          Line(
            points={{-5,-2},{0,5},{5,-2}},
            color={238,46,47},
            thickness=0.5,
            pattern=LinePattern.Dash,
            origin={-78,-23},
            rotation=360),             Text(
            extent={{-88,-76},{-46,-72}},
            textColor={0,0,0},
            textString="Chiller"),     Text(
            extent={{-14,-86},{28,-82}},
            textColor={0,0,0},
            textString="Pump"),        Text(
            extent={{24,-84},{66,-80}},
            textColor={0,0,0},
            textString="Valve"),       Text(
            extent={{42,62},{84,66}},
            textColor={0,0,0},
            textString="Cooling Unit")}));
  end System_LCL;

  model Datacentersystem

    ServerRacks_HeatSource serverRacks_HeatSource annotation (Placement(transformation(extent={{-90,8},{-28,82}})));
    Crah_room_Both crah_room annotation (Placement(transformation(extent={{30,-2},{88,56}})));
    PumpSkid pumpSkid_HW annotation (Placement(transformation(extent={{38,-74},
              {48,-64}})));
    ControlValve controlValve_HW annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=180,
          origin={-1,-69})));
    AirCooledChiller airCooledChiller annotation (Placement(transformation(extent={{-86,-68},
              {-44,-20}})));
    PumpSkid pumpSkid_CW annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=180,
          origin={-19,-41})));
    ControlValve controlValve_CW annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=0,
          origin={31,-41})));

    AirFan airFan annotation (Placement(transformation(extent={{-26,52},{-16,62}})));
    AirFan airFan1 annotation (Placement(transformation(extent={{8,18},{18,28}})));
    Boundary boundary_2(T_set=292)
      annotation (Placement(transformation(extent={{20,60},{40,80}})));
    Boundary boundary(
      p_set=200000,
      T_set=286,
      Cp_air=4184)
      annotation (Placement(transformation(extent={{16,-24},{36,-4}})));
  equation

    connect(crah_room.port_water_out, pumpSkid_HW.port_water_in) annotation (
        Line(
        points={{72.92,9.6},{72.92,-69},{48,-69}},
        color={244,125,35},
        thickness=0.5));

    connect(controlValve_HW.port_water_in, pumpSkid_HW.port_water_out)
      annotation (Line(
        points={{4,-69},{38,-69}},
        color={244,125,35},
        thickness=0.5));
    connect(airCooledChiller.port_water_in, controlValve_HW.port_water_out)
      annotation (Line(
        points={{-54.92,-55.52},{-42,-55.52},{-42,-69.1},{-6,-69.1}},
        color={244,125,35},
        thickness=0.5));
    connect(pumpSkid_CW.port_water_out, controlValve_CW.port_water_in)
      annotation (Line(
        points={{-14,-41},{26,-41}},
        color={28,108,200},
        thickness=0.5));
    connect(serverRacks_HeatSource.port_air_out, airFan.port_air_in) annotation (
        Line(
        points={{-40.4,57.58},{-40.4,57},{-26,57}},
        color={244,125,35},
        thickness=0.5,
        pattern=LinePattern.Dash));
    connect(airFan.port_air_out, crah_room.port_air_in) annotation (Line(
        points={{-16,57},{16,57},{16,36.86},{35.8,36.86}},
        color={244,125,35},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(airFan1.port_air_out, crah_room.port_air_out) annotation (Line(
        points={{18,23},{18,21.78},{35.8,21.78}},
        color={28,108,200},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(serverRacks_HeatSource.port_air_in, airFan1.port_air_in) annotation (
        Line(
        points={{-40.4,31.68},{-28,31.68},{-28,23},{8,23}},
        color={28,108,200},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(airCooledChiller.port_water_out, pumpSkid_CW.port_water_in)
      annotation (Line(
        points={{-50.72,-44},{-36,-44},{-36,-41},{-24,-41}},
        color={28,108,200},
        thickness=0.5));
    connect(controlValve_CW.port_water_out, crah_room.port_water_in)
      annotation (Line(
        points={{36,-40.9},{54,-40.9},{54,-18},{54.36,-18},{54.36,9.6}},
        color={28,108,200},
        thickness=0.5));
    connect(boundary_2.port_in, crah_room.port_air_in) annotation (Line(
        points={{30,70},{30,52},{16,52},{16,36.86},{35.8,36.86}},
        color={244,125,35},
        pattern=LinePattern.Dash,
        thickness=0.5));
    connect(boundary.port_in, crah_room.port_water_in) annotation (Line(
        points={{26,-14},{26,-20},{54,-20},{54,-18},{54.36,-18},{54.36,9.6}},
        color={28,108,200},
        thickness=0.5));
     annotation (

                Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false), graphics={Rectangle(
            extent={{-88,88},{86,4}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            pattern=LinePattern.Dash), Text(
            extent={{46,92},{88,96}},
            textColor={0,0,0},
            textString="White Space"), Text(
            extent={{-86,-70},{-44,-66}},
            textColor={0,0,0},
            textString="Chiller"),     Text(
            extent={{-80,8},{-38,12}},
            textColor={0,0,0},
            textString="Servers"),     Text(
            extent={{40,52},{82,56}},
            textColor={0,0,0},
            textString="Cooling Unit"),Text(
            extent={{-26,38},{16,42}},
            textColor={0,0,0},
            textString="ACL",
            textStyle={TextStyle.Bold}),
                                       Text(
            extent={{-20,-54},{22,-50}},
            textColor={0,0,0},
            textString="WCL",
            textStyle={TextStyle.Bold}),
                                       Text(
            extent={{-40,-32},{2,-28}},
            textColor={0,0,0},
            textString="Pump"),        Text(
            extent={{22,-82},{64,-78}},
            textColor={0,0,0},
            textString="Pump"),        Text(
            extent={{6,-6},{48,-2}},
            textColor={0,0,0},
            textString="Boundary"),    Text(
            extent={{-22,-82},{20,-78}},
            textColor={0,0,0},
            textString="Valve"),       Text(
            extent={{10,-32},{52,-28}},
            textColor={0,0,0},
            textString="Valve"),       Text(
            extent={{-42,66},{0,70}},
            textColor={0,0,0},
            textString="Fan"),         Text(
            extent={{-8,10},{34,14}},
            textColor={0,0,0},
            textString="Fan"),         Text(
            extent={{10,76},{52,80}},
            textColor={0,0,0},
            textString="Boundary")}));
  end Datacentersystem;

  annotation (uses(Modelica(version="4.0.0")));
end Datacenter_Example;
