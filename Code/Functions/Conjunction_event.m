classdef Conjunction_event
    properties
        id                  % Event id
        tca                 % Time of Closest Approach [mjd2000]
        primary_id          % Primary space object NORAD id
        secondary_id        % Secondary space object NORAD id
        secondary_RCS       % Secondary RCS cateegory (SMALL, MEDIUM, LARGE)
        secondary_type      % object type (PAYLOAD/ROCKET BODY/DEBRIS)
        mis_dist            % Miss distance [km]
        status              % Mitigation status [bool] (1-mitigated, 0-not)
    end
end