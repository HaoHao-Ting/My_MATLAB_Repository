%% 采用以下方案仿真的延时积分微分方程
% Koto, Toshiyuki. "Stability of Runge–Kutta methods for delay integro-differential equations." Journal of Computational and Applied Mathematics 145.2 (2002): 483-492.
clearvars; close all;
twin = 19.6e-6;
NN = 2^19; dt= twin/NN; df = 1/twin; fwin = 1/dt;

h = dt; m = NN;
totalLen = NN*20;

% u0(1:(m+1),1) = fftshift(ifft(fftshift(1e-3*randn(m+1,1).*exp(2i*pi*rand(m+1,1)))));
u0_init = real(fftshift(ifft(fftshift(1e-3*randn(m+1,1).*exp(2i*pi*rand(m+1,1))))));

%% 宽带滤波器的仿真代码
% phi0 = -0.97;
% beta0 = 3.; f_L = 3.1; f_H = 480e3; tau0 = 1/(2*pi*f_H); theta0 = 1/(2*pi*f_L);
% func_f = @(Un,Unm,Gn)1/tau0*(-(1+tau0/theta0)*Un+beta0*cos(Unm+phi0).^2-1/theta0*Gn);
%% 窄带滤波器的仿真代码
beta0 = 2; phi0 = -pi/4; w0 = 2*pi*3e9; Dw = 2*pi*2e6;
func_f = @(Un,Unm,Gn)Dw*(-Un+beta0*cos(Unm+phi0).^2-w0^2/Dw*Gn);

for loop = 1:10
    u0 = rk4_DIDEs(u0_init, h, totalLen, m, func_f);
    u0_init = u0((end-m):end);
    disp(loop)
end

u0 = u0((end-NN*5+1):end);
ff = linspace(-fwin/2, fwin/2-df/5, NN*5);
plot(ff, 10*log10(abs(fftshift(fft(fftshift(u0))))));




function u0 = rk4_DIDEs(u0_init, h, NStep, delayM, derivRK)

    m = delayM;
    totalLen = NStep+delayM;
    func_f = derivRK;
    
    UU = zeros(totalLen, 4);
    GG = zeros(totalLen, 5);
    u0 = zeros(totalLen+1,1);

    u0(1:(m+1),1) = u0_init;
    UU(1:m, 1) = u0(1:m, 1);
    UU(1:m, 4) = u0(2:(m+1), 1);
    UU(1:m, 2) = 1/2*(UU(1:m,1)+UU(1:m,4));
    UU(1:m, 3)= 1/2*(UU(1:m,1)+UU(1:m,4));
    GG(2:(m+1), 5) = cumsum(UU(1:m,1)+2*UU(1:m,2)+2*UU(1:m,3)+UU(1:m,4));
    for nn = (m+1):totalLen
        UU(nn,1) = u0(nn);
        GG(nn,1) = h/6*GG(nn,5);

        UU(nn,2) = u0(nn)+h/2*func_f(UU(nn,1), UU(nn-m,1), GG(nn,1));
        GG(nn,2) = h/2*UU(nn,1)+h/6*GG(nn,5);

        UU(nn,3) = u0(nn)+h/2*func_f(UU(nn,2), UU(nn-m,2), GG(nn,2));
        GG(nn,3) = h/2*UU(nn,2)+h/6*GG(nn,5);

        UU(nn,4) = u0(nn)+h*func_f(UU(nn,3),UU(nn-m,3), GG(nn,3));
        GG(nn,4) = h*UU(nn,3)+h/6*GG(nn,5);

        GG(nn+1,5) = GG(nn,5)+UU(nn,1)+2*UU(nn,2)+2*UU(nn,3)+UU(nn,4);
        u0(nn+1) = u0(nn)...
        +h/6*(func_f(UU(nn,1), UU(nn-m,1), GG(nn,1))...
        +2*func_f(UU(nn,2),UU(nn-m,2),GG(nn,2))...
        +2*func_f(UU(nn,3),UU(nn-m,3),GG(nn,3))...
        +func_f(UU(nn,4),UU(nn-m,4),GG(nn,4)));
    end
end


%% 代码备份部分
% UU = zeros(totalLen, 4);
% GG = zeros(totalLen, 5);
% u0 = zeros(totalLen+1,1);

% u0(1:(m+1),1) = fftshift(ifft(fftshift(1e-3*randn(m+1,1).*exp(2i*pi*rand(m+1,1)))));
% u0(1:(m+1),1) = real(fftshift(ifft(fftshift(1e-3*randn(m+1,1).*exp(2i*pi*rand(m+1,1))))));

%% 宽带滤波器的仿真代码
% phi0 = -0.97;
% beta0 = 3.; f_L = 3.1; f_H = 480e3; tau0 = 1/(2*pi*f_H); theta0 = 1/(2*pi*f_L);
% func_f = @(Un,Unm,Gn)1/tau0*(-(1+tau0/theta0)*Un+beta0*cos(Unm+phi0).^2-1/theta0*Gn);
%% 窄带滤波器的仿真代码
% beta0 = 2; phi0 = -pi/4; w0 = 2*pi*3e9; Dw = 2*pi*2e6;
% func_f = @(Un,Unm,Gn)Dw*(-Un+beta0*cos(Unm+phi0).^2-w0^2/Dw*Gn);

% % U_1=u(t+c_1*h) U_2=u(t+c_2*h) U_3=u(t+c_3*h) U_4=u(t+c_4*h)
% UU(1:m, 1) = u0(1:m, 1);
% UU(1:m, 4) = u0(2:(m+1), 1);
% UU(1:m, 2) = 1/2*(UU(1:m,1)+UU(1:m,4));
% UU(1:m, 3)= 1/2*(UU(1:m,1)+UU(1:m,4));

% GG(2:(m+1), 5) = cumsum(UU(1:m,1)+2*UU(1:m,2)+2*UU(1:m,3)+UU(1:m,4));

% for nn = (m+1):totalLen
%     UU(nn,1) = u0(nn);
%     GG(nn,1) = h/6*GG(nn,5);

%     UU(nn,2) = u0(nn)+h/2*func_f(UU(nn,1), UU(nn-m,1), GG(nn,1));
%     GG(nn,2) = h/2*UU(nn,1)+h/6*GG(nn,5);

%     UU(nn,3) = u0(nn)+h/2*func_f(UU(nn,2), UU(nn-m,2), GG(nn,2));
%     GG(nn,3) = h/2*UU(nn,2)+h/6*GG(nn,5);

%     UU(nn,4) = u0(nn)+h*func_f(UU(nn,3),UU(nn-m,3), GG(nn,3));
%     GG(nn,4) = h*UU(nn,3)+h/6*GG(nn,5);

%     GG(nn+1,5) = GG(nn,5)+UU(nn,1)+2*UU(nn,2)+2*UU(nn,3)+UU(nn,4);
%     u0(nn+1) = u0(nn)...
%     +h/6*(func_f(UU(nn,1), UU(nn-m,1), GG(nn,1))...
%     +2*func_f(UU(nn,2),UU(nn-m,2),GG(nn,2))...
%     +2*func_f(UU(nn,3),UU(nn-m,3),GG(nn,3))...
%     +func_f(UU(nn,4),UU(nn-m,4),GG(nn,4)));

% end