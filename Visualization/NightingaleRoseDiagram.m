close all; clearvars;
%% ����õ��ͼ������
countries = {'����','�����','����','�ձ�','�¹�','����','������','����','�¼���','Ӣ��'};
numOfConfirmed = [5766, 3144, 2922, 1035, 351, 285, 223, 158, 112, 87];

% ����õ��ͼ�����εĸ���
itemNum = numel(numOfConfirmed);
% ����õ��ͼ���εĿ��
sectorWidth = 2*pi/itemNum;

% ����õ��ͼ�Ľ��䣬ϵͳĬ����ɫ�У����¼��֣������Լ�ϲ�������±ߵĴ��뼴��
% parula, jet, hsv, hot, cool, spring, summer, autumn, winter, bone
figureColor = colormap(parula);
figureColor = figureColor(round(linspace(1, length(figureColor), itemNum)), :);

%% ��ʼ��ͼ
figure(1); hold on;
for index = 1:itemNum
    % ���ݵ����ĽǶ�
    angle0 = (index-1)*sectorWidth;
    % ����ƽ���߶Ȼ�������
    drawSector(0.2, log10(numOfConfirmed(index)), angle0, sectorWidth, figureColor(index, :), '--', 'r');
    % ��������
    R1 = log10(numOfConfirmed(index))-0.1;
    text(R1*cos(angle0), R1*sin(angle0), countries{index}, ...
        'rotation', 360*(index-1)/itemNum,...
        'FontSize',12, 'FontName','˼Դ���� CN Bold', 'Color', 'k', 'HorizontalAlignment', 'right');
end

axis equal; axis off; hold off;

%% �����϶����ͼ������
function drawSector(r0, R0, angleCenter, width , color, edgeStyle, edgeColor)
% drawSector(������Ȧ�뾶�� ������Ȧ�뾶, ���ε����ĽǶȣ� ���ο�ȣ� ������ɫ, ���α߿������ͣ��߿���ɫ)
    theta = linspace(angleCenter-width/2, angleCenter+width/2, 100);
    sectorPathX_Out = cos(theta)*R0;
    sectorPathY_Out = sin(theta)*R0;
    sectorPathX_In  = fliplr(cos(theta)*r0);
    sectorPathY_In = fliplr(sin(theta)*r0);
    
    fill([sectorPathX_In, sectorPathX_Out], [sectorPathY_In, sectorPathY_Out], color, ...
        'LineStyle', edgeStyle, 'LineWidth', 0.2, 'EdgeColor', edgeColor);
end