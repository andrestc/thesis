function [class, D] = phasespace_ise_classify(signal, signalsTrain, h, timeLag, dimension)

D = [];
train = signalsTrain(:,2:end);
parfor i=1:size(signalsTrain,1)
    D(i) = phasespace_ise(signal, train(i,:), dimension, timeLag, h);
end

[~, idx] = min(D);
class = signalsTrain(idx,1);

end


