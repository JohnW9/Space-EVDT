% FUNCTION NAME:
%   par2car
%
% DESCRIPTION:
%   Keplerian parameters to Cartesian elements converter.
%
% INPUT:
%   state_kep = [6x1] Keplerian state parameters of the object [km;-;rad;rad;rad;rad] 
%                     in this order: [a,e,i,raan,aop,f]'
%
% OUTPUT:
%   state_car = [6x1] Cartesian states of the space object in the ECI frame [km;km;km;km/s;km/s;km/s]
%                     in this order: [x,y,z,vx,vy,vz]'
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Header added
%
function state_car = par2car(state_kep)

mu_E=3.986004330000000e+05;

a = state_kep(1);
e = state_kep(2);
i = state_kep(3);
OM = state_kep(4);
om = state_kep(5);
th = state_kep(6);

p=a.*(1-e.^2);
r=p./(1+e.*cos(th));
rr=[r.*cos(th), r.*sin(th), 0];
vr=sqrt(mu_E./p).*e.*sin(th);
vth=sqrt(mu_E./p).*(1+e.*cos(th));
vv=[vr.*cos(th)-vth.*sin(th), vr.*sin(th)+vth.*cos(th), 0];

ROM=[cos(OM), sin(OM), 0; -sin(OM), cos(OM), 0; 0, 0, 1];
Rom=[cos(om), sin(om), 0; -sin(om), cos(om), 0; 0, 0, 1];
Ri=[1, 0, 0; 0, cos(i), sin(i); 0, -sin(i), cos(i)];
RR=Rom*Ri*ROM;
rr=rr';
vv=vv';
rr=RR'*rr;
vv=RR'*vv;
state_car=[rr;vv];