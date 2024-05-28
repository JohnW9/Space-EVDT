%to be used with realistic CDMs
classdef real_CDM
    properties
        Primary_ID
        Secondary_ID
        Creation_time
        Creation_time_sec                   % CDM creation time in seconds (without counting the year)
        TCA                                 
        TCA_sec                             % TCA time in seconds (without counting the year)
        Drag_primary
        Drag_secondary
        Pc
        HBR
        Event_number
    end
end