classdef Decision_action
    properties
        action_number
        cdm
        collision_label
        cdm_number
        action
        Pc
        TimeToConjunction
        ValueOfCollision
        Contact_possibility
        available_budget
        maneuver_v_based            % Decision based on socio-economical value. 1 primary maneuvers, 2 if secondary maneuvers, 0 if no maneuver
        maneuver_id_based           % Decision based on maneuver id. 1 primary maneuvers, 2 if secondary maneuvers, 0 if no maneuver
    end
end