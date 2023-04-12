function new_event_list = screening_vol_contractor (event_list,screen_vol_type,screen_vol_dim,space_cat,space_cat_ids)
new_event_list = Conjunction_event;
i=0;
for j=1:length(event_list)
    id1 = event_list(j).primary_id;
    id2 = event_list(j).secondary_id;
    tca = event_list(j).tca;
    state_car1= Actual_state (id1,tca,space_cat,space_cat_ids);
    state_car2= Actual_state (id2,tca,space_cat,space_cat_ids);
    pos = state_car1(1:3)-state_car2(1:3);
    r = norm(pos(1));
    s = norm(pos(2));
    w = norm(pos(3));
    switch screen_vol_type
        case 0 % box
            if r<=screen_vol_dim(1)/2 && s<=screen_vol_dim(2)/2 && w<=screen_vol_dim(3)/2
                i=i+1;
                new_event_list(i)=event_list(j);
            end
        case 1 % Ellipsoid
            if r^2/(screen_vol_dim(1)/2)^2+s^2/(screen_vol_dim(2)/2)^2+w^2/(screen_vol_dim(3)/2)^2<=1
                i=i+1;
                new_event_list(i)=event_list(j);
            end
    end
end