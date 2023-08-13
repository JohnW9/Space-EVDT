clc;
clear;
close all;

n = 100;

cell_mat = cell(n,1);

parfor i=1:n
    temp = Conjunction_event;
    for j = 1:randi(10)
        temp(j).id = randi(1000);
    end
    cell_mat{i} = temp;
end