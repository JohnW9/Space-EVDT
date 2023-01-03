classdef Space_object
    properties
        name   % Name of the object
        id     % NORAD ID
        epoch  % Epoch in mjd2000
        a      % Semi-major axis [km]
        e      % Eccentricity
        i      % Inclination [rad]
        raan   % Right Ascension of Ascending Node [rad]
        om     % Argument of perigee [rad]
        M      % Mean anomaly [rad]
        f      % True anomaly [rad]
        type   % Space object tupe (PAYLOAD/ROCKET BODY/DEBRIS)
        RCS    % Radar Cross Section category (LARGE/MEDIUM/SMALL)
        value
        %line1  % TLE line 1
        %line2  % TLE line 2
    end
end