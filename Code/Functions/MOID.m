% FUNCTION NAME:
%   MOID
%
% DESCRIPTION:
%   This function finds the relevant space objects to the EOS satellite under consideration by
%   initially comparing the apoapsis and periapsis of two space objects and then performing a
%   numerical MOID calculation.
%   
%
% INPUT:
%   Primary = (1 object)  Primary NASA satellite as an object from the catalogue [Space_object]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   
% OUTPUT:
%   close_orbits = (G objects) List of space objects from space catalogue with MOIDs less than the threshold [km]
%
% ASSUMPTIONS AND LIMITATIONS:
%   To improve the MOID calculation speed, a tolerance of 1 km is considered
%   Remember that G<=M
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%   15/1/2023 - Sina Es haghi
%       * Modifying the initial Apogee, Perigee filter
%

function close_orbits = MOID(Primary,space_cat)
config = GetConfig;
distance = config.moid_distance;
rarp_distance = config.FirstFilter;
%% First Filter (ra-rp)

ra_primary=Primary.a.*(1+Primary.e);
rp_primary=Primary.a.*(1-Primary.e);
ind=0;

rpra_filtered(length(space_cat))=Space_object;

for i=1:length(space_cat)
    ra_obj=space_cat(i).a*(1+space_cat(i).e);
    rp_obj=space_cat(i).a*(1-space_cat(i).e);
    if strcmp(space_cat(i).name,Primary.name)
        continue
    elseif rp_primary>(rarp_distance+ra_obj) || (ra_primary+rarp_distance)<rp_obj % This just newly modified (only works with J2 propagator)
        continue
    else
        %% The actual MOID calculation
        moid = MOID_numerical (Primary, space_cat(i),distance );
        if moid<=distance
            ind=ind+1;
            rpra_filtered(ind)=space_cat(i);
        end
    end
end

rpra_filtered(ind+1:end)=[];

close_orbits=rpra_filtered;