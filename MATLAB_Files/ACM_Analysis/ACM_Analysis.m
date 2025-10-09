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

EIRP = p_tx - line_loss_tx + gain_antenna_tx;

%% Downlink transmission configuration
bandwidth = 25*1000; %
freq = 437e6; % Hz




%% Analysing MODCOD Benefit with ISS orbit over 1 month

% Setup Satellite Scenario with iss
altitude_gs = 70;
lowest_elevation = 10;
elevation_angles = [lowest_elevation:5:90];
altitude_sat = [425e3,170e3];

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
%gs_lat = 51.45856765398529 % Bristol
%gs_long = -2.602465481454407 % Bristol

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
sim_bits_sent_ACM = sum(sim_bitrates);

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
ist_pass_elevations_binned = histcounts(ist_pass_elevations(:),[lowest_elevation:5:95]);
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
ist_bits_sent_fixed = sum(ist_lowest_elev_rates .* ist_timestep);



%% Plot Elevation vs MODCOD by Altitude
figure
hold on
for alt_it = 1:length(altitude_sat)
    [Elev_vs_modcod_alt_rates,Elev_vs_modcod_alt_modcods] = datarate( ...
                                                                [lowest_elevation:1:90], ...
                                                                repelem( ... 
                                                                    altitude_sat(alt_it), ...
                                                                    length([lowest_elevation:1:90]) ...
                                                                    ), ...
                                                                bandwidth ...
                                                                );
    % get modcod values from struct.
    % Get ordering from mdvs
    Elev_vs_modcod_alt_modcod_mat = [Elev_vs_modcod_alt_modcods.modcod];
    yyaxis left
    plot( ...
        [lowest_elevation:1:90], ...
        Elev_vs_modcod_alt_modcod_mat, ...
        "DisplayName",sprintf('%.0f km',altitude_sat(alt_it)/1000));

    yyaxis right
    plot([lowest_elevation:1:90],Elev_vs_modcod_alt_rates/1e3, ...
        "DisplayName",sprintf('%.0f km',altitude_sat(alt_it)/1000));
end

legend
xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD by Altitude @ BW = "+bandwidth/1000+" kHz")
hold off

%% ACM vs Single Coding / Modulation Rate
% Plotting Time at each elevation
% Also plot Datathroughput of each strategy
% Fixed Orbit
figure
hold on
%sgtitle(sprintf('Variable vs Fixed Coding and Modulation - %.0f km Fixed Orbit',altitude_sat(1)/1000))

% Elevation to MODCOD and bitrate
subplot(2,2,[1,3])
for alt_it = 1:length(altitude_sat)
    [ACM_vs_Single_rates,ACM_vs_Single_modcods] = datarate( ...
                                                    elevation_angles, ...
                                                    repelem( ...
                                                        altitude_sat(1), ...
                                                        length(elevation_angles) ...
                                                        ), ...
                                                    bandwidth ...
                                                    );
    
    yyaxis left
    plot(elevation_angles,vertcat(ACM_vs_Single_modcods.modcod), ...
        "DisplayName",sprintf('%.0f km',altitude_sat(1)/1000));

    yyaxis right
    plot(elevation_angles,ACM_vs_Single_rates/1e3, ...
        "DisplayName",sprintf('%.0f km',altitude_sat(1)/1000));
end

xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD")
legend


subplot(2,2,2)
bar(elevation_angles,elevation_times)
title("Elevation vs Time Spent at Elevation")
xlabel("Elevation (degrees)")
ylabel("Time spent at Elevation (s)")

subplot(2,2,4)
bar(["Adaptive","Fixed"],[sim_bits_sent_ACM,sim_bits_sent_fixed])
title("Adaptive vs Fixed Throughput")
xlabel("Strategy")
ylabel("Throughput (bits)")
hold off

%% IST Orbit Investigation

figure
hold on
sgtitle("Adaptive vs Fixed Coding and Modulation - IST Simulation")

% Elevation to MODCOD and bitrate
subplot(2,2, 1)
hold on
for alt_it = 1:length(altitude_sat)
    ist_relevant_elevations = [lowest_elevation:1:max(ist_pass_elevations)];
    [ACM_vs_Single_rates,ACM_vs_Single_modcods] = datarate( ...
                                                    ist_relevant_elevations, ...
                                                    repelem( ...
                                                        altitude_sat(alt_it), ...
                                                        length(ist_relevant_elevations) ...                                                    ) ...
                                                        ), ...
                                                    bandwidth ...
                                                    );
    
    yyaxis left
    plot(ist_relevant_elevations,vertcat(ACM_vs_Single_modcods.modcod), ...
        "DisplayName",sprintf('%.0f km',altitude_sat(alt_it)/1000));

    yyaxis right
    plot(ist_relevant_elevations,ACM_vs_Single_rates/1e3, ...
        "DisplayName",sprintf('%.0f km',altitude_sat(alt_it)/1000));
end

xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD")
legend

subplot(2,2,3)
title("Satellite Altitude vs Time")
line(ist_pass_times/60/60/24,ist_pass_altitudes/1000);
xlabel("Mission Time (Days)");
ylabel("Satellite Altitude (km)")

subplot(2,2,2)
bar(elevation_angles,ist_pass_elevations_binned)
title("Elevation vs Time Spent at Elevation")
xlabel("Elevation (degrees)")
ylabel("Time spent at Elevation (s)")

subplot(2,2,4)
bar(["Adaptive","Fixed"],[ist_bits_sent_ACM,ist_bits_sent_fixed])
title("Adaptive vs Fixed Throughput")
xlabel("Strategy")
ylabel("Throughput (bits)")
hold off

% Separating plots

figure

% Elevation to MODCOD and bitrate
for alt_it = 1:length(altitude_sat)
    ist_relevant_elevations = [lowest_elevation:1:max(ist_pass_elevations)];
    [ACM_vs_Single_rates,ACM_vs_Single_modcods] = datarate( ...
                                                    ist_relevant_elevations, ...
                                                    repelem( ...
                                                        altitude_sat(alt_it), ...
                                                        length(ist_relevant_elevations) ...                                                    ) ...
                                                        ), ...
                                                    bandwidth ...
                                                    );
    
    yyaxis left
    plot(ist_relevant_elevations,vertcat(ACM_vs_Single_modcods.modcod), ...
        "DisplayName",sprintf('%.0f km',altitude_sat(alt_it)/1000));

    yyaxis right
    plot(ist_relevant_elevations,ACM_vs_Single_rates/1e3, ...
        "DisplayName",sprintf('%.0f km',altitude_sat(alt_it)/1000));
end

xlabel("Elevation Angle (Degrees)")
yyaxis left
ylabel("Modulation and Coding Rate")
yyaxis right
ylabel("Maximum Bitrate (kilobits/sec)")
title("Elevation vs Optimal MODCOD")
legend

figure
hold on
line(ist_pass_times/60/60/24,ist_pass_altitudes/1000);
xlabel("Mission Time (Days)");
ylabel("Satellite Altitude (km)")

figure
hold on
bar(elevation_angles,ist_pass_elevations_binned)
xlabel("Elevation (degrees)")
ylabel("Time spent at Elevation (s)")

figure
hold on
bar(["Adaptive","Fixed"],[ist_bits_sent_ACM,ist_bits_sent_fixed]./1e9)
xlabel("Strategy")
ylabel("Throughput (Gb)")
hold off