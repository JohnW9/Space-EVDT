

function event_list = time_prefilter_candidates (primary0,secondary0,D,time_initial,time_final,event_list,config_data)
% time input is in Date
primary = TwoBP_J2_analytic (primary0,time_initial);
secondary = TwoBP_J2_analytic (secondary0,time_initial);


%% Now we have the states at time_initial

% Finding relative inclination
h_i =@(I,Om) [sin(Om)*sin(I);-cos(Om)*sin(I);cos(I)]; % Modified from Hoots 1984
h_p = h_i(primary.i,primary.raan);
h_s = h_i(secondary.i,secondary.raan);
K = cross(h_s,h_p);
sin_I_R = norm(K); 

% Deltas, the angle between K and line and ascending node
Ip = primary.i;
Is = secondary.i;
Omp = primary.raan;
Oms = secondary.raan;
cos_deltaP = 1/sin_I_R * (sin(Ip)*cos(Is)-sin(Is)*cos(Ip)*cos(Omp-Oms));
sin_deltaP = 1/sin_I_R * (sin(Is)*sin(Omp-Oms));

cos_deltaS = 1/sin_I_R * (sin(Ip)*cos(Is)*cos(Omp-Oms)-sin(Is)*cos(Ip));
sin_deltaS = 1/sin_I_R * (sin(Ip)*sin(Omp - Oms));

delta_p = acos(cos_deltaP);
if sin_deltaP<0; delta_p=2*pi - delta_p; end

delta_s = acos(cos_deltaS);
if sin_deltaS<0; delta_s=2*pi - delta_s; end

% Finding u_r
u_r_p = u_r_calculator (primary.a,primary.e,primary.om,delta_p,D);
u_r_s = u_r_calculator (secondary.a,secondary.e,secondary.om,delta_s,D);

% What if Coplanar?
if isempty(u_r_p) || isempty(u_r_s)
    disp('sth must be done, co-planar');
    objects_list=Space_object;
    objects_list(1)=primary;
    objects_list(2)=secondary;
    propagated_object_list = main_propagator (objects_list,time_final,config_data.timestep,1);
    event_list = conj_assess (propagated_object_list(1), propagated_object_list(2),event_list,space_cat,space_cat_ids,config_data);
    return
end

% converting to f
f_windows_p = mod(u_r_p-primary.om+delta_p,2*pi);
f_windows_s = mod(u_r_s-secondary.om+delta_s,2*pi);

% converting to M
M_windows_p = f2M_window(f_windows_p,primary.e);
M_windows_s = f2M_window(f_windows_s,secondary.e);

% converting to time window
t_p = M2t_window (M_windows_p,primary.M,primary.epoch,primary.a);
t_s = M2t_window (M_windows_s,secondary.M,secondary.epoch,secondary.a);

% Initial time windows have been found, now, series of time windows must be found
[t_list1,t_list2] = time_window_extender (primary,secondary,t_p,t_s,date2mjd2000(time_final));

% Now need to find the overlaps
t_candidate = time_window_overlap_finder(t_list1,t_list2);

% Now need for propagating and finding conjunctions
event_list = t_window_conj_assess (t_candidate,primary,secondary,event_list,config_data);

%% Functions
    function u_r = u_r_calculator (a,e,om,delta,D)
        alpha = a*(1-e^2);
        ax = e*cos(om-delta);
        ay = e*sin(om-delta);
        Q = alpha*(alpha - 2*D*ay) - (1-e^2)*D^2;
        eq1 = (-D^2*ax+(alpha-D*ay)*Q^0.5)/(alpha*(alpha - 2*D*ay)+D^2*e^2);
        eq2 = (-D^2*ax-(alpha-D*ay)*Q^0.5)/(alpha*(alpha - 2*D*ay)+D^2*e^2);

        if Q<0 || (abs(eq1)>1 && abs(eq2)>1)
            u_r = [];
            return;
        end

        ur2 = acos(eq1);
        ur1 = -ur2;
        ur3 = acos(eq2);
        ur4 = -ur3;

        u_r = [ur1,ur2;ur3,ur4];
    end

    function M_window = f2M_window (f_window,e)
        mat_size = size(f_window);
        M_window = f_window;
        for v = 1:mat_size(1)
            for g = 1:mat_size(2)
                M_window(v,g) = f2M(f_window(v,g),e);
            end
        end
    end

    function [t,date] = M2t_window (M_window,M0,epoch,a)
        miu= 3.986004330000000e+05;
        delta_t = (M_window-M0)*sqrt(a^3/miu)/86400; %in hr
        t = delta_t + epoch;
        t = sort(t,1);
        if nargout ==2
            date = [mjd20002date(t(1,1)) mjd20002date(t(1,2));mjd20002date(t(2,1)) mjd20002date(t(2,2))];
        end
    end

    
end