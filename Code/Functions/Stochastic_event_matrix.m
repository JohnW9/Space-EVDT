
% Event matrix details:
% row1: Conjunction event ID number (in chronological order)
% row2: Time of Closest Approach (TCA) in [MJD2000]
% row3: Primary satellite NORAD ID
% row4: Secondary space object NORAD ID
% row5: Miss distance in [km]
% row6: Risk mitigation status (1 asserts the risk is mitigated, 0 asserts the risk is not mitigated)
% row7-12: Orbital elements of the Primary satellite at TCA in [a:km e:-- i:rad raan:rad aop:rad M:rad]
% row13-18: Orbital elements of the Secondary space object at TCA in [a:km e:-- i:rad raan:rad aop:rad M:rad]

% NEW OUTPUT WILL HAVE R and V instead of keplerian elements
function modified_event_matrix = Stochastic_event_matrix (event_matrix,scale,~)
% Conversion means converting cartesian elements to keplerian elements in
% the new modified event matrix
% Scale is logarithmic, from 0 and onwards, the higher the level, the lower
% the maximum miss distance

if nargin == 3
    conversion=1;
elseif nargin == 2
    conversion=0;
else
    scale=1;
    conversion=0;
end
modified_event_matrix=zeros(18,size(event_matrix,2));
for k=1:size(event_matrix,2)
    state_car1 = par2car([event_matrix(7:11,k);M2f(event_matrix(12,k),event_matrix(8,k))]);
    state_car2 = par2car([event_matrix(13:17,k);M2f(event_matrix(18,k),event_matrix(14,k))]);

    R = event_matrix(5,k);

    modified_state_car2=[state_car1(1:3);state_car2(4:6)]+(R/10^scale)/sqrt(3)*(2*[rand(3,1);zeros(3,1)]-[1;1;1;0;0;0]);

    R_new=norm(state_car1(1:3)-modified_state_car2(1:3));
    
    modified_event_matrix(1:6,k)=event_matrix(1:6,k);
    modified_event_matrix(5,k)=R_new;

    if conversion==1
        modified_event_matrix(7:18,k)=[state_car1;modified_state_car2];
    else
        modified_event_matrix(7:12,k)=event_matrix(7:12,k);
        state_kep2 = car2par(modified_state_car2);
        modified_event_matrix(13:18,k)=[state_kep2(1:5);f2M(state_kep2(6),state_kep2(2))];
    end
end

end