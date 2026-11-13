model ControlSystem

import Modelica.Blocks.Interfaces;

//Minimal temperature
parameter Real T_min (unit="K") = 60 + 273.15;
//Maximal temperature 
parameter Real T_max (unit="K") = 115 + 273.15;

Interfaces.RealInput T_out_pipe1(unit="K") "Temperature at HeatPort 1";
Interfaces.RealInput T_out_pipe2(unit="K") "Temperature at HeatPort 2";
Interfaces.RealInput T_out_pipe3(unit="K") "Temperature at HeatPort 3";
Interfaces.RealInput T_out_pipe4(unit="K") "Temperature at HeatPort 4";
Interfaces.RealInput T_out_pipe5(unit="K") "Temperature at HeatPort 5";
Interfaces.RealInput T_out_pipe6(unit="K") "Temperature at HeatPort 6";
Interfaces.RealInput T_out_pipe7(unit="K") "Temperature at HeatPort 7";
Interfaces.RealInput T_out_pipe8(unit="K") "Temperature at HeatPort 8";

//True = on / False = Off
Interfaces.BooleanOutput turn_on;
Interfaces.BooleanOutput turn_off;


equation


turn_off = (T_out_pipe1 < T_min or T_out_pipe1 > T_max) or
             (T_out_pipe2 < T_min or T_out_pipe2 > T_max) or
             (T_out_pipe3 < T_min or T_out_pipe3 > T_max) or
             (T_out_pipe4 < T_min or T_out_pipe4 > T_max) or
             (T_out_pipe5 < T_min or T_out_pipe5 > T_max) or
             (T_out_pipe6 < T_min or T_out_pipe6 > T_max) or
             (T_out_pipe7 < T_min or T_out_pipe7 > T_max) or
             (T_out_pipe8 < T_min or T_out_pipe8 > T_max);

turn_on = not turn_off;


end ControlSystem;
