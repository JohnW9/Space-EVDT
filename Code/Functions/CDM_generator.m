%% CDM generation

function cdm = CDM_generator (event_detection,conjunction_data,t,space_cat,space_cat_ids,eos)
%Event detection and conjunction data matrices shall be single column
%% Converting R V vectors at time t to orbital elements and put in the single event matrix
state_car1=conjunction_data(1:6);
state_car2=conjunction_data(7:12);

state_par1=car2par(state_car1);
state_par2=car2par(state_car2);


single_event_matrix=[event_detection(1);t;event_detection(3:5);0;...
    state_par1(1:5);f2M(state_par1(6),state_par1(2));state_par2(1:5);f2M(state_par2(6),state_par2(2))];

P01_rsw=reshape(conjunction_data(13:48),[6,6]);
P02_rsw=reshape(conjunction_data(49:84),[6,6]);

NoP2=0;
if norm(P02_rsw)==0; NoP2=1;end
%% 

temp_objects(2)=Space_object;

tca=event_detection(9);

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
error_of_missdist=abs(miss_dist-event_detection(5));
if error_of_missdist>1e-3 
    error("error in propagation in cdm generation");
end

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
        dim1=eos(m).dimensions; % [m^2]
        m1=eos(m).mass; % [kg]
        value1=eos(m).value;
        break;
    end
end

second_obj=space_cat(find(space_cat_ids==temp_objects(2).id)); % The masses are completely arbitrary
second_obj=Secondary_value(second_obj);
value2=second_obj.value;
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


if NoP2==0
    [Pc,~,~,~] = Pc2D_Foster(r1_f',v1_f',P1,r2_f',v2_f',P2,HBR,1e-8,HBRType);
else
    Pc = FrisbeeMaxPc(r1_f',v1_f',P1,r2_f',v2_f',[],HBR,1e-8,HBRType);
end

[Catastrophic,NumOfPieces] = CollisionConsequenceNumPieces(m1,norm(v1_f-v2_f)*1000,m2);

cdm=CDM;
cdm.label=event_detection(1);
cdm.creation_date = mjd20002date(t);
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
cdm.cov1=P1;
cdm.dim1=dim1;
cdm.m1=m1;
cdm.value1=value1;
cdm.r2=r2_f;
cdm.v2=v2_f;
cdm.cov2=P2;
cdm.dim2=dim2;
cdm.m2=m2;
cdm.value2=value2;
cdm.read_status=0;
end