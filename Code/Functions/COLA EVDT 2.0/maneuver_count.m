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
%   v_decision = [struct] Struct that 
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

function [v_decision,id_decision] = maneuver_count(decision_list)

    v_decision.nb_no_maneuver = 0;
    v_decision.nb_maneuver_primary = 0;
    v_decision.nb_maneuver_secondary = 0;
    v_decision.proportion_primary = 0;
    id_decision.nb_no_maneuver = 0;
    id_decision.nb_maneuver_primary = 0;
    id_decision.nb_maneuver_secondary = 0;
    id_decision.proportion_primary = 0;

    for i=1:length(decision_list)
        if decision_list(i).maneuver_v_based == 0
            v_decision.nb_no_maneuver = v_decision.nb_no_maneuver + 1;
        elseif decision_list(i).maneuver_v_based == 1
            v_decision.nb_maneuver_primary = v_decision.nb_maneuver_primary + 1;
        elseif decision_list(i).maneuver_v_based == 2
            v_decision.nb_maneuver_secondary = v_decision.nb_maneuver_secondary + 1;
        end
    
        if decision_list(i).maneuver_id_based == 0
            id_decision.nb_no_maneuver = v_decision.nb_no_maneuver + 1;
        elseif decision_list(i).maneuver_id_based == 1
            id_decision.nb_maneuver_primary = id_decision.nb_maneuver_primary + 1;
        elseif decision_list(i).maneuver_id_based == 2
            id_decision.nb_maneuver_secondary = id_decision.nb_maneuver_secondary + 1;
        end
    end
    
    v_decision.proportion_primary = v_decision.nb_maneuver_primary/(v_decision.nb_maneuver_primary + v_decision.nb_maneuver_secondary);
    id_decision.proportion_primary = id_decision.nb_maneuver_primary/(id_decision.nb_maneuver_primary + id_decision.nb_maneuver_secondary);

end