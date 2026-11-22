model Pipes2
  import Modelica.Blocks.Interfaces;
  import Modelica.Thermal.HeatTransfer.Interfaces.{HeatPort_a, HeatPort_b};  
    
Interfaces.RealInput m_flow(unit = "kg/s") "Mass flow rate from PumpModel" annotation(
    Placement(transformation(extent = {{-120, 40}, {-100, 60}}), iconTransformation(origin = {0, -50}, extent = {{-120, 40}, {-100, 60}})));
    
    
Interfaces.RealInput TGround_in(unit = "K", displayUnit = "degC") "Undisturbed ground temperature from weather profile" annotation(
    Placement(transformation(origin = {0, -20}, extent = {{-120, -70}, {-100, -50}}), iconTransformation(origin = {0, -20}, extent = {{-120, -70}, {-100, -50}})));

Real Tin(unit = "K") "Inlet temperature read from port_in";
 
  //HeatPorts
  HeatPort_a port_in "Inlet heat port" annotation(
   Placement(transformation(origin = {0, 80}, extent = {{-110, -10}, {-90, 10}}), iconTransformation(origin = {0, 86}, extent = {{-110, -10}, {-90, 10}})));
  HeatPort_b port_out "Outlet heat port" annotation(
    Placement(transformation(origin = {0, 80}, extent = {{90, -10}, {110, 10}}), iconTransformation(origin = {0, 86}, extent = {{90, -10}, {110, 10}})));
  
  //Parameters
  final constant Real pi = 2*Modelica.Math.asin(1.0);
  // 3.14159265358979;
   
  //Pipe geometry
  parameter Real Pipes_lenght(unit = "m") "Pipe length";
  parameter Real Internal_diameter(unit = "m") "Pipe internal diameter";
  parameter Real External_diameter(unit = "m") "Pipe external diameter";
  parameter Real Burial_Depth(unit = "m") "Pipe burial depth";
  parameter Real Distance_pipes(unit = "m") "Distance between pipes";
  parameter Real Area_pipes(unit = "m2") = pi*((Internal_diameter)^2)/4 "Pipe area";
  
  //Thermic properties
  parameter Real Thickness(unit = "m") "Thickness isolation";
  parameter Real Heat_Conductivity_Isol(unit = "W/(m.K)") "Heat conductivity isolation";
  parameter Real CpWater(unit = "J/kg.K") "Specific heat Cp water";
  parameter Real Density_Water(unit = "kg/m3") "Density water";
  parameter Real Soil_Thermal_Conductivity(unit = "W/(m.K)") "Soil thermal conductivity";
  
  //Variables
  Real Heat_Transmission_Coefficient(unit = "W/(m2.K)") "Heat transmission of the pipes";
  Real Heat_Loss_per_meter(unit = "W/m") "Heat loss without influence of the other pipes";
  Real Heat_Loss_Total(unit = "W") "Heat loss without influence of the other pipes";
  
  Real T_Outlet_Pipe(unit = "K", start = 353.15) "Temperature at the outlet of the pipe";  
  
  Real v(unit = "m/s") "speed of the water";
  Real D_casing(unit = "m") "Total external diameter with insulation";
  Real R_isolation(unit = "m.K/W");
  Real R_ground(unit = "m.K/W");
  
equation

Tin = port_in.T;
port_in.Q_flow = 0;


//Heat transmission of the pipes
  Heat_Transmission_Coefficient = Heat_Conductivity_Isol/Thickness;
  
//Total external diameter with insulation
  D_casing = External_diameter + 2*Thickness;
  
//Resistance isolation
  R_isolation = 1/(2*Modelica.Constants.pi*Heat_Conductivity_Isol)*Modelica.Math.log(D_casing/External_diameter);
  
//Resistance ground
  R_ground = 1/(2*Modelica.Constants.pi*Soil_Thermal_Conductivity)*Modelica.Math.log((4*Burial_Depth)/D_casing);
  
//Heat loss of the pipe
  Heat_Loss_per_meter = (Tin - TGround_in)/(R_isolation + R_ground);
  Heat_Loss_Total = max(m_flow, 1e-4)*CpWater*(Tin - T_Outlet_Pipe);
  
//Temperature drop along the pipes
  T_Outlet_Pipe = TGround_in + (Tin - TGround_in)*Modelica.Math.exp(-Pipes_lenght/(max(m_flow, 1e-4)*CpWater*(R_isolation + R_ground)));
  
// Speed of the water
  v = max(m_flow, 1e-4)/(Density_Water*Area_pipes);
  
//HeatPorts connections
  port_out.T = T_Outlet_Pipe;
  
  
  annotation(
    Icon(graphics = {Ellipse(origin = {47, -3}, lineColor = {0, 0, 255}, lineThickness = 2, extent = {{-37, 37}, {37, -37}}), Ellipse(origin = {-44, -3}, lineColor = {255, 0, 0}, lineThickness = 2, extent = {{-37, 37}, {37, -37}})}),
    Diagram);
end Pipes2;
