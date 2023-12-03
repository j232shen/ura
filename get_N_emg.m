function [emg, subject] = get_N_emg(n)
% This function creates a structure array of EMG signals over active reach 
% states from "P" (passive-active) trials only. It takes an input 'n' for 
% the desired number of EMG signal windows per muscle.

% Subject properties and purposes:
% MVC           -->     contains Time and Data fields from the MVC trial
% S1 ... S5     -->     contains Time and Data fields for 12 consecutive trials per set
% activeRange   -->     start and end times of state 4 (active reaching) in EMG data, over the entire experiment
% normTrials    -->     normalized EMG signals for each muscle, and isolated by trial ""
% features      -->     features generated for each muscle and each trial ""

    subject = get_N_subjects();
    
    path = {'C:\Users\janex\Desktop\School\URA\Analysis\Exports\EMG_Jane\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Exports\EMG_Milad\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Exports\EMG_Joseph\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Exports\EMG_Yewon\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Exports\EMG_Steph\'};
    
    emg = []; % struct (array) for subject structs
    
    for i = 1:length(path) % for each subject folder
        files = dir(path{i});
        len = length(files); % varies from subject to subject as some have repeated MVCs; need last 11 files
    
        MVC = load(fullfile(path{i}, files(len - 10).name)); 
        S1 = load(fullfile(path{i}, files(len - 4).name));
        S2 = load(fullfile(path{i}, files(len - 3).name));
        S3 = load(fullfile(path{i}, files(len - 2).name));
        S4 = load(fullfile(path{i}, files(len - 1).name));
        S5 = load(fullfile(path{i}, files(len).name));
    
        % emg subject creation
        emg = [emg; struct('MVC', MVC, ...
            'S1', S1, ...
            'S2', S2, ...
            'S3', S3, ...
            'S4', S4, ...
            'S5', S5, ...
            'activeRange', [], ...
            'normTrials', [], ...
            'features', [])];  
        
    end
    
    %% SUBPROCESS: looking for corresponding start/end times of state 4 in EMG data
    for i = 1:length(path)
        allActiveRange = []; % 2 column matrix for start and end indices in EMG data; col 1 = start, col 2 = end
        prevTime = 0;
        setNum = 1;
        for j = 1:length(subject(i).activeStartTimes)
            if subject(i).activeStartTimes(j) < prevTime
                setNum = setNum + 1;
                prevTime = 0; % reset
            else
                prevTime = subject(i).activeStartTimes(j);
            end
            switch setNum
                case 1
                    [endIdx, startIdx] = get_range(emg(i).S1.Time(1,:), subject(i).activeStartTimes(j), subject(i).activeEndTimes(j));
                case 2
                    [endIdx, startIdx] = get_range(emg(i).S2.Time(1,:), subject(i).activeStartTimes(j), subject(i).activeEndTimes(j));
                case 3
                    [endIdx, startIdx] = get_range(emg(i).S3.Time(1,:), subject(i).activeStartTimes(j), subject(i).activeEndTimes(j));
                case 4
                    [endIdx, startIdx] = get_range(emg(i).S4.Time(1,:), subject(i).activeStartTimes(j), subject(i).activeEndTimes(j));
                otherwise % trialNum 5
                    [endIdx, startIdx] = get_range(emg(i).S5.Time(1,:), subject(i).activeStartTimes(j), subject(i).activeEndTimes(j));
            end
            allActiveRange = [allActiveRange; startIdx endIdx];
        end
        
        % disp(subject(i).activeStartTimes);
        % disp(subject(i).activeEndTimes);
        % disp(activeRange); 

        %% remove invalid trials 
        edge = false(1, length(path)); % [0 0 0 0 0]
        
        % N ONLY
        if i == 4 % if yewon, skip S3
            edge(3) = true;
        elseif i == 5 % if steph, skip S2 -> no Data field
            edge(2) = true; 
        end
        
        trueRange = []; % temp matrix for holding rows without 0's
        zeroIdx = []; % storing indices where EMG is 0 so that corresponding reachAngles can be removed from kinematic data

        % removing trials where EMG data does not include the corresponding timestamps 
        % (ie. where activeRange has at least one 0 value from binary search)
        for j = 1:length(allActiveRange)
            if allActiveRange(j,1) == 0 || allActiveRange(j,2) == 0
                zeroIdx = [zeroIdx; j];
            else
                trueRange = [trueRange; allActiveRange(j,:)];
            end
        end

        % if steph, skip S2
        if i == 5
            trueRange = [trueRange(1:12,:); trueRange(24:55,:)];
        end

        emg(i).activeRange = trueRange;
        % disp(emg(i).activeRange); 

        % removing same trials from kinematic data
        reachAngle = []; % valid regressors
        for j = 1:length(subject(i).reachAngle)
            if any(ismember([j], zeroIdx)) == false % if j is not in zeroIdx
                reachAngle = [reachAngle; subject(i).reachAngle(j)];
            end
        end

        % if steph, skip S2
        if i == 5
            reachAngle = [reachAngle(1:12,:); reachAngle(24:55,:)];
        end

        subject(i).reachAngle = reachAngle;

        % finding max trial length
        trial_length = emg(i).activeRange(:,2) - emg(i).activeRange(:,1); % all 1 less than true length
        max_trial_length = max(trial_length) + 1;
        
        % isolating EMG signals for each muscle
        trials = partition(emg(i), max_trial_length, emg(i).activeRange, edge);

        % normalizing trials
        emg(i).normTrials = get_norm(trials, emg(i).MVC.Data);

        % computing features for each muscle
        emg(i).features = get_features(emg(i).normTrials, n);
    end
    
end