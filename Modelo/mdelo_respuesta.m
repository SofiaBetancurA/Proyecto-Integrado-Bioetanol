clear; clc; close all;

%% PARÁMETROS CINÉTICOS
mu_m = 0.30; Ks = 21; i = 5e-5; S_star = 65; P_Xm = 86.9;
q_m = 4.8; Ksp = 240; Pm = 116.8;
Yxs = 0.44; Yps = 0.53; m = 0;

%% PARÁMETROS TÉRMICOS 
rho = 1000; cp = 4.18; V = 1;
Rc = rho*cp*V;              % [J/K]
tauT_target_h = 5;          % constante térmica objetivo [h]
UA = Rc / tauT_target_h;    % [J/(h·K)]
k = UA / Rc;                % [1/h]
betaX = 200; betaP = 50;    % [J/(g·h)]

%% FACTOR TÉRMICO 
Topt = 30; sigmaT = 5; T0 = 30;
fT = @(T) exp(-((T - Topt)/sigmaT).^2);
dfT = @(T) fT(T)*(-2*(T - Topt)/sigmaT^2);

%% FUNCIONES BASE 
mu_base = @(S,P) (mu_m*S./(Ks+S) - i*(S - S_star)).*(1 - P/P_Xm);
q_base = @(S,P) (q_m*S./(Ksp+S)).*(1 - P/Pm);
mu_Tfac = @(S,P,T) mu_base(S,P).*fT(T);
q_Tfac = @(S,P,T) q_base(S,P).*fT(T);

%% PUNTOS
eps_mu = 3e-3; eps_q = 3e-3;
x0 = [20; 0.98*min(P_Xm,Pm)];
fun = @(x) [ mu_Tfac(x(1),x(2),T0) + eps_mu;
             q_Tfac(x(1),x(2),T0) + eps_q ];
[xsol, ~] = fminsearch(@(x) norm(fun(x))^2, x0, optimset('Display','off'));
S0 = max(xsol(1),1e-6); P0 = max(xsol(2),1e-6);
X0 = 8; 
mu0 = mu_Tfac(S0,P0,T0);
q0 = q_Tfac(S0,P0,T0);
fprintf('Puntos: S0=%.2f P0=%.2f mu0=%.4f q0=%.4f [1/h]\n',S0,P0,mu0,q0);

%% DERIVADAS PARCIALES
dmu_dS_base = @(S,P) (mu_m*Ks/(Ks+S)^2 - i).*(1 - P/P_Xm);
dmu_dP_base = @(S,P) -(mu_m*S/(Ks+S) - i*(S - S_star))/P_Xm;
dq_dS_base = @(S,P) (q_m*Ksp/(Ksp+S)^2).*(1 - P/Pm);
dq_dP_base = @(S,P) -(q_m*S/(Ksp+S))/Pm;
fT0 = fT(T0); dfT0 = dfT(T0);
mu_S = dmu_dS_base(S0,P0)*fT0;
mu_P = dmu_dP_base(S0,P0)*fT0;
mu_T = mu_base(S0,P0)*dfT0;
q_S = dq_dS_base(S0,P0)*fT0;
q_P = dq_dP_base(S0,P0)*fT0;
q_T = q_base(S0,P0)*dfT0;

%% BALANCE DE ENERGÍA 
Q_X = betaX*mu0 + betaP*q0;
Q_S = 0; Q_P = 0;
Q_T = betaX*mu_T*X0 + betaP*q_T*X0;

%% MATRICES LINEALIZADAS (estados: X,S,P,T ; entrada: delta Tj) 
A = [ ...
    mu0, X0*mu_S, X0*mu_P, X0*mu_T;
    q0, X0*q_S, X0*q_P, X0*q_T;
    -(mu0/Yxs + q0/Yps + m), -X0*(mu_S/Yxs + q_S/Yps), -X0*(mu_P/Yxs + q_P/Yps), -X0*(mu_T/Yxs + q_T/Yps);
    Q_X/Rc, Q_S/Rc, Q_P/Rc, -k + Q_T/Rc ];

B = [0; 0; 0; k];    % Entrada: ΔTj
C = [0 0 0 1];       % Salida: ΔT
D = 0;


%% SIMULACIÓN DEL ESCALÓN
t = linspace(0, 64, 1000);     % tiempo [h]
Tj_inicial = 30;               % [°C]
Tj_final = 35;                 % [°C]
delta_Tj = Tj_final - Tj_inicial;

% Crear señal escalón que ocurre en t = 20 h
u = zeros(size(t));
u(t >= 20) = 1;                % escalón unitario desde t=20
u = u * delta_Tj;              % amplitud de 5 °C

% Simulación con lsim (entrada escalón desplazado)
sysT = ss(A,B,C,D);
[yT, t_out] = lsim(sysT, u, t);

% Temperatura total = T_inicial + respuesta
T_reactor = Tj_inicial + yT;

%% GRÁFICAS
figure;

% Escalón en Tj
subplot(2,1,1);
plot(t, Tj_inicial + u, 'r', 'LineWidth',1.8); hold on;
yline(Tj_inicial, 'k--', 'LineWidth',1.2);
ylabel('T_j [°C]');
title('Escalón en la temperatura de la chaqueta (T_j)');
legend('Escalón aplicado (30-35 °C)', 'Nivel inicial', 'Location','Best');
xlim([0 35]); grid on;

% Respuesta del reactor
subplot(2,1,2);
plot(t_out, T_reactor, 'b', 'LineWidth',1.8);
ylabel('Temperatura del reactor T [°C]');
xlabel('Tiempo [h]');
title('Respuesta en lazo abierto: variación de T ante escalón en T_j ');
xlim([0 35]); grid on;
