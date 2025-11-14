function dCdt = model_equations(t, c, params)
    % Variables
    x = c(1); s = c(2); p = c(3);

    % --- Ecuación (15): crecimiento ---
    dxdt = ((params.umax * s / (params.ks + s)) ...
          - params.i * (s - params.s_bar)) ...
          * (1 - p / params.pxmax) * x;

    % --- Ecuación (16): formación de producto ---
    dpdt = ((params.qmax * s / (params.ksp + s)) ...
          * (1 - p / params.ppmax)) * x;

    % --- Ecuación (17): consumo de sustrato ---
    dsdt = - (1/params.yxs * dxdt + 1/params.yps * dpdt + params.m * x);

    % Vector de salida
    dCdt = [dxdt; dsdt; dpdt];
end