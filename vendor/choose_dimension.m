function dimension = choose_dimension(signals, timeLag)

MAX_DIM = 50;
MIN_PERCENT_FNN = 0.001;

numberOfSignals = size(signals,1);
dimensions = zeros(numberOfSignals,1);

fprintf(['\n' repmat('.',1,numberOfSignals) '\n\n']);
parfor i = 1:numberOfSignals
  out = false_nearest(signals(i,:),1,MAX_DIM,timeLag);
  m = find(out(:,2) <= MIN_PERCENT_FNN);
  if ~isempty(m)
      dimensions(i) = m(1);
  else
      [~, dimensions(i)] = min(out(:,2));
  end
  fprintf('\b|\n');
end 

dimension = ceil(mean(dimensions) + 2 * std(dimensions));

return