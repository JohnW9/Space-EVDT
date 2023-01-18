% FUNCTION NAME:
%   Read_spacetrack
%
% DESCRIPTION:
%   This function downloads the space-catalogue from Space-Track, given a username and password. Then,
%   the catalogue is stored in a CSV file named "Space_catalogue_updated.csv"
%
% INPUT:
%
% OUTPUT:
%
% ASSUMPTIONS AND LIMITATIONS:
% Internet needed to download the catalogue from Space-Track
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function Read_spacetrack

%% Credentials
username='SpaceEVDT@gmail.com';
password='Space-enabled2022';

%% Saving the space catalogue as .csv
URL='https://www.space-track.org/ajaxauth/login';
post={'identity',username,'password',password,'query',...
  'https://www.space-track.org/basicspacedata/query/class/gp/decay_date/null-val/epoch/%3Enow-30/orderby/norad_cat_id/format/csv'};
urlwrite(URL,'Data\Space_catalogue_updated.csv','Post',post,'Timeout',30);
