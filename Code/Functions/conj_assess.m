% FUNCTION NAME:
%   conj_assess
%
% DESCRIPTION:
%   This function does the conjunction assessment based on the propagated data of
%   the space objects at specific timesteps. This function initially detects conjunctions
%   inside the enlarged screening volume based on the initial timestep of the propagated objects.
%   To do so, the maximum orbital velocity of the objects is calculated, summed up and multiplied
%   by the initial propagation timestep. This creates the maximum distance threshold corresponding to the chosen timestep.
%   If the actual distance was less than the threshold, a new propagation is conducted
%   with a finer time step and the conjunction is assessed with the real screening volume. If again
%   the conjunction exists, a super fine tuning is carried out to find the exact time of conjunction
%   with a higher accuracy. Since the conjunction box is defined in the RSW directions,
%   a conversion of the relative positions from ECI to local RSW is implemented.
%
%
% INPUT:
%   primary = (1 object) Propagated primary NASA satellites  [Propagated_space_object]
%   objects_list = (G objects) List of propagated relevant space objects [Propagated_space_object]
%   event_list = (F objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%
% OUTPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%
% ASSUMPTIONS AND LIMITATIONS:
%   The objects must have the same epoch.
%   The states of the space objects are generated at the same timesteps.
%   Remember that number of events in event_list must increase or stay constant after the simulation (F<=P)
%   The screening volume can be either a box or an ellipsoid.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%   30/1/2023 - Sina Es haghi
%       * Ellipsoid screening volume option added
%   14/2/2023 - Sina Es haghi
%       * Initial screening filter modified
%   23/2/2023 - Sina Es haghi
%       * Final conjuncrion layer modified to find the real minimum miss distance
%   28/8/2023 - Sina Es haghi
%       * Deleted the extra inputs
%

function event_list = conj_assess (primary, objects_list,event_list,config_data)
if nargin<4
    global config;
    config_data = config;
end

conj_box = config_data.conjunction_box;

volume_type = config_data.screening_volume_type;

miu= 3.986004330000000e+05;

fine_prop_timestep=config_data.fine_prop_timestep; %[s]

timestep=primary.timestep;
t=primary.t; %[mjd2000]
time_index_final=length(t);
objects_length = length(objects_list);
if volume_type == 0 % If the screening volume is a box
    for k=1:objects_length

        max_v_primary = sqrt(miu/primary.ma * (1+primary.me)/(1-primary.me));
        max_v_object = sqrt(miu/objects_list(k).ma * (1+objects_list(k).me)/(1-objects_list(k).me));


        X_rel_eci=objects_list(k).rx-primary.rx;
        Y_rel_eci=objects_list(k).ry-primary.ry;
        Z_rel_eci=objects_list(k).rz-primary.rz;

        distance = sqrt(X_rel_eci.^2+Y_rel_eci.^2+Z_rel_eci.^2);

        max_possible_distance = (max_v_primary+max_v_object)*timestep;

        for l=1:length(t)

            if  distance(l)<=max_possible_distance

                temp_object(2)=Space_object;
                temp_timestep=fine_prop_timestep;
                if l==1
                    INITIAL_time_ind=1;
                else
                    INITIAL_time_ind=l-1;
                end
                if l==time_index_final
                    FINAL_time_ind=time_index_final;
                else
                    FINAL_time_ind=l+1;
                end

                temp_final_time=mjd20002date(primary.t(FINAL_time_ind));
                temp_object(1).a=primary.ma; temp_object(1).e=primary.me; temp_object(1).i=primary.mi; temp_object(1).raan=primary.mraan(INITIAL_time_ind); temp_object(1).om=primary.mom(INITIAL_time_ind); temp_object(1).M=primary.M(INITIAL_time_ind);
                temp_object(2).a=objects_list(k).ma; temp_object(2).e=objects_list(k).me; temp_object(2).i=objects_list(k).mi; temp_object(2).raan=objects_list(k).mraan(INITIAL_time_ind); temp_object(2).om=objects_list(k).mom(INITIAL_time_ind); temp_object(2).M=objects_list(k).M(INITIAL_time_ind);
                temp_epoch=primary.t(INITIAL_time_ind);
                temp_object(1).epoch=temp_epoch;
                temp_object(2).epoch=temp_epoch;
                temp_object_prop = main_propagator (temp_object,temp_final_time,temp_timestep,1);

                weird_x_rel=temp_object_prop(2).rx-temp_object_prop(1).rx;
                weird_y_rel=temp_object_prop(2).ry-temp_object_prop(1).ry;
                weird_z_rel=temp_object_prop(2).rz-temp_object_prop(1).rz;

                [weird_r_rel,weird_s_rel,weird_w_rel]=ECI2RSW_vect(temp_object_prop(1).rx,temp_object_prop(1).ry,temp_object_prop(1).rz,temp_object_prop(1).vx,temp_object_prop(1).vy,temp_object_prop(1).vz,weird_x_rel,weird_y_rel,weird_z_rel);

                conjunction_existance = 0;

                for g = 1 : length(temp_object_prop(1).t)
                    if abs(weird_r_rel(g))<conj_box(1)/2 && abs(weird_s_rel(g))<conj_box(2)/2 && abs(weird_w_rel(g))<conj_box(3)/2
                        % Conjunction exists
                        conjunction_existance = 1;
                        state0_1 = [temp_object_prop(1).rx(g) temp_object_prop(1).ry(g) temp_object_prop(1).rz(g) temp_object_prop(1).vx(g) temp_object_prop(1).vy(g) temp_object_prop(1).vz(g)]';
                        state0_2 = [temp_object_prop(2).rx(g) temp_object_prop(2).ry(g) temp_object_prop(2).rz(g) temp_object_prop(2).vx(g) temp_object_prop(2).vy(g) temp_object_prop(2).vz(g)]';
                        t0 = temp_object_prop(1).t(g);
                        break;
                    end
                end

                if conjunction_existance == 1

                    [miss_dist,tca] = conjunction_tuning (state0_1,state0_2,t0,config_data);

                    event=Conjunction_event;
                    event.tca=tca;
                    event.primary_id=primary.id;
                    event.secondary_id=objects_list(k).id;
                    event.mis_dist=miss_dist;


                    if ~isempty(event_list(1).tca)
                        new_event=1;
                        for v=1:length(event_list)
                            if event_list(v).secondary_id==event.secondary_id && abs(event_list(v).tca-event.tca)<0.041 % No consecutive events with TCA less than one hour with the same object
                                new_event=0;
                                if event.mis_dist<event_list(v).mis_dist
                                    event_list(v)=event;
                                    event_list(v).id=v;
                                    event_list(v).status=0;
                                end
                                break;
                            end
                        end
                        if new_event==1
                            event_list(end+1)=event;
                            event_list(end).id=length(event_list);
                            event_list(end).status=0;
                        end
                    else
                        event.id=1;
                        event_list=event;
                        event_list.status=0;
                    end
                end
            end
        end
    end

elseif volume_type == 1 % If the screening volume is an ellipsoid

    for k=1:objects_length

        max_v_primary = sqrt(miu/primary.ma * (1+primary.me)/(1-primary.me));
        max_v_object = sqrt(miu/objects_list(k).ma * (1+objects_list(k).me)/(1-objects_list(k).me));


        X_rel_eci=objects_list(k).rx-primary.rx;
        Y_rel_eci=objects_list(k).ry-primary.ry;
        Z_rel_eci=objects_list(k).rz-primary.rz;

        distance = sqrt(X_rel_eci.^2+Y_rel_eci.^2+Z_rel_eci.^2);

        max_possible_distance = (max_v_primary+max_v_object)*timestep;

        for l=1:length(t)

            if  distance(l)<=max_possible_distance
                temp_object(2)=Space_object;
                temp_timestep=fine_prop_timestep;
                if l==1
                    INITIAL_time_ind=1;
                else
                    INITIAL_time_ind=l-1;
                end
                if l==time_index_final
                    FINAL_time_ind=time_index_final;
                else
                    FINAL_time_ind=l+1;
                end

                temp_final_time=mjd20002date(primary.t(FINAL_time_ind));
                temp_object(1).a=primary.ma; temp_object(1).e=primary.me; temp_object(1).i=primary.mi; temp_object(1).raan=primary.mraan(INITIAL_time_ind); temp_object(1).om=primary.mom(INITIAL_time_ind); temp_object(1).M=primary.M(INITIAL_time_ind);
                temp_object(2).a=objects_list(k).ma; temp_object(2).e=objects_list(k).me; temp_object(2).i=objects_list(k).mi; temp_object(2).raan=objects_list(k).mraan(INITIAL_time_ind); temp_object(2).om=objects_list(k).mom(INITIAL_time_ind); temp_object(2).M=objects_list(k).M(INITIAL_time_ind);
                temp_epoch=primary.t(INITIAL_time_ind);
                temp_object(1).epoch=temp_epoch;
                temp_object(2).epoch=temp_epoch;
                temp_object_prop = main_propagator (temp_object,temp_final_time,temp_timestep,1);

                weird_x_rel=temp_object_prop(2).rx-temp_object_prop(1).rx;
                weird_y_rel=temp_object_prop(2).ry-temp_object_prop(1).ry;
                weird_z_rel=temp_object_prop(2).rz-temp_object_prop(1).rz;

                [weird_r_rel,weird_s_rel,weird_w_rel]=ECI2RSW_vect(temp_object_prop(1).rx,temp_object_prop(1).ry,temp_object_prop(1).rz,temp_object_prop(1).vx,temp_object_prop(1).vy,temp_object_prop(1).vz,weird_x_rel,weird_y_rel,weird_z_rel);
                conjunction_existance = 0;
                for g=1:length(temp_object_prop(1).t)
                    if abs(weird_r_rel(g))^2/(conj_box(1)/2)^2 + abs(weird_s_rel(g))^2/(conj_box(2)/2)^2 + abs(weird_w_rel(g))^2/(conj_box(3)/2)^2 <= 1
                        % Conjunction exists
                        conjunction_existance = 1;
                        state0_1 = [temp_object_prop(1).rx(g) temp_object_prop(1).ry(g) temp_object_prop(1).rz(g) temp_object_prop(1).vx(g) temp_object_prop(1).vy(g) temp_object_prop(1).vz(g)]';
                        state0_2 = [temp_object_prop(2).rx(g) temp_object_prop(2).ry(g) temp_object_prop(2).rz(g) temp_object_prop(2).vx(g) temp_object_prop(2).vy(g) temp_object_prop(2).vz(g)]';
                        t0 = temp_object_prop(1).t(g);
                        break;
                    end
                end
                if conjunction_existance == 1

                    [miss_dist,tca] = conjunction_tuning (state0_1,state0_2,t0,config_data);

                    event=Conjunction_event;
                    event.tca=tca;
                    event.primary_id=primary.id;
                    event.secondary_id=objects_list(k).id;
                    event.mis_dist=miss_dist;


                    if ~isempty(event_list(1).tca)
                        new_event=1;
                        for v=1:length(event_list)
                            if event_list(v).secondary_id==event.secondary_id && abs(event_list(v).tca-event.tca)<0.041 % No consecutive events with TCA less than one hour with the same object
                                new_event=0;
                                if event.mis_dist<event_list(v).mis_dist
                                    event_list(v)=event;
                                    event_list(v).id=v;
                                    event_list(v).status=0;
                                end
                                break;
                            end
                        end
                        if new_event==1
                            event_list(end+1)=event;
                            event_list(end).id=length(event_list);
                            event_list(end).status=0;
                        end
                    else
                        event.id=1;
                        event_list=event;
                        event_list.status=0;
                    end
                end
            end
        end
    end
else
    error('Not an acceptable screening volume.')
end