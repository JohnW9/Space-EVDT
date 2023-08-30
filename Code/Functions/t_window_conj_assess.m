function event_list = t_window_conj_assess (t_windows,primary0,secondary0,event_list,config_data)

if isempty(t_windows)
    return;
end

for i=1:size(t_windows,1)
    epoch = t_windows(i,1);
    final = t_windows(i,2);
    primary = TwoBP_J2_analytic (primary0,epoch,'mjd2000');
    secondary = TwoBP_J2_analytic (secondary0,epoch,'mjd2000');
    obj = Space_object;
    obj(1) = primary;
    obj(2) = secondary;

    timestep = 10; %s
    prop_obj = main_propagator (obj,mjd20002date(final),timestep,1);
    event_list = conj_assess (prop_obj(1), prop_obj(2),event_list,config_data);

end

