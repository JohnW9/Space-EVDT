% FUNCTION NAME:
%   Ordinal_valuation_NASA
%
% DESCRIPTION:
%   This is the new function giving a value to each spacecraft in order to
%   have an ordinal ranking of the impact of each spacecraft, allowing a
%   decision as of who maneuvers.
%
% INPUT:
%   eos = (N objects)  Primary NASA satellites under consideration for collision avoidance [NASA_sat]
%
% OUTPUT:
%   eos = (N objects)  Primary NASA satellites under consideration for collision avoidance with monetized
%                      value added to the object [NASA_sat]
%
% ASSUMPTIONS AND LIMITATIONS:
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   17/6/2024 - Jonathan Wei
%       * Adding header
%

function eos = Ordinal_valuation_NASA(eos)
eos(5) = NASA_sat;
config = GetConfig;

%% LANDSAT 7
eos(1).id=25682;
eos(1).name='LANDSAT 7';   
eos(1).dimensions=[4.3,2.8]; % NASA LANDSAT 7 Press kit 1999
eos(1).mass=2200;   % NASA LANDSAT 7 Press kit 1999 (total launch weight)
eos(1).cost=666+51; % Satellite cost taken from NASA LANDSAT 7 Press kit 1999 , Launch vehicle taken from NASA science writer's guide to LANDSAT 7
% estimated launch cost of boeing delta 2 7920 - 10C (type taken from NASA data sheet about delta2). Launch cost is from https://web.archive.org/web/20140714122955/http://www.spaceflight101.com/delta-ii-7920h-10.html
eos(1).cost=eos(1).cost*1.66; % Adjusted to 2021 USD (from data.bls.gov)

%% TERRA
eos(2).id=25994;
eos(2).name='TERRA';
eos(2).dimensions=[6.8,3.5]; % NASA Terra press kit 1999
eos(2).mass=5190; % NASA Terra press kit 1999
eos(2).cost=1300;% NASA Terra press kit 1999
eos(2).cost=eos(2).cost*1.66; % Adjusted to 2021 USD (from data.bls.gov)

%% AQUA
eos(3).id=27424;
eos(3).name='AQUA';
eos(3).dimensions=[16.70,8.04]; % NASA Aqua press kit 2002
eos(3).mass=2934; % NASA Aqua press kit 2002 (weight at launch)
eos(3).cost=952; % NASA Aqua press kit 2002
eos(3).cost=eos(3).cost*1.54; % Adjusted to 2021 USD (from data.bls.gov)

for i = 1:length(eos)
    %% Socio-economic impact (50% of the score)
    if strcmp(eos.general_category,config.human_spaceflight)
        score = 4;
    elseif strcmp(eos.general_category,config.military)
        score = 3;
    elseif strcmp(eos.general_category,config.civil)
        score = 2;
    elseif strcmp(eos.general_category,config.commercial)
        score = 1;
    end
    
    if strcmp(eos.main_application,config.earth_observation)
        score = 2;
    elseif strcmp(eos.main_application,config.scientific_research)
        score = 2;
    elseif strcmp(eos.main_application,config.communication)
        score = 1;
    elseif strcmp(eos.main_application,config.navigation)
        score = 1;
    end

    %% Hardware cost (50% of the score)
    
end
end