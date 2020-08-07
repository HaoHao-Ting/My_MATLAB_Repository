% https://zhuanlan.zhihu.com/p/92866972
% https://juejin.im/post/5dba337df265da4d26043666
global TokenType
TokenName = {'OpenBrace','CloseBrace','COLON','NUMBER', 'SHARP'};
TokenValue = {'{', '}',':','NUMBER','%'};
TokenType = containers.Map(TokenName, TokenValue);


fid = fopen('tmplate.txt', 'r', 'b', 'UTF-8');
% disp(ferror(fid));
confStr = fscanf(fid, '%c');
% disp(confStr);
% figure_Pattern = 'figure:\s*:\s*{';
fclose(fid);

tokens = Lexer(confStr);

for ii = 1:numel(tokens)
    disp([tokens(ii).Type,':', tokens(ii).Value])
end

isFlag = 0;
function out = Lexer(inputStr)
global TokenType
tokens = [];
index = 1;
while (index<=numel(inputStr))
    token = [];
    switch inputStr(index)
        case TokenType('OpenBrace')
            token.Type = 'OpenBrace'; token.Value = inputStr(index);
            index = index+1;
        case TokenType('CloseBrace')
            token.Type = 'CloseBrace'; token.Value = inputStr(index);
            index = index+1;
        case TokenType('SHARP')
            [out, len] = parseComment(inputStr(index:end));
            token.Type = 'SHARP';
            token.Value = out;
            index = index+len;
        case ' '
            index = index+1;          
        case TokenType('COLON')
            token.Type = 'COLON'; token.Value = inputStr(index);
            index = index+1;
        otherwise
            if(isletter(inputStr(index)) || ~isnan(str2double(inputStr(index))) ...
                    || strcmp(inputStr(index), "'") || strcmp(inputStr(index), '"')...
                    && strcmp(inputStr(index), '['))
                [out, len] = parserVales(inputStr(index:end));
                token.Type = 'PROPERTY';
                token.Value = out;
                index = index+len-1;
            else
                index = index+1;
            end
    end
    if(~isempty(token))
        tokens = [tokens, token];
    end
end

out = tokens;
end

function [out, len] = parseComment(inputStr)
cursor = 1;
while(~strcmp(inputStr(cursor), newline) && cursor<=numel(inputStr))
    cursor = cursor+1;
end
out = inputStr(1:cursor);
len = cursor;
end
function [out, len] = parserString(inputStr)
cursor = 1;
while(cursor<=numel(inputStr) && ~strcmp(inputStr(cursor), ':') && ~strcmp(inputStr(cursor), ' '))
    cursor = cursor+1;
end
out = inputStr(1:cursor-1);
len = cursor;
end
function [out, len] = parserVales(inputStr)
cursor = 1;
while(cursor<=numel(inputStr) && ~strcmp(inputStr(cursor), '%') && ~strcmp(inputStr(cursor), newline)...
        && ~strcmp(inputStr(cursor), ':'))
    cursor = cursor+1;
end
out = inputStr(1:cursor-1);
len = cursor;
end