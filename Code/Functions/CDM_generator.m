%% CDM generation

function cdm = CDM_generator (single_event_matrix,t,space_cat,space_cat_ids,eos)
% t is number of days before the TCA
%% Propagating backwards

temp_objects(2)=Space_object;

tca=single_event_matrix(2);

temp_objects(1).id=single_event_matrix(3);
temp_objects(2).id=single_event_matrix(4);

temp_objects(1).epoch=single_event_matrix(2);
temp_objects(2).epoch=single_event_matrix(2);

temp_objects(1).a=single_event_matrix(7); temp_objects(1).e=single_event_matrix(8); temp_objects(1).i=single_event_matrix(9); temp_objects(1).raan=single_event_matrix(10); temp_objects(1).om=single_event_matrix(11); temp_objects(1).M=single_event_matrix(12);
temp_objects(2).a=single_event_matrix(13); temp_objects(2).e=single_event_matrix(14); temp_objects(2).i=single_event_matrix(15); temp_objects(2).raan=single_event_matrix(16); temp_objects(2).om=single_event_matrix(17); temp_objects(2).M=single_event_matrix(18);

state1_f = par2car([single_event_matrix(7:11);M2f(single_event_matrix(12),single_event_matrix(8))]);
r1_f=state1_f(1:3);
v1_f=state1_f(4:6);

state2_f = par2car([single_event_matrix(13:17);M2f(single_event_matrix(18),single_event_matrix(14))]);
r2_f=state2_f(1:3);
v2_f=state2_f(4:6);

%% Position and velocity of space objects at the time of CDM generation
temp_objects(1) = TwoBP_J2_analytic (temp_objects(1),tca-t,'mjd2000');
temp_objects(2) = TwoBP_J2_analytic (temp_objects(2),tca-t,'mjd2000');

%% Covariance matrix in RSW frame
e_r = 0.001; % Error in R direction position [km]
e_s = 0.001; % Error in S direction position [km]
e_w = 0.001; % Error in W direction position [km]
e_vr= 0.0001; % Error in R direction velocity [km/s]
e_vs= 0.0001; % Error in R direction velocity [km/s]
e_vw= 0.0001; % Error in R direction velocity [km/s]

P0_rsw = diag([e_r^2 e_s^2 e_w^2 e_vr^2 e_vs^2 e_vw^2]);

%% Conversion to ECI at TCA
% Object 1
prop_cov1=Cov_prop_TH (P0_rsw,temp_objects(1),tca);
[T1_rsw2eci,~] = ECI2RSW(r1_f,v1_f); % Notations taken from chen's book
J1_rsw2eci=[T1_rsw2eci zeros(3);zeros(3) T1_rsw2eci];
P0_1 = J1_rsw2eci * prop_cov1 * J1_rsw2eci';

% Object 2
prop_cov2=Cov_prop_TH (P0_rsw,temp_objects(2),tca);
[T2_rsw2eci,~] = ECI2RSW(r2_f,v2_f); 
J2_rsw2eci=[T2_rsw2eci zeros(3);zeros(3) T2_rsw2eci];
P0_2 = J2_rsw2eci * prop_cov2 * J2_rsw2eci';
%% Hard Body Radius

for m=1:length(eos)
    if temp_objects(1).id == eos(m).id
        dim1=eos(m).dimensions; % [m^2]
        m1=eos(m).mass; % [kg]
        break;
    end
end

second_obj=space_cat(find(space_cat_ids==temp_objects(2).id)); % The masses are completely arbitrary
if strcmp(second_obj.RCS,'SMALL') 
    dim2=0.1; % [m^2] This is the upper band dimension
    m2=10; %[kg]
elseif strcmp(second_obj.RCS,'MEDIUM')
    dim2=1; % [m^2]
    m2=100; %[kg]
else
    dim2=10; % [m^2] % The cross section dimension is completely arbitrary
    m2=500; %[kg]
end

HBR=1e-3*(sqrt(dim1)+sqrt(dim2)); % [km]
HBRType='circle';

%% Probability of collision



% [Pc,~,IsPosDef,~] = Pc2D_Foster(r1_f',v1_f',P0_1,r2_f',v2_f',P0_2,HBR,1e-8,HBRType);
Pc = FrisbeeMaxPc(r1_f',v1_f',P0_1,r2_f',v2_f',[],HBR,1e-8,HBRType);
[Catastrophic,NumOfPieces] = CollisionConsequenceNumPieces(m1,norm(v1_f-v2_f)*1000,m2);

cdm=CDM;
cdm.creation_date = mjd20002date(tca-t);
cdm.tca=mjd20002date(tca);
cdm.miss_dist=single_event_matrix(5);
cdm.Pc=Pc;
cdm.CC=NumOfPieces;
cdm.catas_flag=Catastrophic;
cdm.HBR=HBR;
cdm.id1=single_event_matrix(3);
cdm.id2=single_event_matrix(4);
cdm.r1=r1_f;
cdm.v1=v1_f;
cdm.cov1=P0_1;
cdm.dim1=dim1;
cdm.m1=m1;
cdm.r2=r2_f;
cdm.v2=v2_f;
cdm.cov2=P0_2;
cdm.dim2=dim2;
cdm.m2=m2;
end