%constants
h = 6.63e-34; % ['Js]']
c = 3e8; % [m/s]
k = 1.38e-23; % [j/K]
T = 5780; % [K]
r_sun = 695700e3; % [m]
r_europa = 778.5e9; % [m]



%variables
max_altitude = [8000 500];

lambda = 850e-9; % [m]

resolution = 0.05; % [m]
surface_length = 125; % [m²]
line_width = 4;

Bw = 10e-9; % bandwidth [m]

reflectivity = 0.35; % [-]
diameter_lens = 0.05; % [m]
opacity_optics = 0.1175; % [-]

PDP = 0.10; % [-]
DCR_SPAD = 200; % [Hz]

FWHM = 333e-12; % [m]
pulse_FWHM = 100e-12; % [s]

bin_width = 100e-12; % [s]

