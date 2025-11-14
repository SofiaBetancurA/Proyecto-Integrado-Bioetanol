
function stats = calc_stat(t_model, c_model, exp_data)
    t_exp = exp_data(:,1);
    x_exp = exp_data(:,2);
    s_exp = exp_data(:,3);
    p_exp = exp_data(:,4);

    x_pred = interp1(t_model, c_model(:,1), t_exp);
    s_pred = interp1(t_model, c_model(:,2), t_exp);
    p_pred = interp1(t_model, c_model(:,3), t_exp);

    stats.R2_x = 1 - sum((x_exp - x_pred).^2) / sum((x_exp - mean(x_exp)).^2);
    stats.R2_s = 1 - sum((s_exp - s_pred).^2) / sum((s_exp - mean(s_exp)).^2);
    stats.R2_p = 1 - sum((p_exp - p_pred).^2) / sum((p_exp - mean(p_exp)).^2);
end