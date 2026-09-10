within ;
package ThermalSolarSystem

  import Modelica.Units.SI;

  import Water = Modelica.Media.Water.ConstantPropertyLiquidWater.BaseProperties;   // 'Water' as a name with base properties

  connector Fluidconnector

    flow Real mflow;    // mass flow rate kg/s
         Real p;        // pressure in bar
    stream Real hOut;   // enthalpy flowing out in J

    annotation (Icon(graphics={Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}));
  end Fluidconnector;

  model Boundary
    Fluidconnector port annotation (Placement(transformation(extent={{-10,-10},{10,
              10}}), iconTransformation(extent={{-10,-10},{10,10}})));
    parameter Real p = 1e5;  // pressure in bar
    parameter Real T = 300;  // temperature in K

    Water fluid;

  equation
    fluid.T = T;
    fluid.p = p;
    port.p = p;
    port.hOut = fluid.h;      // enthalpy flow out

      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Line(
              points={{0,100},{0,-98}}, color={0,0,0})}), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end Boundary;

  model Pump
    Fluidconnector portA annotation (Placement(transformation(extent={{-110,-10},{
              -90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
    Fluidconnector portB annotation (Placement(transformation(extent={{90,-10},{110,
              10}}),  iconTransformation(extent={{90,-10},{110,10}})));
       parameter Real mflow_pump = 0.1;     // mass flow rate kg/s
       parameter Real p_pump = 2e5;         // pressure in bar

  equation
    portA.mflow + portB.mflow = 0;        // mass flow balance

    portB.p - portA.p = p_pump * (1 - abs(portA.mflow) * portA.mflow / (mflow_pump^2)) annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Line(points={{-60,80},{100,0}}, color={0,0,0}),
          Line(points={{-60,-80},{100,0}}, color={0,0,0})}), Diagram(
          coordinateSystem(preserveAspectRatio=false)));

   portA.hOut = inStream(portB.hOut);      // enthalpy stream at portA
   portB.hOut = inStream(portA.hOut);      // enthalpy stream at portB

    annotation (Icon(graphics={
          Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Line(points={{-60,80},{100,0}}, color={0,0,0}),
          Line(points={{-60,-80},{100,0}}, color={0,0,0})}));
  end Pump;

  model Valve

   parameter Real mflow_val = 0.1;    // mass flow rate kg/s
   parameter Real p_val = 1e5;        // pressure in bar

    Fluidconnector portA annotation (Placement(transformation(extent={{-110,-10},{
              -90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
    Fluidconnector portB annotation (Placement(transformation(extent={{90,-10},{110,
              10}}), iconTransformation(extent={{90,-10},{110,10}})));
  equation
    portA.mflow + portB.mflow = 0;      // mass flow balance
    portA.p - portB.p = p_val / mflow_val * portA.mflow;        // pressure drop

   portA.hOut = inStream(portB.hOut);    // enthalpy stream at portA
   portB.hOut = inStream(portA.hOut);    // enthalpy stream at portB

    annotation (Icon(graphics={Polygon(
            points={{-100,100},{-100,-100},{0,0},{-100,100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid), Polygon(
            points={{100,100},{100,-100},{98,-96},{0,0},{100,100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}));
  end Valve;

  model Sensor
    Fluidconnector portA annotation (Placement(transformation(extent={{-70,-10},{-50,
              10}}), iconTransformation(extent={{-70,-10},{-50,10}})));
    Fluidconnector portB annotation (Placement(transformation(extent={{48,-10},{68,
              10}}), iconTransformation(extent={{48,-10},{68,10}})));
       Water fluid;
       Real T;          // temperature in K
       Real mflow;      // mass flow rate kg/s

  equation
    portA.mflow + portB.mflow = 0;        // mass flow balance

    portA.hOut = inStream(portB.hOut);    // enthalpy stream at port A
    portB.hOut = inStream(portA.hOut);    // enthalpy stream at port B

    portA.p = portB.p;
    fluid.p = portA.p;
    fluid.h = actualStream(portA.hOut);
    mflow = portA.mflow;
    T = fluid.T;

       annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Ellipse(
            extent={{-60,60},{58,-60}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Line(points={{-22,-40},{20,-40},{16,-34}}, color={0,0,0}),
          Line(points={{20,-40},{16,-46}}, color={0,0,0}),
          Text(
            extent={{-100,100},{98,60}},
            textColor={0,0,0},
            textString=DynamicSelect("T","T="+String(T))),
          Text(
            extent={{-180,-60},{180,-98}},
            textColor={0,0,0},
            textString=DynamicSelect("mflow","mflow="+String(mflow)))}),                                                          Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end Sensor;

  model StorageTank
    Fluidconnector portA annotation (Placement(transformation(extent={{-110,-10},{
              -90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
    Fluidconnector portB annotation (Placement(transformation(extent={{90,-10},{110,
              10}}), iconTransformation(extent={{90,-10},{110,10}})));
    Water fluid;
    parameter Real Ta_tank = 300;          // temperature in K
    parameter Real kA_tank = 10;           // insulation of storage tank W/K
    parameter SI.Volume V_tank = 300e-3;    // volume in m3 (300 L)

  initial equation
    fluid.T = 300;                          // initial condition

  equation
    portA.mflow + portB.mflow = 0;          // mass flow balance
    portA.p = portB.p;
    fluid.p = portA.p;

    V_tank * fluid.d * der(fluid.u) =
            portA.mflow*actualStream(portA.hOut) + portB.mflow*actualStream(portB.hOut) - kA_tank*(fluid.T - Ta_tank);
                                      //  change in specific internal energy where der(fluid.u) is from dU/dt = HA + HB + Losses

            portA.hOut = fluid.h;
            portB.hOut = fluid.h;

      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Rectangle(
            extent={{-100,80},{100,-80}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{-100,100},{100,60}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Ellipse(
            extent={{-100,-60},{100,-100}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
            preserveAspectRatio=false)));
  end StorageTank;

  model SolarCollector
   Fluidconnector portA annotation (Placement(transformation(extent={{-110,-10},{
             -90,10}}), iconTransformation(extent={{-110,-10},{-90,10}})));
   Fluidconnector portB annotation (Placement(transformation(extent={{90,-10},{110,
             10}}), iconTransformation(extent={{90,-10},{110,10}})));
   Water fluid;
   parameter Real Ta_sol = 300;              // temperature in K
   parameter Real kA_sol = 60;               // insulation of storage tank W/K
   parameter SI.Volume V_sol = 1e-3;         // volume in m3 (1 L)

   parameter SI.Irradiance g = 1000;
   parameter SI.Area A_sol = 9;              // surface area in m2
   parameter SI.Efficiency eta = 0.6;      // efficiency of solar collector

  initial equation
   fluid.T = 290;                        // initial condition

  equation
   portA.mflow + portB.mflow = 0;          // mass flow balance
   portA.p = portB.p;

   fluid.p = portA.p;

   V_sol * fluid.d * der(fluid.u) = portA.mflow*actualStream(portA.hOut) + portB.mflow*actualStream(portB.hOut) - kA_sol*(fluid.T - Ta_sol)+ g* A_sol*eta;
                                    //  change in specific internal energy where der(fluid.u) is from dU/dt = HA + HB + Losses

           portA.hOut = fluid.h;
           portB.hOut = fluid.h;

     annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
         Polygon(
           points={{140,100},{60,-100},{-140,-100},{-60,100},{140,100}},
           lineColor={0,0,0},
           fillColor={255,255,255},
           fillPattern=FillPattern.Solid),
         Line(points={{-82,130},{-36,22}}, color={0,0,0}),
         Line(points={{-36,22},{-32,40}}, color={0,0,0}),
         Line(points={{-36,22},{-48,28}}, color={0,0,0}),
         Line(points={{18,138},{64,30}}, color={0,0,0}),
         Line(points={{64,30},{68,48}}, color={0,0,0}),
         Line(points={{62,32},{50,38}}, color={0,0,0})}),
                                             Diagram(coordinateSystem(
           preserveAspectRatio=false)));
  end SolarCollector;

  model ExpansionTank

    parameter Real p = 1e5;  // pressure in bar
    parameter Real T = 300;  // temperature in K

    Water fluid;

    Fluidconnector port annotation (Placement(transformation(extent={{-10,-110},{10,
              -90}}), iconTransformation(extent={{-10,-110},{10,-90}})));
  equation
    fluid.T = T;
    fluid.p = p;
    port.p = p;
    port.hOut = fluid.h;

    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(extent={{-80,80},{80,-100}},lineColor={0,0,0}), Ellipse(
            extent={{-80,100},{80,60}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}),                           Diagram(
          coordinateSystem(preserveAspectRatio=false)));

  end ExpansionTank;

  model SolarSystem_Complete
    Pump pump annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-40,30})));
    Valve valve annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={70,22})));
    StorageTank storagetank
      annotation (Placement(transformation(extent={{30,-58},{50,-38}})));
    Sensor sensor annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-40,2})));
    Sensor sensor1 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={44,62})));
    Sensor sensor2 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={70,-14})));
    Sensor sensor3 annotation (Placement(transformation(extent={{-4,-58},{16,
              -38}},
            rotation=0)));
    SolarCollector solarCollector
      annotation (Placement(transformation(extent={{-12,52},{8,72}})));
    ExpansionTank expansiontank
      annotation (Placement(transformation(extent={{-80,-34},{-60,-14}})));
  equation
    connect(pump.portA, sensor.portB)
      annotation (Line(points={{-40,20},{-40,7.8}},  color={0,0,0}));
    connect(sensor1.portB, valve.portB)
      annotation (Line(points={{49.8,62},{70,62},{70,32}},  color={0,0,0}));
    connect(valve.portA, sensor2.portA)
      annotation (Line(points={{70,12},{70,-8}},color={0,0,0}));
    connect(sensor2.portB, storagetank.portB)
      annotation (Line(points={{70,-19.8},{70,-48},{50,-48}}, color={0,0,0}));
    connect(sensor3.portB, storagetank.portA)
      annotation (Line(points={{11.8,-48},{30,-48}}, color={0,0,0}));
    connect(pump.portB, solarCollector.portA)
      annotation (Line(points={{-40,40},{-40,62},{-12,62}}, color={0,0,0}));
    connect(solarCollector.portB, sensor1.portA)
      annotation (Line(points={{8,62},{38,62}},   color={0,0,0}));
    connect(sensor.portA, sensor3.portA)
      annotation (Line(points={{-40,-4},{-40,-48},{0,-48}}, color={0,0,0}));
    connect(expansiontank.port, sensor3.portA)
      annotation (Line(points={{-70,-34},{-70,-48},{0,-48}}, color={0,0,0}));
    annotation (
      Icon(coordinateSystem(preserveAspectRatio=false)),
      Diagram(coordinateSystem(preserveAspectRatio=false)),
      experiment(
        StopTime=600,
        __Dymola_NumberOfIntervals=60000,
        __Dymola_Algorithm="Dassl"));
  end SolarSystem_Complete;
  annotation (uses(Modelica(version="4.0.0")));
end ThermalSolarSystem;
