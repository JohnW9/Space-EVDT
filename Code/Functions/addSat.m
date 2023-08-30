function [eos,space_cat] = addSat (nasa_sat,space_object,space_cat,eos)

norad_id = space_cat(end).id + 1;
nasa_sat.id = norad_id;
space_object.id = norad_id;
try
    eos(end+1) = nasa_sat;
catch
    eos = nasa_sat;
end

space_cat(end+1) = space_object;

