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
        maneuver                % 1 primary maneuvers, 2 if secondary maneuvers, 0 if no maneuver
    end
end