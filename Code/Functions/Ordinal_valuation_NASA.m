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
config = GetConfig;

for i = 1:length(eos)
    score_general_category = 0;
    score_main_application = 0;
    score_socioeco = 0;

    %% Socio-economic impact (50% of the score)
    % the score is over 10 for general category, accounting for 30% of the
    % total socio-economic impact
    if strcmp(eos(i).general_category,config.human_spaceflight)
        score_general_category = 10;
    elseif strcmp(eos(i).general_category,config.military)
        score_general_category = 7.5;
    elseif strcmp(eos(i).general_category,config.civil)
        score_general_category = 5;
    elseif strcmp(eos(i).general_category,config.commercial)
        score_general_category = 2.5;
    end
    
    % the score is over 10 for main application, accounting for 70% of the
    % total socio-economic impact
    if strcmp(eos(i).main_application,config.earth_observation) || strcmp(eos.main_application,config.scientific_research)
        score_main_application = 10;
    elseif strcmp(eos(i).main_application,config.communication) || strcmp(eos.main_application,config.navigation)
        score_main_application = 5;
    end

    score_socioeco = 0.3 * score_general_category + 0.7 * score_main_application; %normalized over 10
    if eos(i).redundancy_level > 10
        % if constellation of more than 10 satellites, then we normalize the socio-economical score
        score_socioeco = score_socioeco/(eos(i).redundancy_level*config.redundancy_scale_factor);
    end
    
    cost_score = eos(i).cost/100; % 1 point for 100 milion
    if cost_score > 10
        cost_score = 10;
    end
    
    total_score = 0.5 * score_socioeco + 0.5 * cost_score;

    if eos(i).remaining_lifetime >= 0.5
        % normalization by remaining lifetime with a minimum of 50%
        total_score = total_score * eos(i).remaining_lifetime;
    end

eos(i).value = total_score;
end

end
