% linoSPAD Laser power due to scanning methods


constants_and_variables;
tab_path = '../tab/';

roundtrip_time = max_altitude.*2./3e8;
f_pulse = 1./roundtrip_time;

%----------------------------------

I_lambda = 2*h*c^2/lambda^5/(e^(h*c/(lambda*k*T))-1);% [W/m^3]

%-----------------------------------

no_spads = [surface_length^2/resolution^2 surface_length^2/resolution^2 ...
 surface_length*line_width/resolution surface_length*line_width/resolution];

pulse_s = [1 1/roundtrip_time(2) ...
 surface_length/resolution/line_width 1/roundtrip_time(2)];

window = [roundtrip_time(2) roundtrip_time(2) ...
 roundtrip_time(2) roundtrip_time(2)];

exposure_time = pulse_s.*window;

surface_area = no_spads.*resolution.^2;

%------------------------------------

P_B = I_lambda*Bw*surface_area(1)*(r_sun^2/r_europa^2); % [W]

% -----------------


P_B2 = P_B*reflectivity*diameter_lens*opacity_optics*opacity_filter/(2*max_altitude(2)^2); % [W]

%--------------------------

e_photon = h*c/lambda;

%-------------------------

PPS_B = P_B2*PDP/e_photon;

%---------------------------------------

PPS_B2 = PPS_B.*surface_area.*exposure_time./surface_length^2;
DCR = no_spads.*DCR_SPAD;
PPS_BN = DCR+PPS_B2;
PPS_BN_SPAD = PPS_BN./no_spads;

%-------------------

sigma_n = window./sqrt(12);
sigma_s = pulse_FWHM/2.35;

C = (FWHM/2.35)^2.*pulse_s;
n = PPS_BN_SPAD;

PPS_S_SPAD = n.*(sigma_n.^2-C)./(C-sigma_s^2);

P_av = PPS_S_SPAD/PPS_B*P_B.*no_spads;
P_peak = P_av./pulse_s./pulse_FWHM;
%---------------------


PPS_B_BIN = (PPS_BN_SPAD./window.*bin_width);
threshold = [1 1 1 1]; #ceil(PPS_B_BIN*2);

for i=1:4
	average = PPS_B_BIN(i);
	accumulation(i)=0;
	for events = (threshold(i)+1):threshold(i)*30
		Poission_events = average.^events.*exp(-average)./factorial(events);
		#chance of a number getting dropped times the amount of photons dropped
		accumulation(i) += Poission_events*events; 
	end
end

PPS_BN_SPAD_2 = accumulation.*window./bin_width;
n = PPS_BN_SPAD_2;
PPS_S_SPAD_2 = n.*(sigma_n.^2-C)./(C-sigma_s^2);
P_av_2 = PPS_S_SPAD_2/PPS_B*P_B.*no_spads;
P_peak_2 = P_av./pulse_s./pulse_FWHM;


%---------------------

f_pulse_tab 
sun_irradiation_tab
background_power_tab
energy_of_photon_tab
scanning_power_tab
effective_noise_power_tab
PPS_tab