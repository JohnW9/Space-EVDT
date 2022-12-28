%% Testing the covariance propagation function
clc;
clear;

addpath('..\Functions\');
addpath('..\Data\');
addpath('..\Time_conversion\');


obj_num=4; % CHANGE THIS NUMBER FOR THE OBJECTS LISTED IN THE BOOK CHAPTER 2


switch obj_num
    case 1
        object=Space_object;
        object.epoch=date2mjd2000([2012 1 1 0 0 0]);
        object.a=7151.799943;
        object.e=0.002586;
        object.i=deg2rad(98.618);
        object.raan=deg2rad(77.249);
        object.om=deg2rad(76.679);
        object.M=deg2rad(177.919);
        n=200;
    case 2
        object=Space_object;
        object.epoch=date2mjd2000([2012 1 1 0 0 0]);
        object.a=25507.551932;
        object.e=0.00375;
        object.i=deg2rad(64.354);
        object.raan=deg2rad(242.658);
        object.om=deg2rad(306.373);
        object.M=deg2rad(53.654);
        n=1440;
    case 3
        object=Space_object;
        object.epoch=date2mjd2000([2012 1 1 0 0 0]);
        object.a=42166.577215;
        object.e=0.000036;
        object.i=deg2rad(0.068);
        object.raan=deg2rad(109.622);
        object.om=deg2rad(217.823);
        object.M=deg2rad(41.434);
        n=1440; 
    case 4  
        object=Space_object;
        object.epoch=date2mjd2000([2012 1 1 0 0 0]);
        object.a=25663.740026;
        object.e=0.740361;
        object.i=deg2rad(63.463);
        object.raan=deg2rad(359.792);
        object.om=deg2rad(270.021);
        object.M=deg2rad(40.168);
        n=1440; 
end

P0=diag([1e4 1e4 1e4 1e-2 1e-2 1e-2]); % Initial covariance matrix in RSW and [m^2 , m^2/s^2]

timestep = 60; %[s]

final_time = object.epoch+n/(24*60);

time_range = object.epoch:timestep/86400:final_time; % Range in MJD2000

t=(time_range-object.epoch)*24*60;

r_R = zeros(1,length(time_range));
r_S = zeros(1,length(time_range));
r_W = zeros(1,length(time_range));
v_R = zeros(1,length(time_range));
v_S = zeros(1,length(time_range));
v_W = zeros(1,length(time_range));

for i=1:length(time_range)
    cov= Cov_prop_TH (P0*1e-6,object,time_range(i));
    r_R(i)=sqrt(cov(1,1));
    r_S(i)=sqrt(cov(2,2));
    r_W(i)=sqrt(cov(3,3));
    v_R(i)=sqrt(cov(4,4));
    v_S(i)=sqrt(cov(5,5));
    v_W(i)=sqrt(cov(6,6));
end


figure()
tiledlayout(3, 2, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
title('Position Errors')
plot(t,r_R*1000);
ylabel('R [m]');
xlabel('Time [min]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
title('Velocity Errors')
plot(t,v_R*1000);
ylabel('Vr [m/s]');
xlabel('Time [min]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,r_S*1000);
ylabel('S [m]');
xlabel('Time [min]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,v_S*1000);
ylabel('Vs [m/s]');
xlabel('Time [min]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,r_W*1000);
ylabel('W [m]');
xlabel('Time [min]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,v_W*1000);
ylabel('Vw [m/s]');
xlabel('Time [min]');
xlim([t(1) t(end)]);
grid on;
