%% Analyzing the Meta Data of the Cloud Computer

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Functions\');
addpath('Time_conversion\');
addpath("Data\");

%% Load data
clc;
clear;
load("Full_event_list.mat"); % Simulation time of 365 days epoch of 2005 2015 2023

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NASA EOS ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Number of conjunctions throughout the years for each satellite
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
%% Manipulation of event_lists
%MAIN_LIST_MONTHLY_EVENTS = list_monthly_events;

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
legend('Landsat7','TERRA','Aqua')

%% 

%list_monthly_events=MAIN_LIST_MONTHLY_EVENTS;
list_monthly_events = no_aqua_event_list;

%% No. Conjunctions throughout the years
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
%% Plotting the space catalog variation between 2006 and 2010

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
