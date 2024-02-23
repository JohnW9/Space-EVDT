%% Testing new and old state and covariance propagation methods

% The UKF predictor function is located in the unused functions folder

%% Space object definition

object = Space_object;
object.a = 6378.14+1000;
object.e = 0.01;
object.i = deg2rad(30);
object.raan = deg2rad(40);
object.om = deg2rad(50);
object.M = deg2rad(60);
object.f = M2f(object.M,object.e);
object.epoch = 0;

config = GetConfig;
cov_i_rsw = config.government_SSA_cov;

%% Series
n = 100;
tca = 10; % Maximum days of propagation


t_series = linspace(0, tca, n);
pos_error_series_1 = zeros([1,n]);
vel_error_series_1 = zeros([1,n]);
pos_error_series_2 = zeros([1,n]);
vel_error_series_2 = zeros([1,n]);
state_difference = zeros([2,n]);

for j=1:n
    [pos_error_series_1(j),pos_error_series_2(j),vel_error_series_1(j),vel_error_series_2(j), state_difference(:,j)] = comparing_propagators(object,t_series(j),cov_i_rsw);
end

figure()
tiledlayout(4, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile
hold on
plot(t_series,pos_error_series_1);
plot(t_series,pos_error_series_2);
title('Position covariance')
legend(["Old","New"],"Location","northwest")
grid on;
grid minor;
nexttile
hold on
plot(t_series,vel_error_series_1);
plot(t_series,vel_error_series_2);
title('Velocity covariance')
grid on;
grid minor;
legend(["Old","New"],"Location","northwest")
nexttile
hold on
plot(t_series,state_difference(1,:));
title('Position difference')
grid on;
grid minor;
nexttile
hold on
plot(t_series,state_difference(2,:));
title('Velocity difference')
grid on;
grid minor;
%% Function

function [pos_error_1,pos_error_2,vel_error_1,vel_error_2, state_diff] = comparing_propagators(object,tca,cov_i_rsw)
% Propagating using the old method
object_f_1 = TwoBP_J2_analytic (object,tca,'mjd2000');
cov_f_rsw_1=Cov_prop_TH (cov_i_rsw,object,tca);
state_car_f_1 = par2car([object_f_1.a object_f_1.e object_f_1.i object_f_1.raan object_f_1.om M2f(object_f_1.M,object_f_1.e)]);

pos_error_1 = sqrt(cov_f_rsw_1(1,1)+cov_f_rsw_1(2,2)+cov_f_rsw_1(3,3));
vel_error_1 = sqrt(cov_f_rsw_1(4,4)+cov_f_rsw_1(5,5)+cov_f_rsw_1(6,6));

% Propagating using the new method
state_kep = [object.a;object.e;object.i;object.raan;object.om;object.f];
state_car_i = par2car(state_kep);
[T_rsw2eci,~] = ECI2RSW(state_car_i(1:3),state_car_i(4:6));
J_rsw2eci=[T_rsw2eci zeros(3);zeros(3) T_rsw2eci];
cov_i_eci = J_rsw2eci*cov_i_rsw*J_rsw2eci';
[state_car_f_2, cov_f_eci_2]  = UKF_predictor (state_car_i, cov_i_eci, tca - object.epoch);
[~,T_eci2rsw] = ECI2RSW(state_car_f_2(1:3),state_car_f_2(4:6));
J_eci2rsw=[T_eci2rsw zeros(3);zeros(3) T_eci2rsw];
cov_f_rsw_2=J_eci2rsw*cov_f_eci_2*J_eci2rsw';

pos_error_2 = sqrt(cov_f_rsw_2(1,1)+cov_f_rsw_2(2,2)+cov_f_rsw_2(3,3));
vel_error_2 = sqrt(cov_f_rsw_2(4,4)+cov_f_rsw_2(5,5)+cov_f_rsw_2(6,6));

% Calculating the difference
state_diff = [norm(state_car_f_1(1:3) - state_car_f_2(1:3));norm(state_car_f_1(4:6) - state_car_f_2(4:6))];
%cov_diff_rsw = cov_f_rsw_1 - cov_f_rsw_2;

end

