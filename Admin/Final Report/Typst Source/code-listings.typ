#import "@preview/codelst:2.0.2": sourcecode

= Code Listings <Code-Listings>
== ACM Analysis
//#show: sourcecode[```MATLAB
//```]
=== datarate.m

#show: sourcecode[```MATLAB
function [rates] = datarate(elevation,altitude,bandwidth,margin,verbose, link_parameters)
%DATARATE Calculates datarate for each elevation and altitude pair
% Returns:
%   rates:              Datarates for each      bits/sec, array size                                               
%                       elevation & altitude    length(elevation)
%                       
% Parameters:
%   elevation:          Satellite Elevation     degrees,    can be array
%   altitude:           Satellite Altitude      meters,     can be array (must be same length as elevation)
%   bandwidth:          Link Bandwidth          Hz          Optional
%   margin:             Link Margin Required    dB          Optional
%   link_parameters:    Static link values      struct      Optional
%
% Requires modcod_to_CNR.mat to be in same directory. This contains
% spectral efficiency values for each MODCOD

arguments
    elevation   (1,:)
    altitude    (1,:)
    bandwidth   (1,1) = 158.5*1000
    margin      (1,1) = 10
    verbose     (1,1) = false
    link_parameters struct = struct( ...
                                "Frequency",437e6, ...                      % Hz
                                "GS_Altitude", 41, ...                      % m
                                "EIRP", 0, ...                              % dBW
                                "Receiver_Gain",14.15-2.39, ...             % dB
                                "Receiver_Noise_Temperature",282.6592, ...  % K
                                "Atmo_Effect_Path_Loss",3.56 ...           % dB
                                );
    
    
end
    % Validate Inputs
    if length(elevation) ~= length(altitude)
        error("Elevation and Altitude must have same length")
    end
    
    % Atmospheric losses
    APL = zeros(1,length(elevation));
    for elevation_it = 1:length(elevation)
        % Acubesat absorption values
        if elevation(elevation_it) < 2.5 || elevation(elevation_it) > 180 - 2.5
            Atmo_Absorption_Loss = 10.2;
        elseif elevation(elevation_it) < 5 || elevation(elevation_it) > 180 - 5
            Atmo_Absorption_Loss = 4.6;
        elseif elevation(elevation_it) < 10 || elevation(elevation_it) > 180 - 10
            Atmo_Absorption_Loss = 2.1;
        elseif elevation(elevation_it) < 30 || elevation(elevation_it) > 180 - 30
            Atmo_Absorption_Loss = 1.1;
        elseif elevation(elevation_it) < 45 || elevation(elevation_it) > 180 - 45
            Atmo_Absorption_Loss = 0.4;
        else
            Atmo_Absorption_Loss = 0.0;
        end

        APL(elevation_it) = Atmo_Absorption_Loss + link_parameters.Atmo_Effect_Path_Loss;

        
    end
    slant_ranges = zeros(1,length(altitude));
    for slant_it = 1:length(altitude)
        slant_ranges(slant_it) =  slantRangeCircularOrbit(elevation(slant_it),  ...
                                                          altitude(slant_it),   ...
                                                          link_parameters.GS_Altitude ...
                                                          );
    end
    free_space_path_loss = 20*log10(4*pi*slant_ranges*link_parameters.Frequency/299792458); % dB
    CNR =  link_parameters.EIRP - free_space_path_loss - APL + ...
            link_parameters.Receiver_Gain + 228.6 - 10*log10(link_parameters.Receiver_Noise_Temperature) ...
            - 10*log10(bandwidth);
    
    persistent modcodvalues
    if isempty(modcodvalues)
        modcodvalues = load("modcod_to_CNR.mat","mdvals").mdvals;      
    end
    modcodvalues.("dataratebps") = modcodvalues.("SpectralEfficiency") * bandwidth;
    

    modcodvalues.("CNR_min") = modcodvalues.("EbN0_min") + 10*log10(modcodvalues.("dataratebps")) - 10*log10(bandwidth);
    
    rates = zeros(1,length(CNR));
    for cnr_it = 1:length(CNR)
        modcod_row = modcodvalues(find(modcodvalues.CNR_min < (CNR(cnr_it) - margin),1,"last"),:);
        if verbose
            modcod_row
        end
        % Check if link closes
        if height(modcod_row) == 0
            rates(cnr_it) = 0;
        else
            rates(cnr_it) = modcod_row.dataratebps;
        end
        
    end
    if verbose
        slant_ranges
        free_space_path_loss
        CNR
    end   
end
```]

=== ACM_Analysis.m

#show: sourcecode[```MATLAB
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
bandwidth = 158.5*1000; % 158.5kHz BW defined by link budget investigation
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
    %[CNR_col(cnr_it),modcod_row.CNR_min] % Debug
end

% Change type for plotting
modcod_cats = strcat(string(mdvals.Modulation)," ",string(mdvals.CodingRate));
opt_modcod_col = categorical(opt_modcod_col,modcod_cats);


opt_modcod_tab = table( ...
            elevation_col,alt_col,CNR_col,opt_modcod_col',opt_bitrate, ...
            'VariableNames',["Elevation","Altitude","CNR_dB","Optimal_MODCOD","Optimal_Bitrate_bps"] ...
            );

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
                        "uint16" ...
                        );              

for pass_it = 1:height(passes_coarse)
    pass = passes_coarse(pass_it,:);
    for time_it = 1:pass.Duration
        [~,pass_elevation_val,~] = aer(gs_fine,sat_fine,[pass.StartTime + seconds(time_it -1)]);
        pass_elevations(pass_it,time_it) = uint16(pass_elevation_val);
    end
end


%% Analysing Predicted Pass Data
% Bin into 5 degree angle bins
elevation_times = histcounts(pass_elevations(:),[lowest_elevation:5:95]);

% Time in each modcod at high altitude

time_modcod_tab = opt_modcod_tab(opt_modcod_tab.Altitude == altitude_sat(end),:);
time_modcod_tab.("Elevation_Time") = elevation_times';
time_modcod_tab.("Bits_Sent") = time_modcod_tab.Optimal_Bitrate_bps .* time_modcod_tab.Elevation_Time;

bits_sent_ACM = sum(time_modcod_tab.Bits_Sent);
bits_sent_fixed = time_modcod_tab(time_modcod_tab.Elevation == lowest_elevation,"Optimal_Bitrate_bps").Optimal_Bitrate_bps .* sum(time_modcod_tab.Elevation_Time);

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
ist_pass_capacities = datarate(ist_pass_elevations,ist_pass_altitudes);
% Time in each modcod at high altitude

ist_time_modcod_tab = opt_modcod_tab(opt_modcod_tab.Altitude == altitude_sat(end),:);
ist_time_modcod_tab.("Elevation_Time") = elevation_times';
ist_time_modcod_tab.("Bits_Sent") = time_modcod_tab.Optimal_Bitrate_bps .* time_modcod_tab.Elevation_Time;

ist_bits_sent_ACM = sum(ist_time_modcod_tab.Bits_Sent);
bits_sent_fixed = time_modcod_tab(time_modcod_tab.Elevation == lowest_elevation,"Optimal_Bitrate_bps").Optimal_Bitrate_bps .* sum(time_modcod_tab.Elevation_Time);



%% Plot Elevation vs MODCOD by Altitude
figure
hold on
for alt_it = 1:length(altitude_sat)
    CNR_vals = opt_modcod_tab(opt_modcod_tab.Altitude == altitude_sat(alt_it),:);

    yyaxis left
    plot(CNR_vals.Elevation,CNR_vals.Optimal_MODCOD, ...
        "DisplayName",sprintf('%.3g',altitude_sat(alt_it),'m'));

    yyaxis right
    plot(CNR_vals.Elevation,CNR_vals.Optimal_Bitrate_bps/1e3, ...
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



subplot(2,2,2)
bar(time_modcod_tab.Elevation',time_modcod_tab.Elevation_Time')
title("Elevation vs Time Spent at Elevation")
xlabel("Elevation (degrees)")
ylabel("Time spent at Elevation (s)")

subplot(2,2,4)
bar(["Adaptive","Fixed"],[bits_sent_ACM,bits_sent_fixed])
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
bar(["Adaptive","Fixed"],[bits_sent_ACM,bits_sent_fixed])
title("Adaptive vs Fixed Throughput")
xlabel("Strategy")
ylabel("Throughput (bits)")
hold off
```]
//#show: sourcecode[```MATLAB
//```]
== Transmitter Implementation

=== DFL_Adressing.mlx
#show: sourcecode[```MATLAB

%Intro
%As we're using an AXI-Stream to access the DVB-S2 transmitter, data will be input in 32b words. For ease of implementation, 4b will be reserved for control words leaving a 28b data field. The DFL of a packet can be of size Kbch - 80. What is the optimal data size to fill all possible DFL?
% https://uk.mathworks.com/matlabcentral/answers/1870657-is-there-a-function-to-find-the-paired-factors-of-an-integer
function D = principaldivisors(N)
  % Compute the principal divisors of the scalar variable N, so only those divisors < N.
  % Note if N is prime, then this function returns ONLY 1, as the only factor less than N.
  F = factor(N);
  D = 1;
  if numel(F) > 1
    % N is composite, so it has more than one divisor less than N
    % if N were prime, then 1 and N are the only factors.
    for Fi = F
      D = unique([D,D*Fi]);
    end
    D(D == N) = [];
  end
end
function pairs = allfactorpairs2(N)
  D = principaldivisors(N)';
  D(D > sqrt(N)) = [];
  pairs = [D,N./D];
end
normal FECFRAME

K_normal = [16008, 21408, 25728, 32208, 38688, 43040, 48408, 51648, 53840, 57472, 58192]-80;
normal_factors = allfactorpairs2(K_normal(1));
normal_factors = normal_factors(normal_factors(:,1)<29);


% Find all factors in first column < 29
% Take intersect with current set of factors

for i= 2:length(K_normal)
    ifacts = allfactorpairs2(K_normal(i));
    ifacts = ifacts(ifacts(:,1) < 33);
    normal_factors = intersect(normal_factors,ifacts);
end
normal_factors

Short FECFRAME
K_short = [3072,5232,6312,7032,9552,10632,11712,12432,13152,14232] - 80;
short_factors = allfactorpairs2(K_short(1));
short_factors = short_factors(short_factors(:,1)<29);


% Find all factors in first column < 29i) = mod(K_normal(i),24)
% Take intersect with current set of factors

for i= 2:length(K_short)
    ifacts = allfactorpairs2(K_short(i));
    ifacts = ifacts(ifacts(:,1) < 33);
    short_factors = intersect(short_factors,ifacts);
end
short_factors

fprintf("The highest factor was: %d bits \n",max(short_factors)) 


Checking all long FECFrames at best short:
mods = zeros(1, length(K_normal));
for i = 1:length(K_normal)
    mods(i) = mod(K_normal(i),24); 
end
mods(mods > 0)

```]

=== rolloff_demonstration.mlx
#show: sourcecode[```MATLAB
%Investigation of impact of roll-off factor
%The final block in the DVB-S2 transmission system is a Root-Raised-Cosine Filter for pulse shaping. This has the effect of increasing the total bandwidth of the transmission based on the roll-off factor. Therefore, the maximum symbol rate can be calculated for the target bandwidth for each value of roll-off in the standard. 
modtable = readtable("Rs2Rb.csv");
Bandwidth =150000
alphas = [0.35;0.25;0.20];
alpha = 0.35
Rs = 150e3 / (1 + alpha)
bitsPerSymbol = 5
ratesCells = unique(modtable.CodingRate);
rateVals = double(string(ratesCells).split("/"));
rates = rateVals(:,1) ./ rateVals(:,2)

codingRate    = rates(3)
bitrate = Rs*bitsPerSymbol*double(codingRate)
bitrate_kb = bitrate/1024

fprintf("Bitrate = %2f kbps for: \n" + ...
            "   Alpha = %2f  \n" + ...
            "   Bandwidth = %2f  \n" + ...
            "   BitsPerSymbol = %2f  \n" + ...
            "   Coding Rate = %2f",bitrate_kb, alpha, Bandwidth, bitsPerSymbol, codingRate)
%Plotting resulting bitrates 
modcods = string(modtable.Modulation) + " " + string(modtable.CodingRate);
modcod_Cat = categorical(modcods);
modcod_Cat = reordercats(modcod_Cat,modcods)
figure
hold on
%alpha 0.35
plot(modcod_Cat,modtable.Datarate_kbps____0_35_);
plot(modcod_Cat,modtable.Datarate_kbps____0_25_);
plot(modcod_Cat,modtable.Datarate_kbps____0_20_,"Color","magenta");

xlabel("Modulation and Coding Rate");
ylabel("Bitrate (kbps)")
legend(["Alpha = 0.35", "Alpha = 0.25", "Alpha = 0.20"], "Position", [0.6543 0.3621 0.2507, 0.1335])


hold off



```]
=== gendata.m
#show: sourcecode[```MATLAB
function [data_Out,TSorGS_Out,DFL_Out,UPL_Out,SYNC_Out,MODCOD_Out,FECFRAME_Out] = gendata(nFrames,nPackets, ...
                                                                                            TSorGS_In,DFL_In,UPL_In,SYNC_In,MODCOD_In,FECFRAME_In, ...
                                                                                            frm_bits, pkt_bits, pl_cnt_bits, ...
                                                                                            frameEnd_pos, frameStart_pos, pktEnd_pos, pktStart_pos)
%GENDATA Generates test data samples for the dvb-s2 stream block
% Outputs data bits and control signals padded accordingly
% Data packets contains counters for frame, packet, and byte, as well as
% start and end markers.
% If UPL = 0, then generic stream. Fr
% ---------------------------
% Bit Maps
% data_Out:
%   31 downto 12:   0 / padding
%   11 downto  4:   Data Byte
%   3:              frameEndIn
%   2:              frameStartIn
%   1:              pktEndIn
%   0:              pktStartIn
% Data Byte:
%   7                  downto (7-frm_bits): Frame Count
%   (7-frame_bits-1)   downto (byte_bits) : Packet Count
%   (payload_bits - 1)    downto 0:            Data payload Count   
%
% ---------------------------
% Outputs all of length data_Out
% TODO: Multiple control settings / function run

    arguments
        % Packet Generation
        nFrames         (1,1) {mustBeNonnegative,mustBeInteger}             % Frames to generate
        nPackets        (1,1) {mustBeNonnegative,mustBeInteger}             % Packets to generate / frame
        
        % Control Signals
        TSorGS_In       (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(TSorGS_In,    4)} % fixdt(0,2,0)
        DFL_In          (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(DFL_In,   65536)} % uint16
        UPL_In          (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(UPL_In,   65536)} % uint16
        SYNC_In         (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(SYNC_In,    256)} % uint8
        MODCOD_In       (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(MODCOD_In,   32)} % fixdt(0,5,0)
        FECFRAME_In     (1,1) {mustBeNonnegative,mustBeInteger,mustBeLessThan(FECFRAME_In,  2)} % logical
        
        % Marker bit settings
        frm_bits        (1,1) = 1;
        pkt_bits        (1,1) = 2;
        pl_cnt_bits     (1,1) = 5;

        % Control Signal bit positions
        frameEnd_pos    (1,1) = 3;
        frameStart_pos  (1,1) = 2;
        pktEnd_pos      (1,1) = 1;
        pktStart_pos    (1,1) = 0;
    end
    % Validate Inputs
    assert((UPL_In == 0) | (UPL_In > 8),       "Packet size must be larger than 8 if packetised stream");
    assert(UPL_In <= DFL_In,                    "Packet size larger than Datafield");
    assert(nPackets*UPL_In==DFL_In,            "Packets / Frame larger than Datafield");
    assert(frm_bits+pkt_bits+pl_cnt_bits == 8, "bit fields in data byte must add to 8 bits");
    assert(frm_bits < 8 && pkt_bits < 8 && pl_cnt_bits < 8, "bit fields must not individually be 8 bits")

    % Fixing Types: Will use at end
    TSorGS_In_t   = fi(TSorGS_In,0,2,0);
    DFL_In_t      = uint16(DFL_In);
    UPL_In_t      = uint16(UPL_In);
    SYNC_In_t     = uint8(SYNC_In);
    MODCOD_In_t   = fi(MODCOD_In,0,5,0);
    FECFRAME_In_t = logical(FECFRAME_In);
    
    % Generate nFrames each with nPackets, each containing UPL[bits] / 8 bytes
    axiDataArray = zeros(1,nFrames.*nPackets.*UPL_In./8,'uint32');

    frame_it    = uint32(0);
    packet_it   = uint32(0);
    payload_it  = uint32(0);

    for axi_it = 0:length(axiDataArray)-1
        axi_pkt = uint32(0);
        payload = uint32(0);
        flags   = uint32(0);
        UPL_it  = UPL_In; % TODO: change for UPL_In matrix
        DFL_it  = DFL_In; % TODO: change for DFL_In matrix
        
        % Creating payload byte 
        % 0b[00...][byte_it] -> 0b[0...][byte_bits]
        payload = bitor(payload,mod(payload_it,2^pl_cnt_bits));
        % 0b[000...][packet_it] -> 0b[00...][pkt_bits][byte_bits]
        payload = bitor(payload,bitshift( ...
                            mod(packet_it,2^pkt_bits), ... % Modulo to remain length pkt_bits
                            pl_cnt_bits) ...
                    );
        % 0b[0...][frame_it] -> 0b[0...][frm_bits][pkt_bits][byte_bits]
        payload = bitor(payload,bitshift(...
                            mod(frame_it,2^frm_bits), ...
                            pl_cnt_bits+pkt_bits) ...
                            );
        % payload is of the form: 0b[0...][frm count][pkt count][byte count]
        assert(payload<256, "Payload byte should be a byte! payload_it: %d , payload val: %d",payload_it,payload)

        % Creating control flag bits
        bits_sent = (axi_it+1)*8;
        packet_start = uint32(mod(bits_sent-8,  UPL_it)  == 0);
        packet_end   = uint32(mod(bits_sent,    UPL_it)  == 0);
        frame_start  = uint32(mod(bits_sent-8,  DFL_it)  == 0);
        frame_end    = uint32(mod(bits_sent,    DFL_it)  == 0);
        assert(packet_start<2 && packet_end < 2 && frame_start < 2 && frame_end<2,"Flags should be 1 bit");

        % Creating control flag field
        flags = bitor(flags, bitshift( ...
                                packet_start, ...
                                pktStart_pos ...
                                ) ...
                    );
        flags = bitor(flags, bitshift( ...
                                packet_end, ...
                                pktEnd_pos ...
                                ) ...
                    );
        flags = bitor(flags, bitshift( ...
                                frame_start, ...
                                frameStart_pos ...
                                ) ...
                    );
        flags = bitor(flags, bitshift( ...
                                frame_end, ...
                                frameEnd_pos ...
                                ) ...
                    );
        
        % Create axi packet
        % 0b[0...][payload byte][flags]
        payload_startpos = 4; % Flags always 4 bits
        axi_pkt = bitor(flags, bitshift( ...
                                    payload, ...
                                    payload_startpos ...
                                    ) ...
                    );
        % Place in array
        axiDataArray(axi_it+1) = axi_pkt;

        % Update counters
        if frame_end
            frame_it = frame_it + 1;
        end
        if packet_end
            packet_it = packet_it + 1;
        end
        payload_it = payload_it + 1;
    end % Axi Stream loop



% Assign outputs
data_Out     = axiDataArray;
% Match length of control signals
TSorGS_Out   = repelem(TSorGS_In_t,   length(axiDataArray)); 
DFL_Out      = repelem(DFL_In_t,      length(axiDataArray));
UPL_Out      = repelem(UPL_In_t,      length(axiDataArray));
SYNC_Out     = repelem(SYNC_In_t,     length(axiDataArray));
MODCOD_Out   = repelem(MODCOD_In_t,   length(axiDataArray));
FECFRAME_Out = repelem(FECFRAME_In_t, length(axiDataArray));
    

end % Function
```]
=== parse_axipkt.m
#show: sourcecode[```MATLAB
function [parsed_pkt] = parse_axipkt(axipkt_in, ...
                                    frm_bits, pkt_bits, pl_cnt_bits, ...
                                    frameEnd_pos, frameStart_pos, pktEnd_pos, pktStart_pos)
%PARSE_AXIPKT Parses control fields and payload data generated by gendata.m
%   
arguments
    axipkt_in (1,:) uint32 % 32bit axi TData
        
    % Marker bit settings
    frm_bits        (1,1) = 1;
    pkt_bits        (1,1) = 2;
    pl_cnt_bits    (1,1) = 5;

    % Control Signal bit positions
    frameEnd_pos    (1,1) = 3;
    frameStart_pos  (1,1) = 2;
    pktEnd_pos      (1,1) = 1;
    pktStart_pos    (1,1) = 0;
end
    pkt_struct = struct( ...
                    "Frame_Count",  uint32(0),...
                    "Packet_Count", uint32(0),...
                    "Byte_Count",   uint32(0),...
                    ...
                    "Frame_End",    logical(0),...
                    "Frame_Start",  logical(0),...
                    "Packet_End",   logical(0),...
                    "Packet_Start", logical(0)...
                        );
    pkt_struct_arr = repelem(pkt_struct,length(axipkt_in));
    
    % Bit Masks
    frameEnd_mask   = 2^frameEnd_pos;
    frameStart_mask = 2^frameStart_pos;
    pktEnd_mask     = 2^pktEnd_pos;
    pktStart_mask   = 2^pktStart_pos;

    frm_mask        = bitshift(...
                        (2^frm_bits)-1,...
                        pkt_bits + pl_cnt_bits...
                        );
    pkt_mask        = bitshift(...
                        (2^pkt_bits)-1,...
                        pl_cnt_bits...
                        );
    pl_cnt_mask       = (2^5)-1;

    payload_mask    = bitshift( ...
                        (2^8)-1,...
                        4 ...
                        );
                            
    
    for pkt_it = 1:length(axipkt_in)
        % Setup loop variables
        axipkt = axipkt_in(pkt_it);
        pkt_struct_temp = pkt_struct;
        
        % Get payload byte
        payload_startpos = 4; % Flags always 4 bits
        payload = bitshift(...
                    bitand(axipkt,  payload_mask),...
                    payload_startpos*-1 ...
                  );
        % Get payload byte counts
        pkt_struct_temp.("Frame_Count") = bitshift(...
                                bitand(payload,frm_mask),...
                                -1*(pkt_bits+pl_cnt_bits)...
                                );
                           
        pkt_struct_temp.("Packet_Count") = bitshift(...
                                bitand(payload,pkt_mask),...
                                -1*(pl_cnt_bits)...
                                );
        pkt_struct_temp.("Byte_Count") = bitand(payload,pl_cnt_mask);
        
        % Flags 
        pkt_struct_temp.("Frame_End") = logical(bitshift(...
                            bitand(axipkt,  frameEnd_mask),...
                            frameEnd_pos*-1 ...
                            ));
        pkt_struct_temp.("Frame_Start") = logical(bitshift(...
                            bitand(axipkt,  frameStart_mask),...
                            frameStart_pos*-1 ...
                            ));
        pkt_struct_temp.("Packet_End") = logical(bitshift(...
                            bitand(axipkt,  pktEnd_mask),...
                            pktEnd_pos*-1 ...
                            ));
        pkt_struct_temp.("Packet_Start") = logical(bitshift(...
                            bitand(axipkt,  pktStart_mask),...
                            pktStart_pos*-1 ...
                            ));
        
        % Store result
        pkt_struct_arr(pkt_it) = pkt_struct_temp;
    end
    parsed_pkt = pkt_struct_arr;
end


```]
=== spectMask.m
#show: sourcecode[```MATLAB
function [mask] = spectMask(Bn, Ptx)
%SPECTMASK Creates mask limit boundaries based on ITU-R SM.1541-7 Fig 43
%   Bn   : Necessary bandwidth (Hz)
%   Ptx  : Transmit power (W)
%   Mask : all dBc
arguments
    Bn  (1,1) = 150e3;
    Ptx (1,1) = 1;
end
    bound_50  = -10;
    bound_120 = -1*(31 + 10*log10(Ptx));
    bound_225 = -1*(38 + 10*log10(Ptx));
    posmask = [0,             0;  ...
               Bn/2,          0;  ...
               Bn/2,   bound_50;  ...
               Bn*1.2, bound_50;  ...
               Bn*1.2, bound_120; ...
               Bn*2.25, bound_120; ...
               Bn*2.25, bound_225; ...
               ];
    negmask = flip([posmask(:,1).*-1, posmask(:,2)],1);
    mask = [negmask;posmask];
end
```]

== Packet Handling

=== Packet.hpp
#show: sourcecode[```MATLAB
/* Definition of Packet Class 
*/

#include <cereal/archives/portable_binary.hpp>

#include <stdint.h>
#include <assert.h>
#include <climits>
#include <optional>
#include <vector>

static_assert(sizeof(double) * CHAR_BIT == 64, "64-bit double is assumed.");
typedef uint64_t timestamp;

class GSE_Packet {
public:
    struct FixedHeader {
        bool start    : 1;
        bool end      : 1;
        int labelType : 2;
        int GSElength : 12;
        };
    struct VariableHeader {
        std::optional<char>     fragID;
        std::optional<uint16_t> totalLength;
        std::optional<uint16_t> protocolType;
        std::optional<char[3]>  label;
    };
private:
    FixedHeader fh;
    std::optional<VariableHeader> vh;
    Packet* pdu;

public:
    // constructor
    GSE_Packet(FixedHeader fh, VariableHeader vh, Packet* pdu);
    std::vector<uint8_t> serialise();
};


class Packet {
    uint8_t type;
    uint8_t version;
    timestamp time;
    virtual cereal::PortableBinaryOutputArchive serialise();
};

std::vector<GSE_Packet> fragment(Packet* pdu);



struct PPL_pkt_64k : Packet{
    double standard_deviation;  // Standard deviation of data
    double codebook[16];        // Quantization levels
    uint32_t data[2048];        // compressed PPL data

    cereal::PortableBinaryOutputArchive serialise();
};
```]

