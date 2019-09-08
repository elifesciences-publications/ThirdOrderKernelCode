function [databaseInfo] = UiGetPreCommentsSurgery(defaults)

if nargin < 1 || isempty(defaults)
    % Because perfusion should always be on...
    defaults.perfusion = true;
end

allowEmpty = true;
connDb = connectToDatabase('', allowEmpty);
sysConfig = GetSystemConfiguration;
expressionSystems = '';
if ~isempty(connDb)
    % Grab the database's expression systems
    expressionSystems = fetch(connDb, 'select name from expressionSystem');
    % Save them to a local file for when there's no database
    % First check whether the file's already been saved
    expSysTxtH = fopen(fullfile(sysConfig.logPath, 'expressionSystems.txt'), 'r');
    expSysTxt = '';
    if expSysTxtH ~= -1
        expSysTxt = fread(expSysTxtH);
        fclose(expSysTxtH);
        expSysTxt = char(expSysTxt');
    end
    % Save to it if it hasn't been saved
    if ~strcmp(strjoin(expressionSystems, '\n'), expSysTxt)
        expSysTxtH = fopen(fullfile(sysConfig.logPath, 'expressionSystems.txt'), 'w');
        fprintf(expSysTxtH, strjoin(expressionSystems, '\n'));
        fclose(expSysTxtH);
    end
else
    disp('Using save expression system file');
    % If there's no database (say, the mapped network drive failed to
    % connect), find the file saved in the logpath and use its
    % expressionSystems values
    expSysTxtH = fopen(fullfile(sysConfig.logPath, 'expressionSystems.txt'), 'r');
    if expSysTxtH ~= -1
        expSysTxt = fread(expSysTxtH);
        expSysTxt = char(expSysTxt');
        expressionSystems = strsplit(expSysTxt, sprintf('\n'));
    end
end

formats = {};
entryNum = 0;

entryNum = entryNum + 1;
prompts(entryNum, :) = {sprintf('Genotype (use format from this example: w_+;UASGC6f_+;T4_+'), 'genotype', []};
formats(entryNum,1).type = 'edit';
formats(entryNum,1).format = 'text';
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Cell type (i.e. T4T5)', 'cellType', []};
formats(entryNum,1).type = 'edit';
formats(entryNum,1).format = 'text';
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Fluorescent protein (i.e. GC6f)', 'fluorescentProtein', []};
formats(entryNum,1).type = 'edit';
formats(entryNum,1).format = 'text';
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Expression system (you can select more than one, i.e. GAL4-UAS and lexA-lexAop2', 'expressionSystem', []};
formats(entryNum,1).type = 'list';
formats(entryNum,1).style = 'listbox';
formats(entryNum,1).format = 'text';
formats(entryNum,1).items = expressionSystems;
formats(entryNum,1).labelloc = 'topleft';
formats(entryNum,1).required = 'on';
formats(entryNum,1).limits = [0 4];

% Prompt(end+1,:) = {'Auction Sites:','Site',[]};
% Formats(11,1).type = 'list';
% Formats(11,1).style = 'listbox';
% Formats(11,1).format = 'text'; % Answer will give value shown in items, disable to get integer
% Formats(11,1).items = {'www.auction1.com';'www.auction2.com';'www.bidme.com';'www.bestvalu.com'};
% Formats(11,1).limits = [0 4]; % multi-select
% Formats(11,1).size = [140 80];
% % Formats(11,1).span = [3 1];  % item is 2 fields x 1 fields
% DefAns.Site = {'www.auction1.com','www.bidme.com'};



entryNum = entryNum+1;
prompts(entryNum, :) = { 'Surgeon', 'surgeon', []};
formats(entryNum,1).type = 'edit';
formats(entryNum,1).format = 'text';
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Condition (1-5)', 'condition', []};
formats(entryNum,1).type = 'list';
formats(entryNum,1).format = 'text';
formats(entryNum,1).style = 'radiobutton';
formats(entryNum,1).items = {'1', '2', '3', '4', '5'};
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Eye (left or right)', 'eye', []};
formats(entryNum,1).type = 'list';
formats(entryNum,1).format = 'text';
formats(entryNum,1).style = 'radiobutton';
formats(entryNum,1).items = {'left', 'right'};
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Enter any comments', 'comments', []};
formats(entryNum,1).type = 'edit';
formats(entryNum,1).format = 'text';
formats(entryNum,1).labelloc = 'topleft';

entryNum = entryNum+1;
prompts(entryNum, :) = { 'Perfusion                         ', 'perfusion', []};
formats(entryNum,1).type = 'check';
formats(entryNum,1).format = '';
formats(entryNum,1).style = 'checkbox';
formats(entryNum,1).items = {'Perfusion', 'Not perfusion'};
formats(entryNum,1).labelloc = 'topleft';
perfusionValues = {'No perfusion', 'Check perfusion solution!'};
colorValues = {[.9 .9 .9], [1 0 0]};
formats(entryNum,1).callback = @(~,~,h,k)set(h(k),'String',perfusionValues{get(h(k), 'Value')+1}, 'BackgroundColor', colorValues{get(h(k), 'Value')+1});
perfusionHandleNum = entryNum;

entryNum = entryNum+1;
prompts(entryNum, :) = { 'same fly', 'sameFly', []};
formats(entryNum,1).type = 'check';
formats(entryNum,1).format = '';
formats(entryNum,1).style = 'checkbox';
formats(entryNum,1).items = [0 1];
formats(entryNum,1).labelloc = 'topleft';

dialogTitle = 'Fly database input';

% numLines = [1 80; 1 40; 1 40; 1 80; 1 40; 1 40; 5 80];
% answer = inputdlg(prompts, 'Fly database input',numLines);

options.Interpreter = 'none';
options.CancelButton = 'off';
options.ButtonNames = {'Submit'};
options.CreateFcn = @(~,~,h)set(h(perfusionHandleNum),'String',perfusionValues{get(h(perfusionHandleNum), 'Value')+1}, 'BackgroundColor', colorValues{get(h(perfusionHandleNum), 'Value')+1});

[databaseInfo,Cancelled] = InputsDlg(prompts,dialogTitle,formats,defaults,options);
databaseInfo.expressionSystem = strjoin(databaseInfo.expressionSystem, sprintf('\n'));
% [genostr, cellType, fluorescentProtein, experimenter, condition, eye, condstr] = databaseInfo{:};