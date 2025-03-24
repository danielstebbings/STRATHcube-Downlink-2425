ich function [mask] = spectMask(Bn, Ptx)
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

