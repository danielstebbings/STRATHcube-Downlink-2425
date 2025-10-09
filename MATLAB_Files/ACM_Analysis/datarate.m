function [rates,modcods] = datarate(elevation,altitude,bandwidth,margin,verbose, link_parameters)
%DATARATE Calculates datarate for each elevation and altitude pair
% Returns:
%   rates:              Datarates for each      bits/sec,       array size = length(elevation)                                            
%                       elevation & altitude    
%   modcods:            MODulation & CODing     struct          array size = length(elevation)
%                       rates for each.         (mod,cod,modcod)
%                                               (cat,cat,cat)
%                       
%                       
% Parameters:
%   elevation:          Satellite Elevation     degrees,        can be array
%   altitude:           Satellite Altitude      meters,         can be array (must be same length as elevation)
%   bandwidth:          Link Bandwidth          Hz              Optional
%   margin:             Link Margin Required    dB              Optional
%   link_parameters:    Static link values      struct          Optional
%
% Requires modcod_to_CNR.mat to be in same directory. This contains
% spectral efficiency values for each MODCOD

arguments
    elevation   (1,:)
    altitude    (1,:)
    bandwidth   (1,1) = 5*1000
    margin      (1,1) = 3
    verbose     (1,1) = false
    link_parameters struct = struct( ...
                                "Frequency",            437e6, ...         % Hz
                                "GS_Altitude",          70, ...            % m
                                "EIRP",                 -1.26, ...         % dBW
                                "Antenna_Gain",         14.15, ...         % dB 
                                "Preamp_Gain",          20, ...            % dB SP7000
                                "Preamp_Noise_Figure",  0.9, ...           % dB  
                                "GS_Cable_Losses",      3,...              % dB 36m RG213
                                "Polarisation_Loss",    3, ...             % dB Linear -> Circular   
                                "Pointing_Loss",        1, ...             % dB
                                "Receiver_Noise_Figure",8, ...             % dB
                                "Terrestrial_Noise_Figure",    6, ...      % dB
                                "Antenna_3dB_Beamwidth", 15 ...            % Degrees, single sided
                                );
    
    
end
    % Validate Inputs
    if length(elevation) ~= length(altitude)
        error("Elevation and Altitude must have same length")
    end
    
    % DVB-S2 Modulation and Coding rate to spectral efficiency and CNR
    persistent modcodvalues
    if isempty(modcodvalues)
        modcodvalues = load("modcod_to_CNR.mat","mdvals").mdvals;      
    end
    
    % Atmospheric Absorption Values
    persistent atmoatt
    if isempty(atmoatt)
        atmoatt = load("Atmospheric_Attenuation.mat","Atmospheric_Attenuation").Atmospheric_Attenuation;        
    end
    atmoatt_minelev = min(atmoatt.Angle_deg);
    atmoatt_delev   = atmoatt(2,:).Angle_deg - atmoatt(1,:).Angle_deg;


    % Atmospheric losses
    APL = zeros(1,length(elevation));
    for elevation_it = 1:length(elevation)
        norm_elev = elevation(elevation_it);
        if (norm_elev > 90) 
            norm_elev = 180 - norm_elev;
        end
        if (norm_elev < atmoatt_minelev)
            norm_elev = atmoatt_minelev;
        end
        norm_elev = round(norm_elev/atmoatt_delev)*atmoatt_delev;

        APL(elevation_it) = atmoatt(find(atmoatt.Angle_deg==norm_elev,1),:).Total_dB;
    end

    slant_ranges = zeros(1,length(altitude));
    for slant_it = 1:length(altitude)
        slant_ranges(slant_it) =  slantRangeCircularOrbit(elevation(slant_it),  ...
                                                          altitude(slant_it),   ...
                                                          link_parameters.GS_Altitude ...
                                                          );
    end
    free_space_path_loss = 20*log10(4*pi*slant_ranges*link_parameters.Frequency/299792458); % dB

    Signal_Power = link_parameters.EIRP ...
                    - free_space_path_loss ...
                    - APL ...
                    - link_parameters.Pointing_Loss ...
                    - link_parameters.Polarisation_Loss ...
                    + link_parameters.Antenna_Gain ...
                    + link_parameters.Preamp_Gain ...
                    - link_parameters.GS_Cable_Losses;
    
    Terrestrial_Noise = link_parameters.Terrestrial_Noise_Figure + 10*log10(1.38e-23 * 290 * bandwidth);
    
    Noise_Power = Terrestrial_Noise ...
                    + link_parameters.Preamp_Gain ...
                    + link_parameters.Preamp_Noise_Figure ...
                    + link_parameters.Receiver_Noise_Figure;

    CNR =  Signal_Power - Noise_Power;
    
    
    modcodvalues.("dataratebps") = modcodvalues.("SpectralEfficiency") * bandwidth;
    

    modcodvalues.("CNR_min") = modcodvalues.("EbN0_min") + 10*log10(modcodvalues.("dataratebps")) - 10*log10(bandwidth);
    
    rates = zeros(1,length(CNR));
    
    % Initialise modcod array only if requested
    if nargout == 2
        modcods.mod = "";
        modcods.cod = "";
    end 

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
            modcods(cnr_it).mod = modcod_row.Modulation;
            modcods(cnr_it).cod = modcod_row.CodingRate;

            % Place modcod into ordinal categorical
            % Order from mdvals table
            modcods(cnr_it).modcod = ...
                categorical( ...
                    strcat( ...
                        string(modcod_row.Modulation), ...
                        " ", ...
                        string(modcod_row.CodingRate) ...
                    ), ...
                    strcat( ...
                        string(modcodvalues.Modulation), ...
                        " ", ...
                        string(modcodvalues.CodingRate) ...
                    ), ...
                    Ordinal=true ...
                );
        end
        
    end
    if verbose
        Signal_Power
        Noise_Power
        slant_ranges
        free_space_path_loss
        CNR
    end   


end




