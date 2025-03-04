function [rates] = datarate(elevation,altitude,bandwidth,margin, link_parameters,verbose)
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
    link_parameters struct = struct( ...
                                "Frequency",435e6, ... // Hz
                                "GS_Altitude", 41, ... // m
                                "EIRP", 0.5009, ... // dBW
                                "Receiver_Gain",13-2.39, ... // dB
                                "Receiver_Noise_Temperature",249.3651, ... // K
                                "Atmo_Effect_Path_Loss",3.56 ... // dB
                                );
    verbose     (1,1) = false
    
end
    % Validate Inputs
    if length(elevation) ~= length(altitude)
        error("Elevation and Altitude must have same length")
    end
    
    % Atmospheric losses
    APL = zeros(1,length(elevation));
    for elevation_it = 1:length(elevation)
        % Acubesat absorption values
        if elevation(elevation_it) < 2.5
            Atmo_Absorption_Loss = 10.2;
        elseif elevation(elevation_it) < 5
            Atmo_Absorption_Loss = 4.6;
        elseif elevation(elevation_it) < 10
            Atmo_Absorption_Loss = 2.1;
        elseif elevation(elevation_it) < 30
            Atmo_Absorption_Loss = 1.1;
        elseif elevation(elevation_it) < 45
            Atmo_Absorption_Loss = 0.4;
        else
            Atmo_Absorption_Loss = 0.0;
        end

        APL(elevation_it) = Atmo_Absorption_Loss + link_parameters.Atmo_Effect_Path_Loss;

        
    end
    slant_ranges = zeros(1,length(altitude));
    for slant_it = 1:length(altitude)
        slant_ranges(slant_it) =  slantRangeCircularOrbit(elevation(slant_it), ...
                                                         altitude(slant_it), ...
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
        rates(cnr_it) = modcod_row.dataratebps;
    end
    if verbose
        slant_ranges
        free_space_path_loss
        CNR
        
end




