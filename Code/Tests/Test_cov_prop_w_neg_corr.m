%% Testing the Covariance propagation with negative correlation values based on Chen 2017

clc;
clear;

addpath('..\Functions\');
addpath('..\Functions\NASA\');
addpath('..\Data\');
addpath('..\Time_conversion\');



%% Defining the object
object=Space_object;
object.epoch=date2mjd2000([2012 7 1 0 0 0]);
object.a=7068.920954;
object.e=0.002805;
object.i=deg2rad(98.141);
object.raan=deg2rad(256.737);
object.om=deg2rad(96.061);
object.M=deg2rad(180.974);
object.f=M2f(object.M,object.e);
n=10*1440;

P0=diag([25 100 25 4e-4 1e-4 1e-4]); % Initial covariance matrix in RSW and [m^2 , m^2/s^2]
P0(5,1) = -0.045;
P0(4,2) = -0.18;

P0(1,5)=P0(5,1);
P0(2,4)=P0(4,2);

timestep = 60; %[s]

final_time = object.epoch+n/(24*60);

time_range = object.epoch:timestep/86400:final_time; % Range in MJD2000

t=(time_range-object.epoch);

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

pos_error = sqrt(r_R.^2+r_S.^2+r_W.^2);

figure()
plot(t,pos_error);

figure()
tiledlayout(3, 2, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
title('Position Errors')
plot(t,r_R);
ylabel('R [km]');
xlabel('Time [days]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
title('Velocity Errors')
plot(t,v_R);
ylabel('Vr [km/s]');
xlabel('Time [days]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,r_S);
ylabel('S [km]');
xlabel('Time [days]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,v_S);
ylabel('Vs [km/s]');
xlabel('Time [days]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,r_W);
ylabel('W [km]');
xlabel('Time [days]');
xlim([t(1) t(end)]);
grid on;
nexttile;
hold on;
plot(t,v_W);
ylabel('Vw [km/s]');
xlabel('Time [days]');
xlim([t(1) t(end)]);
grid on;
