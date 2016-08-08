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

PPS_B = P_B2*PDP/e_photon;

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
f_pulse_tab 
sun_irradiation_tab
background_power_tab
energy_of_photon_tab
scanning_power_tab
effective_noise_power_tab
PPS_tab
