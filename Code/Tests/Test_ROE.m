%% TEST new distance calculator

clc;
clear;
close all;

addpath('..\Functions\');
addpath('..\Data\');
addpath('..\Time_conversion\');

space_cat = Read_Space_catalogue;

space_cat=space_cat(1:2);
space_cat(2)=space_cat(1);
space_cat(2).i=space_cat(2).i+deg2rad(0.1);
space_cat(2).M=space_cat(2).M+deg2rad(0.1);


space_cat_reset = Space_catalogue_reset_epoch (space_cat,[2023 1 1 0 0 0]);
%%

final_date=[2027 01 03 0 0 0];

timestep = 15;

%% Mean elements ROE
tic
propagated_object_list_mean = main_propagator (space_cat_reset,final_date,timestep);
[r_rel, s_rel , w_rel] = Element_rel_distance_rsw (propagated_object_list_mean(1),propagated_object_list_mean(2));
toc
%% RV
tic
propagated_object_list_RV = main_propagator (space_cat_reset,final_date,timestep,1);

primary=propagated_object_list_RV(1);
objects_list=propagated_object_list_RV(2);

X_rel_eci=objects_list.rx-primary.rx;
Y_rel_eci=objects_list.ry-primary.ry;
Z_rel_eci=objects_list.rz-primary.rz;

[R_rel,S_rel,W_rel] = ECI2RSW_vect(primary.rx,primary.ry,primary.rz,primary.vx,primary.vy,primary.vz,X_rel_eci,Y_rel_eci,Z_rel_eci);
toc
%%
tic
propagated_object_list_FF = main_propagator (space_cat_reset,final_date,timestep);
[r_rel2, s_rel2 , w_rel2] = ROE2RSW_FF (propagated_object_list_FF(1),propagated_object_list_FF(2));
toc
%% Error

error_r=r_rel-R_rel;
error_s=s_rel-S_rel;
error_w=w_rel-W_rel;

total_error= norm(error_r)+norm(error_s)+norm(error_w)

%% Plot
% 
% figure()
% hold on;
% title('R');
% plot(r_rel2);
% plot(r_rel);
% legend('FF','Actual');
% 
% figure()
% hold on;
% title('S');
% plot(s_rel2);
% plot(s_rel);
% legend('FF','Actual');
% 
% figure()
% hold on;
% title('W');
% plot(w_rel2);
% plot(w_rel);
% legend('FF','Actual');
