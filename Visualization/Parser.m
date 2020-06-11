% TODO 编写自定义的template的解析器
% https://zhuanlan.zhihu.com/p/73508815
clear;

digit = @(source)satisfy(@(x) x>='0' & x<='9', source);
lower = @(source)satisfy(@(x) x>='a' & x<='z', source);
upper = @(source)satisfy(@(x) x>='A' & x<='Z', source);
charEq = @(target, source)satisfy(@(x) strcmp(x, target), source);
charNeq = @(target, source)satisfy(@(x) ~strcmp(x, target), source);
whiteSpace = @(source)oneOf(@(x)charEq(' ',x), @(x) charEq(newline,x), @(x)charEq(sprintf('\t'),x), source);

disp(['first:',conf_first('abc'),conf_first('')]);
disp(['inject:', conf_inject(1,'123'), conf_inject(2,'')]);

disp(['map:',conf_map(@(x)conf_inject(1,x), @(x)x+3, 'test')]);
disp(['apply:',conf_apply(@(x)conf_inject(@(t)t+1, x), @(x)conf_inject(1,x), '123')]);
disp(['applyAll:', conf_applyAll(@(x)conf_inject(@(m,n)m+n,x), @(x)conf_inject(1,x), @(x)conf_inject(2,x), '123');
])
disp(['satify', satisfy(@(x)strcmp(x, '1'), '423')]);
disp(['digit:',digit('1'),digit('a'),digit('A')]);
disp(['lower:',lower('1'),lower('a'),lower('A')]);
disp(['upper:',upper('1'),upper('a'),upper('A')]);
disp(['charEq:',charEq('0','0'),charEq('0','1')]);
disp(['charNeq:',charNeq('1','123'),charNeq('a','abc')]);
disp(['either:', either(@(x)charEq('0',x), @(x)charEq('1', x), '123')])
disp(['oneOf:', oneOf(@(x)charEq('0',x), @(x)charEq('1',x), @(x)charEq('2',x), '123')])
disp(['whiteSpace:',whiteSpace(' '), whiteSpace(newline), whiteSpace(sprintf('\t')), whiteSpace('a')])

disp(['string:', conf_string('123','1234')])
% fid = fopen('tmplate.txt', 'r', 'b', 'UTF-8');
% % disp(ferror(fid));
% confStr = fscanf(fid, '%c');
% disp(confStr);
% figure_Pattern = 'figure:\s*:\s*{';
% fclose(fid);
return;

% disp()
return;

fid = fopen('tmplate.txt', 'r', 'b', 'UTF-8');
% disp(ferror(fid));
confStr = fscanf(fid, '%c');
disp(confStr);
figure_Pattern = 'figure:\s*:\s*{';
fclose(fid);



% parser 获取第一个字符串
function out = conf_first(source)
    if (~isempty(source))
        out = {source(1),source(2:end)};
    else
        out = 'empty source';
    end
end
% constructor 传参
function out = conf_inject(values, source)
    funcTmp = @(source){values, source};
    out = funcTmp(source);
end
% 判断是否是字符串
function out = isFailed(result)
    out = ischar(result);
end
% 映射
function out = conf_map(parser, f, source)
    function res = funcTmp(source)
        result = feval(parser, source);
        if(isFailed(result))
            res = result;
        else
            data = result{1};
            rest_source = result{2};
            res = {feval(f, data), rest_source};
        end
    end
    out = funcTmp(source);
end

function out = conf_apply(parseFn, parseArg, source)
    function res = funcTmp(source)
        resultFn = feval(parseFn, source);
        if(isFailed(resultFn))
            res = resultFn;
            return;
        end
        fn = resultFn{1}; rest_source_fn = resultFn{2};
        % resultArg = parseArg(rest_source_fn);
        resultArg = feval(parseArg, rest_source_fn);
        if(isFailed(resultArg))
            res = resultArg;
            return;
        end
        arg = resultArg{1}; rest_source_arg = resultArg{2};
        res = {feval(fn, arg), rest_source_arg};
    end
    out = funcTmp(source);
end
% apply多个变量
function out = conf_applyAll(varargin)
    % TODO: 补全apply all的实现函数
    if (nargin>=3)
        source = varargin(nargin);
        
        parserFn = varargin{1};
        parserFn = parserFn(' ');
        parserFn = parserFn{1};
        tmpStr = '';
        for index = 2:nargin-2
           eval(['f',num2str(index),'=varargin{',num2str(index),'};']); 
           eval(['f',num2str(index),'=f',num2str(index),'(" ");']);
           eval(['f',num2str(index),'=f',num2str(index),'{1};']);
           tmpStr = [tmpStr,'f',num2str(index),','];
        end
        parserEnd = eval(['@(source)conf_inject(@(x)parserFn(',tmpStr,'x), source);']);
        
        out = conf_apply(parserEnd, varargin{nargin-1}, source);
    else
        out = 'too few input parameters';
    end
end
% 实现了parser维度的字符条件判断语句
function out = satisfy(predicate, source)
    function res = funcTmp(source)
        result = conf_first(source);
        if(isFailed(result))
            res = result;
            return;
        end
        char = result{1};
        rest_source = result{2};
        if(~predicate(char))
            res = ['Unexpect char ', char];  
            return;
        end
        res = {char, rest_source};
    end
    out = funcTmp(source);
end


% 判断满足其中一个Parser
function out = either(parserA, parserB, source)
    function res = funcTmp(source)
        resultA = feval(parserA, source);
        if(~isFailed(resultA))
            res = resultA;
        else
            res = feval(parserB, source);
        end
    end
    out = funcTmp(source);
end
% 其中一个是否满足
function out = oneOf(varargin)
    if (nargin>=3)
        source = varargin{nargin};
        for index = 1:(nargin-2)
            result = feval(varargin{index}, source);
            if(~isFailed(result))
                out = result;
                return;
            end
        end
        out = feval(varargin{nargin-1}, source);
    else
        out = 'error';
    end
end

% 一直匹配，直至无效
function out = conf_many(parser, source)
    function res = concat(item, source)

    end

    out = either(@(source)concat(source), @(source)conf_inject({}, source));
end

function out = conf_string(str, source)
    if(numel(str)==0)
        out = conf_inject('', source);
        return;
    end
    
    out = conf_applyAll(@(source)conf_inject(@(x,xs)x+xs), @(x)charEq(str(1),x), @(x)conf_string(str(2:end),x));
end