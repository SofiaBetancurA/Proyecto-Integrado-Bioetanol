function [t,c] = simula_batch(params, c0, t_span)
    options = odeset('RelTol',1e-6,'AbsTol',1e-6,'NonNegative',[1,2,3]);
    f_model = @(t,c) model_equations(t, c, params);
    [t, c] = ode15s(f_model, t_span, c0, options);
end
