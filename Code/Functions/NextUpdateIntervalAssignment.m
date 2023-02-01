function event_detection = NextUpdateIntervalAssignment (event_detection,t)

global config;
randomer = @(a,b) a+(b-a)*rand([1 1]);
for i = size(event_detection,2):-1:1
    
    if ~isnan(event_detection(7,i))
        continue;
    end

    if event_detection(8,i)==1
        a=0.5*config.commercial_SSA_updateInterval;
        b=1.5*config.commercial_SSA_updateInterval;
        event_detection(7,i) = t + randomer(a,b);
    else
        a=0.5*config.government_SSA_updateInterval;
        b=1.5*config.government_SSA_updateInterval;
        event_detection(7,i) = t + randomer(a,b);
    end
end
