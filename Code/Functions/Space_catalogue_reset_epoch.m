%% Resetting space catalogue to the same epoch

function space_cat_reset = Space_catalogue_reset_epoch (space_cat,date)
n=length(space_cat);
space_cat_reset(n)=Space_object;
for o=1:n
    space_cat_reset(o) = TwoBP_J2_analytic (space_cat(o),date);
end
end