%%
% Nume si prenume: Groza Florin
%

clearvars
clc

%% Magic numbers (replace with received numbers)
m = 5; 
n = 5; 

%% Process data (fixed, do not modify)
c1 = (1000+n*300)/10000;
c2 = (1.15+2*(m+n/10)/20);
a1 = 2*c2*c1;
a2 = c1;
b0 = (1.2+m+n)/5.5;

rng(m+10*n)
x0_slx = [2*(m/2+rand(1)*m/5); m*(n/20+rand(1)*n/100)];

%% Experiment setup (fixed, do not modify)
Ts = 10*c2/c1/1e4*1.5; % fundamental step size
Tfin = 30*c2/c1;

gain = 10;
umin = 0; umax = gain; % input saturation
ymin = 0; ymax = b0*gain/1.5; % output saturation

whtn_pow_in = 1e-6*5*(((m-1)*8+n/2)/5)/2*6/8; % input white noise power and sampling time
whtn_Ts_in = Ts*3;
whtn_seed_in = 23341+m+2*n;
q_in = (umax-umin)/pow2(10); % input quantizer (DAC)

whtn_pow_out = 1e-5*5*(((m-1)*25+n/2)/5)*6/80*(0.5+0.3*(m-2)); % output white noise power and sampling time
whtn_Ts_out = Ts*5;
whtn_seed_out = 23342-m-2*n;
q_out = (ymax-ymin)/pow2(9); % output quantizer (ADC)

u_op_region = (m/2+n/5)/2; % operating point

%% Input setup (can be changed/replaced/deleted)
u0 = 0;        % fixed
ust = 3;       % must be modified (saturation)
t1 = 10*c2/c1; % recommended 


%% Data acquisition (use t, u, y to perform system identification)
out = sim("dynamic_system");
t = out.tout;
u = out.u;
y = out.y;
plot(t,u,t,y)
shg

%% System identification: Proportionality Constant (K)

% Manually selected indices for steady-state regions to filter out noise
% i1 to i2: Initial steady-state before the step input 
% i3 to i4: Final steady-state after the step input 
i1 = 5485;
i2 = 6080;
i3 = 12511;
i4 = 12942;

% Calculate average input and output values for the steady-state regions
u0 = mean(u(i1:i2));
ust = mean(u(i3:i4));
y0 = mean(y(i1:i2));
yst = mean(y(i3:i4));

% Calculate the system gain (K = delta_y / delta_u)
k = (yst-y0)/(ust-u0)
%% System identification: Dominant Time Constant (T1)
% Select indices during the transient response where the logarithm 
% of the output is approximately linear.

i5 = 6820;
i6 = 8925;

t_reg = t(i5:i6);
y_reg = log(yst-y(i5:i6));% Logarithmic transformation of the output

figure
plot(t_reg,y_reg)
title('Linear Regression for T1')

% Perform linear regression (Least Squares method) to find the slope
Areg = [sum(t_reg.^2),sum(t_reg);
    sum(t_reg), length(t_reg )];
Breg = [sum(y_reg.*t_reg);sum(y_reg)];
theta = inv(Areg)*Breg

% T1 is the negative reciprocal of the slope extracted from regression
T1 = -1/theta(1)

%% System identification: Non-dominant Time Constant (T2)
i7 = 10090;
i8 = 10445;

Ti = t(i8)-t(i7); %Time to inflection point

% Define a vector to plot the transcendental equation for T2
T2vec = 0.1:0.1:10;
Y_ecuatie = T1*T2vec.*log(T2vec)-T2vec*(Ti+T1*log(T1))+T1*Ti;

figure
plot(T2vec,Y_ecuatie)
grid on
title('Graphical Solution for T2')

% The value for T2 is chosen by finding the root of the equation (where Y = 0)
% Note: A visual approximation is used here
T2 = 1.3;


%% VALIDATION
% Build the identified Transfer Function
H = tf(k,[T1*T2,T1+T2,1])
ysim = lsim(H,u,t);% Simulate system response with zero initial conditions

figure
plot(t,u,t,y,t,ysim)
title('Model Validation - Initial Transfer Function')
legend('Input (u)', 'Measured Output (y)', 'Simulated Output (ysim)')

%% Fine-Tuning and State-Space Validation
% Applying minor manual corrections to parameters to minimize validation error
k = 2.03;
T1 = 12.3;

% Define the State-Space model matrices based on identified parameters
A = [0,1;-1/T1/T2,-(1/T1+1/T2)];
B = [0;k/T1/T2]
C = [1,0];
D = 0;
sys = ss(A,B,C,D)

% Simulate system response with non-zero initial conditions
ysim2 = lsim(sys,u,t,[y(1),2.5]);

figure
plot(t,u, t,y, t,ysim2)
title('Final Model Validation - State-Space')
legend('Input (u)', 'Measured Output (y)', 'Simulated Output (ysim2)')


% Calculate performance metrics 
J = 1/sqrt(length(t1))*norm(y-ysim2) % Mean Square Error
eMPN = norm(y-ysim2)/norm((y-mean(y))) % Normalized Mean Square Error (Target: < 10%)



