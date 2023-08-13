function obj_car = prop_car (obj,t)
par_obj = TwoBP_J2_analytic(obj,t,'mjd2000');
par_obj.f = M2f(par_obj.M, par_obj.e);
obj_car = par2car([par_obj.a par_obj.e par_obj.i par_obj.raan par_obj.om par_obj.f]);
