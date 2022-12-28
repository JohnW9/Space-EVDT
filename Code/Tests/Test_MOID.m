%% Test MOID

addpath('..\Functions\');
addpath('..\Data\');
addpath('..\Time_conversion\');


clc;
clear;

obj1=Space_object;
obj2=Space_object;
AU=astroConstants(2); 

q1=2.036; %[au]
e1=0.164;


obj1.a= AU*q1/(1-e1);
obj1.e=e1;
obj1.i=0;
obj1.raan=0;
obj1.om=deg2rad(250.227);
obj1.M=0;


casenum=6;

switch casenum
    case 1
        q2=2.55343183;
        e2=0.0777898;
        i2=10.58785;
        raan2=80.35052;
        om2=72.14554;
        expected_result=0.13455874348909; %[au]
    case 6
        q2=2.48391159;
        e2=0.9543470;
        i2=119.29902;
        raan2=39.00301;
        om2=357.90012;
        expected_result=0.26938418933051; %[au]
    case 11
        q2=2.74144856;
        e2=0.1153501;
        i2=0.00431;
        raan2=272.90217;
        om2=251.43828;
        expected_result=0.14766834758223; %[au]
    case 16 % These two don't work for some reason
        q2=1.99601821;
        e2=0.1875129;
        i2=1.26622;
        raan2=238.06043;
        om2=31.32645;
        expected_result=0.00000003815330; %[au]
    case 17 % These two don't work for some reason
        q2=2.03086844;
        e2=0.1653922;
        i2=0.66023;
        raan2=339.21518;
        om2=89.47548;
        expected_result=0.00000419348257; %[au]
    case 19
        q2=1.96745453;
        e2=0.1837814;
        i2=3.69269;
        raan2=98.95749;
        om2=227.52626;
        expected_result=0.00000785853673;
    case 20
        q2=2.15731280;
        e2=0.1007470;
        i2=2.91058;
        raan2=138.77805;
        om2=231.93187;
        expected_result=0.00001189165231; %[au]
end


obj2.a= AU*q2/(1-e2);
obj2.e=e2;
obj2.i=deg2rad(i2);
obj2.raan=deg2rad(raan2);
obj2.om=deg2rad(om2);
obj2.M=0;

moid = MOID_numerical (obj1, obj2);
method_result=moid/AU;
error=abs((method_result-expected_result))*astroConstants(2) %[km]
