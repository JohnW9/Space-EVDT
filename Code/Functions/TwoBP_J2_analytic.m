% FUNCTION NAME:
%   TwoBP_J2_analytic
%
% DESCRIPTION:
%   This function propagates a space object to a desired date using 2 body problem
%   plus the secular effects of J2 zonal harmonics. The outputs are the mean element
%   states of the object at the desired date.
%
% INPUT:
%   object = (1 object) The space object from the space catalogue to be propagated [Space_object]
%   final_time = [1x6]or[1x1] Final propagation time in Gregorian calender date or MJD2000 [yy mm dd hr mn sc] or [mjd2000]
%   data_type = [string] Declaring if the final_time is in mjd2000 format or calender date format
%
% OUTPUT:
%   propagated_object = (1 object) Propagated space object at the desired final time (with mean elements only) [Propagated_space_object]
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   Considering only secular J2 effects during the propagation.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Header added
%

function propagated_object = TwoBP_J2_analytic (object,final_time,date_type)

if nargin == 2
    date_type='date';
end
switch date_type
    case 'date'
        time=date2mjd2000(final_time)-object.epoch;
    case 'mjd2000'
        time=final_time-object.epoch;
end
propagated_object = object;
i=propagated_object.i;
a=propagated_object.a;
e=propagated_object.e;

J2= 0.001082626925639;
Re = 6378.14;
miu= 3.986004330000000e+05;

n=sqrt(miu/a^3);
p=a*(1-e^2);

%% Secular effects of J2
draan = -(3/4*n*Re^2*J2/p^2)*(2*cos(i));
dom= (3/4*n*Re^2*J2/p^2)*(4-5*sin(i)^2);
dmean=-(3/4*n*Re^2*J2/p^2)*(sqrt(1-e^2)*(3*sin(i)^2-2));
%%
propagated_object.epoch=object.epoch+time;
propagated_object.raan=object.raan+86400*time*draan;
propagated_object.om=object.om+86400*time*dom;
propagated_object.M=object.M+86400*time*(n+dmean);

propagated_object.raan=mod(propagated_object.raan,2*pi);
propagated_object.om=mod(propagated_object.om,2*pi);
propagated_object.M=mod(propagated_object.M,2*pi);

end