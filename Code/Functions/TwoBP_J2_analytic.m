%% Analytic Orbit Propagator

function satellite_final = TwoBP_J2_analytic (satellite_initial,final_time,date_type)

if nargin == 2
    date_type='date';
end
switch date_type
    case 'date'
        time=date2mjd2000(final_time)-satellite_initial.epoch;
    case 'mjd2000'
        time=final_time-satellite_initial.epoch;
end
satellite_final = satellite_initial;
i=satellite_final.i;
a=satellite_final.a;
e=satellite_final.e;

% J2 = astroConstants(9);
% miu = astroConstants(13);

J2= 0.001082626925639;
Re = 6378.14;
miu= 3.986004330000000e+05;

n=sqrt(miu/a^3);
p=a*(1-e^2);

draan = -(3/4*n*Re^2*J2/p^2)*(2*cos(i));
dom= (3/4*n*Re^2*J2/p^2)*(4-5*sin(i)^2);
dmean=-(3/4*n*Re^2*J2/p^2)*(sqrt(1-e^2)*(3*sin(i)^2-2));

satellite_final.epoch=satellite_initial.epoch+time;
satellite_final.raan=satellite_initial.raan+86400*time*draan;
satellite_final.om=satellite_initial.om+86400*time*dom;
satellite_final.M=satellite_initial.M+86400*time*(n+dmean);

satellite_final.raan=mod(satellite_final.raan,2*pi);
satellite_final.om=mod(satellite_final.om,2*pi);
satellite_final.M=mod(satellite_final.M,2*pi);

end