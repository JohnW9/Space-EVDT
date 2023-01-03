function Read_spacetrack

%% Credentials
username='SpaceEVDT@gmail.com';
password='Space-enabled2022';

%% Saving the space catalogue as .csv
URL='https://www.space-track.org/ajaxauth/login';
post={'identity',username,'password',password,'query',...
  'https://www.space-track.org/basicspacedata/query/class/gp/decay_date/null-val/epoch/%3Enow-30/orderby/norad_cat_id/format/csv'};
urlwrite(URL,'Data\Space_catalogue_updated.csv','Post',post,'Timeout',10);
