model ControlSystem
  import Modelica.Blocks.Interfaces;
  import Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a;
  import Modelica.Blocks.Logical.{Hysteresis, Or};

  // Number of Heatport tocontrol
  parameter Integer n = 2 "Number of control";

  parameter Real T_min(unit="K") = 60 + 273.15;
  parameter Real T_max(unit="K") = 115 + 273.15;
  parameter Real hysteresis_band(unit="K") = 0.5 "Dead band on T_min and T_max";

  // --- Connectors ---
  HeatPort_a port[n] "HeatPort connected to the pipes (red squares)"
    annotation (Placement(transformation(extent={{-110,-20},{-90,20}})));

  Interfaces.BooleanOutput turn_on(start = true) "Signal sent to the pump (pink triangle)"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));

  // Outings to observe temperatures (blue triangles)
Interfaces.RealOutput T_measure[n](each unit="K", each displayUnit="degC")     annotation (Placement(transformation(extent={{100,-50},{120,-30}})));

  // Internal logic components
  Hysteresis hyst_min[n](each uLow = -hysteresis_band, each uHigh = hysteresis_band, each pre_y_start = false);
  Hysteresis hyst_max[n](each uLow = -hysteresis_band, each uHigh = hysteresis_band, each pre_y_start = false);
  Or port_out_of_bounds[n];

equation
  for i in 1:n loop
    // 1. The controller does not consume energy (it simply listens)
    port[i].Q_flow = 0;

    // 2. The temperature reading is transmitted to the blue output for observation.
    T_measure[i] = port[i].T;

    // 3. Hysteresis logic that reads the port temperature directly
    hyst_min[i].u = T_min - port[i].T;
    hyst_max[i].u = port[i].T - T_max;

    // 4. True if sensor i is out of range
    connect(hyst_min[i].y, port_out_of_bounds[i].u1);
    connect(hyst_max[i].y, port_out_of_bounds[i].u2);
  end for;

  // 5. Final pump signal
  turn_on = not Modelica.Math.BooleanVectors.anyTrue({port_out_of_bounds[i].y for i in 1:n});

  annotation(
    Icon(graphics = {
      Rectangle(extent = {{-100, 100}, {100, -100}}, fillColor = {240, 240, 240}, fillPattern = FillPattern.Solid), 
      Text(extent = {{-80, 30}, {80, -30}}, textString = "Control\nSystem")
    }));
end ControlSystem;
