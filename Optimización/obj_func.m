function error = obj_func(optim_vars, config)
    params = map_parameters(optim_vars, config.base_params);
    t_span = [0, max(config.exp_data(:,1))];
    [t_model, c_model] = simula_batch(params, config.init_cond, t_span);

    t_exp = config.exp_data(:,1);
    x_exp = config.exp_data(:,2);
    s_exp = config.exp_data(:,3);
    p_exp = config.exp_data(:,4);

    if length(t_model) > 1
        x_pred = interp1(t_model, c_model(:,1), t_exp);
        s_pred = interp1(t_model, c_model(:,2), t_exp);
        p_pred = interp1(t_model, c_model(:,3), t_exp);
    else
        error = 1e8;
        return
    end

    err_x = sum(((x_exp - x_pred)./max(x_exp)).^2);
    err_s = sum(((s_exp - s_pred)./max(s_exp)).^2);
    err_p = sum(((p_exp - p_pred)./max(p_exp)).^2);

    error = 10*(err_x/length(x_exp)) + (err_s/length(s_exp)) + (err_p/length(p_exp));

    if ~isreal(error) || isnan(error) || isinf(error)
        error = 1e6;
    end
end