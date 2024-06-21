% FUNCTION NAME:
%   Read_NASA_sat_ordinal
%
% DESCRIPTION:
%   This function defines the details of the NASA EOS satellites for the
%   ordinal ranking Vulnerability model
%   
%
% INPUT:
%   
% OUTPUT:
%   eos = (N objects) List of NASA EOS satellites
%
% ASSUMPTIONS AND LIMITATIONS:
%   The satellites currently under consideration are:
%   Landsat7, Terra, Aqua, ICESat-2
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   18/06/2024 - Jonathan Wei
%       * Header added

function eos = Read_NASA_sat_ordinal
config = GetConfig;
eos(3) = NASA_sat;

%% LANDSAT 7
eos(1).id=25682;
eos(1).name='LANDSAT 7';   
eos(1).dimensions=[4.3,2.8]; % NASA LANDSAT 7 Press kit 1999
eos(1).mass=2200;   % NASA LANDSAT 7 Press kit 1999 (total launch weight)
eos(1).cost=666+51; % Satellite cost taken from NASA LANDSAT 7 Press kit 1999 , Launch vehicle taken from NASA science writer's guide to LANDSAT 7
% estimated launch cost of boeing delta 2 7920 - 10C (type taken from NASA data sheet about delta2). Launch cost is from https://web.archive.org/web/20140714122955/http://www.spaceflight101.com/delta-ii-7920h-10.html
eos(1).cost=eos(1).cost*1.66; % Adjusted to 2021 USD (from data.bls.gov)

eos(1).general_category = config.civil;
eos(1).main_application = config.earth_observation;
eos(1).remaining_lifetime = 0; % already passed expected lifetime
eos(1).redundancy_level = 3; % forms a constellation with Landsat 8 and 9

%% TERRA
eos(2).id=25994;
eos(2).name='TERRA';
eos(2).dimensions=[6.8,3.5]; % NASA Terra press kit 1999
eos(2).mass=5190; % NASA Terra press kit 1999
eos(2).cost=1300;% NASA Terra press kit 1999
eos(2).cost=eos(2).cost*1.66; % Adjusted to 2021 USD (from data.bls.gov)

eos(2).general_category = config.civil;
eos(2).main_application = config.earth_observation;
eos(2).remaining_lifetime = 0; % already passed expected lifetime
eos(1).redundancy_level = 1; % not redundant

%% AQUA
eos(3).id=27424;
eos(3).name='AQUA';
eos(3).dimensions=[16.70,8.04]; % NASA Aqua press kit 2002
eos(3).mass=2934; % NASA Aqua press kit 2002 (weight at launch)
eos(3).cost=952; % NASA Aqua press kit 2002
eos(3).cost=eos(3).cost*1.54; % Adjusted to 2021 USD (from data.bls.gov)

eos(3).general_category = config.civil;
eos(3).main_application = config.earth_observation;
eos(3).remaining_lifetime = 0; % already passed expected lifetime
eos(3).redundancy_level = 1; % not redundant

end