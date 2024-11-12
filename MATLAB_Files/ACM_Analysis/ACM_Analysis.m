% Analysing the effect of Active Coding and Modulation (ACM) for DVB-S2
% By Daniel Stebbings
% Based upon "dynamic_link_schemes_analysis" by Preben

%% Imports

load("modcod_to_CNR.mat")
% Ideal CNR calculated from values for normal FECFRAME, Pilotless given by:
% Table 13 EN 302 307-1 - V1.4.1 
% 
% Spectral efficiency from normal FECFRAME, w. pilots given by:
% Table 3-1 CCSDS 130.12-G-2
%
% This means that these values for throughput are lower than the maximum
% possible.

%% Satellite Parameters
% ESA FYS! constrains antenna power output to 1.5W. ISIS Antenna max power
% output is 2W
p_tx = 10*log10(1.5); % dBW 
% Estimate of line losses in satellite telecom system. Based on numbers
% from AMSAT Link Budget Calculator
line_loss_tx = 1.93; % dB
% ISIS antenna spec
gain_antenna_tx = 0; % dBi
% assumption as the ISIS antenna's beamwidth is unknown
antenna_pointing_loss_tx = 3; % dB

EIRP = p_tx - line_loss_tx + gain_antenna_tx - antenna_pointing_loss_tx;

%% Downlink transmission configuration
bandwidth = 158.5*1000; % 158.5kHz BW defined by link budget investigation
freq = 435e6; % Hz

%% Ground Station Parameters
gain_antenna_rx = 12; % dB
gain_lna_rx = 22.5; % dB
line_loss_rx = 0.2852; % dB
other_line_losses_rx = 2.1; % dB
temperature_line_loss = 10^(-line_loss_rx/10);

% System noise temperature 
temperature_antenna_rx = 154; % K
% reference temperature, usually 290 K
temperature_feedline_rx = 290; % K
temperature_lna_rx = 28; % K
temperature_frontend_rx = 1000; % K
cable_loss = 1.023;
coeff_transmission_line = 0.6331;

temperature_system_noise_rx = coeff_transmission_line*temperature_antenna_rx + (1-coeff_transmission_line)*temperature_feedline_rx + (temperature_frontend_rx*cable_loss)/gain_lna_rx;

%% Path Losses
altitude_sat = [170e3,409e3]; % highest and lowest, m
% Approximate altitude of James Weir
altitude_gs = 41; % m 
lowest_elevation = 10;
elevation_angles = lowest_elevation:5:90; % deg

% direct distance between GS and satellite
slant_ranges = zeros(1,length(altitude_sat));
for alt_it = 1:length(altitude_sat)
    for elev_it = 1:length(elevation_angles)
        slant_ranges(alt_it,elev_it) = slantRangeCircularOrbit(elevation_angles(elev_it), altitude_sat(alt_it), altitude_gs);
    end
end

% FSPL dependent on elevation and altitude
free_space_path_loss = 20*log10(4*pi*slant_ranges*freq/299792458); % dB

% Other Path losses weakly dependent, take as constant
ionospheric_space_loss = 0.4; % dB
atmospheric_space_loss = 1.1; % dB
rain_space_loss = 0; % dB
scintillation_space_loss = 0.16; % dB
polarisation_space_loss = 3; % dB
path_loss = ionospheric_space_loss + atmospheric_space_loss + rain_space_loss + scintillation_space_loss + polarisation_space_loss;



%% System Performance
CNR   = EIRP - free_space_path_loss - path_loss + gain_antenna_rx + 228.6 - 10*log10(temperature_system_noise_rx) - 10*log10(bandwidth);
Margin_Requirement = 10; %dB

%% Optimal MODCOD from CNR by Elevation and Altitude

% Creating a table by flattening each value array into columns
elevation_col = repmat(elevation_angles,[1,length(altitude_sat)])';
alt_col = repelem(altitude_sat, length(elevation_angles)*ones(length(altitude_sat),1))';
CNR_col = reshape(CNR',[],1);

% Finding optimal modulation and coding from CNR
opt_modcod_col = repelem("",length(CNR_col));
opt_bitrate = zeros(length(CNR_col),1);
for cnr_it = 1:length(CNR_col)
    % Find fastest modulation with minimum CNR below current CNR w. margin
    modcod_row = mdvals(find(mdvals.CNR_min < (CNR_col(cnr_it) - Margin_Requirement),1,"last"),:);
    opt_modcod_col(cnr_it) = strcat(string(modcod_row.Modulation)," ", string(modcod_row.CodingRate));
    opt_bitrate(cnr_it) = modcod_row.dataratebps;
    [CNR_col(cnr_it),modcod_row.CNR_min]
end

% Change type for plotting
modcod_cats = strcat(string(mdvals.Modulation)," ",string(mdvals.CodingRate));
opt_modcod_col = categorical(opt_modcod_col,modcod_cats);


opt_modcod_tab = table( ...
            elevation_col,alt_col,CNR_col,opt_modcod_col',opt_bitrate, ...
            'VariableNames',["Elevation","Altitude","CNR_dB","Optimal_MODCOD","Optimal_Bitrate_bps"] ...
            )

%% Analysing MODCOD Benefit with ISS orbit over 1 month

% Setup Satellite Scenario with iss
sc_start = datetime(2024,11,12,12,0,0); % 12:00, 12/11/2024
sc_stop  = sc_start + hours(24*30);     % 
sc_coarse_sample = 120; % seconds / sample
sc_fine_sample   = 1;   % seconds / sample
sc_coarse   = satelliteScenario(sc_start,sc_stop,sc_coarse_sample);
sc_fine     = satelliteScenario(sc_start,sc_stop,sc_fine_sample);
sat_coarse  = satellite(sc_coarse,  "iss_tle.txt");
sat_fine    = satellite(sc_fine,    "iss_tle.txt");

% Setup James Weir Ground Station
gs_name = "James Weir Ground Station";
gs_lat  = 55.86194444;
gs_long = 4.24527778;
gs_coarse = groundStation(sc_coarse,"Name",gs_name,"Altitude",altitude_gs,"Latitude",gs_lat,"Longitude",gs_long,"MinElevationAngle",lowest_elevation);
gs_fine   = groundStation(sc_fine,"Name",gs_name,"Altitude",altitude_gs,"Latitude",gs_lat,"Longitude",gs_long,"MinElevationAngle",lowest_elevation);

% Use coarse sample to quickly find passes
ac_coarse     = access(sat_coarse,gs_coarse);
passes_coarse = accessIntervals(ac_coarse);

% Use fine sampling to get accurate elevations per pass
pass_elevations = zeros( ... % Initialise dimensions
                        height(passes_coarse), ...
                        max(passes_coarse.Duration), ...
                        "uint16" ...
                        );              

for pass_it = 1:height(passes_coarse)
    pass = passes_coarse(pass_it,:);
    for time_it = 1:pass.Duration
        [~,pass_elevation_val,~] = aer(gs_fine,sat_fine,[pass.StartTime + seconds(time_it -1)]);
        pass_elevations(pass_it,time_it) = uint16(pass_elevation_val);
    end
end

% Bin into 5 degree angle bins
elevation_times = histcounts(pass_elevations(:),[lowest_elevation:5:95]);

% Time in each modcod at high altitude

time_modcod_tab = opt_modcod_tab(opt_modcod_tab.Altitude == altitude_sat(end),:)
time_modcod_tab.("Elevation_Time") = elevation_times'



%% Plot Elevation vs MODCOD by Altitude
figure
hold on
for alt_it = 1:length(altitude_sat)
    CNR_vals = opt_modcod_tab(opt_modcod_tab.Altitude == altitude_sat(alt_it),:);

    yyaxis left
    plot(CNR_vals.Elevation,CNR_vals.Optimal_MODCOD, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));

    yyaxis right
    plot(CNR_vals.Elevation,CNR_vals.Optimal_Bitrate_bps/10e3, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));
end

legend
xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD by Altitude")
hold off

%% Next need to look at time in each elevation bin

%% Finally, datarate -> amount of FECFRAMES / elevation bin


