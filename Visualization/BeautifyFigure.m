function BeautifyFigure
%% GUI 的数据结构
% GUI
% +-----------------------------------------------------------------+
% |guiFigure                                                        |
% | +------------+  +--------------+  +------------+                |
% | |btn_loadConf|  |btn_saveConfig|  |btn_gene..  |                |
% | +------------+  +--------------+  +------------+                |
% | +------------+  +--------------+  +------------+  +-----------+ |
% | |pMnu_Type   |  |btn_addUitab  |  |btn_removeUi|  |ed_drawName| |
% | +------------+  +--------------+  +------------+  +-----------+ |
% | +-------------------------------------------------------------+ |
% | |tg_configPanel:标签组控件                                    | |
% | | +---------------------------------------------------------+ | |
% | | |uitab(i):标签控件                                        | | |
% | | |            title:uitabName(i):标签命名                  | | |
% | | |            data: tableInfo(i):标签存储的表控件          | | |
% | | |                                                         | | |
% | | +---------------------------------------------------------+ | |
% | +-------------------------------------------------------------+ |
% +-----------------------------------------------------------------+
% GUI.graphicsTemplate: 存储tableInfo的表模板。

screenSize = get(0, 'ScreenSize');

CONF_FONTSIZE = 10; % 全局字体大小
%% 导入数据
TEMPLATE_FILENAME = 'graphicsTemplate.xlsx'; % 基础图形模板
[~, graphicsName] = xlsfinfo(TEMPLATE_FILENAME);
for iter = 1:numel(graphicsName)
    graphicsTemplate(iter).Name = graphicsName{iter};
    [~,graphicsTemplate(iter).Data,~] = xlsread(TEMPLATE_FILENAME, graphicsName{iter});
end
GUI.graphicsTemplate = graphicsTemplate;
clear graphicsTemplate TEMPLATE_FILENAME;
%% 界面生成
GUI.guiFigure = figure(9989);
close(GUI.guiFigure);
GUI.guiFigure = figure(9989);
set(GUI.guiFigure, 'MenuBar', 'none');
GUI.guiFigure.NumberTitle = 'off';
GUI.guiFigure.Name = "自动生成格式化figure的代码";
GUI.guiFigure.Position = [screenSize(3)-500, screenSize(4)-850, 400, 800];

% 加载配置文件
GUI.btn_loadConfig = uicontrol();
GUI.btn_loadConfig.String = '加载配置文件';
GUI.btn_loadConfig.Style = 'pushbutton';
GUI.btn_loadConfig.Units = 'pixel';
GUI.btn_loadConfig.Position = [5, GUI.guiFigure.Position(4)-20-5,80,20];
% 保存配置文件
GUI.btn_saveConfig = uicontrol();
GUI.btn_saveConfig.String = '保存配置文件';
GUI.btn_saveConfig.Style = 'pushbutton';
GUI.btn_saveConfig.Units = 'pixel';
GUI.btn_saveConfig.Position = [GUI.btn_loadConfig.Position(1)+GUI.btn_loadConfig.Position(3)+5, GUI.guiFigure.Position(4)-20-5, 80,20];
% 生成配置代码
GUI.btn_generateCode = uicontrol();
GUI.btn_generateCode.String = '生成配置代码';
GUI.btn_generateCode.Style = 'pushbutton';
GUI.btn_generateCode.Units = 'pixel';
GUI.btn_generateCode.Position = [GUI.btn_saveConfig.Position(1)+GUI.btn_saveConfig.Position(3)+5, GUI.guiFigure.Position(4)-20-5, 80,20];

% 选择画图类型
GUI.pMnu_Type = uicontrol();
GUI.pMnu_Type.Style = 'popupmenu';
GUI.pMnu_Type.Units = 'pixel';
GUI.pMnu_Type.Position = [GUI.btn_loadConfig.Position(1), GUI.btn_loadConfig.Position(2)-20-10, 80, 20];
GUI.pMnu_Type.String = graphicsName;

% 增加uitab
GUI.btn_addUitab = uicontrol();
GUI.btn_addUitab.String = '增加绘图实例';
GUI.btn_addUitab.Style = 'pushbutton';
GUI.btn_addUitab.Units = 'pixel';
GUI.btn_addUitab.Position = [GUI.btn_saveConfig.Position(1), GUI.btn_saveConfig.Position(2)-20-10, 80, 20];
% 画图类型名
GUI.ed_drawName = uicontrol();
GUI.ed_drawName.Style = 'edit';
GUI.ed_drawName.Tooltip = '请输入新绘图实例的名称';
GUI.ed_drawName.Position = [GUI.btn_generateCode.Position(1)+90, GUI.btn_generateCode.Position(2)-20-10, 80, 20];

% 删除uitab
GUI.btn_removeUitab = uicontrol();
GUI.btn_removeUitab.String = '删除绘图实例';
GUI.btn_removeUitab.Style = 'pushbutton';
GUI.btn_removeUitab.Units = 'pixel';
GUI.btn_removeUitab.Position = [GUI.btn_generateCode.Position(1), GUI.btn_generateCode.Position(2)-20-10, 80, 20];
% 标签选项卡的配置
GUI.tg_configPanel = uitabgroup(GUI.guiFigure);
GUI.tg_configPanel.Units = 'pixel';
GUI.tg_configPanel.Position = [10, 10, GUI.guiFigure.Position(3)-10, GUI.guiFigure.Position(4)-80];

GUI.uitab(1) = uitab(GUI.tg_configPanel, 'Title', 'Figure');
GUI.uitabName(1) = "figure";
GUI.tableInfo(1) = uitable(GUI.uitab(1));
GUI.tableInfo(1).Position = [5, 5, GUI.tg_configPanel.Position(3)-5, GUI.tg_configPanel.Position(4)-35];
GUI.tableInfo(1).ColumnName = {'属性名','属性值', '说明'};
GUI.tableInfo(1).ColumnEditable = [false, true, false];
GUI.tableInfo(1).ColumnWidth = {80, 200, 100};
GUI.tableInfo(1).FontSize = CONF_FONTSIZE;
GUI.tableInfo(1).Data = func_loadDefaultConfig(GUI.graphicsTemplate, 'figure');
%% Set the callback of the button
set([GUI.btn_generateCode, GUI.btn_saveConfig, GUI.btn_loadConfig, GUI.btn_addUitab, GUI.btn_removeUitab], 'call', {@uicontrol_call, GUI});
end

%% 所有的回调函数设置
function [] = uicontrol_call(varargin)
    [h, GUI] = varargin{[1,3]};
    switch h
        case GUI.btn_addUitab % add new draw into panel
            GUI = call_btn_addUitab(GUI);
        case GUI.btn_removeUitab % delete the selected panel
            GUI = call_btn_removeUitab(GUI);
        case GUI.btn_generateCode % generate the code
            call_btn_generateCode(GUI);
        case GUI.btn_loadConfig % load the configuration mat file
            disp('加载保存的配置文件');
            [fileName, filePath] = uigetfile('*.mat', '选择配置文件');
            load([filePath, fileName]);
        case GUI.btn_saveConfig % save the current configuration into mat file
            disp('保存设置好的配置文件')
            [fileName, filePath] = uiputfile('配置文件(*.mat)', '选择需要存储的位置','configFile.mat');
            save([filePath, fileName]);
            disp(['开始存储文件，文件存储在', filePath,'，文件名为：', fileName]);
        otherwise
            disp('程序可能出错了，调用了未设置的回调');
    end

    set([GUI.btn_generateCode, GUI.btn_saveConfig, GUI.btn_loadConfig, GUI.btn_addUitab, GUI.btn_removeUitab], 'call', {@uicontrol_call, GUI});
end
%% call of btn_addUitab
function GUI = call_btn_addUitab(GUI)
    selectType = GUI.pMnu_Type.String{GUI.pMnu_Type.Value};
    typeNum = startsWith(GUI.uitabName, selectType);
    graphicsTemplate = GUI.graphicsTemplate;
    if (strcmp(GUI.ed_drawName.String, ""))
        newName = selectType + "_" + num2str(typeNum+1);
    else
        newName = selectType + "_" + GUI.ed_drawName.String;
    end

    GUI.uitab(end+1) = uitab(GUI.tg_configPanel, 'Title', newName);
    GUI.uitabName(end+1) = newName;

    GUI.tableInfo(end+1) = uitable(GUI.uitab(end));
    GUI.tableInfo(end).Position = [5, 5, GUI.tg_configPanel.Position(3)-5, GUI.tg_configPanel.Position(4)-35];
    GUI.tableInfo(end).ColumnName = {'属性名','属性值', '说明'};
    GUI.tableInfo(end).ColumnEditable = [false, true, false];
    GUI.tableInfo(end).ColumnWidth = {80, 200, 100};
    GUI.tableInfo(end).FontSize = GUI.tableInfo(1).FontSize;
    GUI.tableInfo(end).Data = func_loadDefaultConfig(graphicsTemplate, selectType);
end
%% call of btn_removeUitab
function GUI = call_btn_removeUitab(GUI)
    deleteName = GUI.tg_configPanel.SelectedTab.Title;
    deleteIndex = find(strcmp(GUI.tableInfo, deleteName));
    if (strcmpi(GUI.tg_configPanel.SelectedTab.Title, 'figure'))
        disp('Cannot delete the figure configuration page');
    else
        % delete the SelectedTab from the tabel group;
        delete(GUI.tg_configPanel.SelectedTab); % 这个行为是不可逆的，需要注意
        % 依次删除GUI变量中存储的uitab， uitab标签名， table数据
        GUI.uitab(deleteIndex) = [];
        GUI.uitabName(deleteIndex) = [];
        GUI.tableInfo(deleteIndex) = [];
    end
end
%% call of btn_generateCode
function call_btn_generateCode(GUI)
    disp('点击的生成代码');
    [fileName, filePath] = uiputfile('用于优化figure的函数代码(*.m)', '请选择需要存储的位置', 'BeautyNow.m');
    [~, fileNameWithoutExt, ~] = fileparts([filePath, fileName]);
    fileID = fopen([filePath, fileName], 'w');
    fprintf(fileID, '%s\n', ['function ', fileNameWithoutExt, '()']);
    fprintf(fileID, '%s\n', 'figureHandle = inputHandle;');
    fprintf(fileID, '%s\n', 'axesHandle = figureHandle.Children;');
    fprintf(fileID, '%s\n', 'graphHandle = axesHandle.Children;');
    fprintf(fileID, '%s\n', '%% figure');
    % for dataIndex = 1:numel(GUI.tableInfo)
    tmpTable = GUI.tableInfo(1).Data;
    [Niter, ~] = size(tmpTable);
    for iter = 1:Niter
        fprintf(fileID, '%s\n', ['figureHandle.', tmpTable{iter, 1}, ' = ', tmpTable{iter, 2}, '; % ', tmpTable{iter, 3}]);
    end
    for graphIndex = 2:numel(GUI.tableInfo)
        fprintf(fileID, '%s\n', ['%% ', GUI.uitabName(graphIndex)]);
        tmpTable = GUI.tableInfo(graphIndex).Data;
        [Niter, ~] = size(tmpTable);
        for iter = 1:Niter
            fprintf(fileID, '%s\n', ['figureHandle.', tmpTable{iter, 1}, ' = ', tmpTable{iter, 2}, '; % ', tmpTable{iter, 3}]);
        end
    end
    fclose(fileID); % close file 
end
%% 加载基础配置信息
function out = func_loadDefaultConfig(graphicsTemplate, graphicsName)
    for iter = 1:numel(graphicsTemplate)
        if (strcmpi(graphicsName, graphicsTemplate(iter).Name))
            break;
        end
    end
    out = graphicsTemplate(iter).Data;
end