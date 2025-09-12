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
p_tx = 10*log10(1); % dBW 
% Estimate of line losses in satellite telecom system. Based on numbers
% from AMSAT Link Budget Calculator
line_loss_tx = 1.26; % dB
% ISIS antenna spec
gain_antenna_tx = 0; % dBi
% assumption as the ISIS antenna's beamwidth is unknown
antenna_pointing_loss_tx = 0; % dB

EIRP = p_tx - line_loss_tx + gain_antenna_tx - antenna_pointing_loss_tx;

%% Downlink transmission configuration
bandwidth = 1*1000; % 158.5kHz BW defined by link budget investigation
freq = 437e6; % Hz

%% Ground Station Parameters
gain_antenna_rx = 14.15; % dB STAC
gain_lna_rx = 20; % dB STAC
line_loss_rx = 0.2852; % dB AcubeSAT
other_line_losses_rx = 2.1; % dB AcubeSAT
% System noise temperature 
temperature_antenna_rx = 154; % K AcubeSAT
% reference temperature, usually 290 K
temperature_feedline_rx = 290; % K Sklar
temperature_lna_rx = 66.8; % K STAC
temperature_frontend_rx = 1539.8; % K STAC
cable_loss = 1.023; % AcubeSAT
coeff_transmission_line = 0.6331; % AcubeSAT

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
CNR   = EIRP - free_space_path_loss - path_loss + gain_antenna_rx + 228.6 - 10*log10(temperature_system_noise_rx) - 10*log10(bandwidth) - 2.9;
Margin_Requirement = 10; %dB

% %% Optimal MODCOD from CNR by Elevation and Altitude
% 
% % Creating a table by flattening each value array into columns
% elevation_col = repmat(elevation_angles,[1,length(altitude_sat)])';
% alt_col = repelem(altitude_sat, length(elevation_angles)*ones(length(altitude_sat),1))';
% CNR_col = reshape(CNR',[],1);
% 
% % Finding optimal modulation and coding from CNR
% opt_modcod_col = repelem("",length(CNR_col));
% opt_bitrate = zeros(length(CNR_col),1);
% for cnr_it = 1:length(CNR_col)
%     % Find fastest modulation with minimum CNR below current CNR w. margin
%     modcod_row = mdvals(find(mdvals.CNR_min < (CNR_col(cnr_it) - Margin_Requirement),1,"last"),:);
%     opt_modcod_col(cnr_it) = strcat(string(modcod_row.Modulation)," ", string(modcod_row.CodingRate));
%     opt_bitrate(cnr_it) = modcod_row.dataratebps;
%     %[CNR_col(cnr_it),modcod_row.CNR_min] % Debug
% end
% 
% % Change type for plotting
% modcod_cats = strcat(string(mdvals.Modulation)," ",string(mdvals.CodingRate));
% opt_modcod_col = categorical(opt_modcod_col,modcod_cats);
% 
% 
% opt_modcod_tab = table( ...
%             elevation_col,alt_col,CNR_col,opt_modcod_col',opt_bitrate, ...
%             'VariableNames',["Elevation","Altitude","CNR_dB","Optimal_MODCOD","Optimal_Bitrate_bps"] ...
%             );

%% Analysing MODCOD Benefit with ISS orbit over 1 month

% Setup Satellite Scenario with iss
simlength = 30; % days
sc_start = datetime(2024,11,12,12,0,0); % 12:00, 12/11/2024
sc_stop  = sc_start + hours(24*simlength);     % 
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
                        "single" ...
                        );              

for pass_it = 1:height(passes_coarse)
    pass = passes_coarse(pass_it,:);
    for time_it = 1:pass.Duration
        [~,pass_elevation_val,~] = aer(gs_fine,sat_fine,[pass.StartTime + seconds(time_it -1)]);
        pass_elevations(pass_it,time_it) = single(pass_elevation_val);
    end
end


%% Analysing Predicted Pass Data
% Bin into 5 degree angle bins
elevation_times = histcounts(pass_elevations(:),[lowest_elevation:5:95]);

% Time in each modcod at high altitude

[sim_bitrates,sim_modcods] = datarate( ...
                                pass_elevations(:), ...
                                repelem( ...
                                    altitude_sat(end), ... % Highest value
                                    length(pass_elevations(:)) ...
                                    ), ...
                                bandwidth ...
                                );
% Time in each modcod at high altitude
sim_bits_sent_ACM = sum(sim_bitrates .* elevation_times');

% Get bitrate assuming lowest elevation at all times
sim_lowest_elev_rates = datarate( ...
                            lowest_elevation, ...
                            altitude_sat(end) ...
                            );
sim_bits_sent_fixed = sim_lowest_elev_rates .* sum(elevation_times);


%% Analysing MODCOD Benefit with IST orbit
% pass_elevations(time(s),altitude (km), pass_flag (bool), elevation (degrees),
ist_pass_data = load("IST_Sim_data.mat").outputs;
ist_altmin = 170;  % Minimum altitude to simulate
ist_timestep = 10; % seconds
% Find passes where flag is 1 and altitude > minimum
ist_passes = ist_pass_data(ist_pass_data(:,3)==1 & ist_pass_data(:,2)> ist_altmin,:);
ist_pass_times      = ist_passes(:,1) - ist_passes(1,1); % seconds
ist_pass_altitudes  = ist_passes(:,2)*1000;     % in meters
ist_pass_elevations = ist_passes(:,4);          % degrees
% Bin into 5 degree angle bins
ist_pass_elevations_binned = floor(ist_pass_elevations/5)*5;
% Get capacity for each timestep
[ist_pass_bitrates,ist_pass_modcods] = datarate( ...
                                        ist_pass_elevations, ...
                                        ist_pass_altitudes, ...
                                        bandwidth ...
                                        );
% Sum of bitrate * time at bitrate
ist_bits_sent_ACM = sum(ist_pass_bitrates .* ist_timestep);

% Get bitrate assuming lowest elevation at all times
% Underestimation, as this includes extra atmo losses!
ist_lowest_elev_rates = datarate( ...
                            repelem( ...
                                lowest_elevation, ...
                                length(ist_pass_altitudes) ...
                                ), ...
                            ist_pass_altitudes);
ist_bits_sent_fixed = ist_lowest_elev_rates .* length(ist_pass_times) .* ist_timestep;



%% Plot Elevation vs MODCOD by Altitude
figure
hold on
for alt_it = 1:length(altitude_sat)
    [Elev_vs_modcod_alt_rates,Elev_vs_modcod_alt_modcods] = datarate( ...
                                                                elevation_angles, ...
                                                                repelem( ... 
                                                                    altitude_sat(alt_it), ...
                                                                    length(elevation_angles) ...
                                                                    ) ...
                                                                );
    % get modcod values from struct.
    % Get ordering from mdvs
    Elev_vs_modcod_alt_modcod_mat = [Elev_vs_modcod_alt_modcods.modcod];
    yyaxis left
    plot( ...
        elevation_angles, ...
        Elev_vs_modcod_alt_modcod_mat, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));

    yyaxis right
    plot(elevation_angles,Elev_vs_modcod_alt_rates/1e3, ...
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

%% ACM vs Single Coding / Modulation Rate
% Plotting Time at each elevation
% Also plot Datathroughput of each strategy
figure
hold on
sgtitle("Adaptive vs Fixed Coding and Modulation - 409km Fixed Orbit")

% Elevation to MODCOD and bitrate
subplot(2,2,[1,3])
for alt_it = 1:length(altitude_sat)
    [ACM_vs_Single_rates,ACM_vs_Single_modcods] = datarate(elevation_angles,altitude_sat(alt_it));
    
    yyaxis left
    plot(elevation_angles,ACM_vs_Single_modcods.modcod, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));

    yyaxis right
    plot(elevation_angles,ACM_vs_Single_rates/1e3, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));
end

xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD")



subplot(2,2,2)
bar(time_modcod_tab.Elevation',time_modcod_tab.Elevation_Time')
title("Elevation vs Time Spent at Elevation")
xlabel("Elevation (degrees)")
ylabel("Time spent at Elevation (s)")

subplot(2,2,4)
bar(["Adaptive","Fixed"],[sim_bits_sent_ACM,sim_bits_sent_fixed])
title("Adaptive vs Fixed Throughput")
xlabel("Strategy")
ylabel("Throughput (bits)")


hold off

figure
hold on 
for alt_it = 2:length(altitude_sat)
    CNR_vals = opt_modcod_tab(opt_modcod_tab.Altitude == altitude_sat(alt_it),:);

    yyaxis left
    plot(CNR_vals.Elevation,CNR_vals.Optimal_MODCOD, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));

    yyaxis right
    plot(CNR_vals.Elevation,CNR_vals.Optimal_Bitrate_bps/1e3, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));
end

xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD")
hold off

figure 
hold on 
bar(time_modcod_tab.Elevation',time_modcod_tab.Elevation_Time')
title("Elevation vs Time Spent at Elevation")
xlabel("Elevation (degrees)")
ylabel("Time spent at Elevation (s)")
hold off 

figure 
hold on 
bar(["Adaptive","Fixed"],[sim_bits_sent_ACM,sim_bits_sent_fixed])
title("Adaptive vs Fixed Throughput")
xlabel("Strategy")
ylabel("Throughput (bits)")
hold off