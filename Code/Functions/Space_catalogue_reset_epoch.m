% FUNCTION NAME:
%   Space_catalogue_reset_epoch
%
% DESCRIPTION:
%   Since each of the space objects in the space catalogue might have different epochs,
%   this program uses a secular J2 zonal harmonics propagator to propagate all the space objects
%   to the same epoch given as input.
%
% INPUT:
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   date = [1x6] Epoch propagation date in Gregorian calender [yy mm dd hr mn sc]
%   
% OUTPUT:
%   space_cat_reset = (M objects) Space catalogue propagated to "date" epoch [Space_object]
%
% ASSUMPTIONS AND LIMITATIONS:
%   The propagator used for this matter is a simple secular effec J2 zonal harmonics propagator.
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function space_cat_reset = Space_catalogue_reset_epoch (space_cat,date)
n=length(space_cat);
space_cat_reset(n)=Space_object;
for o=1:n
    space_cat_reset(o) = TwoBP_J2_analytic (space_cat(o),date);
end
end