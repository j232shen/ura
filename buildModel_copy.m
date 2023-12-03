% ACTION: Select how many windows are desired for each muscle's EMG signal, per trial
% So far, n = 7 optimizes the "P" model
n = 7; 

% ACTION: Select "P" or "N" experiment
[emg, subject] = get_N_emg(n); 

%% Combining training data
% ACTION: Select number of observations per subject to be used for training
k = 10; 

% ACTION: Pick minimum number of elements desired per bin
min = 5;

% ACTION: Pick appropriate edges for "P" and "N" experiments
% edges = 10:10:50; % P
edges = 10:10:70; % N

count = 0;
Rsquared = [];

while(count <= 1)
    even = false;
    while(~even)
        features = [];
        regressors = [];

        for i = 1:length(emg)
            rng = randperm(length(emg(i).activeRange), k);
            for j = 1:length(rng)
                row = rng(j);
                
                subject_features = [emg(i).features.bicep(row,:), emg(i).features.tricep(row,:), ...
                emg(i).features.delt(row,:), emg(i).features.trap(row,:), ...
                emg(i).features.pecMajor(row,:), emg(i).features.infra(row,:)];
        
                features = [features; subject_features];
                regressors = [regressors; subject(i).reachAngle(row)];
            end
        end

        [N, edges] = histcounts(regressors, edges);
        even = ~any(N < min); % ACTION: Pick minimum number of elements desired per bin
    end

    %% Building model
    model = fitlm(features, regressors);
    Rsquared = [Rsquared; model.Rsquared.Ordinary];

    count = count + 1;
end

disp(mean(Rsquared));

%% Combining test data
newFeatures = [];
newRegressors = [];
for i = 1:length(emg)
    for j = 1:length(subject(i).reachAngle)
        if any(ismember([j], rng)) == false % if j is not in rng (training set)
            subject_features = [emg(i).features.bicep(j,:), emg(i).features.tricep(j,:), ...
            emg(i).features.delt(j,:), emg(i).features.trap(j,:), ...
            emg(i).features.pecMajor(j,:), emg(i).features.infra(j,:)];

            newFeatures = [newFeatures; subject_features];
            newRegressors = [newRegressors; subject(i).reachAngle(j)];
        end
    end
end

%% Comparing model predictions to observations
[predicted, CI] = predict(model, newFeatures);
predictionError = get_error(predicted, newRegressors);

disp(predictionError);