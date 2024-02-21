% SCRIPT NAME:
%   Post_analysis_MC.m
%
% DESCRIPTION:
%   This script is for post process analysis of the meta data taken from Cloud_computing.m (Conjunctions in 2005,
%   2015, and 2023 for both NASA EOS satellites and Arbitsats). It analyzes the conjunction data for the arbitrary 
%   satellites. Conjunctions for each arbitsat in a specific space catalog year are obtained.
%   Multiple assessment process loops can be carried out using custom decision component functions.
%   The operational cost is also evaluated in these monte carlo simulations and can be used to compare the 
%   different decision components and different SSA sources. The long term monte carlo simulations are very
%   time consuming
%
% INPUT:
%   "Full_event_list.mat" file = A meta data file containing:
%       - space_cat_years = [1x3 cell space catalog] space catalogs of 2005, 2015, 2023 with added 9 arbitrary
%                           satellites to the end of each space catalog
%       - Arb_sats_list = [1x9 NASA_sat] list of all the arbitrary satellites
%       - eos = [1x3 NASA_sat] list of nasa eos satellites considered wich are Landsat7 , Terra, Aqua in order.
%       - event_list_20xx = [N Conjunction_event] list of conjunction events for all 3 nasa eos satellites in the year 20xx.
%                           !!(Note that the space catalog used is only from the first 5 days of 20xx)!!
%       - event_list_arbsats = [3x1 cell] each cell contains all the conjucntions of all arbitsats 
%                              in the years 2005,2015,2023 in order 
%                              !!(Note that the space catalog used is only from the first 5 days of 20xx)!!
%       - MOID_list_20xx = [3x1 cell] list of relevant space objects for nasa eos satellites landsat 7, terra,
%                          and Aqua, in order, in the year 20xx.
%       - MOID_list_arbsats = [9x3 cell] list of relevant space objects for arbitrary satellites. Each row represents
%                             a specific arbitsat and each column represents a year (2005,2015,2023) in order)
%
%
% OUTPUT:
%   "Post_analysis_MC_output.mat" file = containing the workspace after a single run. It can be used instead of
%                                        running the simulations
%   Data visualization including:
%       - Conjunction event types for ArbitSats in different orbits using different SSAs 
%
%   Useful data:
%       - Conjunction events in 2023 for Arbitsats in different altitudes
%       - Comparison of operational cost when using gov or com ssa.
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   20/2/2024 - Sina Es haghi
%       * added the description
%   21/2/2024 - Sina Es haghi
%       * Fixed the issue in plotting different category events for arbitsat (yellow events now contain red events)

%% Assessment Process Post Analysis on Full data

clc;
clear;

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Functions\');
addpath('Time_conversion\');
addpath("Data\");

%% Load the data
load("data\Full_event_list.mat"); % Simulation time of 365 days epoch of 2005 2015 2023

% Remember that the values of the satellites needs to be changed in the next section

%% ArbitSat Norad IDs and conjunctions for a single space catalog
temp_cat = space_cat_years{3}; % this will be the 2023 space catalog
temp_event = event_list_arbsats{3};
Arbitsat_ids = zeros(9,1);
for i=1:9
    Arbitsat_ids(i)=temp_cat(end-9+i).id;
end

conjs = cell(9,1);
for i=1:9
    list(length(temp_event)) = Conjunction_event;
    m = 0;
    for j = 1:length(temp_event)
        if temp_event(j).primary_id == Arbitsat_ids(i)
            m=m+1;
            list(m) = temp_event(j);
        end
    end
    list(m+1:end)=[];
    conjs{i}=list;
end
% conjs will be a 9x1 cell where each cell is the total number of conjunctions for that specific arbit sat at the already defined space catalog year (here it is 2023)

%% Checking number of conjunctions with starlink for all arbitrary satellites in the conjunctions with 2023 space catalog
%{
temp_catalog = space_cat_2023; % must be same catalog year as the conjs
starlink=zeros(9,1);
starlink_ids = zeros(length(temp_catalog),1);
gl = 0;

%finding starlink norad ids
for m =1:length(temp_catalog)
    if contains(temp_catalog(m).name,'starlink','IgnoreCase',true)
        gl=gl+1;
        starlink_ids(gl)=temp_catalog(m).id;
    end
end
starlink_ids(gl+1:end)=[];

for p=1:length(starlink)
    for r = 1:length(conjs{p})
        if ismember(conjs{p}(r).secondary_id,starlink_ids)
            starlink(p)=starlink(p)+1;
        end
    end
end

% Calculating the percentage of conjunctions in 550 km with star link
starlink_percent = sum(starlink(1:3))/sum([length(conjs{1}) length(conjs{2}) length(conjs{3})]);
%}
%% Checking number of Starlink relevant space objects with arbitsat at 550km + plotting the altitude ranges of the starlink sats
%{
starlink_moids = zeros(3,1);
for p =1:length(starlink_moids)
    for r = 1:length(MOID_list_arbsats{p,3})
        if ismember(MOID_list_arbsats{p,3}(r).id,starlink_ids)
            starlink_moids(p)=starlink_moids(p)+1;
        end
    end
end

% Finding how many starlink satellites actually have an altitude of 550+-2 km (Turnsout not many!!)
starlink_550 = 0;
alt_tol = 2;
mean_alts = [0];
for f = 1:length(space_cat_2023)
    if ismember(space_cat_2023(f).id,starlink_ids)
        sp_obj = space_cat_2023(f);
        alt = sp_obj.a - 6378.14;
        mean_alts(end+1)=alt;
        if abs(alt*(1+sp_obj.e))>=(550-alt_tol) %abs(alt-550)<=alt_tol
            starlink_550 = starlink_550+1;
        end
    end
end
mean_alts(1)=[];
figure()
scatter(1:length(mean_alts),mean_alts)
%}
%% Assessment process looped over default decision component
%{
mc = 10;
Analysis_matrix = zeros(5,length(Arbitsat_ids));
for i = 1:length(Arbitsat_ids)
    [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average] = multi_assessment(conjs{i},mc,temp_cat,Arb_sats_list,[2023 1 1 0 0 0],365);
    Analysis_matrix(:,i)=[no_cdms_average events_red_average events_yellow_average dropped_event_average operation_cost_average]';
end
%}

%% Monte carlo Assessment process loops run using different decision models
dec_func1 = @Decision_model_Simple_gov_noDrop;
dec_func2 = @Decision_model_Simple_commercial_noDrop;

mc = 10;

Analysis_matrix_gov = zeros(5,length(Arbitsat_ids));
for i = 1:length(Arbitsat_ids)
    [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average] = multi_assessment(conjs{i},mc,temp_cat,Arb_sats_list,[2023 1 1 0 0 0],365,dec_func1);
    Analysis_matrix_gov(:,i)=[no_cdms_average events_red_average events_yellow_average dropped_event_average operation_cost_average]';
end

Analysis_matrix_com = zeros(5,length(Arbitsat_ids));
for i = 1:length(Arbitsat_ids)
    [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average] = multi_assessment(conjs{i},mc,temp_cat,Arb_sats_list,[2023 1 1 0 0 0],365,dec_func2);
    Analysis_matrix_com(:,i)=[no_cdms_average events_red_average events_yellow_average dropped_event_average operation_cost_average]'; % Remember to add 2500*12 USD to operational cost
end

%% Graphing the different category conjunctions in different altitudes and inclinations arbitsats using either the government or commercial averaged assessment loops
% Uncomment which data to use
Analysis_matrix = Analysis_matrix_com;
%Analysis_matrix = Analysis_matrix_gov;
conj_details = zeros(3,9);
for i = 1:9
    conj_details(:,i) = [length(conjs{i}),Analysis_matrix(3,i)+Analysis_matrix(2,i),Analysis_matrix(2,i)]'; %% Very important
    % The green events contain the red and yellow events and the yellow event also contains the red events, just like nasa cara handbook
end

figure()
hold on;

alts = [550 800 1000];
incs = [0 45 90];
colors = ["#77AC30","#0072BD","#D95319"];
xlabels = cell(1,9);
f=0;
for i=1:3
    for j=1:3
        f=f+1;
        %xlabels{f}=['Alt=' num2str(alts(i)) ' , Inc=' num2str(incs(j))];
        xlabels{f}=[num2str(incs(j))];
    end
end

for i=1:3
    ar(i) = area([0.5 0.5 3.5 3.5]+3*(i-1)*[1 1 1 1],[1e-2 1e5 1e5 1e-2]);
    %ar(i).EdgeColor="none";
    ar(i).LineStyle="--";
    ar(i).FaceAlpha=0.2;
    ar(i).FaceColor=colors{i};
end

t1 = text(0.6,1500,'Altitude: 550 [km]');
t1.FontWeight="bold";

t2 = text(3.6,1500,'Altitude: 800 [km]');
t2.FontWeight="bold";

t3 = text(6.6,1500,'Altitude: 1000 [km]');
t3.FontWeight="bold";

b1 = bar(1:9,conj_details(1,:),'g');
b2 = bar(1:9,conj_details(2,:),'y');
b3 = bar(1:9,conj_details(3,:),'r');

%b1.FaceColor = [0.4660 0.6740 0.1880];
%b2.FaceColor = [0.9290 0.6940 0.1250];
%b3.FaceColor = [0.6350 0.0780 0.1840];

xticks(1:9)
xlim([0.5 9.5]);
ylabel('No. conjunction events')
xlabel('Inclination [deg]')
xticklabels(xlabels)
legend([b1 b2 b3],["Green event", "Yellow event", "Red event"]);
set(gca,'fontname','Arial');
set(gca, 'YScale', 'log');
grid on;
grid minor;
ylim([1e-1 1e4]);


%% Saving the workspace
save("data\Post_analysis_MC_output.mat")

%% Function to do the entire assessment process in monte carlo way and by using a custom decision component and providing results in averaged way
%{
function [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average, cdm_list,cdm_rep_list,operation_cost] = multi_assessment(event_list,MC,space_cat,sats,epoch,no_days,func)
end_date = mjd20002date(date2mjd2000(epoch)+no_days);
config = GetConfig;

space_cat_ids=zeros(1,length(space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end

event_matrix = list2matrix (event_list);
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
    if nargin<7
        [cdm_list,event_detection,total_cost,decision_list,operational_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,sats,0,cdm_list,decision_list,event_detection,total_cost,inf);
    else
        [cdm_list,event_detection,total_cost,decision_list,operational_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,sats,0,cdm_list,decision_list,event_detection,total_cost,inf,func);
    end
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
operation_cost = MC_operation_cost;


operation_cost_average = 0;
no_cdms_average = 0; 
events_red_average = 0;
events_yellow_average = 0;
dropped_event_average = 0;



for i = 1:length(MC_cdm_list)
    %
    operation_cost_average = operation_cost_average+MC_operation_cost{i};
    no_cdms_average = no_cdms_average + length(MC_cdm_list{i});
    %
    temp_red = 0;
    temp_yellow = 0;
    temp_rep_list = MC_cdm_rep_list{i};
    for j = 1:size(temp_rep_list,2)
        if temp_rep_list{2,j} >= config.red_event_Pc
            temp_red = temp_red+1;
        elseif temp_rep_list{2,j} >= config.yellow_event_Pc
            temp_yellow = temp_yellow+1;
        end
    end
    events_red_average = events_red_average+temp_red;
    events_yellow_average = events_yellow_average+temp_yellow;
    %
    temp_drop = 0;
    temp_decision_list = MC_decision_list{i};
    for k =1:length(temp_decision_list)
        try
            if temp_decision_list(k).action == 2
                temp_drop = temp_drop+1;
            end
        catch
            break
        end
    end

    dropped_event_average = dropped_event_average+temp_drop;
       

end

operation_cost_average = operation_cost_average/length(MC_cdm_list);
no_cdms_average = no_cdms_average/length(MC_cdm_list);
events_red_average = events_red_average/length(MC_cdm_list);
events_yellow_average = events_yellow_average/length(MC_cdm_list);
dropped_event_average = dropped_event_average/length(MC_cdm_list);



end
%}

