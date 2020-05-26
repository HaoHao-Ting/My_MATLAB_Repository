% R2016a或较旧版本请将微分方程函数、事件函数单独存为脚本函数
% 如需转载此脚本请注明出处：
% https://github.com/HaoHao-Ting/My_MATLAB_Repository
close all; clearvars;
global R g m
%% 设置半径，重力加速度和质量
R = 1; g = 9.8; m = 1;
% 小球在轨道上的哈密顿量得到的微分方程组
hamilton1 = @(t,x)[R/m*x(2); -m*g*R*cos(x(1))];
% 小球离开轨道的哈密顿量得到的微分方程组
hamilton2 = @(t,x)[x(3)/m; x(4)/m; 0; -m*g];

tmpTheta = linspace(-pi/2, pi/2, 500); % 绘制轨道需要的变量
%% 只考虑在轨道上运动的情况：
option1 = odeset('Events', @(t, x)stopEvent1(t, x, 3*pi/2, 0)); % 设置ode45求解器配置
tspan = 0:0.001:20; % 设置足够长的时间步；
startThetaP = [m*sqrt(1*g*R)/R, m*sqrt(2*g*R)/R, m*sqrt(3*g*R)/R, m*sqrt(4*g*R)/R, m*sqrt(5*g*R)/R]; % 设置初始广义动量
path = nan*ones(numel(tspan),numel(startThetaP));
maxStep = 0;
for loop = 1:numel(startThetaP)
    [~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP(loop)], option1);
    path(1:numel(param(:,1)), loop) = param(:,1);
    maxStep = max(maxStep, numel(param(:,1))); % 获取最长的路径序列，方便画图
end
% 获取运动的视频
v = VideoWriter('path1.avi', 'Motion JPEG AVI');
v.Quality = 100;
open(v);
color = colormap(hsv);
color = color(round(linspace(1,length(color), numel(startThetaP))),:); % 设置绘图颜色
for index = round(linspace(1, maxStep, round(50)))
    clf; hold on;
    % 绘制轨道
    plot([-1.5*R, 0, R*cos(tmpTheta)],[-R, -R, R*sin(tmpTheta)], '-k', 'LineWidth', 4); axis equal;
    plot(R*cos(tmpTheta+pi), R*sin(tmpTheta+pi), '--k', 'LineWidth', 2);
    for loop = 1:numel(startThetaP)
        path1 = path(:,loop); path1 = path1(1:min(index, sum(~isnan(path1))));
        linePathX = R*cos(path1);
        linePathY = R*sin(path1);
        plot(linePathX, linePathY, '-', 'LineWidth', 2, 'Color', color(loop, :));
        plot(linePathX(end), linePathY(end), '.', 'MarkerSize', 40, 'MarkerEdgeColor', color(loop, :));
    end
    hold off;
    frame = getframe(gcf); writeVideo(v,frame);
end
close(v);
%% 考虑在轨道上运动+脱离轨道：
% 设置轨道为半圆，终止角度为pi/2; 设置初始速度为\sqrt(5gR)
option1 = odeset('Events', @(t, x)stopEvent1(t, x, pi/2, 1)); % 设置ode45求解器配置, 加入脱离轨道约束
% 设置脱离轨道的运动情况下ode45求解器配置
option2 = odeset('Events', @(t, x)stopEvent2(t, x, R));

tspan = 0:0.001:80; % 设置足够长的时间步；
% startThetaP = [m*sqrt(1*g*R)/R, m*sqrt(2*g*R)/R, m*sqrt(2.5*g*R)/R, m*sqrt(3*g*R)/R, m*sqrt(3.5*g*R)/R, m*sqrt(4*g*R)/R, m*sqrt(4.5*g*R)/R, m*sqrt(5*g*R)/R, m*sqrt(6*g*R)/R]; % 设置初始广义动量
startThetaP = m*sqrt(([3.0 3.2 3.4 3.6 3.8 4 3.5])*g*R)/R;
path = nan*ones(numel(tspan), 2*numel(startThetaP));
maxStep = 0;
for loop = 1:numel(startThetaP)
    [~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP(loop)], option1);
    % 广义坐标转换为笛卡尔坐标
    clear path1
    path1(:,1) = R*cos(param(:,1));
    path1(:,2) = R*sin(param(:,1));
    % 计算脱离轨道的运动情况，根据上一个演化过程的终点，计算小球脱离轨道的初始状态。
    initState = [R*cos(param(end,1)); R*sin(param(end,1)); param(end,2)*R*cos(pi/2+param(end,1)); param(end,2)*R*sin(pi/2+param(end,1));];
    [~, path2] = ode45(hamilton2, tspan, initState, option2);
    tmp = [path1; path2(:,1:2)];
    path(1:length(tmp), [2*loop-1, 2*loop]) = tmp;
    maxStep = max(maxStep, numel(tmp(:,1))); % 获取最长的路径序列，方便画图
end


% 获取运动的视频
v = VideoWriter('path2.avi', 'Motion JPEG AVI');
v.Quality = 100;
open(v);
color = colormap(hsv);
color = color(round(linspace(1,length(color), numel(startThetaP))),:); % 设置绘图颜色
for index = round(linspace(1, maxStep, round(50)))
    clf; hold on;
    % 绘制轨道
    plot([-3*R, 0, R*cos(tmpTheta)],[-R, -R, R*sin(tmpTheta)], '-k', 'LineWidth', 4); axis equal;
    plot(path(:,end-1), path(:,end), '-k', 'LineWidth', 1);
    for loop = 1:numel(startThetaP)-1
        pathX = path(:,2*loop-1); pathX = pathX(1:min(index, sum(~isnan(pathX))));
        pathY = path(:,2*loop); pathY = pathY(1:min(index, sum(~isnan(pathY))));
        
        plot(pathX, pathY, '-', 'LineWidth', 2, 'Color', color(loop, :));
        plot(pathX(end), pathY(end), '.', 'MarkerSize', 40, 'MarkerEdgeColor', color(loop, :));
    end
    hold off;
    frame = getframe(gcf); writeVideo(v,frame);
end
close(v);
return;

%% 设定演化的停止事件函数
% 第一种哈密顿量情况下的停止事件函数
function [value, isterminal, direction] = stopEvent1(t, x, stopTheta, constraint)
global m g R
% 停止条件一：角度到达设定值，例如pi/2时离开轨道
value(1) = x(1)-stopTheta;
isterminal(1) = 1;
direction(1) = 1;
% 停止条件二：小球倒回到起点角度-pi/2时
value(2) = x(1)+pi/2;
isterminal(2) = 1;
direction(2) = -1;
% 是否添加向心力与重力关系的约束
if (constraint > 0 )
    % 停止条件三：重力的分力大于向心力
    value(3) = m*g*sin(x(1))-x(2)^2*R/m;
    isterminal(3) = 1;
    direction(3) = 0;
end
end
% 第二种哈密顿量情况下的事件函数
function [value, isterminal, direction] = stopEvent2(t, x, R)
% 停止条件一：落到水平轨道，根据建立的坐标系，水平轨道的坐标为y=-R;
value(1) = x(2) + R;
isterminal(1) = 1;
direction(1) = 0;
% 停止条件二：落到半圆轨道，根据建立的坐标系，x^2+y^2=R^2 AND x>0;
value(2) = x(1)-sqrt(abs(R^2-x(2)^2));
isterminal(2) = 1;
direction(2) = 1;
end