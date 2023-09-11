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
plot(no_objects_in_cat,'-o');
xline(Fengyun_index,'Color','r','Label','Fengyun');
xline(CosIrid33_index,'Color','r','Label','Cosmos-Iridium');
xticks(1:6:60);
xticklabels(cat_date(1:6:end));
