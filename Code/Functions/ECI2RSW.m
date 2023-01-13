% FUNCTION NAME:
%   ECI2RSW
%
% DESCRIPTION:
%   This function provides the [3x3] frame transformation matrices for converting ECI to RSW and vice versa.
%   
%
% INPUT:
%   r = [3x1] The position vector of the space object in ECI [km;km;km]
%   v = [3x1] The velocity vector of the space object in ECI [km/s;km/s;km/s]
%   
% OUTPUT:
%   T_rsw2eci = [3x3] RSW to ECI transformation matrix
%   T_eci2rsw = [3x3] ECI to RSW transformation matrix
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Adding header
%
function [T_rsw2eci,T_eci2rsw] = ECI2RSW(r,v)
if size(r,1)==1; r=r'; end
if size(v,1)==1; v=v'; end
R=r/norm(r);
W=cross(r,v)/norm(cross(r,v));
S=cross(W,R);
T_rsw2eci=[R S W];
T_eci2rsw=T_rsw2eci';
end

