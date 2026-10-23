model WeatherProfile
  "Simple periodic outdoor-temperature and solar-radiation boundary model"
  parameter SI.Temperature TMean=278.15
    "Annual mean outdoor temperature";
  parameter SI.TemperatureDifference TDailyAmplitude=5
    "Daily outdoor-temperature swing";
  parameter SI.TemperatureDifference TSeasonAmplitude=10
    "Seasonal outdoor-temperature swing";
  parameter SI.Time year=365*86400;
  parameter SI.Time day=86400;

  output SI.Temperature TOutdoor
    "Outdoor dry-bulb temperature";
  output Real solarGain(unit="W/m2")
    "Idealized global solar irradiance";
equation
  // Annual cosine gives the slow seasonal change. The second cosine produces
  // a daily variation with the warmest time shifted toward mid-afternoon.
  TOutdoor = TMean
    + TSeasonAmplitude*cos(2*Modelica.Constants.pi*time/year)
    + TDailyAmplitude*cos(2*Modelica.Constants.pi*(time-15*3600)/day);

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
end WeatherProfile;
