% FUNCTION NAME:
%   f2M
%
% DESCRIPTION:
%   This function converts an array of True anomalies to Mean anomalies.
%   
%
% INPUT:
%   f = [N] Array of True anomalies [rad]
%   e = [1x1] or [N] Eccentricity
%   
% OUTPUT:
%   M = [N] Array of Mean anomalies [rad]
%
% ASSUMPTIONS AND LIMITATIONS:
% The output Mean anomaly values are between 0 and 2pi
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Adding header
%
function M=f2M (f,e)
E=2.*atan(tan(f./2).*sqrt((1-e)./(1+e)));
M=E-e.*sin(E);
M=mod(M,2*pi);
end