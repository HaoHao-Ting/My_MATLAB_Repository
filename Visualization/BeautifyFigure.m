function BeautifyFigure
%% GUI �����ݽṹ
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
% | |tg_configPanel:��ǩ��ؼ�                                    | |
% | | +---------------------------------------------------------+ | |
% | | |uitab(i):��ǩ�ؼ�                                        | | |
% | | |            title:uitabName(i):��ǩ����                  | | |
% | | |            data: tableInfo(i):��ǩ�洢�ı�ؼ�          | | |
% | | |                                                         | | |
% | | +---------------------------------------------------------+ | |
% | +-------------------------------------------------------------+ |
% +-----------------------------------------------------------------+
% GUI.graphicsTemplate: �洢tableInfo�ı�ģ�塣

screenSize = get(0, 'ScreenSize');

CONF_FONTSIZE = 10; % ȫ�������С
%% ��������
TEMPLATE_FILENAME = 'graphicsTemplate.xlsx'; % ����ͼ��ģ��
[~, graphicsName] = xlsfinfo(TEMPLATE_FILENAME);
for iter = 1:numel(graphicsName)
    graphicsTemplate(iter).Name = graphicsName{iter};
    [~,graphicsTemplate(iter).Data,~] = xlsread(TEMPLATE_FILENAME, graphicsName{iter});
end
GUI.graphicsTemplate = graphicsTemplate;
clear graphicsTemplate TEMPLATE_FILENAME;
%% ��������
GUI.guiFigure = figure(9989);
close(GUI.guiFigure);
GUI.guiFigure = figure(9989);
set(GUI.guiFigure, 'MenuBar', 'none');
GUI.guiFigure.NumberTitle = 'off';
GUI.guiFigure.Name = "�Զ����ɸ�ʽ��figure�Ĵ���";
GUI.guiFigure.Position = [screenSize(3)-500, screenSize(4)-850, 400, 800];

% ���������ļ�
GUI.btn_loadConfig = uicontrol();
GUI.btn_loadConfig.String = '���������ļ�';
GUI.btn_loadConfig.Style = 'pushbutton';
GUI.btn_loadConfig.Units = 'pixel';
GUI.btn_loadConfig.Position = [5, GUI.guiFigure.Position(4)-20-5,80,20];
% ���������ļ�
GUI.btn_saveConfig = uicontrol();
GUI.btn_saveConfig.String = '���������ļ�';
GUI.btn_saveConfig.Style = 'pushbutton';
GUI.btn_saveConfig.Units = 'pixel';
GUI.btn_saveConfig.Position = [GUI.btn_loadConfig.Position(1)+GUI.btn_loadConfig.Position(3)+5, GUI.guiFigure.Position(4)-20-5, 80,20];
% �������ô���
GUI.btn_generateCode = uicontrol();
GUI.btn_generateCode.String = '�������ô���';
GUI.btn_generateCode.Style = 'pushbutton';
GUI.btn_generateCode.Units = 'pixel';
GUI.btn_generateCode.Position = [GUI.btn_saveConfig.Position(1)+GUI.btn_saveConfig.Position(3)+5, GUI.guiFigure.Position(4)-20-5, 80,20];

% ѡ��ͼ����
GUI.pMnu_Type = uicontrol();
GUI.pMnu_Type.Style = 'popupmenu';
GUI.pMnu_Type.Units = 'pixel';
GUI.pMnu_Type.Position = [GUI.btn_loadConfig.Position(1), GUI.btn_loadConfig.Position(2)-20-10, 80, 20];
GUI.pMnu_Type.String = graphicsName;

% ����uitab
GUI.btn_addUitab = uicontrol();
GUI.btn_addUitab.String = '���ӻ�ͼʵ��';
GUI.btn_addUitab.Style = 'pushbutton';
GUI.btn_addUitab.Units = 'pixel';
GUI.btn_addUitab.Position = [GUI.btn_saveConfig.Position(1), GUI.btn_saveConfig.Position(2)-20-10, 80, 20];
% ��ͼ������
GUI.ed_drawName = uicontrol();
GUI.ed_drawName.Style = 'edit';
GUI.ed_drawName.Tooltip = '�������»�ͼʵ��������';
GUI.ed_drawName.Position = [GUI.btn_generateCode.Position(1)+90, GUI.btn_generateCode.Position(2)-20-10, 80, 20];

% ɾ��uitab
GUI.btn_removeUitab = uicontrol();
GUI.btn_removeUitab.String = 'ɾ����ͼʵ��';
GUI.btn_removeUitab.Style = 'pushbutton';
GUI.btn_removeUitab.Units = 'pixel';
GUI.btn_removeUitab.Position = [GUI.btn_generateCode.Position(1), GUI.btn_generateCode.Position(2)-20-10, 80, 20];
% ��ǩѡ�������
GUI.tg_configPanel = uitabgroup(GUI.guiFigure);
GUI.tg_configPanel.Units = 'pixel';
GUI.tg_configPanel.Position = [10, 10, GUI.guiFigure.Position(3)-10, GUI.guiFigure.Position(4)-80];

GUI.uitab(1) = uitab(GUI.tg_configPanel, 'Title', 'Figure');
GUI.uitabName(1) = "figure";
GUI.tableInfo(1) = uitable(GUI.uitab(1));
GUI.tableInfo(1).Position = [5, 5, GUI.tg_configPanel.Position(3)-5, GUI.tg_configPanel.Position(4)-35];
GUI.tableInfo(1).ColumnName = {'������','����ֵ', '˵��'};
GUI.tableInfo(1).ColumnEditable = [false, true, false];
GUI.tableInfo(1).ColumnWidth = {80, 200, 100};
GUI.tableInfo(1).FontSize = CONF_FONTSIZE;
GUI.tableInfo(1).Data = func_loadDefaultConfig(GUI.graphicsTemplate, 'figure');
%% Set the callback of the button
set([GUI.btn_generateCode, GUI.btn_saveConfig, GUI.btn_loadConfig, GUI.btn_addUitab, GUI.btn_removeUitab], 'call', {@uicontrol_call, GUI});
end

%% ���еĻص���������
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
            disp('���ر���������ļ�');
            [fileName, filePath] = uigetfile('*.mat', 'ѡ�������ļ�');
            load([filePath, fileName]);
        case GUI.btn_saveConfig % save the current configuration into mat file
            disp('�������úõ������ļ�')
            [fileName, filePath] = uiputfile('�����ļ�(*.mat)', 'ѡ����Ҫ�洢��λ��','configFile.mat');
            save([filePath, fileName]);
            disp(['��ʼ�洢�ļ����ļ��洢��', filePath,'���ļ���Ϊ��', fileName]);
        otherwise
            disp('������ܳ����ˣ�������δ���õĻص�');
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
    GUI.tableInfo(end).ColumnName = {'������','����ֵ', '˵��'};
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
        delete(GUI.tg_configPanel.SelectedTab); % �����Ϊ�ǲ�����ģ���Ҫע��
        % ����ɾ��GUI�����д洢��uitab�� uitab��ǩ���� table����
        GUI.uitab(deleteIndex) = [];
        GUI.uitabName(deleteIndex) = [];
        GUI.tableInfo(deleteIndex) = [];
    end
end
%% call of btn_generateCode
function call_btn_generateCode(GUI)
    disp('��������ɴ���');
    [fileName, filePath] = uiputfile('�����Ż�figure�ĺ�������(*.m)', '��ѡ����Ҫ�洢��λ��', 'BeautyNow.m');
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
%% ���ػ���������Ϣ
function out = func_loadDefaultConfig(graphicsTemplate, graphicsName)
    for iter = 1:numel(graphicsTemplate)
        if (strcmpi(graphicsName, graphicsTemplate(iter).Name))
            break;
        end
    end
    out = graphicsTemplate(iter).Data;
end