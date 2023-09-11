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
%   28/8/2023 - Sina Es haghi
%       * Download a catalog within epoch range
%
function Read_spacetrack(initial_epoch,final_epoch)


%% Credentials
fileID=fopen("Credentials.txt");
if fileID == -1; error('Credentials.txt file, containing the space-track username and password, is missing');end
username=fgetl(fileID);
password=fgetl(fileID);

%% Saving the space catalogue as .csv
URL='https://www.space-track.org/ajaxauth/login';

if nargin == 0
    post={'identity',username,'password',password,'query',...
        'https://www.space-track.org/basicspacedata/query/class/gp/decay_date/null-val/epoch/%3Enow-30/orderby/norad_cat_id/format/csv'};
else
    %post={'identity',username,'password',password,'query',...
    %    ['https://www.space-track.org/basicspacedata/query/class/gp_history/EPOCH/%3E' initial_epoch '%2C%3C' final_epoch '/orderby/NORAD_CAT_ID%20asc/format/csv/']};
    post={'identity',username,'password',password,'query',...
        ['https://www.space-track.org/basicspacedata/query/class/gp_history/EPOCH/>' initial_epoch ',<' final_epoch '/orderby/NORAD_CAT_ID asc/format/csv/']};
    
end

urlwrite(URL,'Data\Space_catalogue_updated.csv','Post',post,'Timeout',60);
