% Project Name: Macroeconomics PS 8

% Created Date: 2023/11/27

% Author: Dan Song (Daisy)

% Functions: None

% Update Date:

% Update Changes:


%% Problem 8
clear all;
close all;

% set constant 
xgrid = 1000;
tol = 1e-10;
maxits = 1000;

% set parameter
beta = 0.95;
R = 1.05;
theta = 0.25;
a_0 = 0;
y_0 = 1/4;
p = 3/10;
ymax = 1;
ymin = 1/4;

% set initial guess
E_y = ymin * p + ymax *(1-p);
xmin = ymin;
xmax = R/(R-1) * ymax ; 
xmat = linspace(xmin,xmax,xgrid);
xmat = xmat';
[N,n] = size(xmat);
x_0 = a_0 + y_0;
f_0 = (1 - R^(-1)*((beta*R)^(1/theta))).*(xmat + E_y/(R-1));

% set loops
its = 0;
dif = tol + 10000;
f_old = f_0;
f_new = zeros(N,n);

while dif > tol & its < maxits

    for i = 1:N
        x_lower = R.*(xmat(i) - f_old(i)) + ymin;
        x_upper = R.*(xmat(i) - f_old(i)) + ymax;
        f_lower = interp1(xmat,f_old,x_lower,'linear','extrap'); 
        f_upper = interp1(xmat,f_old,x_upper,'linear','extrap'); 
        u_lower = f_lower.^(-theta);
        u_upper = f_upper.^(-theta);
        u_expect = p .* u_lower + (1-p) .* u_upper;
        f_expect = (beta * R .* u_expect).^(-1/theta);

        f = min(f_expect,xmat(i));
        f_new(i) = f;
    end 

    dif = abs(max(f_new - f_old));
    f_old = f_new;
    its = its + 1;

end 

if its == maxits
    fprintf("Failed to find the policy function of consumption \n");
else
    fprintf("Succeed finding the policy function of consumption \n");
    formatSpec = "The number of iteration is %d. \n";
    fprintf(formatSpec,its);
end

%% Problem 9
% I choose the minimum as ymin because x_t needs to be larger than c_t, the
% minimum value of c_t should be zero, therefore ymin is an ideal lower bound.
% I choose the maximum as R/(R-1) * ymax because the optimum x_t will not
% exceed the value when consumtion is the highest and income is zero in the
% equilibrium that x_t+1 = x_t

%% Problem 10

% define asset sequence
asset = R.*(xmat-f_new); 
asset_PIH = R.*(xmat-f_0); 

% define x*
for i = 1:N
    if f_new(i) == xmat(i);
        x_star = xmat(i);
    end
end 

% plot consumption
figure(1)
plot(xmat,f_new,xmat,f_0);
x_star_line = xline(x_star,'--r','x^{*}','Interpreter', 'tex');
x_star_line .LabelOrientation = 'horizontal';
legend('Buffer Stock','E-PIH','x^{*}','Interpreter', 'tex');
legend('Location', 'southeast');
xlabel('cash-on-hand, x_{t}','Interpreter', 'tex')
ylabel('consumption, c_{t}','Interpreter', 'tex')

% plot asset
figure(2)
plot(xmat,asset,xmat,asset_PIH);
x_star_line  = xline(x_star,'--r','x^{*}');
x_star_line .LabelOrientation = 'horizontal';
legend('assest','assest_PIH','x^{*}','Interpreter', 'tex');
legend('Location', 'southeast');
xlabel('cash-on-hand, x_{t}','Interpreter', 'tex')
ylabel('asset, a_{t+1}','Interpreter', 'tex')
xlim([0,25]);
%% Problem 11

% initialize setting
t = 1000;
a_t = zeros(t,n);
x_t = zeros(t,n);
c_t = zeros(t,n);

% generate stochastic process of y
y_t = binornd(1,p,t,n);
for i =1:t
    if y_t(i) == 1
        y_t(i) = ymin;
    else 
        y_t(i) = ymax;
    end
end

% set initial values
a_t(1) = a_0;
x_t(1) = x_0;
y_t(1) = y_0;

% generate a,x,t accroding to budget constraint
for i = 2:t 
    a_t(i) = R * (x_t(i-1)-c_t(i - 1));
    x_t(i) = a_t(i) + y_t(i);
    c_t(i) = interp1(xmat, f_new, x_t(i),'linear','extrap');
end

% define horizontal axis
x_axis = 1:t;

% plot consumption
figure(3)
plot(x_axis,c_t)
xlabel('t')
ylabel('c_{t}')

% plot assets
figure(4)
plot(x_axis,a_t)
xlabel('t')
ylabel(' a_{t}')

%% Problem 12

% set band
lower_band = 2.5;
upper_band = 97.5;

% initialize setting
t = 1000;
n_mc = 5000;
a_t_mc = zeros(t,n_mc);
x_t_mc = zeros(t,n_mc);
c_t_mc = zeros(t,n_mc);

% generate stochastic process of y
y_t_mc = binornd(1,p,t,n_mc);
for j = 1:n_mc
    for i = 1:t
        if y_t_mc(i,j) == 1
            y_t_mc(i,j) = ymin;
        else 
            y_t_mc(i,j) = ymax;
        end
    end
end

% set initial values
a_t_mc(1,:) = a_0;
x_t_mc(1,:) = x_0;
y_t_mc(1,:) = y_0;

% generate a,x,t accroding to budget constraint
for i = 2:t 
    a_t_mc(i,:) = R * (x_t_mc(i-1,:) - c_t_mc(i - 1,:));
    x_t_mc(i,:) = a_t_mc(i,:) + y_t_mc(i,:);
    c_t_mc(i,:) = interp1(xmat, f_new, x_t_mc(i,:),'linear','extrap');
end

% define horizontal axis
x_axis = 1:t;

% confidence band
c_t_lower = prctile(c_t_mc,lower_band,2);
c_t_med = prctile(c_t_mc,50,2);
c_t_upper = prctile(c_t_mc,upper_band,2);

% Plot confidence band, consumption
figure(5)
plot(x_axis,c_t_lower,'r',x_axis,c_t_med,'b',x_axis,c_t_upper,'k')
xlabel('t')
title('c_t', 'Interpreter', 'tex');
xlabel('Time');
legend('Monte-Carlo 97.5% Bands', 'Median','Monte-Carlo 2.5% Bands');
legend('Location', 'southeast');


%% Problem 13
% According to the hint in the problem set, we can know that x_ss is just limitation of the expectation of x_t with t going to infinity. Therefore, in the code we can compute the mean of x_t across the Monte-Carlo samples.
x_t_mean = mean(x_t_mc,2); 
x_ss = mean(x_t_mean(t-100,end));

%% Problem 14

% plot x_ss on to the figure 1
figure(6)
plot(xmat,f_new,xmat,f_0);
x_star_line = xline(x_star,'--r','x^{*}','Interpreter', 'tex');
x_star_line .LabelOrientation = 'horizontal';
x_ss_line = xline(x_ss,'--b','x^{**}','Interpreter', 'tex');
x_ss_line .LabelOrientation = 'horizontal';
legend('Buffer Stock','E-PIH','x^{*}','Interpreter', 'tex');
legend('Location', 'southeast');
xlabel('cash-on-hand, x_{t}','Interpreter', 'tex')
ylabel('consumption, c_{t}','Interpreter', 'tex')
xlim([0,25]);

%% Problem 15

% initialize setting
t = 1000;
n_mc = 10000;
x_t_g = zeros(t,n_mc);
c_t_g = zeros(t,n_mc);

% generate stochastic process of y
y_t_g = binornd(1,p,1,n_mc);
for i =1:n_mc
    if y_t_g(i) == 1
        y_t_g(i) = ymin;
    else 
        y_t_g(i) = ymax;
    end
end

% generate x,c accroding to budget constraint
for i = 1:N 
    x_t_g(i,:) = R * (xmat(i) - f_new(i)) + y_t_g;
    c_t_g(i,:) = interp1(xmat, f_new, x_t_g(i,:),'linear','extrap');
end

% calculate growth rate
c_growth = log(c_t_g)-log(f_new);

% calculate variance and mean
c_var = var(c_growth,1,2);

% Plot Var(log(c_{t+1}))
figure(7)
plot(xmat,c_var);
x_star_line = xline(x_star,'--r','x^{*}','Interpreter', 'tex');
x_star_line .LabelOrientation = 'horizontal';
x_ss_line = xline(x_ss,'--b','x^{**}','Interpreter', 'tex');
x_ss_line .LabelOrientation = 'horizontal';
legend('buffer Stock','E-PIH','x^{*}','Interpreter', 'tex');
legend('Location', 'southeast');
xlabel('cash-on-hand x_{t}')
ylabel('variance of growth of c_{t})','Interpreter', 'tex')
xlim([0,25]);


%% Problem 16 

% set constant 
xgrid = 1000;
tol = 1e-10;
maxits = 1000;

% different theta
c_plot = zeros(length(theta),xgrid);
a_plot = zeros(length(theta),xgrid);

for iter = 1:length(theta_list)
    
    % set parameter
    beta = 0.95;
    R = 1.05;
    theta = theta_list(iter);
    a_0 = 0;
    y_0 = 1/4;
    p = 3/10;
    ymax = 1;
    ymin = 1/4;
    
    % set initial guess
    E_y = ymin * p + ymax *(1-p);
    xmin = ymin;
    xmax = R/(R-1) * ymax ; 
    xmat = linspace(xmin,xmax,xgrid);
    xmat = xmat';
    [N,n] = size(xmat);
    x_0 = a_0 + y_0;
    f_0 = (1 - R^(-1)*((beta*R)^(1/theta))).*(xmat + E_y/(R-1));
    
    % set loops
    its = 0;
    dif = tol + 10000;
    f_old = f_0;
    f_new = zeros(N,n);
    
    while dif > tol & its < maxits
    
        for i = 1:N
            x_lower = R.*(xmat(i) - f_old(i)) + ymin;
            x_upper = R.*(xmat(i) - f_old(i)) + ymax;
            f_lower = interp1(xmat,f_old,x_lower,'linear','extrap'); 
            f_upper = interp1(xmat,f_old,x_upper,'linear','extrap'); 
            u_lower = f_lower.^(-theta);
            u_upper = f_upper.^(-theta);
            u_expect = p .* u_lower + (1-p) .* u_upper;
            f_expect = (beta * R .* u_expect).^(-1/theta);
    
            f = min(f_expect,xmat(i));
            f_new(i) = f;
        end 
    
        dif = abs(max(f_new - f_old));
        f_old = f_new;
        its = its + 1;
    
    end 
    
    if its == maxits
        fprintf("Failed to find the policy function of consumption \n");
    else
        fprintf("Succeed finding the policy function of consumption \n");
        formatSpec = "The number of iteration is %d. \n";
        fprintf(formatSpec,its);
    end  
    
    c_plot(iter,:) = f_new;
    a_plot(iter,:) = R.*(xmat - f_new);

end 


% plot consumption
figure(8)
hold on
for i = 1:length(theta_list)
    plot(xmat,c_plot(i,:));
end
hold off
legend(string(theta_list))
xlabel('cash-on-hand, x_{t}')
ylabel('consumption, c_{t}')
title ('consumption function, different \theta calibrations')

figure(9)
hold on
for i = 1:length(theta_list)
    plot(xmat,a_plot(i,:));
end
hold off
legend(string(theta_list))
xlabel('cash-on-hand, x_{t}')
ylabel('consumption, c_{t}')
title ('consumption function, different \theta calibrations')

%% Problem 16

% different R
R_list = linspace(1.01,1.05,10);
c_plot = zeros(length(theta),xgrid);
a_plot = zeros(length(theta),xgrid);

% set constant 
xgrid = 1000;
tol = 1e-10;
maxits = 1000;

for iter = 1:length(R_list)
    
    % set parameter
    beta = 0.95;
    R = R_list(iter);
    theta = 0.25;
    a_0 = 0;
    y_0 = 1/4;
    p = 3/10;
    ymax = 1;
    ymin = 1/4;
    
    % set initial guess
    E_y = ymin * p + ymax *(1-p);
    xmin = ymin;
    xmax = R/(R-1) * ymax ; 
    xmat = linspace(xmin,xmax,xgrid);
    xmat = xmat';
    [N,n] = size(xmat);
    x_0 = a_0 + y_0;
    f_0 = (1 - R^(-1)*((beta*R)^(1/theta))).*(xmat + E_y/(R-1));
    
    % set loops
    its = 0;
    dif = tol + 10000;
    f_old = f_0;
    f_new = zeros(N,n);
    
    while dif > tol & its < maxits
    
        for i = 1:N
            x_lower = R.*(xmat(i) - f_old(i)) + ymin;
            x_upper = R.*(xmat(i) - f_old(i)) + ymax;
            f_lower = interp1(xmat,f_old,x_lower,'linear','extrap'); 
            f_upper = interp1(xmat,f_old,x_upper,'linear','extrap'); 
            u_lower = f_lower.^(-theta);
            u_upper = f_upper.^(-theta);
            u_expect = p .* u_lower + (1-p) .* u_upper;
            f_expect = (beta * R .* u_expect).^(-1/theta);
    
            f = min(f_expect,xmat(i));
            f_new(i) = f;
        end 
    
        dif = abs(max(f_new - f_old));
        f_old = f_new;
        its = its + 1;
    
    end 
    
    if its == maxits
        fprintf("Failed to find the policy function of consumption \n");
    else
        fprintf("Succeed finding the policy function of consumption \n");
        formatSpec = "The number of iteration is %d. \n";
        fprintf(formatSpec,its);
    end  
    
    c_plot(iter,:) = f_new;
    a_plot(iter,:) = R.*(xmat - f_new);

end 


% plot consumption
figure(10)
hold on
for i = 1:length(R_list)
    plot(xmat,c_plot(i,:));
end
hold off
legend(string(theta_list))
xlabel('cash-on-hand, x_{t}')
ylabel('consumption, c_{t}')
title ('consumption function, different \theta calibrations')

figure(11)
hold on
for i = 1:length(R_list)
    plot(xmat,a_plot(i,:));
end
hold off
legend(string(theta_list))
xlabel('cash-on-hand, x_{t}')
ylabel('consumption, c_{t}')
title ('consumption function, different \theta calibrations')


