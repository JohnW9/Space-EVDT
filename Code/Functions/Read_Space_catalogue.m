% FUNCTION NAME:
%   Read_Space_catalogue
%
% DESCRIPTION:
%   This function provides a space catalogue either from space-track or a local file.
%   If the online catalogue is unavailable, a local file is used.
%
% INPUT:
%   read_from_web = [1x1] or Null This is an indicater whether the function should download the
%                         space catalogue from the web or not (if no input, no download)
%
% OUTPUT:
%   space_cat = (M objects) Space catalogue containing thousands of space objects [Space_object]
%
% ASSUMPTIONS AND LIMITATIONS:
%   The current SSA providers can detect objects only bigger than 10 cm.
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
%   28/8/2023 - Sina Es haghi
%       * Possibility to read old space catalogues within a given date
%
%
function space_obj = Read_Space_catalogue(read_from_web,initial_epoch,final_epoch)
if nargin<=1 || read_from_web==0
    read_from_web=0;
elseif nargin >1
    read_from_web = 2; % If a given date range for the space catalog is given
else
    read_from_web=1;
end

if read_from_web==1 % Update the space catalogue    
    try
        Read_spacetrack;
        raw_data=readtable("Space_catalogue_updated.csv");
                disp("Space catalogue downloaded from Space-Track");
 
    catch % Reading from web unsuccessful, reads from local file
        raw_data=readtable("Space_catalogue_old.csv");
        disp("Couldn't dowoload space catalogue from Space-Track; Local file loaded");
    end
elseif read_from_web ==2
    try
        Read_spacetrack(initial_epoch,final_epoch);
        raw_data=readtable("Space_catalogue_updated.csv");
       disp("Space catalogue downloaded from Space-Track for the specified date range");
    catch % Reading from web unsuccessful, reads from local file
        raw_data=readtable("Space_catalogue_old.csv");
        disp("Couldn't dowoload space catalogue from Space-Track; Local file loaded");
    end
    
else
    raw_data=readtable("Space_catalogue_old.csv");
    disp("Local space catalogue loaded");
end

% Initialization
NAMES=table2array(raw_data(:,'OBJECT_NAME'));
NORADIDS=table2array(raw_data(:,'NORAD_CAT_ID'));
SEMIMAJORS=table2array(raw_data(:,'SEMIMAJOR_AXIS'));
ECCENTRICITIES=table2array(raw_data(:,'ECCENTRICITY'));
INCLINATIONS=table2array(raw_data(:,'INCLINATION'));
RAANS=table2array(raw_data(:,'RA_OF_ASC_NODE'));
ARGPERIGEES=table2array(raw_data(:,'ARG_OF_PERICENTER'));
MEANANOMALIES=table2array(raw_data(:,'MEAN_ANOMALY'));
EPOCHS=table2array(raw_data(:,'EPOCH'));
TYPE_OBJECTS=table2array(raw_data(:,'OBJECT_TYPE'));
RCSs=table2array(raw_data(:,'RCS_SIZE'));
BSTAR=table2array(raw_data(:,'BSTAR')); %retrieve BSTAR
%TLELINE1s=table2array(raw_data(:,'TLE_LINE1'));
%TLELINE2s=table2array(raw_data(:,'TLE_LINE2'));

% Converting to Space_object
no_obj=length(NAMES);
space_obj (1:no_obj) = Space_object;
j = 0;
for i=1:no_obj

    %% This part is to avoid space object duplication (the catalogue needs to be sorted by NORAD ID)
    if i<no_obj
        if NORADIDS(i)==NORADIDS(i+1)
            continue;
        end
    end

    j=j+1;
    %%

    space_obj(j).name = char(NAMES(i));
    space_obj(j).id=NORADIDS(i);
    %epoch=char(EPOCHS(i));
    %space_obj(i).epoch=date2mjd2000([str2double(epoch(1:4)) str2double(epoch(6:7)) str2double(epoch(9:10)) str2double(epoch(12:13)) str2double(epoch(15:16)) str2double(epoch(18:end))]);
    epoch=datevec(EPOCHS(i));
    space_obj(j).epoch=date2mjd2000(epoch);
    space_obj(j).a=SEMIMAJORS(i);
    space_obj(j).e=ECCENTRICITIES(i);
    space_obj(j).i=deg2rad(INCLINATIONS(i));
    space_obj(j).raan=deg2rad(RAANS(i));
    space_obj(j).om=deg2rad(ARGPERIGEES(i));
    space_obj(j).M=deg2rad(MEANANOMALIES(i));
    space_obj(j).type = char(TYPE_OBJECTS(i));
    space_obj(j).RCS = char(RCSs(i));
    space_obj(j).B_star = BSTAR(i); %add BSTAR to space_obj
    %space_obj(i).line1= char(TLELINE1s(i));
    %space_obj(i).line2= char(TLELINE2s(i));
end

for k = no_obj:-1:1
    if isempty(space_obj(k).name)
        space_obj(k)=[];
    end
end