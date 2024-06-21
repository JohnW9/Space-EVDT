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
%   obj = (1 object) Secondary space object in conjunction with the NASA satellite [Space_object]
%
% OUTPUT:
%   obj = (1 object) Secondary space object in conjunction with the NASA satellite, with added value [Space_object]
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

function obj = Valuing_Secondary_ordinal(obj)
config = GetConfig;
found = 0;
if strcmp(obj.type,'PAYLOAD')
   
  secondary_data = load("Secondary_value.mat");
  database_length = size(secondary_data,1);
  for i = 1:database_length %lookup database if secondary object is in it
        if obj.id == secondary_data(i,1)
            obj.general_category = secondary_data(i,2);
            obj.main_application = secondary_data(i,3);
            obj.remaining_lifetime = secondary_data(i,4);
            obj.redundancy_level = secondary_data(i,5);
            found = 1;
        end
        if found == 1
            break;
        end
  end

  if found == 0 % secondary object not in the database
      validAnswer = [1,2,3,4];
      given_input = -1;
      while ~ismember(given_input,validAnswer)
          given_input = input('Please give the general category of the secondary object: 1 for human spaceflight, 2 formilitary, 3 for civil, 4 for commercial');
          if ~ismember(given_input,validAnswer)
              disp('Invalid input.')
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

      obj.general_category = input_string;
      input_string = "";
      given_input = -1;

      while ~ismember(given_input,validAnswer)
          given_input = input('Please give the main application of the secondary object: 1 for Earth Observation, 2 for scientific research, 3 for communication, 4 for navigation');
          if ~ismember(given_input,validAnswer)
              disp('Invalid input.')
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

      obj.main_application = input_string;
      input_string = "";
      given_input = -1;

      while given_input < 0 || given_input > 1
          given_input = input('Please give the remaining lifetime value between 0 and 1.');
          if given_input < 0 || given_input > 1
              disp('Invalid input.')
          end
      end

      obj.remaining_lifetime = given_input;
      given_input = -1;

      while given_input < 1
          given_input = input('Plase give the redundancy level, i.e. the number of satellites in the same constellation (1 if standalone)');
          if given_input < 1
              disp('Invalid input.');
          end
      end

      obj.redundancy_level = given_input;
      given_input = -1;

      yesOrNo = [1,0];
      while ~ismember(given_input,yesOrNo)
            given_input = input('Do you wish to save the data in the database for future reuse? 1 for Yes, 0 for No.');
            if ~ismember(given_input,yesOrNo)
                disp('Invalid input.')
            end
      end
      if given_input == 1
          save('Secondary_value.mat',"obj");
      end
  end

else
    obj.value = 0;
end