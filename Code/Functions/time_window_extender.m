function [t_list1,t_list2] = time_window_extender (obj1,obj2,t_window_01,t_window_02,t_final)
% t in mjd2000

miu= 3.986004330000000e+05;
J2= 0.001082626925639;
Re = 6378.14;

% Initial matrix attribution for primary obj

n1 = sqrt(miu/obj1.a^3);
T1 = (2*pi/n1)/86400; % in days
guess_size1 = ceil((t_final-t_window_01(1,1))*3/T1);
t_list1 = NaN(guess_size1,2);
t_list1(1:2,1:2) = t_window_01;

p1=obj1.a*(1-obj1.e^2);

draan1 = -(3/4*n1*Re^2*J2/p1^2)*(2*cos(obj1.i));
dom1= (3/4*n1*Re^2*J2/p1^2)*(4-5*sin(obj1.i)^2);
dmean1=-(3/4*n1*Re^2*J2/p1^2)*(sqrt(1-obj1.e^2)*(3*sin(obj1.i)^2-2));


% Initial matrix attribution for secondary obj

n2=sqrt(miu/obj2.a^3);
p2=obj2.a*(1-obj2.e^2);
T2 = (2*pi/n2)/86400; % in days
guess_size2 = ceil((t_final-t_window_02(1,1))*3/T2);
t_list2 = NaN(guess_size2,2);
t_list2(1:2,1:2) = t_window_02;

% Secular effects of J2
draan2 = -(3/4*n2*Re^2*J2/p2^2)*(2*cos(obj2.i));
dom2= (3/4*n2*Re^2*J2/p2^2)*(4-5*sin(obj2.i)^2);
dmean2=-(3/4*n2*Re^2*J2/p2^2)*(sqrt(1-obj2.e^2)*(3*sin(obj2.i)^2-2));



h_i =@(I,Om) [sin(Om)*sin(I);-cos(Om)*sin(I);cos(I)];
cos_delta_i =@(I_i,I_j,Om_i,Om_j,sin_I_R) 1/sin_I_R*(sin(I_i)*cos(I_j)-sin(I_j)*cos(I_i)*cos(Om_i-Om_j));
sin_delta_i =@(I_i,I_j,Om_i,Om_j,sin_I_R) 1/sin_I_R*(sin(I_j)*sin(Om_i-Om_j)); % Notice that for secondary, the input of raans should be inverted

% t_list for object 1
i=1;
while true
    if t_list1(i+1,2)>t_final
        break;
    end

    primary = TwoBP_J2_analytic(obj1,(t_list1(i,1)+t_list1(i+1,2))/2,'mjd2000');
    secondary = TwoBP_J2_analytic(obj2,(t_list1(i,1)+t_list1(i+1,2))/2,'mjd2000');
    

    h_p = h_i(primary.i,primary.raan);
    h_s = h_i(secondary.i,secondary.raan);

    K = cross(h_s,h_p); % There is another way to calculate this as well without cartesian info

    sin_I_R = norm(K);

    % Deltas, the angle between K and line and ascending node

    

%     delta_p = acos(cos_delta_i(primary.i,secondary.i,primary.raan,secondary.raan,sin_I_R));
%     if sin_delta_i(primary.i,secondary.i,primary.raan,secondary.raan,sin_I_R)<0; delta_p=2*pi - delta_p; end

    delta_s = acos(cos_delta_i(secondary.i,primary.i,secondary.raan,primary.raan,sin_I_R));
    if sin_delta_i(secondary.i,primary.i,primary.raan,secondary.raan,sin_I_R)<0 % Notice the sine input for RAAN!!
        delta_s=2*pi - delta_s;
    end
    
    %%
    Ip = primary.i;
Is = secondary.i;
Omp = primary.raan;
Oms = secondary.raan;
cos_deltaP = 1/sin_I_R * (sin(Ip)*cos(Is)-sin(Is)*cos(Ip)*cos(Omp-Oms));
sin_deltaP = 1/sin_I_R * (sin(Is)*sin(Omp-Oms));

cos_deltaS = 1/sin_I_R * (sin(Ip)*cos(Is)*cos(Omp-Oms)-sin(Is)*cos(Ip));
sin_deltaS = 1/sin_I_R * (sin(Ip)*sin(Omp - Oms));

delta_p = acos(cos_deltaP);
if sin_deltaP<0; delta_p=2*pi - delta_p; end

delta_s = acos(cos_deltaS);
if sin_deltaS<0; delta_s=2*pi - delta_s; end

%%
    d_delta_p = 1/sin_I_R * sin(secondary.i)*cos(delta_s)*(draan1 - draan2);
    
    T1_temp = 2*pi/(n1+dmean1+dom1-d_delta_p);
    % check the difference of period with and without d_delta_p

    %% Trial section (delete afterwards)


    %%
    
    i=i+2;
    t_list1(i:i+1,1:2) = t_list1(i-2:i-1,1:2) + T1_temp/86400 ; 

end

t_list1(i+2:end,:) = [];

% t_list for object 2

i=1;
while true
    if t_list2(i+1,2)>t_final
        break;
    end

    primary = TwoBP_J2_analytic(obj1,(t_list2(i,1)+t_list2(i+1,2))/2,'mjd2000');
    secondary = TwoBP_J2_analytic(obj2,(t_list2(i,1)+t_list2(i+1,2))/2,'mjd2000');
    

    h_p = h_i(primary.i,primary.raan);
    h_s = h_i(secondary.i,secondary.raan);

    K = cross(h_s,h_p); % There is another way to calculate this as well without cartesian info

    sin_I_R = norm(K);

    % Deltas, the angle between K and line and ascending node

    

    delta_p = acos(cos_delta_i(primary.i,secondary.i,primary.raan,secondary.raan,sin_I_R));
    if sin_delta_i(primary.i,secondary.i,primary.raan,secondary.raan,sin_I_R)<0; delta_p=2*pi - delta_p; end

%     delta_s = acos(cos_delta_i(secondary.i,primary.i,secondary.raan,primary.raan,sin_I_R));
%     if sin_delta_i(secondary.i,primary.i,primary.raan,secondary.raan,sin_I_R)<0 % Notice the sine input for RAAN!!
%         delta_s=2*pi - delta_s;
%     end
    

 %%
    Ip = primary.i;
Is = secondary.i;
Omp = primary.raan;
Oms = secondary.raan;
cos_deltaP = 1/sin_I_R * (sin(Ip)*cos(Is)-sin(Is)*cos(Ip)*cos(Omp-Oms));
sin_deltaP = 1/sin_I_R * (sin(Is)*sin(Omp-Oms));

cos_deltaS = 1/sin_I_R * (sin(Ip)*cos(Is)*cos(Omp-Oms)-sin(Is)*cos(Ip));
sin_deltaS = 1/sin_I_R * (sin(Ip)*sin(Omp - Oms));

delta_p = acos(cos_deltaP);
if sin_deltaP<0; delta_p=2*pi - delta_p; end

delta_s = acos(cos_deltaS);
if sin_deltaS<0; delta_s=2*pi - delta_s; end

%%


    d_delta_s = 1/sin_I_R * sin(primary.i)*cos(delta_p)*(draan1 - draan2);
    
    T2_temp = 2*pi/(n2+dmean2+dom2-d_delta_s);
    % check the difference of period with and without d_delta_p
    
    i=i+2;
    t_list2(i:i+1,1:2) = t_list2(i-2:i-1,1:2) + T2_temp/86400 ; 

end

t_list2(i+2:end,:) = [];
