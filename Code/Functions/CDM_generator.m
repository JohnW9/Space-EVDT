% FUNCTION NAME:
%   CDM_generator
%
% DESCRIPTION:
%   This function generates a Conjunction Data Message (CDM) whenever data is provided
%   by the SSA providers. The data will be the states and covariance matrices of the 
%   objects at time t. Therefore, this function propagates the states and covariances
%   to TCA and also converts the covariances to ECI frame. This function also does a 
%   very simple estimation of the size and mass of the secondary space object.
%
% INPUT:
%   event_column = [14x1] A matrix with one column corresponding to a conjunction,Containing important 
%                         space object informations. 
%                         [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   conjunction_data = [84x1] A matrix containing all the orbital data and covariances of the two
%                             space objects at the real observation time.
%   t = [1x1] Realistic observation time [mjd2000]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   space_cat_ids = [1xM] A matrix containing the NORAD IDs of the space catalogue objects in order
%   eos = (N objects)  Primary NASA satellites under consideration for collision avoidance [NASA_sat]
%   ind_cdm = [1x1] The CDM number
%
%     event_column details:
%     row1: Conjunction event ID number (in chronological order)
%     row2: Time of detection in [MJD2000]
%     row3: Primary satellite NORAD ID
%     row4: Secondary space object NORAD ID
%     row5: Estimated Miss distance in [km]
%     row6: Number of times the cdm is generated for the event
%     row7: Next expected conjunction update [MJD2000]
%     row8: Type of SSA to use
%     row9: TCA [MJD2000]
%     row10: Mitigation status (0-not mitigated 1-mitigated -1-not mitigated and TCA passed)
%     row11: Request status (0-no special tasking request 1-commercial SSA request -1-commercial request denied by the provider)
%     row12: Last successful observation time [MJD2000]
%     row13: Real miss distance (either manipulated or not) [km]
%     row14: Real Time of Closes Approach [mjd2000]
%
%
%     conjunction_data matrix details:
%     row1-6: Cartesian state of object 1 in ECI [km;km;km;km/s;km/s;km/s]
%     row7-12: Cartesian state of object 2 in ECI [km;km;km;km/s;km/s;km/s]
%     row13-48: Covariance elements of object 1 in RSW [units in km^2 and km^2/s^2]
%     row49-84: Covariance elements of object 2 in RSW [units in km^2 and km^2/s^2]
%
% OUTPUT:
%   cdm = (1 object) A conjunction data message including important data at TCA [CDM]
%
%   A cdm includes all the following data AT TCA:
%   Num = [1x1] CDM number
%   label = [1x1] Represents which conjunction event is this cdm representing (The conjunction event are numbered in the chronological order)
%   creation_date = [1x6] Gregorian calender date of when the CDM is generated, which is realistic time (t) [yy mm dd hr mn sc]
%   miss_dist = [1x1] This is the ESTIMATED miss distance from propagating the estimated states of the objects to TCA [km]
%   Pc = [1x1] Probability of collision value calculated by NASA function (Default is 2D, then Max Pc)
%   CC = [1x1] Collision consequenc, number of fragments generated in case of collision. Obtained through the NASA software
%   HBR = [1x1] The hard body radius of the two objects summed and projected on a plane for maximum cross area [m]
%   id1 = [1x1] NORAD ID of object 1 (The primary NASA satellite)
%   id2 = [1x1] NORAD ID of object 2 (The secondary space object)
%   r1 = [3x1] The position vector of object 1 in the ECI frame [km;km;km]
%   v1 = [3x1] The velocity vector of object 1 in the ECI frame [km/s;km/s;km/s]
%   cov1 = [6x6] The propagated covariance matrix of object 1 in the RSW frame [units is km^2, km^2/s, and km^2/s^2]
%   dim1 = [1x1] conjuncting dimension of object 1 [m]
%   m1 = [1x1] Mass of object 1 [kg]
%   value1 = [1x1] Socio-economic value of object 1 
%   r2 = [3x1] The position vector of object 2 in the ECI frame [km;km;km]
%   v2 = [3x1] The velocity vector of object 2 in the ECI frame [km/s;km/s;km/s]
%   cov2 = [6x6] The propagated covariance matrix of object 2 in the RSW frame [units is km^2, km^2/s, and km^2/s^2]
%   dim2 = [1x1] conjuncting dimension of object 2 [m]
%   m2 = [1x1] Mass of object 2 [kg]
%   value2 = [1x1] Socio-economic value of object 2
%   value_CC = [1x1] Collision consequence value
%   read_status = [1x1] Read status of the CDM (0-the CDM is not read by the decision model, 1-the CDM is read by the decision model)
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   The program currently takes into account the maximum dimension of the NASA satellite for HBR.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Header added
%   13/1/2023 - Sina Es haghi
%       * Modified the hard body radius calculation
%   06/3/2023 - Sina Es haghi
%       * Covariance matrices in CDM are now in RSW frame along with function header
%
%

function cdm = CDM_generator (event_column,conjunction_data,t,space_cat,space_cat_ids,eos,ind_cdm)
config = GetConfig;
%% Converting R V vectors at time t to orbital elements and put in the single event matrix
state_car1=conjunction_data(1:6);
state_car2=conjunction_data(7:12);

state_par1=car2par(state_car1);
state_par2=car2par(state_car2);


single_event_matrix=[event_column(1);t;event_column(3:5);0;...
    state_par1(1:5);f2M(state_par1(6),state_par1(2));state_par2(1:5);f2M(state_par2(6),state_par2(2))];

P01_rsw=reshape(conjunction_data(13:48),[6,6]);
P02_rsw=reshape(conjunction_data(49:84),[6,6]);

NoP2=0;
if norm(P02_rsw)==0; NoP2=1;end % Checks if no value for the covariance matrix of the secondary object is available
%% 

temp_objects(2)=Space_object;

tca=event_column(9);

temp_objects(1).id=single_event_matrix(3);
temp_objects(2).id=single_event_matrix(4);

temp_objects(1).epoch=single_event_matrix(2);
temp_objects(2).epoch=single_event_matrix(2);

temp_objects(1).a=single_event_matrix(7); temp_objects(1).e=single_event_matrix(8); temp_objects(1).i=single_event_matrix(9); temp_objects(1).raan=single_event_matrix(10); temp_objects(1).om=single_event_matrix(11); temp_objects(1).M=single_event_matrix(12);
temp_objects(2).a=single_event_matrix(13); temp_objects(2).e=single_event_matrix(14); temp_objects(2).i=single_event_matrix(15); temp_objects(2).raan=single_event_matrix(16); temp_objects(2).om=single_event_matrix(17); temp_objects(2).M=single_event_matrix(18);

r1_i=state_car1(1:3);
v1_i=state_car1(4:6);

r2_i=state_car2(1:3);
v2_i=state_car2(4:6);

%% Propagating the Covariance matrices in RSW
prop_cov1=Cov_prop_TH (P01_rsw,temp_objects(1),tca);
if NoP2==0;prop_cov2=Cov_prop_TH (P02_rsw,temp_objects(2),tca);end

%% Position and velocity of space objects at TCA
temp_objects(1) = TwoBP_J2_analytic (temp_objects(1),tca,'mjd2000');
temp_objects(2) = TwoBP_J2_analytic (temp_objects(2),tca,'mjd2000');


stat1_f=par2car([temp_objects(1).a;temp_objects(1).e;temp_objects(1).i;temp_objects(1).raan;temp_objects(1).om;M2f(temp_objects(1).M,temp_objects(1).e)]);
stat2_f=par2car([temp_objects(2).a;temp_objects(2).e;temp_objects(2).i;temp_objects(2).raan;temp_objects(2).om;M2f(temp_objects(2).M,temp_objects(2).e)]);

r1_f=stat1_f(1:3);
v1_f=stat1_f(4:6);

r2_f=stat2_f(1:3);
v2_f=stat2_f(4:6);

%% quick check
miss_dist=norm(r1_f-r2_f);
error_of_missdist=abs(miss_dist-event_column(5));
%if error_of_missdist/miss_dist>1e-3 
%    error("error in propagation in cdm generation");
%end

%% Conversion to ECI at TCA
% Object 1
[T1_rsw2eci,~] = ECI2RSW(r1_f,v1_f); % Notations taken from chen's book
J1_rsw2eci=[T1_rsw2eci zeros(3);zeros(3) T1_rsw2eci];
P1 = J1_rsw2eci * prop_cov1 * J1_rsw2eci';

% Object 2
if NoP2==0
    [T2_rsw2eci,~] = ECI2RSW(r2_f,v2_f);
    J2_rsw2eci=[T2_rsw2eci zeros(3);zeros(3) T2_rsw2eci];
    P2 = J2_rsw2eci * prop_cov2 * J2_rsw2eci';
end
%% Hard Body Radius

for m=1:length(eos)
    if temp_objects(1).id == eos(m).id
        dim1=max(eos(m).dimensions); % [m^2]
        m1=eos(m).mass; % [kg]
        break;
    end
end

second_obj=space_cat(find(space_cat_ids==temp_objects(2).id)); % The masses are completely arbitrary
%% Estimating the size and mass of the secondary space object
% NASA does have a model called: "NASA_SEM_RCSToSizeVec.m" but requires the RCS normalized vectors
% NASA also has a model called: "EstimateMassFromRCS.m" but requires the RCS value
if strcmp(second_obj.RCS,'SMALL') 
    dim2=config.small_dim; % [m] This is the upper band dimension
    m2=config.small_mass; %[kg]
elseif strcmp(second_obj.RCS,'MEDIUM')
    dim2=config.medium_dim; % [m]
    m2=config.medium_mass; %[kg]
else
    dim2=config.large_dim; % [m] % The maximum dimension is completely arbitrary
    m2=config.large_mass; %[kg]
end
HBR=1e-3*(dim1+dim2); % [km]
HBRType=config.HBRType;

%% Valuing the space objects
[value1,value2,value_CC,NumOfPieces]=Vulnerability_model(eos(m),second_obj,m1,norm(v1_f-v2_f)*1000,m2);

%% Probability of collision (using NASA software)


if NoP2==0
    [Pc,~,~,~] = Pc2D_Foster(r1_f',v1_f',P1,r2_f',v2_f',P2,HBR,1e-8,HBRType);
else
    Pc = FrisbeeMaxPc(r1_f',v1_f',P1,r2_f',v2_f',[],HBR,1e-8,HBRType);
end

if Pc < 1e-30  % This is just added to have the plots clean
    Pc = 1e-30;
end

cdm=CDM;
cdm.Num = ind_cdm;
cdm.label=event_column(1);
cdm.creation_date = mjd20002date(t);
cdm.tca=mjd20002date(tca);
cdm.miss_dist=single_event_matrix(5);
cdm.Pc=Pc;
cdm.CC=NumOfPieces;
cdm.HBR=HBR*1e3;
cdm.id1=single_event_matrix(3);
cdm.id2=single_event_matrix(4);
cdm.r1=r1_f;
cdm.v1=v1_f;
cdm.cov1=prop_cov1; % In RSW frame
cdm.dim1=dim1;
cdm.m1=m1;
cdm.value1=value1;
cdm.r2=r2_f;
cdm.v2=v2_f;
if NoP2 == 0
    cdm.cov2=prop_cov2; % In RSW frame
else
    cdm.cov2=NaN;
end
cdm.dim2=dim2;
cdm.m2=m2;
cdm.value2=value2;
cdm.CC_value =value_CC;
cdm.read_status=0;
end