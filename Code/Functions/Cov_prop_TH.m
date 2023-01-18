% FUNCTION NAME:
%   Cov_prop_TH
%
% DESCRIPTION:
%   Propagating an initial 6x6 covariance matrix in the RSW (RIC) frame to
%   a desired final time, based on relative motion equations developed by
%   Tschauner and Hempel. Applicable to eccentric orbits. Based on the
%   textbook "Orbital Data Applications for Space Objects" by Chen L. et al
%   Chapter 2 and Appendix A.
%
% INPUT:
%   P0 = 6x6 Initial covariance matrix in RSW frame 
%   (Units in km^2 and km^2/s^2)
%   object = (Space_object) Space_object containing the orbital data at the
%   initial epoch time. AN ALTERNATIVE in case the Space_object class is
%   not defined, is to input an array of data for the 'object' entry. This
%   array of data should contain the following data:
%   [initial_epoch ,  object_semimajoraxis , object_eccentricity ,
%   object_initial_true_anomaly , object_final_true_anomaly]
%   the units should be [(mjd2000) , (km) , (-) , (rad) , (rad)]
%   final_time = (mjd2000 days) Final propagation time
%
% OUTPUT:
%   P = 6x6 Final covariance matrix in RSW frame at the final time
%   (Units in km^2 and km^2/s^2)
%
% ASSUMPTIONS AND LIMITATIONS:
%   Reference frame is RSW
%   The square root of the covariance matrix elements should be negligible 
%   with respect to the radius of the object's orbit.
%
%
% EXAMPLE OF USE:
%
%   INPUT:
%   P0 = diag([0.0001 0.0001 0.0001 0.000001 0.000001 0.000001])
%   object = [8.400500000000000e+03 , 8000 , 0.08 , 0 , pi]
%   final_time = 8.400541209962927e+03
%
%   OUTPUT:
%   P = 
%    24.1275  -52.4702         0    0.0430   -0.0140         0
%   -52.4702  131.6158         0   -0.1037    0.0305         0
%          0         0    0.0001         0         0   -0.0000
%     0.0430   -0.1037         0    0.0001   -0.0000         0
%    -0.0140    0.0305         0   -0.0000    0.0000         0
%          0         0   -0.0000         0         0    0.0000
%
%
% REVISION HISTORY:
%   20/11/2022 - Sina Es haghi
%       * Initial implementation
%


function P = Cov_prop_TH (P0,object,final_time)


%% Standard gravitational parameter of earth [km^3/s^2]

    miu= 3.986004330000000e+05;


%% Checking the type of object input

if isa(object,'Space_object')
    if isempty(object.f)
        f0=M2f(object.M,object.e);
    else
        f0=object.f; % Initial true anomaly [rad]
    end
    object_final = TwoBP_J2_analytic (object,final_time,'mjd2000');
    f=M2f(object_final.M,object_final.e); % Final true anomaly [rad]

    t0=object.epoch*86400; % Converting initial time from [mjd2000] to [sec]
    a=object.a; % Semi-major axis [km]
    e=object.e; % Eccentricity
else
    % Then object should be in this format: 
    % object = [ t0_mjd2000 , a_km , e , f0_rad , f_rad]
    t0=object(1)*86400;
    a=object(2);
    e=object(3);
    f0=object(4);
    f=object(5);
end

t=final_time*86400; % Converting final time from [mjd2000] to [sec]

%% Defining the variables
p=a*(1-e^2); % Semi-latus rectum, Instead of p=h^2/miu
rho=1+e*cos(f);
s=rho*sin(f);
c=rho*cos(f);
d=-e*sin(f);
rho0=1+e*cos(f0);
s0=rho0*sin(f0);
c0=rho0*cos(f0);
d0=-e*sin(f0);
sp=cos(f)+e*cos(2*f);
cp=-(sin(f)+e*sin(2*f));
k2=sqrt(miu/p^3);
J=k2*(t-t0);

% Additionally, the angular velocity (df/dt) at initial time and final time
omega=k2*rho^2;
omega0=k2*rho0^2;

%% The T-H State Transition Matrix Elements

t11=(3*e*rho0*s*(e^2+3*rho0-1)/(rho*(e^2-1))-3*e^3*s*s0^2/(rho*rho0*(e^2-1)))*J+...
    e*s0*(2*e*s0-c*s0+s*(c0-2*e))/(rho*rho0*(e^2-1))+...
    rho0*(-2*(e^2+3*rho0-1)+3*c*(e+c0/rho0)+3*s*s0*(1/rho0+e^2/rho0^2))/(rho*(e^2-1));

t12=(-3*e^2*rho0*s*s0/(rho*(e^2-1)))*J-...
    e*s0*(c*e+(c*c0+s*s0)*(1/rho0+1)-2*rho0^2)/(rho*rho0*(e^2-1));

t14=(3*e^2*s*s0/(k2*rho*rho0*(e^2-1)))*J+...
    (c*s0-c0*s+2*e*s-2*e*s0)/(k2*rho*rho0*(e^2-1));

t15=(3*e*rho0*s/(k2*rho*(e^2-1)))*J+...
    (c*e+(s*s0+c*c0)*(1/rho0+1)-2*rho0^2)/(k2*rho*rho0*(e^2-1));

t21=(3*rho*rho0*(e^2+3*rho0-1)/(e^2-1)-3*e^2*rho*s0^2/(rho0*(e^2-1)))*J+...
    3*rho0*(e*s0*(1/rho0+1/rho0^2)-s*(1/rho+1)*(e+c0/rho0))/(rho*(e^2-1))+...
    3*rho0*c*s0*(1/rho0+e^2/rho0^2)*(1/rho+1)/(rho*(e^2-1))+...
    e*s0*(c0*e-2+s*s0*(1/rho+1)+c*(1/rho+1)*(c0-2*e))/(rho*rho0*(e^2-1));

t22=(-3*e*rho*rho0*s0/(e^2-1))*J+rho0/rho-...
    e*s0*(e*s0*(1/rho0+1)-s*(1/rho+1)*(e+c0*(1/rho0+1))+c*s0*(1/rho+1)*(1/rho0+1))/(rho*rho0*(e^2-1));

t24=(3*e*rho*s0/(k2*rho0*(e^2-1)))*J-(c0*e-2+s*s0*(1/rho+1)+c*(1/rho+1)*(c0-2*e))/(k2*rho*rho0*(e^2-1));

t25=(3*rho*rho0/(k2*(e^2-1)))*J+...
    (e*s0*(1/rho0+1)-s*(1/rho+1)*(e+c0*(1/rho0+1))+c*s0*(1/rho+1)*(1/rho0+1))/(k2*rho*rho0*(e^2-1));

t33=(rho0*cos(f-f0)+d0*sin(f-f0))/rho;

t36=sin(f-f0)/(k2*rho*rho0);

t41=(rho0*(3*e^2*k2*s^2+3*sp*e*k2*rho^2)*(e^2+3*rho0-1)/(rho*(e^2-1))-(3*e^4*k2*s^2*s0^2+3*sp*e^3*k2*rho^2*s0^2)/(rho*rho0*(e^2-1)))*J+...
    3*k2*rho0*e*s*(e^2+3*rho0-1)/(rho*(e^2-1))+3*k2*rho*rho0*(cp*(e+c0/rho0)+sp*s0*(1/rho0+e^2/rho0^2))/(e^2-1)-...
    e*s0*k2*rho*(cp*s0-sp*(c0-2*e))/(rho0*(e^2-1))-3*k2*e^3*s*s0^2/(rho0*rho*(e^2-1))+...
    rho0*e*k2*s*(3*c*(e+c0/rho0)-2*(e^2+3*rho0-1)+3*s*s0*(1/rho0+e^2/rho0^2))/(rho*(e^2-1));

t42=(-3*sp*e^2*k2*rho*rho0*s0/(e^2-1)-3*e^3*k2*rho*s^2*s0/(rho*(e^2-1)))*J-...
    e*k2*rho*s0*(cp*e+(cp*c0+sp*s0)*(1/rho0+1))/(rho0*(e^2-1))+...
    e^2*k2*s*s0*(c*e+(c*c0+s*s0)*(1/rho0+1)+rho0^2)/(rho*rho0*(e^2-1));

t44=((3*e^3*s^2*s0+3*sp*e^2*rho^2*s0)/(rho*rho0*(e^2-1)))*J+...
    rho*(2*sp*e-c0*sp+cp*s0)/(rho0*(e^2-1))+...
    (2*e^2*s^2+s0*e^2*s-c0*e*s^2+c*s0*e*s)/(rho*rho0*(e^2-1));

t45=((3*sp*e*rho^2*rho0+3*e^2*rho0*s^2)/(rho*(e^2-1)))*J+...
    rho*(cp*(e+c0*(1/rho0+1))+sp*s0*(1/rho0+1))/(rho0*(e^2-1))+...
    e*s*(c*(e+c0*(1/rho0+1))+rho0^2+s*s0*(1/rho0+1))/(rho*rho0*(e^2-1));

t51=(3*e^3*k2*rho*s*s0^2/(rho0*(e^2-1))-3*e*k2*rho*rho0*s*(e^2+3*rho0-1)/(e^2-1))*J-...
    k2*rho*e*s0*(3*e*s0-s0*(2*c-e)+2*s*(c0-2*e))/(rho0*(e^2-1))-...
    e*k2*s*rho0*((3*e*s0*(1/rho0+1/rho0^2)-3*s*(1/rho+1)*(e+c0/rho0)+3*c*s0*(1/rho0+e^2/rho0^2)*(1/rho+1))/(rho*(e^2-1)))-...
    k2*rho*rho0*((-3*(e^2+3*rho0-1)+3*(e+c0/rho0)*(2*c-e)+6*s*s0*(1/rho0+e^2/rho0^2))/(e^2-1))-...
    e^2*k2*s*s0*(c0*e-2+s*s0*(1/rho+1)+c*(1/rho+1)*(c0-2*e))/(rho*rho0*(e^2-1));

t52=(3*e^2*k2*rho*rho0*s*s0/(e^2-1))*J+...
    k2*rho*e*s0*((e+c0*(1/rho0+1))*(2*c-e)-3*rho0^2+2*s*s0*(1/rho0+1))/(rho0*(e^2-1))+...
    e*k2*rho0*s/rho-...
    e^2*k2*s*s0*(e*s0*(1/rho0+1)-s*(1/rho+1)*(e+c0*(1/rho0+1))+c*s0*(1/rho+1)*(1/rho0+1))/(rho*rho0*(e^2-1));

t54=(-3*e^2*rho*s*s0/(rho0*(e^2-1)))*J+...
    rho*(3*e*s0-s0*(2*c-e)+2*s*(c0-2*e))/(rho0*(e^2-1))-...
    e*s*(c0*e-2+s*s0*(1/rho+1)+c*(1/rho+1)*(c0-2*e))/(rho*rho0*(e^2-1));

t55=(-3*e*rho*rho0*s/(e^2-1))*J-...
    rho*((e+c0*(1/rho0+1))*(2*c-e)-3*rho0^2+2*s*s0*(1/rho0+1))/(rho0*(e^2-1))+...
    e*s*(e*s0*(1/rho0+1)-s*(1/rho+1)*(e+c0*(1/rho0+1))+c*s0*(1/rho+1)*(1/rho0+1))/(rho*rho0*(e^2-1));

t63=d0*k2*(rho*cos(f-f0)-d*sin(f-f0))-rho0*k2*(d*cos(f-f0)+rho*sin(f-f0));

t66=rho*cos(f-f0)/rho0-d*sin(f-f0)/rho0; % Derived myself

%% Converting the velocities to absolute values in RSW instead of relative

phi = [t11-omega0*t15 t12+omega0*t14 0 t14 t15 0;...
       t21-omega0*t25 t22+omega0*t24 0 t24 t25 0;
       0 0 t33 0 0 t36;
       t41-omega*t21-omega0*(t45-omega*t25) t42-omega*t22+omega0*(t44-omega*t24) 0 t44-omega*t24 t45-omega*t25 0;
       t51+omega*t11-omega0*(t55+omega*t15) t52+omega*t12+omega0*(t54+omega*t14) 0 t54+omega*t14 t55+omega*t15 0;
       0 0 t63 0 0 t66];

%% Propagating the covariance matrix

P=phi*P0*phi';

end