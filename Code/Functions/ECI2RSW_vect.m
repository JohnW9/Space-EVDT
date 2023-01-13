% FUNCTION NAME:
%   ECI2RSW_vect
%
% DESCRIPTION:
%   This function converts a vector with three element arrays in the ECI frame to the RSW frame at each time
%   step of the primary space object. (Since the RSW frame is moving with the object)
%   
%
% INPUT:
%   x = [N] The position array of the primary (target) space object in ECI frame in the X direction [km]
%   y = [N] The position array of the primary (target) space object in ECI frame in the Y direction [km]
%   z = [N] The position array of the primary (target) space object in ECI frame in the Z direction [km]
%   vx = [N] The velocity array of the primary (target) space object in ECI frame in the X direction [km]
%   vy = [N] The velocity array of the primary (target) space object in ECI frame in the Y direction [km]
%   vz = [N] The velocity array of the primary (target) space object in ECI frame in the Z direction [km]
%   vect1 = [N] The array of the first element of the desired vector to be transformed to RSW
%   vect2 = [N] The array of the second element of the desired vector to be transformed to RSW
%   vect3 = [N] The array of the third element of the desired vector to be transformed to RSW
%   
% OUTPUT:
%   vect1_rsw = [N] The array of the desired vector in the R direction
%   vect2_rsw = [N] The array of the desired vector in the S direction
%   vect3_rsw = [N] The array of the desired vector in the W direction
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function [vect1_rsw,vect2_rsw,vect3_rsw] = ECI2RSW_vect(x,y,z,vx,vy,vz,vect1,vect2,vect3)

normR= sqrt(x.^2+y.^2+z.^2);

Rx=x./normR;
Ry=y./normR;
Rz=z./normR;

crossRVx=y.*vz-z.*vy;
crossRVy=z.*vx-x.*vz;
crossRVz=x.*vy-y.*vx;

normW= sqrt(crossRVx.^2+crossRVy.^2+crossRVz.^2);

Wx=crossRVx./normW;
Wy=crossRVy./normW;
Wz=crossRVz./normW;

Sx=Wy.*Rz-Wz.*Ry;
Sy=Wz.*Rx-Wx.*Rz;
Sz=Wx.*Ry-Wy.*Rx;

vect1_rsw=Rx.*vect1+Ry.*vect2+Rz.*vect3;
vect2_rsw=Sx.*vect1+Sy.*vect2+Sz.*vect3;
vect3_rsw=Wx.*vect1+Wy.*vect2+Wz.*vect3;

