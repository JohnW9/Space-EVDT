%% Main
% New header will be added here
clc;
clear;

addpath('Functions/');
addpath('Functions/NASA/');
addpath('Time_conversion/');
addpath("Data/");
addpath('Functions/real_CDM/');

CDM_mode = 1; % 1 for reading CDMs, 0 for reading TLEs
data_reading_mode = 1; 
if CDM_mode == 1
    data_2015 = load("OCMDB_20150101_to_20151231.mat");
    data_2023 = load("OCMDB_20230101_to_20230630.mat");
    list1 = read_real_CDM(data_2015.DB);
    list2 = read_real_CDM(data_2023.DB);

    red_Pc_list = [1e-6,2.5e-6,5e-6,7.5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4,4.4e-4,5e-4,7.5e-4,1e-3];
    tom_list = [12*3600,24*3600,36*3600,48*3600,60*3600]; %time of maneuver before TCA
    nb_of_maneuver_list = []; % list of nb of maneuvers for different time of maneuver
    nb_of_maneuver_list_total = {}; % list of lists of nb of maneuvers for different threshold Pc
    sat_ids = [25682,25994,27424,43613]; % in order LANDSAT 7, TERRA, AQUA, ICESAT-2
    sat_maneuvers = zeros(1,4);
    sat_maneuver_dict = dictionary(sat_ids,sat_maneuvers);
    
if data_reading_mode == 1 % plotting nb of maneuvers vs time of maneuver for different Pc thresholds
    for red_Pc = red_Pc_list
        for time_of_maneuver = tom_list
            [real_CDM_list, nb_of_maneuver,sat_maneuver_dict] = Decision_model_v2_CDM(list1,red_Pc,time_of_maneuver,sat_maneuver_dict);
            disp("for threshold Pc " + string(red_Pc) + " and t of maneuver (before TCA) of " + string(time_of_maneuver/3600) +" h, we have " + string(nb_of_maneuver) + " maneuvers");
            disp(sat_maneuver_dict);
            sat_maneuver_dict(sat_ids) = 0;
            nb_of_maneuver_list(end+1) = nb_of_maneuver;
        end
        nb_of_maneuver_list_total{end+1} = nb_of_maneuver_list;
        nb_of_maneuver_list = [];
    end

    plot_tom_Pc_tradespace(nb_of_maneuver_list_total,tom_list,red_Pc_list);

else % plotting each relevant conjunction
    plot_conjunction_list(list1);
end

else

    %% User inputs
    tic
    epoch = [2023 3 15 0 0 0];
    end_date= [2023 3 20 0 0 0];           % Simulation end date and time in gregorian calender
    %epoch = [2015 1 1 0 0 0]; end_date = [2015 7 1 0 0 0];
    %epoch = [2005 1 1 0 0 0]; end_date = [2005 7 1 0 0 0];
    accelerator=0;                          % details to be added
    config = GetConfig;
    total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;

    %% NASA satellites
    eos = Read_NASA_satellites;
    eos(2:3)=[];
    %eos = eos(1);
    disp('NASA satellites loaded')

    %% Space catalogue
    fileID=fopen("Credentials.txt");
    if fileID == -1; error('Credentials.txt file, containing the space-track username and password, is missing');end
    fclose(fileID);
    space_cat = Read_Space_catalogue(0); % Local SC downloaded at 11:12 AM (EST) March 6th 2023
    %space_cat = Read_Space_catalogue(2,'2015-01-01','2015-01-05'); % Use in case space catalog from a specific period is needed
    %space_cat = Read_Space_catalogue(2,'2005-01-01','2005-01-05');
    %% Adding Arbitrary Satellites
    
    SinaSat1 = {'SinaSat1',[2,2],100,1000,date2mjd2000([2023 1 1 0 0 0]),[550+6378.14,0,deg2rad(0),deg2rad(100),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
    %SinaSat1 = {'SinaSat1',[2,2],100,1000,date2mjd2000([2015 1 1 0 0 0]),[550+6378.14,0,deg2rad(45),deg2rad(100),deg2rad(200),0],'PAYLOAD','MEDIUM',10};
    %SinaSat1 = {'SinaSat1',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[550+6378.14,0,deg2rad(45),deg2rad(100),deg2rad(200),0],'PAYLOAD','MEDIUM',10};
    [sina1_nasa_sat,sina1_space_object]=create_sat(SinaSat1);
    %[eos,space_cat] = addSat (sina1_nasa_sat,sina1_space_object,space_cat); % Delete the ",eos)" in input if only arbitrary satellites are to be analyzed
    
    
    %% Additional info
    if config.TPF == 1
        disp("Time prefilter method selected; Using parallel pool")
        try
            parpool;
        catch
            disp("Parallel pool already running")
        end
    elseif config.TPF == 0
        %delete(gcp('nocreate'));
    end
    %% Main program run
    %[cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list,MOID_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
    [cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list,MOID_list,operation_cost] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator,2);
    runtime=toc;
    %% After a long run
    %save("Data\Final_6March.mat");
    %% Load instead of the full run
    %load("Data\Final_6March.mat");
    
    %% Plotting
    %disp('Plotting...');
    FinalPlot (epoch, end_date,cdm_rep_list{1},20,12)
    %% For the long run
    %system('shutdown -s');
    %% Post processing 
    
    % Finding Starlink MOID sats
    
    starlink = 0;
    ariane = 0;
    
    list = MOID_list{1};
    for o = 1:length(list)
        if contains(list(o).name,'starlink','IgnoreCase',true)
            starlink=starlink+1;
        elseif contains(list(o).name,'ariane','IgnoreCase',true)
            ariane = ariane+1;
        end
    end
    
    
    %{
    figure()
    cdm_values = zeros(1,length(cdm_list));
    for i=1:length(cdm_list)
        cdm_values(i)=cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC/config.CC_normalizer;
    end
    ind = 1:length(cdm_values);
    scatter(ind,cdm_values);
    %% Post processing (Collision number of pieces)
    figure()
    cdm_collisions = zeros(1,length(cdm_list));
    for i=1:length(cdm_list)
        cdm_collisions(i)=cdm_list(i).CC;
    end
    ind = 1:length(cdm_collisions);
    scatter(ind,cdm_collisions);
    %}
end