function params = map_parameters(optim_vars, base_params)
    params.umax  = base_params.umax * optim_vars(1);
    params.ks    = base_params.ks * optim_vars(2);
    params.i     = base_params.i * optim_vars(3);
    params.s_bar = base_params.s_bar * optim_vars(4);
    params.pxmax = base_params.pxmax * optim_vars(5);
    params.qmax  = base_params.qmax * optim_vars(6);
    params.ksp   = base_params.ksp * optim_vars(7);
    params.ppmax = base_params.ppmax * optim_vars(8);
    params.yxs   = base_params.yxs;
    params.yps   = base_params.yps;
    params.m     = base_params.m;
end
