% RBC Model with Indivisible Labor (Eric Sims, 2017)
% Calibration and 9-equation system

% Endogenous variables
var C N K Y w R r A I;

% Exogenous variables
varexo e;

% Parameters
parameters alpha beta delta B rho;

% Calibration (Eric Sims' values)
alpha = 0.33;       % Capital share
beta = 0.99;        % Discount factor
delta = 0.025;      % Depreciation rate
rho = 0.95;         % Persistence of technology shock

% Steady-state calculations
% 1. Compute K/N ratio from Euler equation (eq. 15)
K_over_N_steady = (alpha / (1/beta - (1 - delta)))^(1/(1 - alpha));

% 2. Compute B (eq. 18)
B = ( (1 - alpha) * (K_over_N_steady)^alpha ) / ( (1/3) * ( (K_over_N_steady)^alpha - delta * K_over_N_steady ) );

% Model equations (nonlinear system)
model;
    % (6) Euler equation (capital)
    1/C = beta * (1/C(+1)) * (R(+1) + (1 - delta));

    % (7) Euler equation (bonds)
    1/C = beta * (1/C(+1)) * (1 + r);

    % (8) Labor supply
    B = w / C;

    % (9) Wage (from firm FOC)
    w = (1 - alpha) * A * K(-1)^alpha * N^(-alpha);

    % (10) Rental rate (from firm FOC)
    R = alpha * A * K(-1)^(alpha - 1) * N^(1 - alpha);

    % (11) Capital accumulation
    K = (1 - delta) * K(-1) + I;

    % (12) Resource constraint
    Y = C + I;

    % (13) Production function
    Y = A * K(-1)^alpha * N^(1 - alpha);

    % (14) Technology shock (AR(1))
    log(A) = rho * log(A(-1)) + e;
end;

% Steady-state computations
steady_state_model;
    % Target N_star = 1/3 (calibration)
    N = 1/3;

    % K/N ratio (from Euler equation)
    K_over_N = (alpha / (1/beta - (1 - delta)))^(1/(1 - alpha));

    % Steady-state capital
    K = K_over_N * N;

    % Production function
    Y = K^alpha * N^(1 - alpha);

    % Resource constraint
    I = delta * K;
    C = Y - I;

    % Factor prices
    w = (1 - alpha) * K^alpha * N^(-alpha);
    R = alpha * K^(alpha - 1) * N^(1 - alpha);

    % Interest rate (from bonds Euler)
    r = (1 / beta) - 1;

    % Technology (normalized)
    A = 1;

    % Verify B (should be ~2.63)
    B = w / C;
end;

% Shocks
shocks;
    var e = 0.01^2; % Variance of tech shock (1% std. dev.)
end;

% Solve the model
steady;
check;

% Impulse responses (40 periods)
stoch_simul(irf=40) Y C I N w R r A;