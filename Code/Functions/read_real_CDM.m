% FUNCTION NAME:
%   read_real_CDM
%
% DESCRIPTION:
% 
% INPUT:
%   databse: CDM database
%
% OUTPUT:
%  real_CDM_list
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   22/5/2024 - Jonathan Wei
%       * Header added

function real_CDM_list = read_real_CDM(database)
    database_length=size(database,1);
    real_CDM_list(database_length) = real_CDM;
    for current_line = 1:database_length
       real_CDM_list(current_line).Primary_ID = database(current_line,1);
       real_CDM_list(current_line).Secondary_ID = database(current_line,2);
       real_CDM_list(current_line).Drag_primary = database(current_line,60);
       real_CDM_list(current_line).Drag_secondary = database(current_line,120);
       real_CDM_list(current_line).Pc = database(current_line,156);
       real_CDM_list(current_line).HBR = database(current_line,157);
       real_CDM_list(current_line).Event_number = database(current_line,217);

       creation_date = [];
       TCA_date = [];
       for date_index_cre=3:8
           creation_date(end+1) = database(current_line,date_index_cre);
       end

       for date_index_tca=12:17
           TCA_date(end+1) = database(current_line,date_index_tca);
       end

       real_CDM_list(current_line).Creation_time = creation_date;
       real_CDM_list(current_line).TCA = TCA_date;
       disp(real_CDM_list(current_line));
    end
end



