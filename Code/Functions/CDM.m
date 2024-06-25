classdef CDM
    properties
        Num                 % CDM number
        label               % Label of the Conjunction Data Message
        creation_date       % The CDM creation date [yyyy mm dd hr min sec]
        tca                 % The time of closest approach [yyyy mm dd hr min sec]
        miss_dist           % Miss distance [km]
        Pc                  % Probability of collision
        CC                  % Collision consequence number of pieces
        CC_value            % Value of the collision consequence
        HBR                 % Hard body radius [km]
        read_status         % Read status by the decision model [bool]
        cost                % Operational cost of analyzing the cdm [$]
        
        id1                 % NORAD id of object 1
        r1                  % Position vector of object 1
        v1                  % Velocity vector of object 1
        cov1                % Covariance matrix of object 1 at TCA [km^2 and km^2/s^2]
        dim1                % Max conjunction dimension of object 1 [m] 
        m1                  % Mass of object 1 [kg]
        value1              % Value of object 1
        
        id2                 % NORAD id of object 2
        r2                  % Position vector of object 2
        v2                  % Velocity vector of object 2
        cov2                % Covariance matrix of object 2 at TCA [km^2 and km^2/s^2]
        dim2                % Max conjunction dimension of object 2 [m] 
        m2                  % Mass of object 2 [kg]
        value2              % Value of object 2
        type2               % Type of object 2 (debris, payload, rocket body)

    end
end

