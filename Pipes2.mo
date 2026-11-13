model Pipes2

import Modelica.Blocks.Interfaces;

//Inputtemperature is a temporary code to test this code
extends Inputtemperature;
extends Weather;

//Parameters

final constant Real pi = 2*Modelica.Math.asin(1.0); // 3.14159265358979;
//Pipe geometry
parameter Real Pipes_lenght (unit="m") "Pipe length";
parameter Real Internal_diameter (unit="m") "Pipe internal diameter";
parameter Real External_diameter (unit="m") "Pipe external diameter";
parameter Real Burial_Depth (unit="m") "Pipe burial depth";
parameter Real Distance_pipes (unit="m") "Distance between pipes";
parameter Real Area_pipes (unit="m2") = pi * ((Internal_diameter)^2)/4  "Pipe area";


//Thermic properties
parameter Real Thickness (unit="m") "Thickness isolation";
parameter Real Heat_Conductivity_Isol (unit="W/(m.K)") "Heat conductivity isolation";
parameter Real CpWater (unit="J/kg.K") "Specific heat Cp water";
parameter Real Density_Water (unit="kg/m3") "Density water";
parameter Real Soil_Thermal_Conductivity (unit="W/(m.K)") "Soil thermal conductivity";

//Variables
Real Heat_Transmission_Coefficient (unit="W/(m^2.K)") "Heat transmission of the pipes";
Real Heat_Loss (unit="W") "Heat loss without influence of the other pipes";
Real T_Outlet_Pipe (unit="K") "Temperature at the outlet of the pipe";
Real v(unit="m/s") "speed of the water";
Real D_casing (unit="m") "Total external diameter with insulation";
Real R_isolation (unit="m²·K/W");
Real R_ground (unit="m²·K/W");



equation
//Heat transmission of the pipes
  Heat_Transmission_Coefficient = Thickness/Heat_Conductivity_Isol;
  
//Total external diameter with insulation
  D_casing = External_diameter + 2*Thickness;
  
//Resistance isolation
  R_isolation = 1 / (2 * Modelica.Constants.pi * Heat_Conductivity_Isol) * Modelica.Math.log(D_casing / External_diameter);

//Resistance ground 
  R_ground = 1 / (2 * Modelica.Constants.pi * Soil_Thermal_Conductivity) * Modelica.Math.log((4 * Burial_Depth) / D_casing);

//Heat loss of the pipe 
  Heat_Loss = (Tin - TGround) / (R_isolation + R_ground);
  
//Temperature drop along the pipes
  T_Outlet_Pipe = TGround + (Tin - TGround) * Modelica.Math.exp(-Pipes_lenght / (m_flow * CpWater * (R_isolation + R_ground)));  
  
// Speed of the water
  v = m_flow/(Density_Water*Area_pipes);



  
  
  annotation(
    Icon(graphics = {Ellipse(origin = {47, -3}, lineColor = {0, 0, 255}, lineThickness = 2, extent = {{-37, 37}, {37, -37}}), Ellipse(origin = {-44, -3}, lineColor = {255, 0, 0}, lineThickness = 2, extent = {{-37, 37}, {37, -37}})}),
  Diagram(graphics));
end Pipes2;
