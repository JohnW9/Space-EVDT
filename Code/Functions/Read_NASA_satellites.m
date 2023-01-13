% FUNCTION NAME:
%   Read_NASA_satellites
%
% DESCRIPTION:
%   This function defines the details of the NASA EOS satellites.
%   Comments on each line show the source of the data taken.
%   
%
% INPUT:
%   
% OUTPUT:
%   eos = (N objects) List of NASA EOS satellites
%
% ASSUMPTIONS AND LIMITATIONS:
%   The satellites currently under consideration are:
%   Landsat7, Landsat8, Landsat9, Terra, Aqua
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Header added

function eos = Read_NASA_satellites
eos(5)=NASA_sat;

%% LANDSAT 7
eos(1).id=25682;
eos(1).name='LANDSAT 7';   
eos(1).dimensions=[4.3,2.8]; % NASA LANDSAT 7 Press kit 1999
eos(1).mass=2200;   % NASA LANDSAT 7 Press kit 1999 (total launch weight)
eos(1).science=["Carbon Cycle, Ecosystems, and Biogeochemistry","Earth Surface and Interior"]; % NASA EOS website
eos(1).applications=["Agricultural Efficiency" "Air Quality" "Aviation" "Carbon Management" "Coastal Management" "Disaster Management" "Ecological Forecasting" "Energy Management" "Homeland Security" "Invasive Species" "Public Health" "Water Management"]; % NASA EOS website
eos(1).no_instruments=1;% NASA EOS website
eos(1).instruments='ETM+';% NASA EOS website
eos(1).cost=666+51; % Satellite cost taken from NASA LANDSAT 7 Press kit 1999 , Launch vehicle taken from NASA science writer's guide to LANDSAT 7
% estimated launch cost of boeing delta 2 7920 - 10C (type taken from NASA data sheet about delta2). Launch cost is from https://web.archive.org/web/20140714122955/http://www.spaceflight101.com/delta-ii-7920h-10.html
eos(1).cost=eos(1).cost*1.66; % Adjusted to 2021 USD (from data.bls.gov)
%% LANDSAT 8
eos(2).id=39084;
eos(2).name='LANDSAT 8';
eos(2).dimensions=[(9.75+3),4.8]; % NASA LDCM presskit 2013
eos(2).mass=2782;   % NASA LDCM presskit 2013 (total launch weight)
eos(2).science=["Carbon Cycle, Ecosystems, and Biogeochemistry" "Earth Surface and Interior"]; % NASA EOS website
eos(2).applications=["Agricultural Efficiency" "Carbon Management" "Coastal Management" "Disaster Management" "Ecological Forecasting" "Energy Management" "Homeland Security" "Invasive Species" "Public Health" "Water Management"];% NASA EOS website
eos(2).no_instruments=2;% NASA EOS website
eos(2).instruments=["OLI" "TIRS"];% NASA EOS website
eos(2).cost=855;  % NASA LDCM presskit 2013
eos(2).cost=eos(2).cost*1.2; % Adjusted to 2021 USD (from data.bls.gov)
%% LANDSAT 9
eos(3).id=49260;
eos(3).name='LANDSAT 9'; %%  data copied from LANDSAT 8
eos(3).dimensions=[(9.75+3),4.8]; %%  data copied from LANDSAT 8 (Everywhere it is said that it has the same bus as Landsat 8)
eos(3).mass=2864;% Data taken from https://space.skyrocket.de/doc_sdat/landsat-8.htm
eos(3).science=["Carbon Cycle, Ecosystems, and Biogeochemistry" "Earth Surface and Interior"]; %%  data copied from LANDSAT 8
eos(3).applications=["Agricultural Efficiency" "Carbon Management" "Coastal Management" "Disaster Management" "Ecological Forecasting" "Energy Management" "Homeland Security" "Invasive Species" "Public Health" "Water Management"]; %%  data copied from LANDSAT 8
eos(3).no_instruments=2;% NASA EOS website
eos(3).instruments=["OLI-2" "TIRS-2"];% NASA EOS website
eos(3).cost=750; % Based on https://www.space.com/nasa-landsat-9-earth-observation-satellite-launch-success
%% TERRA
eos(4).id=25994;
eos(4).name='TERRA';
eos(4).dimensions=[6.8,3.5]; % NASA Terra press kit 1999
eos(4).mass=5190; % NASA Terra press kit 1999
eos(4).science=["Atmospheric Composition" "Carbon Cycle, Ecosystems, and Biogeochemistry" "Climate Variability and Change" "Earth Surface and Interior" "Water and Energy Cycles" "Weather"];% NASA EOS website
eos(4).applications=["Agricultural Efficiency" "Air Quality" "Carbon Management" "Coastal Management" "Disaster Management" "Ecological Forecasting" "Energy Management" "Homeland Security" "Invasive Species" "Public Health" "Water Management"];% NASA EOS website
eos(4).no_instruments=5;% NASA EOS website
eos(4).instruments=["ASTER" "CERES" "MISR" "MODIS" "MOPITT"];% NASA EOS website
eos(4).cost=1300;% NASA Terra press kit 1999
eos(4).cost=eos(4).cost*1.66; % Adjusted to 2021 USD (from data.bls.gov)
%% AQUA
eos(5).id=27424;
eos(5).name='AQUA';
eos(5).dimensions=[16.70,8.04]; % NASA Aqua press kit 2002
eos(5).mass=2934; % NASA Aqua press kit 2002 (weight at launch)
eos(5).science=["Atmospheric Composition" "Carbon Cycle, Ecosystems, and Biogeochemistry" "Climate Variability and Change" "Water and Energy Cycles" "Weather"];% NASA EOS website
eos(5).applications=["Agricultural Efficiency" "Air Quality" "Carbon Management" "Coastal Management" "Disaster Management" "Ecological Forecasting" "Homeland Security" "Water Management"];% NASA EOS website
eos(5).no_instruments=6;% NASA EOS website
eos(5).instruments=["AIRS" "AMSR-E" "AMSU-A" "CERES" "HSB" "MODIS"];% NASA EOS website
eos(5).cost=952; % NASA Aqua press kit 2002
eos(5).cost=eos(5).cost*1.54; % Adjusted to 2021 USD (from data.bls.gov)