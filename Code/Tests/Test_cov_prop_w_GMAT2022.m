%% Testing the Covariance propagation values with GMAT

clc;
clear;

addpath('..\Functions\');
addpath('..\Functions\NASA\');
addpath('..\Data\');
addpath('..\Time_conversion\');
addpath('C:\Users\sina\Documents\GMAT\bin','-end'); % This needs to be changed according to the directory of GMAT



%[myMod, gmatStartupPath, result] = load_gmat("sample.script");

%% Defining the object
object=Space_object;
object.epoch=date2mjd2000([2012 1 1 0 0 0]);
object.a=25663.740026;
object.e=0.740361;
object.i=deg2rad(63.463);
object.raan=deg2rad(359.792);
object.om=deg2rad(270.021);
object.M=deg2rad(40.168);
object.f=M2f(object.M,object.e);
n=1440;