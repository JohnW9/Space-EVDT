%% NASA Satellite info

classdef NASA_sat
    properties
        id                      % NORAD ID
        name                    % Name of the satellite
        dimensions              % Array of satellite dimensions [m] or up to [m,m,m]
        mass                    % Satellite mass [kg]
        cost                    % Production and launch cost of the satellite [million $]
        science                 % Science areas that the satellite is producing data in
        applications            % Application areas that the satellite is producing data in
        no_instruments          % Number of instruments onboard the satellite
        instruments             % Instrument names onboard the satellite
        value                   % Value of the satellite assigned by the Vulnerability model
        
        general_category        % Human spaceflight/military/civil/commercial
        main_application        % Earth Observation/scientific research/communication/Navigation
        remaining_lifetime      % remaining lifetime of the spacecraft (between 0 and 1; e.g. 0.3 means 30% lifetime remaining)
        redundancy_level        % if the spacecraft is part of a constellation
    end
end