model Weather

import Modelica.Units.SI;

  parameter SI.Temperature TMean=278.15
    "Annual mean outdoor temperature";
  parameter SI.TemperatureDifference TDailyAmplitude=5
    "Daily outdoor-temperature swing";
  parameter SI.TemperatureDifference TSeasonAmplitude=10
    "Seasonal outdoor-temperature swing";
  parameter SI.Time year=365*86400;
  parameter SI.Time day=86400;
 
  parameter SI.Length depth
    "Depth below ground surface";
  parameter Real DampingAnnualCoeff
    "Attenuation coefficient for annual wave";
  parameter Real DampingDailyCoeff
    "Attenuation coefficient for dayli wave";
  parameter Real PhaseShiftAnnualCoeff
    "Phase shift coefficient";
  parameter Real PhaseShiftDailyCoeff
    "Phase shift coefficient";
 
  parameter SI.Velocity vWind
    "Wind speed (constant)";


  output SI.Temperature TOutdoor
    "Outdoor dry-bulb temperature";
  output Real solarGain(unit="W/m2")
    "Idealized global solar irradiance";
  output SI.Temperature TGround
    "Ground temperature at specified depth";
    
  output SI.Velocity WindSpeed
   "Wind speed for convection losses";
  
equation
  // Annual cosine gives the slow seasonal change. The second cosine produces
  // We assume that the daily variation is useless for the ground
  TOutdoor = TMean
    + TSeasonAmplitude*cos(2*Modelica.Constants.pi*time/year)
    + TDailyAmplitude*cos(2*Modelica.Constants.pi*(time-15*3600)/day);
    
  // Ground temperature with depth and damping, and phase lag
  // a daily variation with the warmest time shifted toward mid-afternoon.
  TGround = TMean
    + TSeasonAmplitude*exp(- DampingAnnualCoeff * depth) * cos(2*Modelica.Constants.pi*time/year - PhaseShiftAnnualCoeff * depth)
    + TDailyAmplitude*exp(- DampingDailyCoeff * depth) * cos(2*Modelica.Constants.pi*(time-15*3600)/day - PhaseShiftDailyCoeff * depth) ;

  // Wind speed (constant) 
  WindSpeed = vWind ;

  
  // Solar radiation is represented by a half-wave sinusoid. positivePart()
  // suppresses the negative night-time half-cycle without a hard event.
  solarGain = 350*positivePart(
    sin(2*Modelica.Constants.pi*(time-6*3600)/day));
 

  annotation(Icon(graphics={
    Ellipse(extent={{-70,70},{70,-70}}, lineColor={220,140,0}, fillColor={255,220,80}, fillPattern=FillPattern.Solid),
    Line(points={{0,100},{0,76}}, color={220,140,0}, thickness=2),
    Line(points={{0,-76},{0,-100}}, color={220,140,0}, thickness=2),
    Line(points={{76,0},{100,0}}, color={220,140,0}, thickness=2),
    Line(points={{-76,0},{-100,0}}, color={220,140,0}, thickness=2),
    Text(extent={{-100,-82},{100,-110}}, textString="Weather")}));
end Weather;
