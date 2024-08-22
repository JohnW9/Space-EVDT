% FUNCTION NAME:
%  real_CDM2space_object
%
% DESCRIPTION:
%   Converts real_CDM format to space_object format and replaces the
%   orbital elements with the newly computed ones.
%
% INPUT:
%   real_CDM_i: currently considered real_CDM [real_CDM]
%   Input_Object_Designator - (optional, Defaults to Secondary Object) 
%                             Text or Numeric Entry indicating whether to
%                             analyze the Primary "1" or Secondary "2"
%                             Object Allowable Inputs:
%                               - 1 '1' 'Primary'
%                               - 2 '2' 'Secondary'
%   orbital_elements: a struct with the orbital elements in it.
%
% OUTPUT:
%   space_object_i: ith space object
%        name   % Name of the object
%        id     % NORAD ID
%        epoch  % Epoch in mjd2000
%        a      % Semi-major axis [km]
%        e      % Eccentricity
%        i      % Inclination [rad]
%        raan   % Right Ascension of Ascending Node [rad]
%        om     % Argument of perigee [rad]
%        M      % Mean anomaly [rad]
%        f      % True anomaly [rad]
%        type   % Space object type (PAYLOAD/ROCKET BODY/DEBRIS)
%        RCS    % Radar Cross Section category (LARGE/MEDIUM/SMALL)
%        value  % Monetized value of the space object
%        B_star % B* value used for SWTS
        
%        general_category        % Human spaceflight/military/civil/commercial
%        main_application        % Earth Observation/scientific research/communication/Navigation
%        remaining_lifetime      % remaining lifetime of the spacecraft (between 0 and 1; e.g. 0.3 means 30% lifetime remaining)
%        redundancy_level        % if the spacecraft is part of a constellation
%
% ASSUMPTIONS AND LIMITATIONS:
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   03/06/2024 - Jonathan Wei
%       * Header added

function space_object_i = real_CDM2space_object(real_CDM_i,Input_Object_Designator,orbital_elements)

space_object_i = Space_object;
if nargin == 3
    space_object_i.a = orbital_elements.a;
    space_object_i.e = orbital_elements.e;
    space_object_i.i = orbital_elements.i;
    space_object_i.raan = orbital_elements.Omega;
    space_object_i.om = orbital_elements.w;
    space_object_i.f = orbital_elements.anom;

elseif nargin == 2
    %change of uppercase to lowercase
    if strcmp(Input_Object_Designator,'Primary')
        temp_designator = 'primary';
    elseif strcmp(Input_Object_Designator,'Secondary')
        temp_designator = 'secondary';
    end

       [Kep] = Cart2Kep([real_CDM_i.(['X_ECI_' temp_designator]),...
                                        real_CDM_i.(['Y_ECI_' temp_designator]),...
                                        real_CDM_i.(['Z_ECI_' temp_designator]),... 
                                        real_CDM_i.(['X_DOT_ECI_' temp_designator]),... 
                                        real_CDM_i.(['Y_DOT_ECI_' temp_designator]),...
                                        real_CDM_i.(['Z_DOT_ECI_' temp_designator])],...
                                        'True','rad');
    space_object_i.a = Kep(1);
    space_object_i.e = Kep(2);
    space_object_i.i = Kep(3);
    space_object_i.raan = Kep(4);
    space_object_i.om = Kep(5);
    space_object_i.f = Kep(6);
end

    space_object_i.id = real_CDM_i.([Input_Object_Designator '_ID']);
end