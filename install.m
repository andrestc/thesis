addpath(fullfile(pwd, 'deps'),path);
addpath(fullfile(pwd,'funcs'),path);

resultsDir = sprintf('./results');
% Finally, create the folder if it doesn't exist already.
if ~exist(resultsDir, 'dir')
  mkdir(resultsDir);
end
