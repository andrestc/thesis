% This experiment runs for multiple combinations of dimension, tau and bandwith
% The generated results table contains the result of the best combination for each dataset
clear; clc;

files = dir('./data');
files = files(arrayfun(@(x) x.name(1), files) ~= '.');
SETS = extractfield(files, 'name');

tau = 1:30;
d = 2:2:20;
h = 0.1:0.1:5;
    
for s=SETS
    set = s{:};
    disp(set);
    TRAIN = load(strcat('data/',set,'/',set,'_TRAIN'));
    TEST = load(strcat('data/',set,'/',set,'_TEST'));
        
    acc = []; conf = {}; dists = {}; elapsed = [];
    for i=1:length(h)
        for j=1:length(d)
            for k=1:length(tau)
                class = zeros(size(TEST,1), 1);
                D = zeros(size(TEST,1), size(TRAIN,1));
                tic;
                for x=1:size(TEST,1)
                    [class(x), D(x,:)] = phasespace_ise_classify(TEST(x,2:end),TRAIN, h(i), tau(k), d(j));
                end
                elapsed(i,j,k) = toc;
                acc(i,j,k) = mean(class == TEST(:,1));
                conf{i,j,k} = confusionmat(TEST(:,1), class);
                dists{i,j,k} = D;
                disp([h(i) acc(i,j,k) d(j) tau(k)]);
                save(strcat('./results/grid_', set, '.mat'), 'acc', 'conf', 'dists', 'd', 'h', 'tau', 'i', 'set', 'elapsed');
            end
        end
    end
end

%% Genereta results table
results = zeros(4,4);
l = 1;
for s=SETS
    set = s{:};
    r = load(strcat('./results/grid_', set, '.mat'));
    [m, I] = max(r.acc(:));
    [i, j, k] = ind2sub(size(r.acc),I);
    results(l,:) = [m r.h(i) r.d(j) r.tau(k)];
    l=l+1;
end
T = array2table(results, 'RowNames', SETS, 'VariableNames', {'acc' 'h' 'd' 'tau'});
disp(T);

writetable(T, './results/table_grid.csv')
