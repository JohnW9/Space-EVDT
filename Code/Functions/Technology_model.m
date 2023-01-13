% FUNCTION NAME:
%   Technology_model
%
% DESCRIPTION:
%   To do Orbital determination for the two space objects in conjunction, this function is used.
%   It intakes the actual states of the objects, and outputs the estimated observed states of objects.
%   Since the states are observed with some error, an estimated miss-distance is also calculated.
%   The program uses the Government SSA provider by default and at daily time scales, however any
%   tasking requests by the decision model will make the technology model to use the commercial 
%   SSA provider for OD. Although, the commercial SSA provider has a chance of being unavailable, 
%   resulting in a failed request. 
%
% INPUT:
%   event_column = [13x1] A matrix with one column corresponding to a conjunction,Containing important 
%                         space object informations. 
%                         [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km]'
%   t = [1x1] Realistic observation time [mjd2000]
%   actual_objects_states = [12x1] Actual cartesian states of the 2 objects at real time t [units in km and km/s]
%   actual_objects_states_at_tca = [12x1] Actual cartesian states of the 2 objects at TCA [units in km and km/s]
%
%     event_column details:
%     row1: Conjunction event ID number (in chronological order)
%     row2: Time of detection in [MJD2000]
%     row3: Primary satellite NORAD ID
%     row4: Secondary space object NORAD ID
%     row5: Estimated Miss distance in [km]
%     row6: Number of times the cdm is generated for the event
%     row7: Next expected conjunction update [MJD2000]
%     row8: Type of SSA to use
%     row9: TCA [MJD2000]
%     row10: Mitigation status (0-not mitigated 1-mitigated -1-not mitigated and TCA passed)
%     row11: Request status (0-no special tasking request 1-commercial SSA request -1-commercial request denied by the provider)
%     row12: Last successful observation time [MJD2000]
%     row13: Real miss distance (either manipulated or not) [km]
%
% OUTPUT:
%   event_column = [12x1] A matrix with one column corresponding to the same conjunction,Containing important 
%                         space object informations. Some are modified since input. 
%                         [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000]'
%   conjunction_data = [84x1] A matrix containing all the orbital data and covariances of the two
%                             space objects at the real observation time.
%   cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%
%     conjunction_data matrix details:
%     row1-6: Cartesian state of object 1 in ECI [km;km;km;km/s;km/s;km/s]
%     row7-12: Cartesian state of object 2 in ECI [km;km;km;km/s;km/s;km/s]
%     row13-48: Covariance elements of object 1 in RSW [units in km^2 and km^2/s^2]
%     row49-84: Covariance elements of object 2 in RSW [units in km^2 and km^2/s^2]
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   The program currently gives the same deterministic covariances to both objects.
%   No stochastic
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%   12/1/2023 - Sina Es haghi
%       * Adding the stochastic functions to the technology model
%
function [event_column,conjunction_data,cost] = Technology_model (event_column,t,actual_objects_states,actual_objects_states_at_tca)

ssa_type=event_column(8);
conjunction_data=zeros(84,1);

tca = event_column(9);

actual_stats_at_t1=actual_objects_states(1:6);
actual_stats_at_t2=actual_objects_states(7:12);

actual_stats_at_tca1=actual_objects_states_at_tca(1:6);
actual_stats_at_tca2=actual_objects_states_at_tca(7:12);

switch ssa_type
    case 0 % Using the 18 SDS
        
        %[state_car1,P01]=SDS18 (event_column(3),t,space_cat,space_cat_ids);
        [state_car1,P01,state_car_tca1]=SDS18 (actual_stats_at_t1,actual_stats_at_tca1,t,tca);
        [state_car2,P02,state_car_tca2]=SDS18 (actual_stats_at_t2,actual_stats_at_tca2,t,tca);
        %[state_car2,P02]=SDS18 (event_column(4),t,space_cat,space_cat_ids);

        %% Adding the OD and Covariance values to the conjunction data
        conjunction_data=[state_car1;state_car2;reshape(P01,[36,1]);reshape(P02,[36,1])];
        cost = 0;
        event_column(11)=0;
        event_column(12)=t;
        event_column(5)=norm(state_car_tca1(1:3)-state_car_tca2(1:3));

    case 1 % Using the commercial version

        acceptance_chance=rand(1,1);

        if acceptance_chance<=0.8 %% What is the availability possibility of using the commercial ssa provider
            event_column(11)=1;
            [state_car1,P01,state_car_tca1]=LEOLABS (actual_stats_at_t1,actual_stats_at_tca1,t,tca);
            [state_car2,P02,state_car_tca2]=LEOLABS (actual_stats_at_t2,actual_stats_at_tca2,t,tca);
            
            %% Adding the OD and Covariance values to the conjunction data
            conjunction_data=[state_car1;state_car2;reshape(P01,[36,1]);reshape(P02,[36,1])];
            cost = 1; %% CHANGE THIS VALUE
            event_column(11)=1;
            event_column(5)=norm(state_car_tca1(1:3)-state_car_tca2(1:3));
            event_column(12)=t;
        else
            event_column(11)=-1;
            cost=0;
        end
end

%% returning to default setting for next update

event_column(8)=0;
event_column(7)=event_column(12)+1; % One day later from the last successful observation


%%%%% REMEMBER THAT IF NO COVARIANCE IS AVAILABLE FOR OBJECT 2 , THE COVARIANCE SHOULD BE ZERO COMPLETELY
        