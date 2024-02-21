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
%   MC = [1x1] Number of monte carlo runs to be performed on the assessment loop
%   event_list = (X objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   cdm_list = (F objects) List of all CDMs generated in the chronological order [CDM]
%   decision_list = (U objects) The list containing all the actions taken by the decision model [Decision_action]
%   event_detection = [14xB] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%   total_budget = [1x1] Initial budget available to the COLA team dependant on the simulation time
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
%   MOID_list = [Vx1] a list of relevant space objects detected throughout the simulation time
%   total_budget = [1x1] Initial budget available to the COLA team dependant on the simulation time (constant)
%   operation_cost = [1x1] Total operational cost calculated by now for analyzing the CDMs [$]
%%%%%%% OPTIONAL OUTPUTS (For monte carlo simulations) %%%%%%%%%%%%%
% Data with MC_XXXX are list of the same outputs in different monte carlo runs. 
% They are then equalled to the normal outputs as cell lists
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
%   20/2/2024 - Sina Es haghi
%       * Description modified plus the output of the function


function [cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list,MOID_list,total_budget,operation_cost] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator,MC,event_list,cdm_list,decision_list,event_detection,total_cost,total_budget)
%% Input check
if nargin<5
    error('Insufficient number of inputs.');
elseif nargin == 5
    MC = 1;
    event_list=Conjunction_event;
    cdm_list=CDM;
    decision_list=Decision_action;
    event_detection=zeros(14,1);
    event_detection(1)=NaN;
    total_cost=0;
    config = GetConfig; %% Configuring the properties of the program using a global variable
    total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
elseif nargin == 6
    event_list=Conjunction_event;
    cdm_list=CDM;
    decision_list=Decision_action;
    event_detection=zeros(14,1);
    event_detection(1)=NaN;
    total_cost=0;
    config = GetConfig; %% Configuring the properties of the program using a global variable
    total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
else
    for k=length(event_list):-1:1
        if event_list(k).tca>date2mjd2000(epoch) % Deleting all the previously detected events with TCA's after the new epoch
            event_list(k)=[];
        end
    end
end


%config = GetConfig; %% Configuring the properties of the program using a global variable

%% Pre-process
no_days=date2mjd2000(end_date)-date2mjd2000(epoch); % simulation time in days after epoch
%% Propagation and event detection
MOID_list = cell(length(eos),1);
WaitBar = waitbar(0,['Conjunction Assessment Initialization (0/' num2str(length(eos)) ')']);
for eos_sat=1:length(eos)
    [event_list,MOID_list{eos_sat}] = Event_detection (eos(eos_sat),space_cat,epoch,no_days,event_list);
    waitbar(eos_sat/length(eos),WaitBar,['Events for ' eos(eos_sat).name ' determined (' num2str(eos_sat) '/' num2str(length(eos)) ')' ]);
end
close(WaitBar);
disp('All conjunctions throughout the simulation time detected')
%% Event list to matrix conversion
try
    clear cdm_list total_cost decision_list event_detection cdm_rep_list
    space_cat_ids=zeros(1,length(space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
    for j=1:length(space_cat)
        space_cat_ids(j)=space_cat(j).id;
    end

catch
    space_cat_ids=zeros(1,length(space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
    for j=1:length(space_cat)
        space_cat_ids(j)=space_cat(j).id;
    end

end

try
    event_matrix = list2matrix (event_list);
catch
    error('No conjunction events detected with the current inputs')
end
disp('Event list converted to conjunction event matrix (and sorted)');

%% Saving 
%save("Data\Intermediate_6March.mat");
%% Loading
% clc
% clear
% load("Data\Intermediate_6March.mat");
% MC = 10;
% config = GetConfig; %% Configuring the properties of the program using a global variable
% total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
% load("Data\Intermediate_28March.mat")
% global total_budget;
% total_budget=305;
% GetConfig;
%% Monte Carlo Run
if MC == 1
    % Replicating NASA CARA
    [cdm_list,event_detection,total_cost,decision_list]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,accelerator,cdm_list,decision_list,event_detection,total_cost,total_budget);
    disp('NASA CARA process replicated')
    % CDM repetition list
    cdm_rep_list = CDM_rep_list (event_detection,cdm_list);
else
    MC_cdm_list = cell(MC,1);
    %MC_event_detection = cell(MC,1);
    MC_total_cost = cell(MC,1);
    MC_decision_list = cell(MC,1);
    MC_cdm_rep_list = cell(MC,1);
    MC_operation_cost = cell(MC,1);
    WaitBar_Assess = waitbar(0,'Starting Monte Carlo simulation...');
    %parfor ind = 1:MC
    for ind = 1:MC
        cdm_list=CDM;
        decision_list=Decision_action;
        event_detection=zeros(14,1);
        event_detection(1)=NaN;
        total_cost=0;
        %[cdm_list,event_detection,total_cost,decision_list]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,accelerator,cdm_list,decision_list,event_detection,total_cost,total_budget);
        [cdm_list,event_detection,total_cost,decision_list,operational_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,accelerator,cdm_list,decision_list,event_detection,total_cost,total_budget);
        cdm_rep_list = CDM_rep_list (event_detection,cdm_list);

        MC_cdm_list{ind} = cdm_list;
        %MC_event_detection{ind} = event_detection;
        MC_total_cost{ind} = total_cost;
        MC_decision_list{ind} = decision_list;
        MC_cdm_rep_list{ind} = cdm_rep_list;
        MC_operation_cost{ind} = operational_cost;

        waitbar(ind/MC,WaitBar_Assess,['Simulation ' num2str(ind) ' out of ' num2str(MC) ' completed']);
    end
    close(WaitBar_Assess);
    cdm_list = MC_cdm_list;
    cdm_rep_list = MC_cdm_rep_list;
    %event_detection = MC_event_detection;
    total_cost = MC_total_cost;
    decision_list = MC_decision_list;
    if nargout == 9
        operation_cost = MC_operation_cost;
    end
end