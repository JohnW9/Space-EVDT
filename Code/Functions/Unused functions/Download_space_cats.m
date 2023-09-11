%% Downloading the Space catalog
clc;
clear;
addpath('Functions/');
addpath('Functions/NASA/');
addpath('Functions/');
addpath('Time_conversion/');
addpath('Data/');

%% Goal is from Jan 2006 till Dec 2010

space_catalog_list = cell(5*12,1);
space_cat_length = 0;

year_in = 2006;
year_en = 2010;
month_in = 1;


temp_year = year_in;
temp_month = month_in;

FW = waitbar(0,'Downloading space catalogs');
while temp_year<=year_en
    if temp_month<10
        initial_date = [num2str(temp_year) '-0' num2str(temp_month) '-01'];
        final_date   = [num2str(temp_year) '-0' num2str(temp_month) '-05'];
    else
        initial_date = [num2str(temp_year) '-' num2str(temp_month) '-01'];
        final_date   = [num2str(temp_year) '-' num2str(temp_month) '-05'];
    end
    temp_space_cat = Read_Space_catalogue(2,initial_date,final_date);

    space_cat_length = space_cat_length +1;
    space_catalog_list{space_cat_length} = temp_space_cat;
    
    temp_month = temp_month+1;
    if temp_month>12
        temp_month = 1;
        temp_year = temp_year+1;
    end
    waitbar(space_cat_length/length(space_catalog_list),FW,['Downloading space catalogs (' num2str(space_cat_length) '/' num2str(length(space_catalog_list)) ')']);
end

close(FW);

%save("long_catalog.mat","space_catalog_list");


%% Load monthly space catalog from 
%load("Data/long_catalog.mat");

%% No. of objects per space catalog
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
h = plot(no_objects_in_cat,'-o');
xline(Fengyun_index,'Color','r','Label','Fengyun');
xline(CosIrid33_index,'Color','r','Label','Cosmos-Iridium');
xticks(1:6:60);
xticklabels(cat_date(1:6:end));
ax = ancestor(h, 'axes');
ax.XAxis.Exponent = 0 ;
ax.XAxis.TickLabelFormat = '%.0f';