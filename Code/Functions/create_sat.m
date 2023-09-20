function [nasa_sat,space_object]=create_sat(cell_array)

%cell_array = {'SinaSat1',[2,2],100,1000,date2mjd2000([2023 1 1 0 0 0]),[10000,0,deg2rad(10),deg2rad(100),deg2rad(200),0],'PAYLOAD','MEDIUM',10};

nasa_sat = NASA_sat;
space_object = Space_object;

nasa_sat.name=cell_array{1};
nasa_sat.dimensions=cell_array{2};
nasa_sat.mass=cell_array{3};   
nasa_sat.cost=cell_array{4};
nasa_sat.value=cell_array{9};

space_object.name = cell_array{1};
space_object.epoch = cell_array{5};

elements = cell_array{6};

space_object.a =elements(1);
space_object.e =elements(2);
space_object.i =elements(3);
space_object.raan =elements(4);
space_object.om =elements(5);
space_object.M =elements(6);

space_object.type = cell_array{7};
space_object.RCS = cell_array{8};
space_object.value = cell_array{9};
