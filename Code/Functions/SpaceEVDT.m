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
%   conj_box = [1x3] The conjunction screening volume currently defined as a box in RSW directions [km km km]
%   moid_distance = [1x1] The minimum orbit intersection distance treshold, to find the relative 
%                         space objects from the space catalogue. [km]
%   accelerator = [1x1] This value is for the manipulating the miss distance of a conjunction at the time of 
%                       closest approach. the accelerator will decrease the miss distance with the relation of
%                       10^-(accelerator). (0 by default)
%   
% OUTPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   cdm_list = (Q objects) List of all CDMs generated in the chronological order [CDM]
%   event_detection = [13xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km]'
%   action_list = [5xL] A matrix containing all the actions taken by the Decision model [--,--,--,days,--]'
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%
% ASSUMPTIONS AND LIMITATIONS:
%   The current program uses a simple analytic propagator, considering only secular J2 effects.
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%

function [event_list,cdm_list,event_detection,action_list,total_cost] = SpaceEVDT (epoch, end_date , eos, space_cat, conj_box , moid_distance,accelerator)
%% Input check
if nargin<4
    error('Insufficient number of inputs.');
elseif nargin==4
    conj_box=[2,25,25];                   %[km,km,km] in order, RSW directions
    moid_distance=200;                    %[km]
    accelerator=0;
elseif nargin==5
    moid_distance=200;                    %[km]
    accelerator=0;
elseif nargin==6
    accelerator=0;
end

space_cat_ids=zeros(1,length(space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end

%% Pre-process
timestep=15;                              % [s]
space_cat = Space_catalogue_reset_epoch (space_cat,epoch); % all objects in the catalogue propagated to the same epoch
no_days=date2mjd2000(end_date)-date2mjd2000(epoch); % simulation time in days after epoch
%% Propagation and event detection
event_list=Conjunction_event;
for eos_sat=1:length(eos)
    event_list = Event_detection (eos(eos_sat),space_cat,no_days,timestep,conj_box,moid_distance,event_list,space_cat_ids);
end
%% Event list to matrix conversion
event_matrix = list2matrix (event_list);
disp('Event list converted to conjunction event matrix');
%% Saving 
%save('Data\Intermediate_9Jan.mat');

%% Loading
load('Data\Temp_modular_before_CARAPROCESS.mat');

%%
[cdm_list,event_detection,action_list,total_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,7,0);
