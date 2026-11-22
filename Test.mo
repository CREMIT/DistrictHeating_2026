model Test
  WeatherProfile weatherProfile annotation(
    Placement(transformation(origin = {-82, 82}, extent = {{-10, -10}, {10, 10}})));
  PumpModel pumpModel annotation(
    Placement(transformation(origin = {18, -54}, extent = {{-10, -10}, {10, 10}})));
  Pipes2 pipes2(Pipes_lenght = 1000, Internal_diameter = 0.2, External_diameter = 0.22, Burial_Depth = 3, Distance_pipes = 1.5, Thickness = 0.00045, Heat_Conductivity_Isol = 0.0025, CpWater = 4185, Density_Water = 1000, Soil_Thermal_Conductivity = 1)  annotation(
    Placement(transformation(origin = {-2, 54}, extent = {{-10, -10}, {10, 10}})));
  ControlSystem controlSystem annotation(
    Placement(transformation(origin = {-54, -4}, extent = {{-10, -10}, {10, 10}})));
  Pipes2 pipes21(Burial_Depth = 3, CpWater = 4185, Density_Water = 1000, Distance_pipes = 1.5, External_diameter = 0.22, Heat_Conductivity_Isol = 0.0025, Internal_diameter = 0.2, Pipes_lenght = 750, Soil_Thermal_Conductivity = 1, Thickness = 0.00045) annotation(
    Placement(transformation(origin = {56, 40}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T(displayUnit = "K") = 353.15)  annotation(
    Placement(transformation(origin = {-38, 84}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(controlSystem.port[1], pipes2.port_out) annotation(
    Line(points = {{-64, -4}, {-64, -6}, {8, -6}, {8, 63}}, color = {191, 0, 0}));
  connect(controlSystem.turn_on, pumpModel.turn_on) annotation(
    Line(points = {{-42, -4}, {-42, -54}, {7, -54}}, color = {255, 0, 255}));
  connect(weatherProfile.TGround, pipes2.TGround_in) annotation(
    Line(points = {{-70, 72}, {-56, 72}, {-56, 46}, {-13, 46}}, color = {0, 0, 127}));
  connect(pumpModel.m_flow, pipes2.m_flow) annotation(
    Line(points = {{29, -54}, {-8, -54}, {-8, 22}, {-34, 22}, {-34, 54}, {-13, 54}}, color = {0, 0, 127}));
  connect(weatherProfile.TGround, pipes21.TGround_in) annotation(
    Line(points = {{-70, 72}, {-64, 72}, {-64, 32}, {45, 32}}, color = {0, 0, 127}));
  connect(controlSystem.port[2], pipes21.port_out) annotation(
    Line(points = {{-64, -4}, {-70, -4}, {-70, -80}, {80, -80}, {80, 49}, {66, 49}}, color = {191, 0, 0}));
  connect(pipes21.port_in, pipes2.port_out) annotation(
    Line(points = {{46, 49}, {46, 80}, {22, 80}, {22, 80.5}, {10, 80.5}, {10, 71.75}, {8, 71.75}, {8, 63}}, color = {191, 0, 0}));
  connect(pumpModel.m_flow, pipes21.m_flow) annotation(
    Line(points = {{29, -54}, {44, -54}, {44, 40}, {45, 40}}, color = {0, 0, 127}));
  connect(fixedTemperature.port, pipes2.port_in) annotation(
    Line(points = {{-28, 84}, {-28, 71.5}, {-12, 71.5}, {-12, 63}}, color = {191, 0, 0}));

annotation(
    uses(Modelica(version = "4.1.0")));
end Test;
