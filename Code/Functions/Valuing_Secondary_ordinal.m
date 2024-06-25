% FUNCTION NAME:
%   Valuing_Secondary_ordinal
%
% DESCRIPTION:
%   As part of the vulnerability model, this function gives a monetized
%   value to the secondary space object in conjunction with the NASA satellite.
%   The valuation process takes place only if the object is a payload, a
%   maneuver is being planned and the information has not already been given
%   in the database.
%
% INPUT:
%   cdm = (1 cdm) Considered generated cdm [cdm]
%
% OUTPUT:
%   cdm = (1 cdm) Considered generated cdm, with added value [cdm]
%
% ASSUMPTIONS AND LIMITATIONS:
%   Only giving a value to the object if it is a PAYLOAD.
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   20/06/2024 - Jonathan Wei
%       * Adding header
%

function cdm = Valuing_Secondary_ordinal(cdm)
config = GetConfig;
found = 0;
%% Read Secondary Data
%if strcmp(cdm.type2,'PAYLOAD')
  
  secondary_data = readmatrix("Secondary_value.xlsx");
  database_length = size(secondary_data,1);
  for i = 2:database_length %lookup database if secondary object is in it
        if cdm.id2 == secondary_data(i,1)
            cdm.general_category = secondary_data(i,2);
            cdm.main_application = secondary_data(i,3);
            cdm.remaining_lifetime = secondary_data(i,4);
            cdm.redundancy_level = secondary_data(i,5);
            found = 1;
        end
        if found == 1
            break;
        end
  end

  if found == 0 % secondary object not in the database
      validAnswer = [1,2,3,4];
      given_input = -1;
      % get general category input
      disp('Secondary object with ID ' + string(cdm.id2) + ' not found in database. Please provide the values.')
      while ~ismember(given_input,validAnswer)
          given_input = input('Please give the general category of the secondary object: 1 for human spaceflight, 2 formilitary, 3 for civil, 4 for commercial \n', 's');
          given_input = str2double(given_input);
          if ~ismember(given_input,validAnswer) || isnan(given_input)
              disp('Invalid input.')
              given_input = -1;
          end
      end

      if given_input == 1
          input_string = config.human_spaceflight;
      elseif given_input == 2
          input_string = config.military;
      elseif given_input == 3
          input_string = config.civil;
      else
          input_string = config.commercial;
      end

      general_category = input_string;
      input_string = "";
      given_input = -1;
      
      % get main application input
      while ~ismember(given_input,validAnswer)
          given_input = input('Please give the main application of the secondary object: 1 for Earth Observation, 2 for scientific research, 3 for communication, 4 for navigation\n');
          given_input = str2double(given_input);
          if ~ismember(given_input,validAnswer)
              disp('Invalid input.')
              given_input = -1;
          end
      end

      if given_input == 1
          input_string = config.earth_observation;
      elseif given_input == 2
          input_string = config.scientific_research;
      elseif given_input == 3
          input_string = config.communication;
      else
          input_string = config.navigation;
      end

      main_application = input_string;
      input_string = "";
      given_input = -1;
      
      % get remaining lifetime input
      while given_input < 0 || given_input > 1
          given_input = input('Please give the remaining lifetime value between 0 and 1.\n');
          given_input = str2double(given_input);
          if given_input < 0 || given_input > 1
              disp('Invalid input.')
              given_input = -1;
          end
      end

      remaining_lifetime = given_input;
      given_input = -1;
      
      % get redundancy level input
      while given_input < 1
          given_input = input('Plase give the redundancy level, i.e. the number of satellites in the same constellation (1 if standalone)\n');
          given_input = str2double(given_input);
          if given_input < 1
              disp('Invalid input.');
              given_input = -1;
          end
      end

      redundancy_level = given_input;
      given_input = -1;
      
      % get saving input
      yesOrNo = [1,0];
      while ~ismember(given_input,yesOrNo)
            given_input = input('Do you wish to save the data in the database for future reuse? 1 for Yes, 0 for No.\n');
            given_input = str2double(given_input);
            if ~ismember(given_input,yesOrNo)
                disp('Invalid input.')
                given_input = -1;
            end
      end
   
      if given_input == 1
          secondary_data_line = [cdm.id2,general_category,main_application,remaining_lifetime,redundancy_level];
          save('Secondary_value.xlsx',"secondary_data_line");
      end
  end

%else
 %   cdm.value2 = 0;
%end

%% Valuation of Secondary
    score_general_category = 0;
    score_main_application = 0;
    score_socioeco = 0;

    %% Socio-economic impact (50% of the score)
    % the score is over 10 for general category, accounting for 30% of the
    % total socio-economic impact
    if strcmp(general_category,config.human_spaceflight)
        score_general_category = 10;
    elseif strcmp(general_category,config.military)
        score_general_category = 7.5;
    elseif strcmp(general_category,config.civil)
        score_general_category = 5;
    elseif strcmp(general_category,config.commercial)
        score_general_category = 2.5;
    end
    
    % the score is over 10 for main application, accounting for 70% of the
    % total socio-economic impact
    if strcmp(main_application,config.earth_observation) || strcmp(main_application,config.scientific_research)
        score_main_application = 10;
    elseif strcmp(main_application,config.communication) || strcmp(main_application,config.navigation)
        score_main_application = 5;
    end

    score_socioeco = 0.3 * score_general_category + 0.7 * score_main_application; %normalized over 10
    if redundancy_level > 10
        % if constellation of more than 10 satellites, then we normalize the socio-economical score
        score_socioeco = score_socioeco/(redundancy_level*config.redundancy_scale_factor);
    end
    
    cost_score = cdm.value2/100; % 1 point for 100 milion
    if cost_score > 10
        cost_score = 10;
    end
    
    total_score = 0.5 * score_socioeco + 0.5 * cost_score;

    if remaining_lifetime >= 0.5
        % normalization by remaining lifetime with a minimum of 50%
        total_score = total_score * remaining_lifetime;
    end

cdm.value2 = total_score;
end