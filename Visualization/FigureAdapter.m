%% 将xml格式转换成MATLAB图片里的设置。
% 避免了MATLAB绘图函数的复杂

fid = fopen('template.m', 'r', 'b', 'gb2312');
% disp(ferror(fid));
confStr = fscanf(fid, '%c');
% disp(confStr);
% figure_Pattern = 'figure:\s*:\s*{';
fclose(fid);

disp(confStr)


f = gcf;
ss=Parser(f, Lexer(confStr));
disp(ss)
% for ii = 1:numel(out)
%     disp({out(ii).Type,out(ii).Value});
% end
% Parser
function SetFigureByConf(figureHandle, conf)
    try
        axesHandler = figureHandle.Children;
        graphHandler = axesHandle.Children;

        figConf = conf{1};
        figConf_fieldName = fieldnames(figConf);
        figConfLen = length(figConf_fieldName);
        disp(class(graphHandler));
        % for index = 1:figConfLen
        %     if (strcmp(class(), 'struct'))

        %     end
        % end

    catch ME
        rethrow(ME)
    end
end
function out = Parser(tokens)
out = {};
index = 1;
while(index<=numel(tokens))
    token = tokens(index);
    if (strcmp(token.Type, 'Tag') && strcmp(token.Value, '[figure]'))
        if(exist('figureTag', 'var'))
            out{end+1} = figureTag;
        end
        figureTag = [];
    else
        if(exist('figureTag', 'var'))
            switch token.Type
                case 'Property'
                    if(strcmp(tokens(index+1).Type, 'Value'))
                        eval(['figureTag.', token.Value,'=', tokens(index+1).Value,';']);
                        index = index+1;
                    else
                        error('No value for %s', token.Value);
                    end
                case 'Tag'
                    tagName = token.Value; tagName = tagName(2:(end-1));
                    checkTag(tagName);
                    [tmpClass, len] = addTag(tokens((index+1):end), tagName);
                    index = index+len;
                    eval(['figureTag.', tagName,'=tmpClass;']);
                case 'Comment'
                    disp({token.Type, token.Value});
                otherwise
                    error('Unexpected %s in configuration file', token.Value);
            end
        end
    end
    index = index+1;
end
out{end+1} = figureTag;
end
% Lexer
function out = Lexer(inputStr)
tokens = [];
cursor = 1;
while (cursor<=numel(inputStr))
    token = [];
    switch inputStr(cursor)
        case '['
            [out, len] = parserTag(inputStr(cursor:end));
            token.Type = 'Tag';
            token.Value = out;
            cursor = cursor+len;
        case '%'
            [out, len] = parserComment(inputStr(cursor:end));
            token.Type = 'Comment';
            token.Value = out;
            cursor = cursor+len;
        case ':'
            [out, len] = parserValue(inputStr(cursor:end));
            token.Type = 'Value';
            token.Value = out;
            cursor = cursor+len;
        otherwise
            if(isletter(inputStr(cursor)))
                [out, len] = parserProperty(inputStr(cursor:end));
                token.Type = 'Property';
                token.Value = out;
                cursor = cursor+len;
            else
                cursor = cursor+1;
            end
    end
    if(~isempty(token))
        tokens = [tokens, token];
    end
end

out = tokens;
end

% 匹配绘图标签，figure plot等
function [out, len] = parserTag(inputStr)
cursor = 1;
while(cursor<=numel(inputStr) && ~strcmp(inputStr(cursor), ']'))
    if(strcmp(inputStr(cursor), newline))
        error('unexpected line break in [...]');
    end
    cursor = cursor+1;
end
len = cursor;
out = inputStr(1:cursor);
end
% 匹配样式表的注释
function [out, len] = parserComment(inputStr)
cursor = 1;
while(cursor<=numel(inputStr) && ~strcmp(inputStr(cursor), newline))
    cursor = cursor+1;
end
out = inputStr(1:cursor-1);
len = cursor;
end
% 匹配属性名
function [out, len] = parserProperty(inputStr)
cursor = 1;
while(cursor<=numel(inputStr) && ~strcmp(inputStr(cursor), ':'))
    cursor = cursor+1;
end
len = cursor-1;
out = strip(inputStr(1:len));
end
% 匹配属性值
function [out, len] = parserValue(inputStr)
cursor = 1;
while(cursor<=numel(inputStr) && ~strcmp(inputStr(cursor), '%') && ~strcmp(inputStr(cursor), newline))
    cursor = cursor+1;
end
len = cursor;
out = inputStr(2:len);
if(endsWith(out, '%'))
    len = len-1;
    out(end) = [];
end
out = strip(out);
end
% 匹配得到的Tag值
function [out, len] = addTag(tokens, tagName)
index = 1;
while(index<=numel(tokens) && ~strcmp(tokens(index).Type, 'Tag'))
    token = tokens(index);
    tokenNext = tokens(index+1);
    if(strcmp(token.Type, 'Property') && strcmp(tokenNext.Type, 'Value'))
        eval(['out.', token.Value, '=', tokenNext.Value]);
        index = index+2;
    else
        error('Error in Tag: %s', tagName);
    end
end
len = index-1;
end
%% 检查tagName是否是Figure中的属性
function checkTag(tagName)
    defaultTag = ["plot", "bar", "plot3", "stem", "legend", "surf", "text", "scatter", "scatter3"...
    "pie", "pie3", "porlar", "porlarplot", "histogram"];
    if (~contains(defaultTag, lower(tagName)))
        error(['There is no "', tagName, '" in the figure settings!"']);
    end
end