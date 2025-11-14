clear; clc; close all;

%% =======================
%  Cargamos los datos
%  =======================
try
    load("data.mat");
    config.exp_data = DataExp;
catch
    error('Error: no se encontró el archivo mencionado');
end

%% =======================
%  Definición de parámetros base 
%  =======================
config.base_params.umax   = 0.3;      % [1/h]
config.base_params.ks     = 21;       % [g/L]
config.base_params.i      = 0.00005;  % [1/h]
config.base_params.s_bar  = 65;       % [g/L]
config.base_params.pxmax  = 86.9;     % [g/L]
config.base_params.qmax   = 4.8;      % [g_P/(g_X·h)]
config.base_params.ksp    = 240;      % [g/L]
config.base_params.ppmax  = 1160.8;    % [g/L]
config.base_params.yxs    = 0.44;     % [g_X/g_S]
config.base_params.yps    = 0.53;     % [g_P/g_S]
config.base_params.m      = 0.0;      % [g_S/(g_X·h)]

%% =======================
%  Condiciones iniciales
%  =======================
config.init_cond = [DataExp(1,2); DataExp(1,3); DataExp(1,4)];

%% =======================
%  Configuración de optimización
%  =======================
n_par = 8;
lb = ones(1,n_par) * 0.1;
ub = ones(1,n_par) * 2.0;
f_obj = @(optim_vars) obj_func(optim_vars, config);

execute_optim = true;
if execute_optim
    [x_opt,fval] = setup_run_ga(f_obj, n_par, lb, ub);
    save('optimal_parameters.mat','x_opt','fval');
else
    load('optimal_parameters.mat','x_opt','fval');
end

params_opt = map_parameters(x_opt, config.base_params);

%% =======================
%  Simulación del modelo
%  =======================
t_span_val = [0, max(config.exp_data(:,1))];
[t_sim,c_sim] = simula_batch(params_opt, config.init_cond, t_span_val);

x_sim = c_sim(:,1);
s_sim = c_sim(:,2);
p_sim = c_sim(:,3);

t_exp = config.exp_data(:,1);
x_exp = config.exp_data(:,2);
s_exp = config.exp_data(:,3);
p_exp = config.exp_data(:,4);


%% =======================
%  Estadísticos
%  =======================
stats = calc_stat(t_sim, c_sim, config.exp_data);
fprintf('R2 BIOMASA: %.4f\n', stats.R2_x);
fprintf('R2 SUSTRATO: %.4f\n', stats.R2_s);
fprintf('R2 PRODUCTO: %.4f\n', stats.R2_p);

set(0, 'DefaultFigureVisible', 'on'); % Fuerza que se muestre
figure('Name','Validacion modelo vs datos exp', 'Color', 'w');

subplot(2,2,1)
plot(t_sim,x_sim,'b-','LineWidth',2); hold on
plot(t_exp,x_exp,'ro','MarkerFaceColor','r')
title('Biomasa (X)'); ylabel('X (g/L)'); grid on

subplot(2,2,2)
plot(t_sim,s_sim,'b-','LineWidth',2); hold on
plot(t_exp,s_exp,'ro','MarkerFaceColor','r')
title('Sustrato (S)'); ylabel('S (g/L)'); grid on

subplot(2,2,3)
plot(t_sim,p_sim,'b-','LineWidth',2); hold on
plot(t_exp,p_exp,'ro','MarkerFaceColor','r')
title('Producto (P)'); ylabel('P (g/L)'); grid on

sgtitle('Comparación modelo óptimo vs Datos experimentales', 'Fontsize',14,'FontWeight',"bold");

saveas(gcf, 'validacion_modelo_vs_datos.png');

