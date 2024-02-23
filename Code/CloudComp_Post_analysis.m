% SCRIPT NAME:
%   CloudComp_Post_analysis.m
%
% DESCRIPTION:
%   This script is for post process analysis of the meta data taken from Cloud_computing.m (Conjunctions in 2005,
%   2015, and 2023 for both NASA EOS satellites and Arbitsats) and data taken from Cloud_computing2.m (Monthly 
%   conjunctions for landsat7, terra, aqua between 2006 and 2010). It should be noted that the input files are 
%   large thus it is better to load them in each section only when needed. Many of the sections can run independantly
%   but some require the data from the previous sections in the script. 
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
%   "long_catalog.mat" file = [60x1 space catalog] A list Contains the space catalogs downloaded from the 
%                             first 5 days of each month from Jan 2006 to Dec 2010.  
%
%   "list_monthly_2006to2010.mat" file = A data file containing:
%       - list_monthly_events = [60x1 cell Conjunction_event] list of total number of conjunction events per month 
%                               for the combination of landsat 7, terra, and aqua
%
% OUTPUT:
%   Data visualization including:
%       - Number of conjunctions for each NASA EOS satellite in 2005, 2015, 2023
%       - Number of monthly conjunctions for Landsat7 and Terra between 2006 and end of 2010, with displaying
%         conjunctions related to FY-1, Iri_Cos debris
%       - Number of relevant space objects for Arbitsats at different altitudes and in different years (2005,2015,2023)
%         and also the contributions by specific space objects (FY-1 & Cos-Iri debris, and starlink)
%
%   Useful data:
%       - Conjunction events in years 2005,2015,2023 for landsat7, terra, aqua (landsat_events, terra_events, aqua_events)
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   20/2/2024 - Sina Es haghi
%       * added the description
%

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Functions\');
addpath('Time_conversion\');
addpath("Data\");

%% Load data
clc;
clear;
load("data\Full_event_list.mat"); % Simulation time of 365 days epoch of 2005 2015 2023

%% Details of the NASA EOS sats
% 25682 Landsat 7  
% 25994 Terra
% 27424 Aqua

%% Details of ArbSat
% epoch [2005 1 1 0 0 0]
% alt [550 , 800 , 1000]
% ecc 0
% inc [0, 45 , 90]
% ran 0
% aop 0
% M   0
% type PAYLOAD
% RCS MEDIUM
% value 10
% max_dim 2 [m]
% mass 100 [kg]
% cost 1000 [M$]

%% Configuration data
% conjunction_box = [2,25,25];                        % Conjunction box dimensions in RSW directions [km,km,km]
% moid_distance = 200;                                % MOID threshold for geometricallyfinding relevant objects [km]
% screening_volume_type = ellipsoid;                  
% time prefiltration not used!

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NASA EOS ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Number of conjunctions throughout the years for each nasa eos satellite (2005-2015-2023)
eos_events = {event_list_2005 event_list_2015 event_list_2023};

% Landsat 7
landsat_events = cell(3,1);
lengths_of_landsat7 = [0 0 0];

for k = 1:length(eos_events)
    temp_conj(length(event_list_2023)) = Conjunction_event;
    temp_event = eos_events{k};
    for i=1:length(temp_event)
        if temp_event(i).primary_id == 25682
            lengths_of_landsat7(k) = lengths_of_landsat7(k) + 1;
            temp_conj(lengths_of_landsat7(k)) = temp_event(i);
        end
    end
    temp_conj(lengths_of_landsat7(k)+1:end)=[];
    landsat_events{k}=temp_conj;
end

% Terra
terra_events = cell(3,1);
lengths_of_terra = [0 0 0];

for k = 1:length(eos_events)
    temp_conj(length(event_list_2023)) = Conjunction_event;
    temp_event = eos_events{k};
    for i=1:length(temp_event)
        if temp_event(i).primary_id == 25994
            lengths_of_terra(k) = lengths_of_terra(k) + 1;
            temp_conj(lengths_of_terra(k)) = temp_event(i);
        end
    end
    temp_conj(lengths_of_terra(k)+1:end)=[];
    terra_events{k}=temp_conj;
end

% Aqua
aqua_events = cell(3,1);
lengths_of_aqua = [0 0 0];

for k = 1:length(eos_events)
    temp_conj(length(event_list_2023)) = Conjunction_event;
    temp_event = eos_events{k};
    for i=1:length(temp_event)
        if temp_event(i).primary_id == 27424
            lengths_of_aqua(k) = lengths_of_aqua(k) + 1;
            temp_conj(lengths_of_aqua(k)) = temp_event(i);
        end
    end
    temp_conj(lengths_of_aqua(k)+1:end)=[];
    aqua_events{k}=temp_conj;
end

figure()
hold on
plot(lengths_of_landsat7);
plot(lengths_of_terra);
plot(lengths_of_aqua);
legend('Landsat7','TERRA','Aqua')
ylabel("Number of conjunctions in the year")
xticks([1,2,3])
grid on;
grid minor;
xticklabels(["2005","2015","2023"])

%% Conjunctions for Iri-Cos and Fy1 with the eos sats in 2015
temp_space_cat = space_cat_2015;
space_cat_ids=zeros(1,length(temp_space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
for j=1:length(temp_space_cat)
    space_cat_ids(j)=temp_space_cat(j).id;
end

cos_iri_2015_categorized = {landsat_events{2}, terra_events{2}, aqua_events{2}};

conjs_cos_iri_fy1_2015_categorized = cell(2,length(cos_iri_2015_categorized));

for l = 1:length(cos_iri_2015_categorized)
single_sat_events = cos_iri_2015_categorized{l};
temp_cos_iri(length(single_sat_events)) = Conjunction_event;
temp_cos_iri_ind = 0;
temp_fy1(length(single_sat_events)) = Conjunction_event;
temp_fy1_ind = 0;
for i = 1:length(single_sat_events)
    sec_ob_name = temp_space_cat(space_cat_ids==single_sat_events(i).secondary_id).name;
    if contains(sec_ob_name,'FENGYUN 1C DEB','IgnoreCase',true)
        temp_fy1_ind=temp_fy1_ind+1;
        temp_fy1(temp_fy1_ind) = single_sat_events(i);
    elseif contains(sec_ob_name,'COSMOS 2251 DEB','IgnoreCase',true) || contains(sec_ob_name,'IRIDIUM 33 DEB','IgnoreCase',true)
        temp_cos_iri_ind=temp_cos_iri_ind+1;
        temp_cos_iri(temp_cos_iri_ind) = single_sat_events(i);
    end
end
temp_fy1(temp_fy1_ind+1:end) = [];
temp_cos_iri(temp_cos_iri_ind+1:end) = [];
conjs_cos_iri_fy1_2015_categorized{1,l}=temp_cos_iri;
conjs_cos_iri_fy1_2015_categorized{2,l}=temp_fy1;
end
% conjs_cos_iri_fy1_2015_categorized, first row represents the conj events with iri-cos and second row represents events with FY1
% each column is in order for landsat7, terra, aqua

%% Cos-Iri Conjunction event analysis on 2015 space catalog for NASA EOS
% the previous section must be run
%events2015_categorized = {landsat_events{2}, terra_events{2}, aqua_events{2}}; % ALL CONJUNCTIONS, not just cosmos-iri
events2015_categorized = {conjs_cos_iri_fy1_2015_categorized{1,1},conjs_cos_iri_fy1_2015_categorized{1,2},conjs_cos_iri_fy1_2015_categorized{1,3}}; % analyzing conjunctions only with cos_iri

MC = 10;
dec_func = @Decision_model_Simple_commercial_noDrop; %% USING THE COMMERCIAL SSA DATA
Analysis_matrix = zeros(5,length(eos));
for i = 1:length(eos)
    [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average, cdm_list,cdm_rep_list,operation_cost] = multi_assessment(events2015_categorized{i},MC,space_cat_2015,eos,[2015 1 1 0 0 0],365,dec_func);
    Analysis_matrix(:,i)=[no_cdms_average events_red_average events_yellow_average dropped_event_average operation_cost_average]';
end

%% FY-1 Conjunction event analysis on 2015 space catalog for NASA EOS
% the previous section must be run
%events2015_categorized = {landsat_events{2}, terra_events{2}, aqua_events{2}}; % ALL CONJUNCTIONS, not just cosmos-iri
events2015_categorized2 = {conjs_cos_iri_fy1_2015_categorized{2,1},conjs_cos_iri_fy1_2015_categorized{2,2},conjs_cos_iri_fy1_2015_categorized{2,3}}; % analyzing conjunctions only with cos_iri

MC = 10;
dec_func = @Decision_model_Simple_commercial_noDrop; %% USING THE COMMERCIAL SSA DATA
Analysis_matrix2 = zeros(5,length(eos));
for i = 1:length(eos)
    [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average, cdm_list,cdm_rep_list,operation_cost] = multi_assessment(events2015_categorized2{i},MC,space_cat_2015,eos,[2015 1 1 0 0 0],365,dec_func);
    Analysis_matrix2(:,i)=[no_cdms_average events_red_average events_yellow_average dropped_event_average operation_cost_average]';
end

%% Plotting conjunction categories for eos sats in 2015
average_no_green_events = [length(events2015_categorized{1})-(Analysis_matrix(2,1)+Analysis_matrix(3,1)) length(events2015_categorized{2})-(Analysis_matrix(2,2)+Analysis_matrix(3,2)) length(events2015_categorized{3})-(Analysis_matrix(2,3)+Analysis_matrix(3,3))];
average_no_green_events2 = [length(events2015_categorized2{1})-(Analysis_matrix2(2,1)+Analysis_matrix2(3,1)) length(events2015_categorized2{2})-(Analysis_matrix2(2,2)+Analysis_matrix2(3,2)) length(events2015_categorized2{3})-(Analysis_matrix2(2,3)+Analysis_matrix2(3,3))];
figure()
hold on
% bar(1:3,average_no_green_events,'g');
% bar(1:3,Analysis_matrix(3,:),'y');
% bar(1:3,Analysis_matrix(2,:),'r');
bar(1:3,average_no_green_events+Analysis_matrix(3,:)+Analysis_matrix(2,:),'g');
bar(1:3,Analysis_matrix(3,:)+Analysis_matrix(2,:),'y');
bar(1:3,Analysis_matrix(2,:),'r');
bar(4:6,average_no_green_events2+Analysis_matrix2(3,:)+Analysis_matrix2(2,:),'g');
bar(4:6,Analysis_matrix2(3,:)+Analysis_matrix2(2,:),'y');
bar(4:6,Analysis_matrix2(2,:),'r');
xline(3.5,'--');
%xticks([1,2,3]);
%xticklabels(["Landsat7 (25682)","Terra (25994)","Aqua (27424)"])
xticks(1:6);
xticklabels(["Landsat7 (25682)","Terra (25994)","Aqua (27424)","Landsat7 (25682)","Terra (25994)","Aqua (27424)"])
grid on

%% Manipulation of event_lists to remove data from Aqua later (2006-2010) Monthly events

load("data\list_monthly_2006to2010.mat");

landsat7_events_monthly = zeros(60,1);
Terra_events_monthly = zeros(60,1);
Aqua_events_monthly = zeros(60,1);
no_aqua_event_list = cell(60,1);

for il = 1:60
    temp_conj_event_list = list_monthly_events{il};
    s1 =0;
    s2 =0;
    s3 =0;
    for kl = length(temp_conj_event_list):-1:1
        primary_id = temp_conj_event_list(kl).primary_id;
        if primary_id==25682
            s1 = s1+1;
        elseif primary_id==25994
            s2 = s2+1;
        elseif primary_id==27424
            s3 = s3+1;
            temp_conj_event_list(kl)=[];
        end
    end
    no_aqua_event_list{il} = temp_conj_event_list;
    landsat7_events_monthly(il)=s1;
    Terra_events_monthly(il)=s2;
    Aqua_events_monthly(il)=s3;
end

figure
hold on
plot(landsat7_events_monthly);
plot(Terra_events_monthly);
plot(Aqua_events_monthly);
ylabel('Number of monthly conjunctions')
legend('Landsat7','TERRA','Aqua')

%% Removing Aqua's data (2006-2010) Monthly events
% some irregularities observed
list_monthly_events = no_aqua_event_list;

%% No. Conjunctions throughout the years with FY-1C and IRID-COS (2006-2010) Monthly events
load("data\long_catalog.mat")
no_conjs = zeros(1,length(list_monthly_events));
for k = 1:length(list_monthly_events)
    no_conjs(k) = length(list_monthly_events{k});
end

fy1c = zeros(1,length(list_monthly_events));
ir_cos = zeros(1,length(list_monthly_events));
for k = 1:length(list_monthly_events)
    temp_conj_event_list = list_monthly_events{k};
    temp_space_cat = space_catalog_list{k};
    space_cat_ids=zeros(1,length(temp_space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
    for j=1:length(temp_space_cat)
        space_cat_ids(j)=temp_space_cat(j).id;
    end
    temp_sum1 = 0;
    temp_sum2 = 0;
    for l = 1:length(temp_conj_event_list)
        sec_ob_name = temp_space_cat(space_cat_ids==temp_conj_event_list(l).secondary_id).name;
        if contains(sec_ob_name,'FENGYUN 1C DEB','IgnoreCase',true)
            temp_sum1=temp_sum1+1;
        elseif contains(sec_ob_name,'COSMOS 2251 DEB','IgnoreCase',true) || contains(sec_ob_name,'IRIDIUM 33 DEB','IgnoreCase',true)
            temp_sum2=temp_sum2+1;
        end
    end
    fy1c(k) = temp_sum1;
    ir_cos(k) = temp_sum2;
end

total_catastrophe = fy1c+ir_cos;
%% Plotting the space catalog variation between 2006 and 2010 (2006-2010) & Monthly events
%load("Data\long_catalog.mat");
no_objects_in_cat = zeros(length(space_catalog_list),1);
cat_date = cell(length(space_catalog_list),1);
temp_date = mjd20002date(space_catalog_list{1}(1).epoch);
year_month = [temp_date(1) temp_date(2)];

for i=1:length(no_objects_in_cat)
    cat_date{i}=[num2str(year_month(1)) '-' num2str(year_month(2))];

    if year_month(1)==2007 && year_month(2)==1
        Fengyun_index = i;
    elseif year_month(1)==2009 && year_month(2)==2
        CosIrid33_index = i;
    end

    no_objects_in_cat(i) = length(space_catalog_list{i});
    year_month(2) = year_month(2)+1;
    if year_month(2)>12
        year_month(2) = 1;
        year_month(1) = year_month(1)+1;
    end
end

figure()
hold on;
yyaxis right;
b_tot = bar(1:60,no_conjs);
b_tot.FaceColor = [0 0.4470 0.7410];
b_tot.FaceAlpha = 0.6;
b_tot.EdgeColor = "none";
%b_catas = bar(1:60,total_catastrophe);
b_fy = bar(1:60,fy1c);
b_fy.FaceColor = [0.8500 0.3250 0.0980];
b_fy.FaceAlpha = 0.6;
b_fy.EdgeColor = "none";
b_ircos = bar(1:60,ir_cos);
b_ircos.FaceColor = [0.4660 0.6740 0.1880];
b_ircos.FaceAlpha = 0.6;
b_ircos.EdgeColor = "none";
ylabel('Number of conjunctions');

yyaxis left;
plot(no_objects_in_cat,'-','color','k','LineWidth',1.1);
ax = gca; % axes handle
ax.YAxis(1).Exponent = 0;
ax.YAxis(2).Exponent = 0;
ax.YAxis(1).Color = [0 0 0];
ax.YAxis(2).Color = [0 0.4470 0.7410];
ylabel('Number of tracked space objects');

xline(Fengyun_index,'Color','r','Label','FY-1C destruction','FontWeight','bold');
xline(CosIrid33_index,'Color','r','Label','Cos2251-Iri33 collision','FontWeight','bold');
xticks(1:6:60);
xticklabels(cat_date(1:6:end));
xlabel('Date');

legend([b_tot b_fy b_ircos],{'All conjunctions' 'FY-1C debris conjunctions' 'Cos2251-Iri33 debris conjunctions'});

ylabel('Number of tracked space objects');
set(gca,'fontname','Arial')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ArbitSat ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To plot the ArbitSat MOID 2005-2015-2023
%load("data\Full_event_list.mat"); % Simulation time of 365 days epoch of 2005 2015 2023


colors = {"#77AC30","#0072BD","#D95319"};
xlabels = cell(1,9);
f=0;
alts = [550 800 1000];
incs = [0 45 90];
for i=1:3
    for j=1:3
        f=f+1;
        %xlabels{f}=['Alt=' num2str(alts(i)) ' , Inc=' num2str(incs(j))];
        xlabels{f}=[num2str(incs(j))];
    end
end

figure()
hold on;
for i=1:3
    ar(i) = area([0.5 0.5 3.5 3.5]+3*(i-1)*[1 1 1 1],[-10 10000 10000 -10]);
    %ar(i).EdgeColor="none";
    ar(i).LineStyle="--";
    ar(i).FaceAlpha=0.2;
    ar(i).FaceColor=colors{i};
end

t1 = text(0.6,6500,'Altitude: 550 [km]');
t1.FontWeight="bold";

t2 = text(3.6,6500,'Altitude: 800 [km]');
t2.FontWeight="bold";

t3 = text(6.6,6500,'Altitude: 1000 [km]');
t3.FontWeight="bold";


f=0;
for i = 3:-1:1 % From 2023 to 2005
    for j = 1:9
        f=f+1;
        b(f)=bar(j,length(MOID_list_arbsats{j,i}));
        b(f).EdgeColor="none";
        b(f).FaceColor=colors{i};
    end
end
grid on;
legend([b(19) b(10) b(1)],{'2005' '2015' '2023'})
xticks(1:9)
xlim([0.5 9.5]);
ylim([0 7000])
ylabel('No. close relevant space objects')
xlabel('Inclination [deg]')
xticklabels(xlabels)
set(gca,'fontname','Arial');

%% MOID for ArbitSat but 3D (2005-2015-2023)
%load("data\Full_event_list.mat"); % Simulation time of 365 days epoch of 2005 2015 2023


colors = {"#77AC30","#0072BD","#D95319"};

for i = 1:3
    for j=1:9
        MOID_lengths(j,i) = length(MOID_list_arbsats{j,i});
    end
end

for i = 1:3
    for j = 1:3
        MOID_lengths_incAv(j,i) = ceil(mean(MOID_lengths(3*j-2:3*j,i)));
    end
end

figure()
hold on;

b = bar3(MOID_lengths_incAv);
grid on;
grid minor;
box on;
view(3);
xticks([1 2 3]);
xticklabels([2005 2015 2023]);
yticks([1 2 3]);
yticklabels([550 800 1000]);
ylabel('Altitude [km]');
xlabel('Space catalog');
zlabel('No. of relevant space objects');
set(gca,'fontname','Arial');
%% Calculating number of MOID pieces with arbitsat related to FY-1, COSMOS, Iridium and starlink and oneweb 
fy1_moid = zeros(9,3);
cos_moid = zeros(9,3);
iri_moid = zeros(9,3);
slk_moid = zeros(9,3);
onw_moid = zeros(9,3);
for i = 1:3
    for j = 1:9
        for p = 1:length(MOID_list_arbsats{j,i})
            temp_obj_name = MOID_list_arbsats{j,i}(p).name;
            if contains(temp_obj_name,'FENGYUN 1C DEB','IgnoreCase',true)
                fy1_moid(j,i) = fy1_moid(j,i)+1;
            elseif contains(temp_obj_name,'COSMOS 2251 DEB','IgnoreCase',true)
                cos_moid(j,i) = cos_moid(j,i)+1;
            elseif contains(temp_obj_name,'IRIDIUM 33 DEB','IgnoreCase',true)
                iri_moid(j,i)=iri_moid(j,i)+1;
            elseif contains(temp_obj_name,'STARLINK','IgnoreCase',true)
                slk_moid(j,i)=slk_moid(j,i)+1;
            elseif contains(temp_obj_name,'ONEWEB','IgnoreCase',true)
                onw_moid(j,i)=onw_moid(j,i)+1;
            end
        end
    end
end
fy1_moid = moid_averager(fy1_moid);
cos_moid = moid_averager(cos_moid);
iri_moid = moid_averager(iri_moid);
slk_moid = moid_averager(slk_moid);
onw_moid = moid_averager(onw_moid);  % Oneweb doesnt affect arbitsat much due to its orbit

% 3D matrix creation

mix_2007_9 = fy1_moid+cos_moid+iri_moid;
mix_const = slk_moid+onw_moid;

moid_wo_events = MOID_lengths_incAv - mix_2007_9 -mix_const;
MIX_total = cat(3,moid_wo_events,mix_2007_9,mix_const);

for i=1:3
    for j=1:3
        for k=1:3
            if MIX_total(i,j,k)==0
                MIX_total(i,j,k)=NaN;
            end
        end
    end
end


%figure()
hold on;

bar3_stacked(MIX_total);
grid on;
grid minor;
box on;
view(3);
yticks([1 2 3]);
yticklabels([2005 2015 2023]);
xticks([2 3 4]);
xticklabels([1000 800 550]);
xlabel('Altitude [km]');
ylabel('Space catalog');
zlabel('No. of relevant space objects');
set(gca,'fontname','Arial');

%% Function that averages the MOID between different arbitsat inclinations
function temp = moid_averager (A)
temp = zeros(3,3);
    for i=1:3
        temp(i,:) = ceil(mean(A(3*i-2:3*i,:)));
    end
end