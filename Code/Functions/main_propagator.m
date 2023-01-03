%% Vectorized 2BP with secular J2 effect propagator

% final_time is in 1x6 date format

function propagated_object_list = main_propagator (objects_list,final_time,timestep,~)

if nargin == 3
    bool =0;
else
    bool =1;
end

objects_length = length(objects_list);

ti=objects_list(1).epoch;
tf=date2mjd2000(final_time);
t = ti:timestep/86400:tf;
t(end)=tf; % For some reason this might be needed

a    = zeros (objects_length,1);
e    = zeros (objects_length,1);
i    = zeros (objects_length,1);
raan0= zeros (objects_length,1);
om0  = zeros (objects_length,1);
M0   = zeros (objects_length,1);

for k = 1:objects_length
    a(k) = objects_list(k).a;
    e(k) = objects_list(k).e;
    i(k) = objects_list(k).i;
    raan0(k) = objects_list(k).raan;
    om0(k)   = objects_list(k).om;
    M0(k)    = objects_list(k).M;
end

% raan(:,1) = raan0;
% om(:,1)   = om0;
% M(:,1)    = M0;

% J2 = astroConstants(9);
% miu = astroConstants(13);

J2= 0.001082626925639;
Re = 6378.14;
miu= 3.986004330000000e+05;

n=sqrt(miu./a.^3);
p=a.*(1-e.^2);

draan = -(3/4*n.*Re^2*J2./p.^2).*(2.*cos(i));
dom= (3/4*n.*Re^2*J2./p.^2).*(4-5.*sin(i).^2);
dmean=-(3/4*n.*Re^2*J2./p.^2).*(sqrt(1-e.^2).*(3*sin(i).^2-2));

propagated_object_list (objects_length) = Propagated_space_object;


for k = 1:objects_length
    raan=mod(raan0(k)+(t-ti)*86400.*draan(k),2*pi);
    om=mod(om0(k)+(t-ti)*86400.*dom(k),2*pi);
    M=mod(M0(k)+(t-ti)*86400.*(n(k)+dmean(k)),2*pi);
    
    propagated_object_list(k).name=objects_list(k).name;
    propagated_object_list(k).id=objects_list(k).id;
    propagated_object_list(k).epoch=ti;
    propagated_object_list(k).final_time=tf;
    propagated_object_list(k).timestep=timestep;
    propagated_object_list(k).RCS=objects_list(k).RCS;
    propagated_object_list(k).t=t;
    propagated_object_list(k).ma=a(k);
    propagated_object_list(k).me=e(k);
    propagated_object_list(k).mi=i(k);
    propagated_object_list(k).mraan=raan;
    propagated_object_list(k).mom  =om;
    propagated_object_list(k).M    =M;

    if bool == 1
        f = M2f (M,e(k));
        [x, y, z, vx, vy, vz] = par2car_vect (a(k), e(k), i(k), raan, om, f);
        propagated_object_list(k).f=f;
        propagated_object_list(k).rx=x;
        propagated_object_list(k).ry=y;
        propagated_object_list(k).rz=z;
        propagated_object_list(k).vx=vx;
        propagated_object_list(k).vy=vy;
        propagated_object_list(k).vz=vz;
    end
    
end
