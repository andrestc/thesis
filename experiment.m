clear; clc;

files = dir('./data');
files = files(arrayfun(@(x) x.name(1), files) ~= '.');
SETS = extractfield(files, 'name');

for s=SETS
    set = s{:};
    disp(set);
    TRAIN = load(strcat('data/',set,'/',set,'_TRAIN'));
    TEST = load(strcat('data/',set,'/',set,'_TEST'));
    
    tau = choose_tau(TRAIN(:,2:end)); 
    d = choose_dimension(TRAIN(:,2:end), tau);
    h = [0.01 0.05 0.1 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5];
    
    acc = []; conf = {}; dists = {};
    for i=1:length(h)
        class = zeros(size(TEST,1), 1);
        D = zeros(size(TEST,1), size(TRAIN,1));
        tic;
        for j=1:size(TEST,1)
            [class(j), D(j,:)] = phasespace_ise_classify(TEST(j,2:end),TRAIN, h(i), tau, d);
        end
        elapsed(i) = toc;
        acc(i) = mean(class == TEST(:,1));
        conf{i} = confusionmat(TEST(:,1), class);
        dists{i} = D;
        disp([h(i) acc(i)]);
        save(strcat('./results/', set, '.mat'), 'acc', 'conf', 'dists', 'd', 'h', 'tau', 'i', 'set', 'elapsed');
    end
end

%% Generate results table
results = [];
for s=SETS
    set = s{:};
    r = load(strcat('./results/', set, '.mat'));
    [~, i] = max(r.acc(2:end));
    results = [results; r.acc];
end
header = {};
i = 1;
for h=r.h
    header{i} = strcat('h_', strrep(num2str(h), '.', '_'));
    i = i + 1;
end
T = array2table(results, 'RowNames', SETS, 'VariableNames', header);
disp(T);

writetable(T, 'table.csv')



