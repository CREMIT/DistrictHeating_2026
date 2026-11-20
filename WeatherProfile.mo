model WeatherProfile "Periodic outdoor temperature, global horizontal irradiance, wind speed and ground temperature profile"
  import SI = Modelica.Units.SI;
  import Modelica.Constants.pi;
  // ------------------------------------------------------------------ Climate
  parameter SI.Temperature TMean = 278.15 "Annual mean outdoor temperature (Poulsbo ~10.7 degC => 283.85 K)";
  parameter SI.TemperatureDifference TDailyAmplitude = 5 "Daily outdoor-temperature swing (peak-to-mean)";
  parameter SI.TemperatureDifference TSeasonAmplitude = 10 "Seasonal outdoor-temperature swing (peak-to-mean)";
  parameter SI.Time tWarmest = 200*86400 "Time of the warmest day, counted from simulation start";
  // ------------------------------------------------------------ Ground profile
  parameter SI.Length depth = 1.5 "Depth below the ground surface where TGround is evaluated (buried pipes ~1-2 m)";
  parameter SI.ThermalDiffusivity alphaSoil = 0.5e-6 "Soil thermal diffusivity (dry sand ~0.3e-6, moist clay/loam ~0.5e-6, wet rock ~1e-6 m2/s)";
  parameter SI.TemperatureDifference dTGroundMean = 0 "Offset of the mean ground temperature with respect to TMean (e.g. snow cover, shading)";
  parameter SI.Time tWarmestDay = 15*3600 "Time of day of the warmest surface temperature";
  // Damped-wave solution of the 1-D heat equation in a semi-infinite soil:
  //   amplitude(z) = A*exp(-z/d_p),  phase lag(z) = z/d_p,
  //   damping depth d_p = sqrt(alpha*P/pi)   (P = period of the wave)
  final parameter SI.Length dampingDepthAnnual = sqrt(alphaSoil*year/pi) "Damping depth of the annual wave (about 2.2 m for alpha = 0.5e-6)";
  final parameter SI.Length dampingDepthDaily = sqrt(alphaSoil*day/pi) "Damping depth of the daily wave (about 0.12 m for alpha = 0.5e-6)";
  final parameter Real DampingAnnualCoeff(unit = "1/m") = 1/dampingDepthAnnual "Attenuation coefficient k of the annual wave: exp(-k*depth)";
  final parameter Real DampingDailyCoeff(unit = "1/m") = 1/dampingDepthDaily "Attenuation coefficient of the daily wave";
  final parameter Real PhaseShiftAnnualCoeff(unit = "rad/m") = 1/dampingDepthAnnual "Phase lag per metre of the annual wave";
  final parameter Real PhaseShiftDailyCoeff(unit = "rad/m") = 1/dampingDepthDaily "Phase lag per metre of the daily wave";
  // ------------------------------------------------------------------- Solar
  parameter Real GPeak(unit = "W/m2") = 1000 "Peak solar irradiance at solar noon (used only if seasonalSolar = false)";
  parameter Boolean seasonalSolar = true "true: noon peak follows the seasonal daily irradiation H(t) below";
  parameter Real HMean(unit = "kWh/(m2.d)") = 3.48 "Annual mean daily irradiation (Poulsbo, PVWatts, Task 2 Fig. 3)";
  parameter Real HAmplitude(unit = "kWh/(m2.d)") = 2.8 "Seasonal swing of the daily irradiation (Jul 6.47, Dec 0.90)";
  parameter SI.Time tSunniest = 190*86400 "Time of the sunniest day";
  parameter SI.Time tSunrise = 6*3600 "Sunrise (half-sine model)";
  parameter SI.Time tSunset = 18*3600 "Sunset (half-sine model)";
  // -------------------------------------------------------------------- Wind
  parameter SI.Velocity vWindMean = 3 "Annual mean wind speed";
  parameter SI.Velocity vWindAmplitude = 1.5 "Seasonal wind-speed swing";
  parameter SI.Time tWindiest = 30*86400 "Time of the windiest day";
  parameter SI.Velocity vWindMin = 0.5 "Lower clip of the wind speed";
  // -------------------------------------------------------------- Parameters
  parameter SI.Time year = 365*86400 "Length of the simulated year";
  parameter SI.Time day = 86400 "Length of one day";
  // ---------------------------------------------------------------- Connectors
  Modelica.Blocks.Interfaces.RealOutput TOutdoor(final quantity = "ThermodynamicTemperature", final unit = "K", displayUnit = "degC") "Outdoor dry-bulb temperature" annotation(
    Placement(transformation(extent = {{100, 40}, {120, 60}})));
  Modelica.Blocks.Interfaces.RealOutput solarGain(final unit = "W/m2") "Global horizontal irradiance" annotation(
    Placement(transformation(extent = {{100, -10}, {120, 10}})));
  Modelica.Blocks.Interfaces.RealOutput windSpeed(final unit = "m/s") "Wind speed at 10 m (used by the envelope convection coefficient)" annotation(
    Placement(transformation(extent = {{100, -60}, {120, -40}})));
  Modelica.Blocks.Interfaces.RealOutput TGround(final quantity = "ThermodynamicTemperature", final unit = "K", displayUnit = "degC") "Undisturbed ground temperature at the given depth" annotation(
    Placement(transformation(extent = {{100, -110}, {120, -90}})));
  // ---------------------------------------------------------------- Variables
  Real H(unit = "kWh/(m2.d)") "Daily global horizontal irradiation";
  Real GPeakDay(unit = "W/m2") "Noon peak of the half-sine on the current day";
  SI.Temperature TSurface "Ground surface temperature (= outdoor air, no snow/solar offset)";
equation
// Seasonal cosine plus a daily cosine (warmest time 15:00).
  TOutdoor = TMean + TSeasonAmplitude*cos(2*pi*(time - tWarmest)/year) + TDailyAmplitude*cos(2*pi*(time - tWarmestDay)/day);
// Ground temperature at depth z: each wave is attenuated by exp(-z/d_p) and
// delayed by z/d_p radians. The phase is referred to the same warmest times as
// the outdoor air, so the ground is warmest in autumn (lag of ~40 days at 1.5 m).
  TSurface = TOutdoor;
  TGround = TMean + dTGroundMean + TSeasonAmplitude*exp(-DampingAnnualCoeff*depth)*cos(2*pi*(time - tWarmest)/year - PhaseShiftAnnualCoeff*depth) + TDailyAmplitude*exp(-DampingDailyCoeff*depth)*cos(2*pi*(time - tWarmestDay)/day - PhaseShiftDailyCoeff*depth);
// Solar radiation as a half-wave sinusoid: sunrise 06:00, noon peak, sunset 18:00.
// max() clips the night-time negative half-cycle.
// Half-sine over 12 h integrates to GPeakDay*12h*2/pi, so GPeakDay = pi/24*H*1000.
  H = HMean + HAmplitude*cos(2*pi*(time - tSunniest)/year);
  GPeakDay = if seasonalSolar then pi/24*1000*H else GPeak;
  solarGain = GPeakDay*max(0, sin(pi*(time - tSunrise)/(tSunset - tSunrise)));
// Slow seasonal wind variation, always positive.
  windSpeed = max(vWindMin, vWindMean + vWindAmplitude*cos(2*pi*(time - tWindiest)/year));
  annotation(
    experiment(StartTime = 0, StopTime = 604800, Interval = 600, Tolerance = 1e-6),
    Icon(graphics = {Ellipse(extent = {{-70, 70}, {70, -70}}, lineColor = {220, 140, 0}, fillColor = {255, 220, 80}, fillPattern = FillPattern.Solid), Line(points = {{0, 100}, {0, 76}}, color = {220, 140, 0}, thickness = 2), Line(points = {{0, -76}, {0, -100}}, color = {220, 140, 0}, thickness = 2), Line(points = {{76, 0}, {100, 0}}, color = {220, 140, 0}, thickness = 2), Line(points = {{-76, 0}, {-100, 0}}, color = {220, 140, 0}, thickness = 2), Text(extent = {{-100, -82}, {100, -110}}, textString = "Weather")}),
    Documentation(info = "<html>
<p>Simple <b>periodic</b> weather boundary model. It is not a weather file: it
reproduces the annual and daily cycles of the Poulsbo (WA) climate that were
used in Task 2, plus the temperature of the ground at the depth of the buried
pipes.</p>

<h4>Outdoor temperature</h4>
<p><code>T = TMean + TSeasonAmplitude*cos(2*pi*(t-tWarmest)/year)
 + TDailyAmplitude*cos(2*pi*(t-15h)/day)</code></p>
<p>Default values give about 4.5 &deg;C in January and 19 &deg;C in August,
which matches Fig. 1 of Task 2.</p>

<h4>Ground temperature profile</h4>
<p>Solution of the 1-D heat equation in a semi-infinite soil driven by a
sinusoidal surface temperature. For a wave of period <code>P</code> the damping
depth is <code>d = sqrt(alpha*P/pi)</code> and at depth <code>z</code>:</p>
<p><code>T(z,t) = TMean + A*exp(-z/d)*cos(2*pi*(t-tWarmest)/P - z/d)</code></p>
<p>The annual and the daily wave are added. With <code>alphaSoil = 0.5e-6</code>
m&sup2;/s: <code>d_annual = 2.2 m</code>, <code>d_daily = 0.12 m</code>. At
<code>depth = 1.5 m</code> the annual swing is reduced to about 51 % (3.7 K) and
delayed by about 40 days; the daily wave practically disappears. The damping and
phase coefficients are <b>derived</b> from <code>alphaSoil</code>, so only
<code>depth</code> and <code>alphaSoil</code> need to be set.</p>
<p><code>TGround</code> is meant for the <code>ambient</code> port of the
<code>Pipe</code> blocks (through a <code>PrescribedTemperature</code>).</p>

<h4>Solar irradiance</h4>
<p>A half sine wave between 06:00 and 18:00 solar time. Its amplitude is chosen
so that the daily energy matches the monthly mean daily irradiation of
PVWatts (Fig. 3 of Task 2): <code>GPeak = pi/24 * H</code> with
<code>H</code> in kWh/(m&sup2;&middot;d). Only the <b>global horizontal</b>
irradiance is provided; <code>BuildingLoads</code> splits it into beam and
diffuse with the Erbs correlation and projects it on every facade.</p>

<h4>Wind</h4>
<p>The course notes suggest including wind speed to improve the calculation of
the envelope losses. <code>BuildingLoads</code> uses it in
<code>h = 2.8 + 3*Vwind</code> (Eq. 3 of Task 2).</p>

<h4>Assumptions and limitations</h4>
<ul>
<li>No cloud transients: every day has the same shape, only the amplitude
    changes with the season. Real irradiance has much more variance.</li>
<li>No humidity and no rain. The Task 2 model does include a latent load, but
    it is controlled by constant humidity ratios.</li>
<li>Solar time = simulation time (no equation of time, no longitude
    correction).</li>
<li>Homogeneous soil, constant diffusivity, no snow cover, no moisture
    movement, and the surface temperature equals the air temperature.</li>
</ul>
</html>"));
end WeatherProfile;
