%% WORKING PROGRESS

function close_orbits = MOID(Primary,distance,space_cat)
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
    elseif rp_primary>(distance+ra_obj) || (ra_primary+distance)<rp_obj
        continue
    else
        %% Here you have to add the MOID calculation
        moid = MOID_numerical (Primary, space_cat(i),distance );
        if moid<=distance
            ind=ind+1;
            rpra_filtered(ind)=space_cat(i);
        end
    end
end

rpra_filtered(ind+1:end)=[];

close_orbits=rpra_filtered;