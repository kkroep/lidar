% linoSPAD Laser power due to scanning methods


tab_path = '../report/tab/';


%% Pulse frequency graph
% 1 = altimetry, 2 = hazard
max_altitude = [8000 500];
roundtrip_time = max_altitude.*2./3e8;
f_pulse = 1./roundtrip_time;

f_pulse_tab %make latex table