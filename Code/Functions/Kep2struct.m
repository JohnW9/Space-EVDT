% FUNCTION NAME:
%   Kep2struct
%
% DESCRIPTION:
%   A simple function that wraps a list of Keplerian orbital elements into
%   a struct
%
% INPUT:
%   Kep: a list of Keplerian orbital elements [a,e,i,Omega,w,anom]
%   
% OUTPUT:
%   orbital_elements: a struct with the orbital elements in it.
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/6/2024 - Jonathan Wei
%       * Adding header
%
function orbital_elements = Kep2struct(Kep)

orbital_elements.a = Kep(1);
orbital_elements.e = Kep(2);
orbital_elements.i = Kep(3);
orbital_elements.Omega = Kep(4);
orbital_elements.w = Kep(5);
orbital_elements.anom = Kep(6);

end