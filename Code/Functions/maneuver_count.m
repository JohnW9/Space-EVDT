% FUNCTION NAME:
%   maneuver_count
%
% DESCRIPTION:
%   This functions counts the number of maneuvers to be performed by the
%   primary and secondary objects respectively and displays it.
%
% INPUT:
%   decision_list = (U objects) The list containing all the actions taken by the decision model [Decision_action]
%
% OUTPUT:
%   display of number of maneuvers by primary and secondary objects for
%   Vulnerability based decision and ID based decision
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   28/06/2024 - Jonathan Wei
%       * Header added
%
%

function maneuver_count(decision_list)

    nb_no_maneuver_v = 0;
    nb_maneuver_primary_v = 0;
    nb_maneuver_secondary_v = 0;
    proportion_primary_v = 0;
    nb_no_maneuver_id = 0;
    nb_maneuver_primary_id = 0;
    nb_maneuver_secondary_id = 0;
    proportion_primary_id = 0;

    for i=1:length(decision_list)
        if decision_list(i).maneuver_v_based == 0
            nb_no_maneuver_v = nb_no_maneuver_v + 1;
        elseif decision_list(i).maneuver_v_based == 1
            nb_maneuver_primary_v = nb_maneuver_primary_v + 1;
        elseif decision_list(i).maneuver_v_based == 2
            nb_maneuver_secondary_v = nb_maneuver_secondary_v + 1;
        end
    
        if decision_list(i).maneuver_id_based == 0
            nb_no_maneuver_id = nb_no_maneuver_id + 1;
        elseif decision_list(i).maneuver_id_based == 1
            nb_maneuver_primary_id = nb_maneuver_primary_id + 1;
        elseif decision_list(i).maneuver_id_based == 2
            nb_maneuver_secondary_id = nb_maneuver_secondary_id + 1;
        end
    end
    proportion_primary_v = nb_maneuver_primary_v/(nb_maneuver_primary_v + nb_maneuver_secondary_v);
    proportion_primary_id = nb_maneuver_primary_id/(nb_maneuver_primary_id + nb_maneuver_secondary_id);
    
    disp('Vulnerability based decision:');
    disp('number of no maneuvers: ' + string(nb_no_maneuver_v));
    disp('number of primary maneuvers: ' + string(nb_maneuver_primary_v));
    disp('number of secondary maneuvers: ' + string(nb_maneuver_secondary_v));
    disp('Primary objects maneuvers ' + string(proportion_primary_v*100) + ' % of the time. Secondary maneuvers ' + string((1-proportion_primary_v)*100) + ' % of the time.');
    
    disp('ID base decision:');
    disp('number of no maneuvers: ' + string(nb_no_maneuver_id));
    disp('number of primary maneuvers: ' + string(nb_maneuver_primary_id));
    disp('number of secondary maneuvers: ' + string(nb_maneuver_secondary_id));
    disp('Primary objects maneuvers ' + string(proportion_primary_id*100) + ' % of the time. Secondary maneuvers ' + string((1-proportion_primary_id)*100) + ' % of the time.');
end