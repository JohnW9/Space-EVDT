function [event_column,conjunction_data,cost] = Technology_model (event_column,t,space_cat,space_cat_ids)

ssa_type=event_column(8);
conjunction_data=zeros(84,1);
switch ssa_type
    case 0 % Using the 18 SDS
        
        [state_car1,P01]=SDS18 (event_column(3),t,space_cat,space_cat_ids);
        [state_car2,P02]=SDS18 (event_column(4),t,space_cat,space_cat_ids);

        %% Adding the OD and Covariance values to the conjunction data
        conjunction_data=[state_car1;state_car2;reshape(P01,[36,1]);reshape(P02,[36,1])];
        cost = 0;
        event_column(11)=0;

    case 1 % Using the commercial version

        acceptance_chance=rand(1,1);

        if acceptance_chance<=0.8 %% What is the availability possibility of using the commercial ssa provider
            event_column(11)=1;
            [state_car1,P01]=LEOLABS (event_column(3),t,space_cat,space_cat_ids);
            [state_car2,P02]=LEOLABS (event_column(4),t,space_cat,space_cat_ids);
            %% Adding the OD and Covariance values to the conjunction data
            conjunction_data=[state_car1;state_car2;reshape(P01,[36,1]);reshape(P02,[36,1])];
            cost = 1; %% CHANGE THIS VALUE
            event_column(11)=1;
        else
            event_column(11)=-1;
            cost=0;
        end
end

%% returning to default setting for next update

event_column(8)=0;
event_column(7)=t+1; % One day later


%%%%% REMEMBER THAT IF NO COVARIANCE IS AVAILABLE FOR OBJECT 2 , THE COVARIANCE SHOULD BE ZERO COMPLETELY
        