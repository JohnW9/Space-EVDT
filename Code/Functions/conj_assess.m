% FUNCTION NAME:
%   conj_assess
%
% DESCRIPTION:
%   This function does the conjunction assessment based on the propagated data of
%   the space objects at specific timesteps. This function initially detects conjunctions
%   inside the enlarged screening volume based on the initial timestep of the propagated objects.
%   Since the timesteps might be large, an auxillary distance is also considered where the relative
%   velocity of the two objects is multiplied by the timestep, resulting in a distance that can be 
%   subtracted from the actual distance, resulting in a possible minimum distance.
%   If there was a conjunction in the enlarged screening volume, a new propagation is conducted
%   with a finer time step and the conjunction is assessed with the real screening volume. If again
%   the conjunction exists, a super fine propagation is carried out to find the exact time of conjunction
%   with an accuracy of 0.1 seconds. Since the conjunction box is defined in the RSW directions,
%   a conversion of the relative positions from ECI to local RSW is implemented.
%   
%
% INPUT:
%   primary = (1 object) Propagated primary NASA satellites  [Propagated_space_object]
%   objects_list = (G objects) List of propagated relevant space objects [Propagated_space_object]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   space_cat_ids = [1xM] A matrix containing the NORAD IDs of the space catalogue objects in order
%   event_list = (F objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   
% OUTPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%
% ASSUMPTIONS AND LIMITATIONS:
%   The objects must have the same epoch.
%   The states of the space objects are generated at the same timesteps.
%   Remember that number of events in event_list must increase or stay constant after the simulation (F<=P)
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%

function event_list = conj_assess (primary, objects_list,event_list,space_cat,space_cat_ids)
global config;
conj_box = config.conjunction_box;
                                              %Experimental relation (Since the best timestep for conjunction screening
                                              % is in the order of 1 second, this value box multiplier value is used to 
                                              % enlarge the screening volume so even with larger timesteps, conjunctions
                                              % are not missed. The relation is completely imperical.

box_multiplier = config.screeningBoxMultiplier;

fine_prop_timestep=config.fine_prop_timestep; %[s]

timestep=primary.timestep;
t=primary.t; %[mjd2000]
time_index_final=length(t);
objects_length = length(objects_list);
for k=1:objects_length
    
    X_rel_eci=objects_list(k).rx-primary.rx;
    Y_rel_eci=objects_list(k).ry-primary.ry;
    Z_rel_eci=objects_list(k).rz-primary.rz;

    [R_rel,S_rel,W_rel] = ECI2RSW_vect(primary.rx,primary.ry,primary.rz,primary.vx,primary.vy,primary.vz,X_rel_eci,Y_rel_eci,Z_rel_eci);

    VX_rel_eci=objects_list(k).vx-primary.vx;
    VY_rel_eci=objects_list(k).vy-primary.vy;
    VZ_rel_eci=objects_list(k).vz-primary.vz;

    [VR_rel,VS_rel,VW_rel] = ECI2RSW_vect(primary.rx,primary.ry,primary.rz,primary.vx,primary.vy,primary.vz,VX_rel_eci,VY_rel_eci,VZ_rel_eci);

    % Auxillary distance calculation
    virt_dist_r = timestep.*VR_rel;
    virt_dist_s = timestep.*VS_rel;
    virt_dist_w = timestep.*VW_rel;

    aux_dist_r = abs(R_rel-virt_dist_r);
    aux_dist_s = abs(S_rel-virt_dist_s);
    aux_dist_w = abs(W_rel-virt_dist_w);

    for l=1:length(t)
        
        if  min(abs(R_rel(l)),aux_dist_r(l))<conj_box(1)/2*box_multiplier  &&  min(abs(S_rel(l)),aux_dist_s(l))<conj_box(2)/2*box_multiplier  &&  min(abs(W_rel(l)),aux_dist_w(l))<conj_box(3)/2*box_multiplier
            
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
            index_holder=1:length(temp_object_prop(1).t);
            for g=length(temp_object_prop(1).t):-1:1
                if abs(weird_r_rel(g))>conj_box(1)/2 || abs(weird_s_rel(g))>conj_box(2)/2 || abs(weird_w_rel(g))>conj_box(3)/2
                    weird_r_rel(g)=[];
                    weird_s_rel(g)=[];
                    weird_w_rel(g)=[];
                    index_holder(g)=[];
                end
            end

            if isempty(index_holder)
                continue;
            end

            weird_distance=sqrt(weird_r_rel.^2+weird_s_rel.^2+weird_w_rel.^2);
            [min_distance,minimum_dist_index]=min(weird_distance);
            if abs(R_rel(l))<conj_box(1)/2 && abs(S_rel(l))<conj_box(2)/2 && abs(W_rel(l))<conj_box(3)/2
                distance=norm([X_rel_eci(l),Y_rel_eci(l),Z_rel_eci(l)]);
            else
                distance=0.5*box_multiplier*sqrt(conj_box(1)^2+conj_box(2)^2+conj_box(3)^2);
            end
            if min_distance>distance+0.0001
                disp('Something wrong in fine propagation');
            end
            
            minimum_dist_index=index_holder(minimum_dist_index);


            if true %min_distance<box
                if minimum_dist_index==1
                    in_time=temp_object_prop(1).t(1);
                    kol=minimum_dist_index;
                else
                    in_time=temp_object_prop(1).t(minimum_dist_index-1);
                    kol=minimum_dist_index-1;
                end
                if minimum_dist_index==length(temp_object_prop(1).t)
                    f_time=mjd20002date(temp_object_prop(1).t(end));
                else
                    f_time=mjd20002date(temp_object_prop(1).t(minimum_dist_index+1));
                end
                super_temp_object(2)=Space_object;
                super_temp_timestep=config.superfine_prop_timestep; %% Super fine propagation timestep
                for gooz=1:2
                    super_temp_object(gooz).epoch=in_time;
                    super_temp_object(gooz).a=temp_object_prop(gooz).ma;
                    super_temp_object(gooz).e=temp_object_prop(gooz).me;
                    super_temp_object(gooz).i=temp_object_prop(gooz).mi;
                    super_temp_object(gooz).raan=temp_object_prop(gooz).mraan(kol);
                    super_temp_object(gooz).om=temp_object_prop(gooz).mom(kol);
                    super_temp_object(gooz).M=temp_object_prop(gooz).M(kol);
                end
                super_temp_object_prop = main_propagator (super_temp_object,f_time,super_temp_timestep,1);

                
                super_weird_x_rel=super_temp_object_prop(2).rx-super_temp_object_prop(1).rx;
                super_weird_y_rel=super_temp_object_prop(2).ry-super_temp_object_prop(1).ry;
                super_weird_z_rel=super_temp_object_prop(2).rz-super_temp_object_prop(1).rz;

                [super_weird_r_rel,super_weird_s_rel,super_weird_w_rel]=ECI2RSW_vect(super_temp_object_prop(1).rx,super_temp_object_prop(1).ry,super_temp_object_prop(1).rz,super_temp_object_prop(1).vx,super_temp_object_prop(1).vy,super_temp_object_prop(1).vz,super_weird_x_rel,super_weird_y_rel,super_weird_z_rel);


                super_index_holder=1:length(super_temp_object_prop(1).t);
                
                for d=length(super_temp_object_prop(1).t):-1:1
                    if abs(super_weird_r_rel(d))>conj_box(1)/2 || abs(super_weird_s_rel(d))>conj_box(2)/2 || abs(super_weird_w_rel(d))>conj_box(3)/2
                        super_weird_r_rel(d)=[];
                        super_weird_s_rel(d)=[];
                        super_weird_w_rel(d)=[];
                        super_index_holder(d)=[];
                    end
                end

                if isempty(super_index_holder)
                    continue;
                end


                super_weird_distance=sqrt(super_weird_r_rel.^2+super_weird_s_rel.^2+super_weird_w_rel.^2);
                [super_min_distance,super_minimum_dist_index]=min(super_weird_distance);


                if super_min_distance>min_distance+0.0001
                    disp('Something wrong in Super fine propagation');
                end
                
                super_minimum_dist_index=super_index_holder(super_minimum_dist_index);

                event=Conjunction_event;
                event.tca=super_temp_object_prop(1).t(super_minimum_dist_index);
                event.primary_id=primary.id;
                event.secondary_id=objects_list(k).id;
                event.mis_dist=super_min_distance;

                %% delete afterwards
                obj1_index = find(space_cat_ids==primary.id);
                obj2_index = find(space_cat_ids==objects_list(k).id);
                temp_objects(1)=space_cat(obj1_index);
                temp_objects(2)=space_cat(obj2_index);
                temp_objects(1) = TwoBP_J2_analytic (temp_objects(1),super_temp_object_prop(1).t(super_minimum_dist_index),'mjd2000');
                temp_objects(2) = TwoBP_J2_analytic (temp_objects(2),super_temp_object_prop(1).t(super_minimum_dist_index),'mjd2000');
                single_event_matrix=zeros(18,1);
                single_event_matrix(7:18)=[temp_objects(1).a temp_objects(1).e temp_objects(1).i temp_objects(1).raan temp_objects(1).om temp_objects(1).M ...
                                           temp_objects(2).a temp_objects(2).e temp_objects(2).i temp_objects(2).raan temp_objects(2).om temp_objects(2).M]';
                state1_f = par2car([single_event_matrix(7:11);M2f(single_event_matrix(12),single_event_matrix(8))]);
                r1_f=state1_f(1:3);
                state2_f = par2car([single_event_matrix(13:17);M2f(single_event_matrix(18),single_event_matrix(14))]);
                r2_f=state2_f(1:3);
                if abs(norm(r1_f-r2_f)-super_min_distance)>0.001
                    disp('Inconsistency between the mis distance and the final positions of the space objects')
                end
                %%


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
