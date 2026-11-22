model PumpModel

import Modelica.Blocks.Interfaces;

// Fix mass flow of the pump
parameter Real m_flow_nominal (unit="kg/s") = 24;

//Inlet
Interfaces.BooleanInput turn_on "Signal from Control System" annotation(
    Placement(transformation(extent = {{-120, -10}, {-100, 10}})));
//Outlet
Interfaces.RealOutput m_flow(unit = "kg/s", start = m_flow_nominal) "Output mass flow" annotation(
    Placement(transformation(extent = {{100, -10}, {120, 10}})));

equation

m_flow = if turn_on then m_flow_nominal else 0.0;


annotation(
    Icon(graphics = {Ellipse( fillColor = {134, 180, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Polygon(origin = {18, -14}, lineThickness = 1, points = {{-18, 114}, {82, 14}, {-18, -86}, {-18, 114}})}));
end PumpModel;
