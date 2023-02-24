% FUNCTION NAME:
%   SpaceEVDT
%
% DESCRIPTION:
%   Given an epoch and end date, along with the space catalogue and the primary 
%   NASA satellites under consideration, this function will use models of the
%   Environment, Vulnerability, Decision-making, and Technology within the EVDT
%   framework to simulate a scenario similar to realistic space collision avoidance.
%
% INPUT:
%   epoch = [1x6] Simulation start date in Gregorian calender [yy mm dd hr mn sc]
%   end_date = [1x6] Simulation end date in Gregorian calender [yy mm dd hr mn sc]
%   eos = (N objects)  Primary NASA satellites under consideration for collision avoidance [NASA_sat]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   accelerator = [1x1] This value is for the manipulating the miss distance of a conjunction at the time of 
%                       closest approach. the accelerator will decrease the miss distance with the relation of
%                       10^-(accelerator). (0 by default)
%%%%%%% OPTIONAL INPUTS (For modular use) %%%%%%%%%%%%%
%   event_list = (X objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   cdm_list = (F objects) List of all CDMs generated in the chronological order [CDM]
%   decision_list = (U objects) The list containing all the actions taken by the decision model [Decision_action]
%   event_detection = [14xB] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%   
% OUTPUT:
%   cdm_rep_list = [SxP] A cell matrix with each column representing a single conjunction event 
%                        in an ascending chronological order, and rows containing the CDMs 
%                        corresponding to that conjunction event.
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   cdm_list = (Q objects) List of all CDMs generated in the chronological order [CDM]
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%   decision_list = (J objects) The list containing all the actions taken by the decision model [Decision_action]
%
% ASSUMPTIONS AND LIMITATIONS:
%   The current program uses a simple analytic propagator, considering only secular J2 effects.
%   The program has completely become modular. In case some event_list, cdm_list ... are available,
%   they can be fed as inputs and the module can continue the process with new space catalogue.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%   1/2/2023 - Sina Es haghi
%       * Completed the modular mode of the function, inputs and outputs are modified


function [cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator,event_list,cdm_list,decision_list,event_detection,total_cost)
%% Input check
if nargin<5
    error('Insufficient number of inputs.');
elseif nargin == 5
    event_list=Conjunction_event;
    cdm_list=CDM;
    decision_list=Decision_action;
    event_detection=zeros(13,1);
    event_detection(1)=NaN;
    total_cost=0;
else
    for k=length(event_list):-1:1
        if event_list(k).tca>date2mjd2000(epoch) % Deleting all the previously detected events with TCA's after the new epoch
            event_list(k)=[];
        end
    end
end


GetConfig; %% Configuring the properties of the program using a global variable

space_cat_ids=zeros(1,length(space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end

%% Pre-process
no_days=date2mjd2000(end_date)-date2mjd2000(epoch); % simulation time in days after epoch
%% Propagation and event detection
for eos_sat=1:length(eos)
    event_list = Event_detection (eos(eos_sat),space_cat,epoch,no_days,event_list,space_cat_ids);
end
disp('All conjunctions throughout the simulation time detected')
%% Event list to matrix conversion
event_matrix = list2matrix (event_list);
disp('Event list converted to conjunction event matrix');
%% Saving 
%save("Data\Intermediate_23Feb.mat");
%% Loading
%load("Data\Intermediate_23Feb.mat");
GetConfig;
%% Replicating NASA CARA
[cdm_list,event_detection,total_cost,decision_list]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,accelerator,cdm_list,decision_list,event_detection,total_cost);
disp('NASA CARA process replicated')
%% CDM repetition list
cdm_rep_list = CDM_rep_list (event_detection,cdm_list);