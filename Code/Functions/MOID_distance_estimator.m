function distance = MOID_distance_estimator (t)
% t in days

J2= 0.001082626925639;
Re = 6378.14; % [km]
miu= 3.986004330000000e+05; % [km^3/s^2]

e_max = 0 ; % Maximum for LEO we assume
a_min = 7000; % Minimum semi_major axis in LEO

draan_max = @(a,e) (3/2*Re^2*J2*sqrt(miu))*1/(a^3.5*(1-e^2)^2); %(cos(i)=1)

theta = 2*draan_max(a_min,e_max)*(t*86400);

distance = a_min*sqrt(2*(1-cos(theta))); 