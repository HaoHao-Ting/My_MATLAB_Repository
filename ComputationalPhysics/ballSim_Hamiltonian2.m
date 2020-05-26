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

%% ���ʼ�ٶȱ仯��·�����㣺
% ���ù��Ϊ��Բ����ֹ�Ƕ�Ϊpi/2; ���ó�ʼ�ٶ�Ϊ\sqrt(5gR)
option1 = odeset('Events', @(t, x)stopEvent1(t, x, pi/2, 1)); % ����ode45���������, ����������Լ��
% �������������˶������ode45���������
option2 = odeset('Events', @(t, x)stopEvent2(t, x, R));

tspan = 0:0.001:80; % �����㹻����ʱ�䲽��

%% �������������������
startThetaP = m*sqrt(3.5*g*R)/R;
[~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP], option1);
% ��������ת��Ϊ�ѿ�������
clear path1
path1(:,1) = R*cos(param(:,1));
path1(:,2) = R*sin(param(:,1));
% �������������˶������������һ���ݻ����̵��յ㣬����С���������ĳ�ʼ״̬��
initState = [R*cos(param(end,1)); R*sin(param(end,1)); param(end,2)*R*cos(pi/2+param(end,1)); param(end,2)*R*sin(pi/2+param(end,1));];
[~, path2] = ode45(hamilton2, tspan, initState, option2);
path35 = [path1; path2(:,1:2)];
startThetaP = m*sqrt(5*g*R)/R;
[~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP], option1);
% ��������ת��Ϊ�ѿ�������
clear path1
path1(:,1) = R*cos(param(:,1));
path1(:,2) = R*sin(param(:,1));
% �������������˶������������һ���ݻ����̵��յ㣬����С���������ĳ�ʼ״̬��
initState = [R*cos(param(end,1)); R*sin(param(end,1)); param(end,2)*R*cos(pi/2+param(end,1)); param(end,2)*R*sin(pi/2+param(end,1));];
[~, path2] = ode45(hamilton2, tspan, initState, option2);
path5 = [path1; path2(:,1:2)];

factor = 5:0.01:6;
figure(1); hold on;
% ��ȡ�˶�����Ƶ
v = VideoWriter('path02.avi', 'Motion JPEG AVI');
v.Quality = 100;
open(v);
% color = colormap(hsv);
% color = color(round(linspace(1,length(color), numel(factor))),:); % ���û�ͼ��ɫ
for loop = 1:numel(factor)
    startThetaP = m*sqrt(factor(loop)*g*R)/R;
    [~, param] = ode45(hamilton1, tspan, [-pi/2, startThetaP], option1);
    % ��������ת��Ϊ�ѿ�������
    clear path1
    path1(:,1) = R*cos(param(:,1));
    path1(:,2) = R*sin(param(:,1));
    % �������������˶������������һ���ݻ����̵��յ㣬����С���������ĳ�ʼ״̬��
    initState = [R*cos(param(end,1)); R*sin(param(end,1)); param(end,2)*R*cos(pi/2+param(end,1)); param(end,2)*R*sin(pi/2+param(end,1));];
    [~, path2] = ode45(hamilton2, tspan, initState, option2);
    path = [path1; path2(:,1:2)];
    clf;
    plot([-4*R, 0, R*cos(tmpTheta)],[-R, -R, R*sin(tmpTheta)], '-k', 'LineWidth', 2); hold on; % ���
    p1 = plot(path35(:,1), path35(:,2), '--k', 'LineWidth', 1.5);
    p3 = plot(path5(:,1), path5(:,2), '-.k', 'LineWidth', 1.5);
    axis equal; xlim([-4*R R]); ylim([-1.2*R 1.2*R]);
    p2 = plot(path(:,1), path(:,2), '-r', 'LineWidth', 1.5); %
    legend([p1,p2,p3],{'ǡ��ͨ����ߵ�','ǡ��������','С��켣'},...
        'FontSize',16,'FontName','����','Location','northwest');
    
    % ���ƹ��
    title(['$v_0= \sqrt{',num2str(factor(loop),'%10.3f'),'gR} $'],'FontSize',16,'Interpreter','latex');
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