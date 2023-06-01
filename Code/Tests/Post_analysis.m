%% Some post analysis section functions, used to analyze the program outputs (work in progress)
%
%
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
%load("Data\Intermediate_28March_WithCommercialSSA_afterRepList.mat");

%% Number of conjunctions per each satellite

id_aqua = eos(3).id;
id_landsat7 = eos(1).id;
id_terra = eos(2).id;

i_aqua=0;
i_landsat7=0;
i_terra=0;
i_both=0;

for i=1:length(event_list)
    if event_list(i).primary_id == id_aqua; i_aqua=i_aqua+1;end
    if event_list(i).primary_id == id_landsat7; i_landsat7=i_landsat7+1;end
    if event_list(i).primary_id == id_terra; i_terra=i_terra+1;end
    if event_list(i).secondary_id == id_aqua || event_list(i).secondary_id == id_landsat7 || event_list(i).secondary_id == id_terra;i_both=i_both+1;end
end

%% Type of secondary ASO in conjunction
i_sat_sat=0;
i_sat_debris=0;
i_sat_rocket=0;

i_large=0;
i_medium=0;
i_small=0;
for i=1:length(event_list)
    m=find(space_cat_ids==event_list(i).secondary_id);
    if strcmp(space_cat(m).type,'PAYLOAD')
        i_sat_sat=i_sat_sat+1;
    elseif strcmp(space_cat(m).type,'DEBRIS')
        i_sat_debris=i_sat_debris+1;
    else
        i_sat_rocket=i_sat_rocket+1;
    end
    if strcmp(space_cat(m).RCS,'LARGE')
        i_large=i_large+1;
    elseif strcmp(space_cat(m).RCS,'MEDIUM')
        i_medium=i_medium+1;
    else
        i_small=i_small+1;
    end
end

%% Max Pc
max_Pc=cell2mat(cdm_rep_list(2,1:end));
num_cdms = cell2mat(cdm_rep_list(4,1:end));

set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
%yyaxis left
scatter(1:1983,max_Pc);
set(gca, 'YScale', 'log');
ylim([1e-10 1e-2]);
ylabel('Maximum $P_C$ of the event [-]');

%yyaxis right
%plot(num_cdms);

grid on;
grid minor;

xlabel("Conjunction event's number");

figure_dimensions = [0 0 10 10]; 
filename = "Data\" + "max_pc"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500')
%% Event category
max_Pc=cell2mat(cdm_rep_list(2,1:end));
index_yellow=0;
index_red=0;
for l = 1:length(max_Pc)
    if max_Pc(l)>1e-7
        index_yellow = index_yellow+1;
    end
    if max_Pc(l)>1e-4
        index_red=index_red+1;
    end
end
index_green=length(max_Pc);

figure()
hold on
bar(1,index_green/3,'FaceColor',"green");
bar(1,index_yellow/3,'FaceColor',"yellow");
bar(1,index_red/3,'FaceColor',"red");
ylim([1e-2 1e3]);
xticks(1);
xticklabels('13.2')
xlabel('Hard Body Radius [m]');
ylabel('Events per Payload per Year');
set(gca, 'YScale', 'log');
grid on;
grid minor;
figure_dimensions = [0 0 4 10]; 
filename = "Data\" + "event_categories"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500')
%% HIE list
HIE_list=0;
HIE_rep_list=cell(31,171);
k=0;
for j=1:1983
    if cdm_rep_list{2,j}>1e-4
        k=k+1;
        HIE_list(k)=j;
        HIE_rep_list(:,k)=cdm_rep_list(:,j);
    end
end
%% Single HIE
date2=mjd20002date(8507);
date1=mjd20002date(8499);

%FinalPlot ([2023 3 15 0 0 0], [2024 3 15 0 0 0],HIE_rep_list,20,12)
FinalPlot (date1, date2,HIE_rep_list(:,35),20,12)
%% Covariance
x=35;
%HIE_event = HIE_rep_list(5:4+cell2mat(HIE_rep_list(4,x)),x);
HIE_event = cdm_rep_list(5:4+cell2mat(cdm_rep_list(4,x)),x);
clear time_series pos_error vel_error
for l = 1:length(HIE_event)
    cov1 = HIE_event{l}.cov1;
    cov2= HIE_event{l}.cov2;
    
    pos_error(l) = sqrt(cov1(1,1)+cov1(2,2)+cov1(3,3));
    vel_error(l) = sqrt(cov1(4,4)+cov1(5,5)+cov1(6,6));
    time_series(l) = date2mjd2000(HIE_event{l}.creation_date);
end

time_series = time_series - date2mjd2000(HIE_event{1}.tca);

set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
yyaxis left
area(time_series,pos_error,'FaceColor',"#0072BD");
plot(time_series,pos_error,'o','Color',"black");
%ylim([0 200]);
ylabel('Position error [km]')
yyaxis right
area(time_series,vel_error,'FaceColor',"#D95319");
%plot(time_series,vel_error,'o','Color',"black");
ylabel('Velocity error [km/s]')
%ylim([0 0.5])
xlim([time_series(1) time_series(end)]);
xticks(-7:0);
xlabel("Time with respect to event's TCA [days]")
grid on;
grid minor;
figure_dimensions = [0 0 20 8]; 
filename = "Data\" + "Covariance"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500')
%% Miss distance difference
x=35;
HIE_event = HIE_rep_list(5:4+cell2mat(HIE_rep_list(4,x)),x);
clear time_series 
for l = 1:length(HIE_event)
    MissDist_error(l) = norm (event_detection(13,205)-HIE_event{l}.miss_dist);
    TCA_error(l) = norm (event_detection(14,205)-date2mjd2000(HIE_event{l}.tca))*86400;
    time_series(l) = date2mjd2000(HIE_event{l}.creation_date);
end

time_series = time_series - event_detection(14,205);

figure()
plot(time_series,MissDist_error)

figure()
plot(time_series,TCA_error)
%% Number of collision avoidance maneuver suggestions
i_man=0;
for k = 1:1983
    if event_detection(10,k)==1
        i_man=i_man+1;
    end
end


%% Post processing (Collision value)
GetConfig;
global config;
set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
cdm_values = zeros(1,length(cdm_list));
for i=1:length(cdm_list)
    cdm_values(i)=cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC_value;
end
ind = 1:length(cdm_values);
scatter(ind,cdm_values);
grid on;
ylabel('Normalized conjunction value [-]')
xlabel("Conjunction Data Message's number");

figure_dimensions = [0 0 20 8]; 
filename = "Data\" + "conjunction_value"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500')
%% Post processing (Collision number of pieces)
GetConfig;
global config;

set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

cdm_collisions = zeros(1,length(cdm_list));
for i=1:length(cdm_list)
    cdm_collisions(i)=cdm_list(i).CC;

end
ind = 1:length(cdm_collisions);

figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
scatter(ind,cdm_collisions);
grid on;
ylabel('Number of pieces produced (CC)')
xlabel("Conjunction Data Message's number");
figure_dimensions = [0 0 20 8]; 
filename = "Data\" + "conjunction_CC"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500')
%% Minimum and Average Miss distances

[min_miss,min_index]=min(event_detection(13,:));

average_miss = sum(event_detection(13,:))/size(event_detection,2);

%% Miss distance CDM vs Truth comparison

av_in = zeros(1,7);
av_sum = zeros(1,7);
sum_pos_primary = zeros (1,7);
sum_vel_primary = zeros (1,7);

for o = 1:size(cdm_rep_list,2)
    real_miss_dist = event_detection(13,o);
    real_tca = event_detection(14,o);
    rep_size = cdm_rep_list{4,o};
    
    for m = 5:4+rep_size
        cdm = cdm_rep_list{m,o};
        time2tca = real_tca - date2mjd2000(cdm.creation_date);
        error_miss_dist = norm (real_miss_dist-cdm.miss_dist);
        cov1 = cdm.cov1;
        pos_error_prime = sqrt(cov1(1,1)+cov1(2,2)+cov1(3,3));
        vel_error_prime = sqrt(cov1(4,4)+cov1(5,5)+cov1(6,6));
        if time2tca<1
            pf=1;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        elseif time2tca<2
            pf=2;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        elseif time2tca<3
            pf=3;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        elseif time2tca<4
            pf=4;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        elseif time2tca<5
            pf=5;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        elseif time2tca<6
            pf=6;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        else
            pf=7;
            av_in(pf)=av_in(pf)+1;
            av_sum(pf)=av_sum(pf)+error_miss_dist;
            sum_pos_primary(pf)=sum_pos_primary(pf)+pos_error_prime;
            sum_vel_primary(pf)=sum_vel_primary(pf)+vel_error_prime;
        end
    end
end

average_error = av_sum./av_in;
average_error=flip(average_error);

average_pos_cov = sum_pos_primary./av_in;
average_vel_cov = sum_vel_primary./av_in;

set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

figure()
hold on;
yyaxis left
plot(1:7,flip(average_pos_cov));
yyaxis right
plot(1:7,flip(average_vel_cov));


figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
plot(1:7,average_error,'-o');
ylabel("Average miss distance error [km]");
xlabel("Time to TCA [days]")
grid on;
xticklabels(["7-6","6-5","5-4","4-3","3-2","2-1","1-0"]);

figure_dimensions = [0 0 20 8]; 
filename = "Data\" + "miss_dist_error"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500')

%% Smaller plot

cdm_rep_temp = cdm_rep_list (:,1095:1295);
FinalPlot ([2023 10 20 0 0 0], [2023 10 29 0 0 0],cdm_rep_temp,20,9)