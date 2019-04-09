function loadFlexibleInputs(Z, inputsRequired)
% %% Receive input variables
% for ii = 1:2:length(varargin)
%     eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
% end 
% %% Load params structure
% if exist('Z') && isfield(Z,'params')
%     paramsFields = fieldnames(Z.params);
%     for ii = 1:length(paramsFields)
%         eval([paramsFields{ii} ' = Z.params.' paramsFields{ii}]);
%     end
% end
% paramsFields = fieldnames(Z.params);
% for ii = 1:length(paramsFields)
%     eval([paramsFields{ii} ' = Z.params.' paramsFields{ii} ';']);
% end
if nargin<2
    inputsRequired = {};
end

paramsFields = fieldnames(Z.params);
for ii = 1:length(paramsFields)
    if any(strcmp(inputsRequired, paramsFields{ii})) || isempty(inputsRequired)
        assignin('caller', paramsFields{ii}, Z.params.(paramsFields{ii}));
    end
end

end