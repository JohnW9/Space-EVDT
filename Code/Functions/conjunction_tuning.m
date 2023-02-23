function [miss_dist,tca] = conjunction_tuning (state0_1,state0_2,t0)

% assuming state 0 is the state of the objects at t0 which is the presumed TCA

global config;

timestep = config.fine_prop_timestep/86400;
min_d = norm(state0_1(1:3)-state0_2(1:3));
state1 = state0_1;
state2 = state0_2;
d = min_d;
tca = t0;

while timestep >= config.superfine_prop_timestep/86400

    % Backward propagation
    state_back_1 = TwoBP_J2_analytic_car_state (state1,-timestep);
    state_back_2 = TwoBP_J2_analytic_car_state (state2,-timestep);
    d_back = norm(state_back_1(1:3)-state_back_2(1:3));

    % Forward propagation
    state_forw_1 = TwoBP_J2_analytic_car_state (state1,+timestep);
    state_forw_2 = TwoBP_J2_analytic_car_state (state2,+timestep);
    d_forw = norm(state_forw_1(1:3)-state_forw_2(1:3));

    distances = [d_back d d_forw];

    [minimum_dist,minimum_index] = min(distances);

    if minimum_index == 2 || minimum_dist == d
        timestep = timestep * 0.1 ;
    else
        if minimum_index == 3
            d=minimum_dist;
            tca = tca + timestep;
            state1 = state_forw_1;
            state2 = state_forw_2;
        else
            d=minimum_dist;
            tca = tca - timestep;
            state1 = state_back_1;
            state2 = state_back_2;
        end
    end
end

if d>min_d
    error('Error in conjunction miss distance tuning');
end

miss_dist = d;


end