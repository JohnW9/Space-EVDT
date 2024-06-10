% FUNCTION NAME:
%  real_CDM2space_object
%
% DESCRIPTION:
%   Converts real_CDM format to space_object format and replaces the
%   orbital elements with the newly computed ones.
%
% INPUT:
%
%
% OUTPUT:
%
%
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
       [a,e,i,Omega,w,anom] = Cart2Kep([real_CDM_i.(['X_ECI_' Input_Object_Designator]),...
                                        real_CDM_i.(['Y_ECI_' Input_Object_Designator]),...
                                        real_CDM_i.(['Z_ECI_' Input_Object_Designator]),... 
                                        real_CDM_i.(['X_DOT_ECI_' Input_Object_Designator]),... 
                                        real_CDM_i.(['Y_DOT_ECI_' Input_Object_Designator]),...
                                        real_CDM_i.(['Z_DOT_ECI_' Input_Object_Designator])],...
                                        'True','rad');
    space_object_i.a = a;
    space_object_i.e = e;
    space_object_i.i = i;
    space_object_i.raan = Omega;
    space_object_i.om = w;
    space_object_i.f = anom;
end

    space_object_i.id = real_CDM_i.([Input_Object_Designator '_ID']);
end