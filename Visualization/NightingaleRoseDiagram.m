close all; clearvars;
%% 设置玫瑰图的数据
countries = {'韩国','意大利','伊朗','日本','德国','法国','西班牙','美国','新加坡','英国'};
numOfConfirmed = [5766, 3144, 2922, 1035, 351, 285, 223, 158, 112, 87];

% 计算玫瑰图中扇形的个数
itemNum = numel(numOfConfirmed);
% 计算玫瑰图扇形的宽度
sectorWidth = 2*pi/itemNum;

% 设置玫瑰图的渐变，系统默认配色有，如下几种，根据自己喜欢更改下边的代码即可
% parula, jet, hsv, hot, cool, spring, summer, autumn, winter, bone
figureColor = colormap(parula);
figureColor = figureColor(round(linspace(1, length(figureColor), itemNum)), :);

%% 开始绘图
figure(1); hold on;
for index = 1:itemNum
    % 数据的中心角度
    angle0 = (index-1)*sectorWidth;
    % 按照平常高度绘制扇形
    drawSector(0.2, log10(numOfConfirmed(index)), angle0, sectorWidth, figureColor(index, :), '--', 'r');
    % 标上文字
    R1 = log10(numOfConfirmed(index))-0.1;
    text(R1*cos(angle0), R1*sin(angle0), countries{index}, ...
        'rotation', 360*(index-1)/itemNum,...
        'FontSize',12, 'FontName','思源黑体 CN Bold', 'Color', 'k', 'HorizontalAlignment', 'right');
end

axis equal; axis off; hold off;

%% 绘制南丁格尔图的扇形
function drawSector(r0, R0, angleCenter, width , color, edgeStyle, edgeColor)
% drawSector(扇形内圈半径， 扇形外圈半径, 扇形的中心角度， 扇形宽度， 扇形颜色, 扇形边框线类型，边框颜色)
    theta = linspace(angleCenter-width/2, angleCenter+width/2, 100);
    sectorPathX_Out = cos(theta)*R0;
    sectorPathY_Out = sin(theta)*R0;
    sectorPathX_In  = fliplr(cos(theta)*r0);
    sectorPathY_In = fliplr(sin(theta)*r0);
    
    fill([sectorPathX_In, sectorPathX_Out], [sectorPathY_In, sectorPathY_Out], color, ...
        'LineStyle', edgeStyle, 'LineWidth', 0.2, 'EdgeColor', edgeColor);
end