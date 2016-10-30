clear; clc;

SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};

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
SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};

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



%% Multiple d, tau e h (For?a Bruta)
clear; clc;

%SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};
%SETS = { 'Lighting2' 'Lighting7' 'OliveOil'};
SETS = {'ECG200'};
tau = [1:50];
d = 2;
h = [0.1];
    
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
                save(strcat('./results/FB_50_tau_', set, '.mat'), 'acc', 'conf', 'dists', 'd', 'h', 'tau', 'i', 'set', 'elapsed');
            end
        end
    end
end

%% Genereta results table
SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};
results = zeros(4,4);
l = 1;
for s=SETS
    set = s{:};
    r = load(strcat('./results/FB_more_range_', set, '.mat'));
    [m, I] = max(r.acc(:));
    [i, j, k] = ind2sub(size(r.acc),I);
    results(l,:) = [m r.h(i) r.d(j) r.tau(k)];
    l=l+1;
end
T = array2table(results, 'RowNames', SETS, 'VariableNames', {'acc' 'h' 'd' 'tau'});
disp(T);

%writetable(T, 'tableFB.csv')



