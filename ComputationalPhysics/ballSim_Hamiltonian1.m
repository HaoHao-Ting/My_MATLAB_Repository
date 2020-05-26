% R2016a��Ͼɰ汾�뽫΢�ַ��̺������¼�����������Ϊ�ű�����
% ����ת�ش˽ű���ע��������
% https://github.com/HaoHao-Ting/My_MATLAB_Repository
close all; clearvars;
global R g m
%% ���ð뾶���������ٶȺ�����
R = 1; g = 9.8; m = 1;
% С���ڹ���ϵĹ��ܶ����õ���΢�ַ�����
hamilton1 = @(t,x)[R/m*x(2); -m*g*R*cos(x(1))];
% С���뿪����Ĺ��ܶ����õ���΢�ַ�����
hamilton2 = @(t,x)[x(3)/m; x(4)/m; 0; -m*g];

tmpTheta = linspace(-pi/2, pi/2, 500); % ���ƹ����Ҫ�ı���
%% ֻ�����ڹ�����˶��������
option1 = odeset('Events', @(t, x)stopEvent1(t, x, 3*pi/2, 0)); % ����ode45���������
tspan = 0:0.001:20; % �����㹻����ʱ�䲽��
startThetaP = [m*sqrt(1*g*R)/R, m*sqrt(2*g*R)/R, m*sqrt(3*g*R)/R, m*sqrt(4*g*R)/R, m*sqrt(5*g*R)/R]; % ���ó�ʼ���嶯��
path = nan*ones(numel(tspan),numel(startThetaP));
maxStep = 0;
for loop = 1:numel(startThetaP)
    [~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP(loop)], option1);
    path(1:numel(param(:,1)), loop) = param(:,1);
    maxStep = max(maxStep, numel(param(:,1))); % ��ȡ���·�����У����㻭ͼ
end
% ��ȡ�˶�����Ƶ
v = VideoWriter('path1.avi', 'Motion JPEG AVI');
v.Quality = 100;
open(v);
color = colormap(hsv);
color = color(round(linspace(1,length(color), numel(startThetaP))),:); % ���û�ͼ��ɫ
for index = round(linspace(1, maxStep, round(50)))
    clf; hold on;
    % ���ƹ��
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
%% �����ڹ�����˶�+��������
% ���ù��Ϊ��Բ����ֹ�Ƕ�Ϊpi/2; ���ó�ʼ�ٶ�Ϊ\sqrt(5gR)
option1 = odeset('Events', @(t, x)stopEvent1(t, x, pi/2, 1)); % ����ode45���������, ����������Լ��
% �������������˶������ode45���������
option2 = odeset('Events', @(t, x)stopEvent2(t, x, R));

tspan = 0:0.001:80; % �����㹻����ʱ�䲽��
% startThetaP = [m*sqrt(1*g*R)/R, m*sqrt(2*g*R)/R, m*sqrt(2.5*g*R)/R, m*sqrt(3*g*R)/R, m*sqrt(3.5*g*R)/R, m*sqrt(4*g*R)/R, m*sqrt(4.5*g*R)/R, m*sqrt(5*g*R)/R, m*sqrt(6*g*R)/R]; % ���ó�ʼ���嶯��
startThetaP = m*sqrt(([3.0 3.2 3.4 3.6 3.8 4 3.5])*g*R)/R;
path = nan*ones(numel(tspan), 2*numel(startThetaP));
maxStep = 0;
for loop = 1:numel(startThetaP)
    [~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP(loop)], option1);
    % ��������ת��Ϊ�ѿ�������
    clear path1
    path1(:,1) = R*cos(param(:,1));
    path1(:,2) = R*sin(param(:,1));
    % �������������˶������������һ���ݻ����̵��յ㣬����С���������ĳ�ʼ״̬��
    initState = [R*cos(param(end,1)); R*sin(param(end,1)); param(end,2)*R*cos(pi/2+param(end,1)); param(end,2)*R*sin(pi/2+param(end,1));];
    [~, path2] = ode45(hamilton2, tspan, initState, option2);
    tmp = [path1; path2(:,1:2)];
    path(1:length(tmp), [2*loop-1, 2*loop]) = tmp;
    maxStep = max(maxStep, numel(tmp(:,1))); % ��ȡ���·�����У����㻭ͼ
end


% ��ȡ�˶�����Ƶ
v = VideoWriter('path2.avi', 'Motion JPEG AVI');
v.Quality = 100;
open(v);
color = colormap(hsv);
color = color(round(linspace(1,length(color), numel(startThetaP))),:); % ���û�ͼ��ɫ
for index = round(linspace(1, maxStep, round(50)))
    clf; hold on;
    % ���ƹ��
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

%% �趨�ݻ���ֹͣ�¼�����
% ��һ�ֹ��ܶ�������µ�ֹͣ�¼�����
function [value, isterminal, direction] = stopEvent1(t, x, stopTheta, constraint)
global m g R
% ֹͣ����һ���Ƕȵ����趨ֵ������pi/2ʱ�뿪���
value(1) = x(1)-stopTheta;
isterminal(1) = 1;
direction(1) = 1;
% ֹͣ��������С�򵹻ص����Ƕ�-pi/2ʱ
value(2) = x(1)+pi/2;
isterminal(2) = 1;
direction(2) = -1;
% �Ƿ������������������ϵ��Լ��
if (constraint > 0 )
    % ֹͣ�������������ķ�������������
    value(3) = m*g*sin(x(1))-x(2)^2*R/m;
    isterminal(3) = 1;
    direction(3) = 0;
end
end
% �ڶ��ֹ��ܶ�������µ��¼�����
function [value, isterminal, direction] = stopEvent2(t, x, R)
% ֹͣ����һ���䵽ˮƽ��������ݽ���������ϵ��ˮƽ���������Ϊy=-R;
value(1) = x(2) + R;
isterminal(1) = 1;
direction(1) = 0;
% ֹͣ���������䵽��Բ��������ݽ���������ϵ��x^2+y^2=R^2 AND x>0;
value(2) = x(1)-sqrt(abs(R^2-x(2)^2));
isterminal(2) = 1;
direction(2) = 1;
end