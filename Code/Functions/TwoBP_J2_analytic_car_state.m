% FUNCTION NAME:
%   TwoBP_J2_analytic
%
% DESCRIPTION:
%   This function propagates a cartesian state of an object for a desired amount of time
%   using 2 body problem plus the secular effects of J2 zonal harmonics.
%   The outputs are the cartesian ECI frame.
%
% INPUT:
%   state_i = [6x1] The initial cartesian state of the object [km;km;km;km/s;km/s;km/s]
%   time = [1x1] Amount of time for propagation [days]
%
% OUTPUT:
%   state_f = [6x1] The final cartesian state of the object [km;km;km;km/s;km/s;km/s]
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

function state_f = TwoBP_J2_analytic_car_state (state_i,time)

state_i_kep=car2par(state_i);

a=state_i_kep(1);
e=state_i_kep(2);
i=state_i_kep(3);
raan=state_i_kep(4);
om=state_i_kep(5);
f=state_i_kep(6);
M=f2M(f,e);

J2= 0.001082626925639;
Re = 6378.14;
miu= 3.986004330000000e+05;

n=sqrt(miu/a^3);
p=a*(1-e^2);

draan = -(3/4*n*Re^2*J2/p^2)*(2*cos(i));
dom= (3/4*n*Re^2*J2/p^2)*(4-5*sin(i)^2);
dmean=-(3/4*n*Re^2*J2/p^2)*(sqrt(1-e^2)*(3*sin(i)^2-2));

raan=raan+86400*time*draan;
om=om+86400*time*dom;
M=M+86400*time*(n+dmean);

raan=mod(raan,2*pi);
om=mod(om,2*pi);
M=mod(M,2*pi);

f=M2f(M,e);

state_f=par2car([a e i raan om f]);

end