%% Test two propagation methods
clc;
clear;

addpath('..\Functions\');
addpath('..\Functions\NASA\');
addpath('..\Data\');
addpath('..\Time_conversion\');

initial_time=date2mjd2000([2023 1 1 0 0 0]);
final_time  = [2027 1 1 0 0 0];
time_step = 60;
object=Space_object;
object.epoch=initial_time;
object.a=25663.740026;
object.e=0.740361;
object.i=deg2rad(63.463);
object.raan=deg2rad(359.792);
object.om=deg2rad(270.021);
object.M=deg2rad(40.168);

time_range=initial_time:time_step/86400:date2mjd2000(final_time);

matrix_main=zeros(6,length(time_range));
matrix_anal=zeros(6,length(time_range));

propagated_object = main_propagator (object,final_time,time_step);

parfor i=1:length(time_range)
    
    matrix_main(:,i)=[propagated_object.ma propagated_object.me propagated_object.mi propagated_object.mraan(i) propagated_object.mom(i) propagated_object.M(i)]';
    
    satellite_final = TwoBP_J2_analytic (object,time_range(i),'mjd2000');
    
    matrix_anal(:,i)=[satellite_final.a satellite_final.e satellite_final.i satellite_final.raan satellite_final.om satellite_final.M]';

end

error=matrix_main-matrix_anal;

norm(error)
