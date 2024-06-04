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
       real_CDM_list(current_line).Creat_t_to_TCA = database(current_line,169);

       real_CDM_list(current_line).WRMS_primary = database(current_line,55);
       real_CDM_list(current_line).WRMS_secondary = database(current_line,115);
       real_CDM_list(current_line).r_vel = database(current_line,20);                               % relative velocity value
       real_CDM_list(current_line).EDR_primary = database(current_line,58);                         % Energy Dissipation Rate
       real_CDM_list(current_line).EDR_secondary = database(current_line,118);
       real_CDM_list(current_line).SRP_primary = database(current_line,62);                         % Solar Radiation Pressure
       real_CDM_list(current_line).SRP_secondary = database(current_line,122);
       real_CDM_list(current_line).Lun_Sol_primary = database(current_line,61);                    % Lunar/Solar effects
       real_CDM_list(current_line).Lun_Sol_secondary = database(current_line,121);
       real_CDM_list(current_line).Earth_Tides_primary = database(current_line,63);
       real_CDM_list(current_line).Earth_Tides_secondary = database(current_line,123);
       real_CDM_list(current_line).LUPI_primary = database(current_line,44);
       real_CDM_list(current_line).LUPI_secondary = database(current_line,104);
       real_CDM_list(current_line).DC_span_primary = database(current_line,45);                     % Differential Correction span
       real_CDM_list(current_line).DC_span_secondary = database(current_line,105);
       real_CDM_list(current_line).DC_residuals_primary = database(current_line,46);
       real_CDM_list(current_line).DC_residuals_secondary = database(current_line,106);

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
       %disp(real_CDM_list(current_line));
    end
end



