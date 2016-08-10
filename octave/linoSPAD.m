%// linoSPAD Laser power due to scanning methods
function linoSPAD(tab_path)

% arg_list = argv ();


constants_and_variables;

% if(size(arg_list,1)>0)
	% tab_path = sprintf('%s',arg_list{1})
% else
	% tab_path = '../report/test'
% end

% calculate optics performance

f_number = 2;
absorption = 0.05;
opacity = (1-absorption)/f_number^2;
basic_optics_tab;
%//----------------- calculate max pulsefrequency

roundtrip_time = max_altitude.*2./3e8;
f_pulse = 1./roundtrip_time;

%//----------------- calculate sun irradiation

I_lambda = 2*h*c^2/lambda^5/(e^(h*c/(lambda*k*T))-1);%// [W/m^3]

%//----------------- calculate background power on target area

no_spads = [surface_length^2/resolution^2 surface_length^2/resolution^2 ...
 surface_length*line_width/resolution surface_length*line_width/resolution];

pulse_s = [1 1/roundtrip_time(2) ...
surface_length/resolution/line_width 1/roundtrip_time(2)];

window = [roundtrip_time(2) roundtrip_time(2) ...
 roundtrip_time(2) roundtrip_time(2)];

exposure_time = pulse_s.*window;

surface_area = no_spads.*resolution.^2;


P_B = I_lambda*Bw*surface_area(1)*(r_sun^2/r_europa^2); %// [W]

%//----------------- calculate background power at SPAD area

P_B2 = P_B*reflectivity*diameter_lens*opacity_optics/(2*max_altitude(2)^2); %// [W]

%//----------------- calculate energy of photon

e_photon = h*c/lambda;

% Photons hitting SPADs

photons_hittings_SPAD = P_B2/e_photon;
photons_hitting_SPADs

%//----------------- calculate number of background photons that are detected per second

effective_area = 0.5; % percentage of surface area that is sensitive
PPS_B = photons_hittings_SPAD*PDP*effective_area;

% calculate the amount of detected signal photons per watt of electrical energy

P_S = 1;
P_S2 = P_S*reflectivity*diameter_lens*opacity_optics/(2*max_altitude(1)^2); %// [W]
PS_hittings_SPAD = P_S2/e_photon;
PPS_S = PS_hittings_SPAD*PDP*effective_area;
PPS_S_tab

% intermezzo calculating required average power to match noise power at max altitude  

lim_P_av = P_B*max_altitude(1)^2/max_altitude(2)^2;
p_av_matching

% calculate the requirements for altimetry mode

AM_altitude = [max_altitude(2), max_altitude(1)];
AM_resolution = AM_altitude.*0.001; % 0.1% resolution
AM_FWHM = AM_resolution.*2./c;
AM_sigma = AM_FWHM./(2*sqrt(2*log(2)));

AM_requirements_tab

% --- calculate some graphs
f_pulse_tab 
sun_irradiation_tab
background_power_tab
energy_of_photon_tab

%%
%% HAZARD DETECTION MODE
%%
pixels = 2048*8;
PPS_B
PPS_S
PPSS_B = PPS_B/pixels/2048*8; 
PPSS_S = PPS_S*max_altitude(1)^2/(max_altitude(2)^2)/pixels;
PPSS_N = 2000;

photons_per_SPAD_tab

%//----------------- calculate number of unwanted photons detected per SPAD per second

PPS_B2 = PPS_B.*surface_area.*exposure_time./surface_length^2;
DCR = no_spads.*DCR_SPAD.*exposure_time;
PPS_BN = DCR+PPS_B2;
PPS_BN_SPAD = PPS_BN./no_spads;

%//----------------- calculate the average and peak optical laser power 

sigma_n = window./sqrt(12);
sigma_s = pulse_FWHM/2.35;

C = (FWHM/2.35)^2.*pulse_s./surface_length^2.*surface_area;
n = PPS_BN_SPAD;

PPS_S_SPAD = n.*(sigma_n.^2-C)./(C-sigma_s^2);

P_av = PPS_S_SPAD/PPS_B*P_B.*no_spads;
P_peak = P_av./pulse_s./pulse_FWHM;

%//----------------- calculate threshold and effect of threshold

PPS_B_BIN = (PPS_BN_SPAD./window.*bin_width);
threshold = ceil(PPS_B_BIN*2);
threshold = [2 70 5 70];

for i=1:4
	average = PPS_B_BIN(i);
	accumulation(i)=0;
	for events = (threshold(i)+1):threshold(i)+100
		Poission_events = average.^events.*exp(-average)./factorial(events);
		%chance of a number getting dropped times the amount of photons dropped
		accumulation(i) += Poission_events*events; 
	end
end

PPS_BN_SPAD_2 = accumulation.*window./bin_width;
n = PPS_BN_SPAD_2;
PPS_S_SPAD_2 = n.*(sigma_n.^2-C)./(C-sigma_s^2);
P_av_2 = PPS_S_SPAD_2/PPS_B*P_B.*no_spads;
P_peak_2 = P_av_2./pulse_s./pulse_FWHM;


%//----------------- make all latex tables
scanning_power_tab
effective_noise_power_tab
PPS_tab
