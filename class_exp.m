clear; clc;

SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};
%SETS = {'Synthetic_Control'};
for s=SETS
    set = s{:};
    disp(set);
    TRAIN = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TRAIN'));
    TEST = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TEST'));
    
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



%% Multiple d, tau e h (Força Bruta)
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
    TRAIN = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TRAIN'));
    TEST = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TEST'));
        
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
%SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};
SETS = { 'Lighting2' 'Lighting7' 'Beef' 'OliveOil'};
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



%% Primeiro EXP agora com GMM
clear; clc;

SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};

for s=SETS
    set = s{:};
    disp(set);
    TRAIN = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TRAIN'));
    TEST = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TEST'));
    
    tau = choose_tau(TRAIN(:,2:end)); 
    d = choose_dimension(TRAIN(:,2:end), tau);
    h = [1 2 4 8 16 32];
    
    acc = []; conf = {}; dists = {};
    while length(acc) < length(h)
        i = length(acc) + 1;
        class = zeros(size(TEST,1), 1);
        D = zeros(size(TEST,1), size(TRAIN,1));
        tic;
        try
            models = learnModelsMat(TRAIN, h(i), tau, d);
        catch
            disp(['failed to learn models', num2str(i)]);
            continue
        end
        for j=1:size(TEST,1)
            class(j) = classify(TEST(j,2:end),models, tau, d);
        end
        elapsed(i) = toc;
        acc(i) = mean(class == TEST(:,1));
        conf{i} = confusionmat(TEST(:,1), class);
        disp([h(i) acc(i)]);
        save(strcat('./results/', set, '_gmm.mat'), 'acc', 'conf', 'd', 'h', 'tau', 'i', 'set', 'elapsed');
    end
end

%% Generate results table
SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};

results = [];
for s=SETS
    set = s{:};
    r = load(strcat('./results/', set, '_gmm.mat'));
    results = [results; r.acc];
end

header = {};
i = 1;
for h=r.h
    header{i} = strcat('m_', strrep(num2str(h), '.', '_'));
    i = i + 1;
end
T = array2table(results, 'RowNames', SETS, 'VariableNames', header);
disp(T);

writetable(T, 'table_gmm.csv')


%% Multiple d, tau e h (Força Bruta)
clear; clc;

SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};

tau = [1 3 5];
d = 2:2:20;
h = [8 16 32];
    
for s=SETS
    set = s{:};
    disp(set);
    TRAIN = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TRAIN'));
    TEST = load(strcat('../UCR_TS_Archive_2015/',set,'/',set,'_TEST'));
        
    acc = []; conf = {}; dists = {};
    for i=1:length(h)
        for j=1:length(d)
            for k=1:length(tau)
                class = zeros(size(TEST,1), 1);
                D = zeros(size(TEST,1), size(TRAIN,1));
                try
                    models = learnModelsMat(TRAIN, h(i), tau(k), d(j));
                catch
                    disp('failed to learn models');
                    acc(i,j,k) = 0;
                    conf{i,j,k} = [];
                    save(strcat('./results/FB_', set, '_gmm.mat'), 'acc', 'conf', 'd', 'h', 'tau', 'i', 'set');
                    continue
                end
                for x=1:size(TEST,1)
                    try
                        class(x) = classify(TEST(x,2:end),models, tau(k), d(j));
                    catch
                        class(x) = Inf;
                    end
                end

                acc(i,j,k) = mean(class == TEST(:,1));
                conf{i,j,k} = confusionmat(TEST(:,1), class);
                disp([h(i) acc(i,j,k) d(j) tau(k)]);
                save(strcat('./results/FB_', set, '_gmm.mat'), 'acc', 'conf', 'dists', 'd', 'h', 'tau', 'i', 'set');
            end
            
        end

    end
end

%% Genereta results table
SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};

results = zeros(11,4);
tau = [1 3 5];
d = 2:2:20;
h = [8 16 32];
l = 1;
for s=SETS
    set = s{:};
    r = load(strcat('./results/FB_', set, '_gmm.mat'));
    acc = r.acc(:,:,1);
    [m, I] = max(acc(:));
    [i, j, k] = ind2sub(size(r.acc),I);
    results(l,:) = [m r.h(i) r.d(j) r.tau(k)];
    l=l+1;
end
T = array2table(results, 'RowNames', SETS, 'VariableNames', {'acc' 'h' 'd' 'tau'});
disp(T);

writetable(T, 'tableFB_gmm.csv')


%% view results elapsed time
clear; clc;
SETS = {'Synthetic_Control' 'Gun_Point' 'CBF' 'Trace' 'FaceFour' 'Lighting2' 'Lighting7' 'ECG200' 'Beef' 'Coffee' 'OliveOil'};
Eise = [];
Egmm = [];
Mgmm = [];
for s=SETS
    set = s{:};
    r = load(strcat('./results/', set, '.mat'));
    Eise = [Eise; r.elapsed];
    Hise = [r.h];
    
    r = load(strcat('./results/', set, '_gmm.mat'));
    Egmm = [Egmm; r.elapsed];
    Mgmm = [r.h];
end
