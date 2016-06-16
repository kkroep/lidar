% linoSPAD Laser power due to scanning methods


tab_path = '../tab/';




%% Pulse frequency graph
% 1 = altimetry, 2 = hazard
max_altitude = [8000 500];
roundtrip_time = max_altitude.*2./3e8;
f_pulse = 1./roundtrip_time;


%----------------------------------

h = 6.63e-34; % ['Js]']
c = 3e8; % [m/s]
k = 1.38e-23; % [j/K]
lambda = 850e-9; % [m]
T = 5780; % [K]

I_lambda = 2*h*c^2/lambda^5/(e^(h*c/(lambda*k*T))-1);% [W/m^3]







%-----------------------------------
resolution = 0.05; % [m]
surface_length = 125; % [m²]
line_width = 4;
Mode = 2; % pyut in hazard detection mode


no_spads = [surface_length^2/resolution^2 surface_length^2/resolution^2 ...
 surface_length*line_width/resolution surface_length*line_width/resolution];

pulse_s = [1 1/roundtrip_time(Mode) ...
 surface_length/resolution/line_width 1/roundtrip_time(Mode)];

window = [roundtrip_time(Mode) roundtrip_time(Mode) ...
 roundtrip_time(Mode) roundtrip_time(Mode)];

exposure_time = pulse_s.*window;

surface_area = no_spads.*resolution.^2;



%------------------------------------

Bw = 10e-9; % bandwidth [m]

r_sun = 695700; % [m]
r_europa = 8e8; % [m]
P_B = I_lambda*Bw*surface_area(1)*(r_sun^2/r_europa^2); % [W]

% -----------------

reflectivity = 0.35; % [-]
diameter_lens = 0.05; % [m]
opacity_filter = 0.5; % [-]
opacity_optics = 0.146; % [-]

P_B2 = P_B*reflectivity*diameter_lens*opacity_optics*opacity_filter/(2*max_altitude(2)^2); % [W]

%--------------------------

e_photon = h*c/lambda;


f_pulse_tab 
sun_irradiation_tab
background_power_tab
energy_of_photon_tab
scanning_power_tab
effective_noise_power_tab
