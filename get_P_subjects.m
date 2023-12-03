function [subject] = get_P_subjects()
% This function creates a structure array of subjects and computes
% relevant properties needed for kinematic data analysis, 
% from "P" (passive-active) trials only.

% Subject properties and purposes:
% jointPos2          -->     for calculating target and reaching angles
% state              -->     for identifying desired data ranges depending on experiment state
% time               -->     experimentTime; for syncing with emg data
% targetAngle        -->     for computation of absolute error
% reachAngle         -->     for computation of absolute error
% angleError         -->     storing absolute error; for scatter/histogram plots
% meanErr            -->     mean errors for ranges of targetAngle; for errorbar plots
% stdev              -->     standard deviation of reachAngle for ranges of targetAngle; for errorbar plots
% activeStartTimes   -->     start times of state 4 (active reach) from kinematic data; for syncing with emg data
% activeEndTimes     -->     end times ""

    % cell array of folder directories
    path = {'C:\Users\janex\Desktop\School\URA\Analysis\Originals\ExpData\Jane_April_4\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Originals\ExpData\Milad_April_4\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Originals\ExpData\Joseph_April_5\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Originals\ExpData\Yewon_April_5\';
        'C:\Users\janex\Desktop\School\URA\Analysis\Originals\ExpData\Steph_April_26\'};
    
    % struct (array) for subject structs
    subject = [];
    
    %% extracting jointPos2, state, time fields
    for i = 1:length(path) % iterating through files
        % field arrays that need to be read and concatenated directly from file
        jointPos2 = [];
        state = [];
        time = [];
        
        files = dir(path{i});
        % vertcat variables across all P trials
        for j = 3:length(files) % j = 1, 2 -> '.' and '..' respectively
            if mod(j, 2) == 0 % even index; P trial
                P = readtable(fullfile(path{i}, files(j).name));
                jointPos2 = [jointPos2; P(:,11)]; 
                state = [state; P(:,16)];         
                time = [time; P(:,27)];
            end
        end
    
        % subject creation
        subject = [subject; struct('jointPos2', table2array(jointPos2), ...
            'state', table2array(state), ...
            'time', table2array(time), ...
            'targetAngle', [], ...
            'reachAngle', [], ...
            'angleError', [], ...
            'meanErr', [], ... 
            'stdev', [], ...
            'activeStartTimes', [], ...
            'activeEndTimes', [])];  
        
        %% computing targetAngle, reachAngle, angleError fields
        % SUBPROCESS: getting all unadjusted angles
        % state sequence for experiment 1 (P): 2, 5, 3, 6, 4, 5, 3, 6
        allAngles = [];
        % temp variables for identifying ranges of state 5
        startIndex = 0;
        endIndex = 0;
    
        for j = 1:length(subject(i).state) - 1
            if subject(i).state(j) == 2 && subject(i).state(j+1) == 5 % start of hold state
                startIndex = j+1;
            elseif subject(i).state(j) == 4 && subject(i).state(j+1) == 5 % alternate start of hold state
                startIndex = j+1;
            elseif subject(i).state(j) == 5 && subject(i).state(j+1) == 3 % end of hold state
                endIndex = j;
                avgAngle = mean(subject(i).jointPos2(startIndex:endIndex));
                allAngles = [allAngles; avgAngle];
            end
        end
        
        % SUBPROCESS: looking for avg home angle to get positive angles
        avgHome = 0;
        notFound = true;
        for j = 1:length(subject(i).state) - 1
            if subject(i).state(j) == 3 && subject(i).state(j+1) == 6 && notFound % start of home state
                startIndex = j+1;
            elseif subject(i).state(j) == 6 && subject(i).state(j+1) == 4 && notFound % end of home state
                endIndex = j;
                avgHome = mean(subject(i).jointPos2(startIndex:endIndex)); 
                notFound = false;
            end
        end
    
        % convert rad to pi
        allAngles = allAngles.*180./pi;
        avgHome = avgHome*180/pi;
    
        % offset by avgHome
        allAngles = allAngles.*(-1) + avgHome; % avgHome - reachAngle
    
        % removing bad trials
        if i == 3 % joseph
            allAngles = [allAngles(1:92); allAngles(95:120)];
        elseif i == 4 % yewon
            allAngles = [allAngles(1:86); allAngles(89:120)];
        end
    
        % separating angles
        subject(i).targetAngle = allAngles(1:2:end,:); % odd rows
        subject(i).reachAngle = allAngles(2:2:end,:); % even rows
    
        % finding absolute error
        subject(i).angleError = get_error(subject(i).targetAngle, subject(i).reachAngle);
    end

    %% computing activeStartTimes and activeEndTimes
    for i = 1:length(subject) % iterating through subjects
        for j = 1:length(subject(i).state) - 2
            if subject(i).state(j) == 6 && subject(i).state(j+1) == 4 && subject(i).state(j+2) ~= 10 % edge case at end of trial
                subject(i).activeStartTimes = [subject(i).activeStartTimes; subject(i).time(j+1)]; % vertcat start times
            elseif subject(i).state(j) == 4 && subject(i).state(j+1) == 5
                subject(i).activeEndTimes = [subject(i).activeEndTimes; subject(i).time(j)]; % vertcat end times
            end
        end
    end
    
    %% computing meanErr and stdev fields
    bins = 10:10:60; % length = 6
    
    for i = 1:length(subject)
        sum = 0;
        n = 0;
        
        absError = abs(subject(i).angleError);
        meanError = zeros(1, length(bins) - 1);
        stdev = zeros(1, length(bins) - 1); % vector of standard deviations for each meanError
        
        % SUBPROCESS: finding mean error & std
        for j = 1:length(bins) - 1 % for each bin
            dist = [];  % set of values in a bin; resets for every bin
            for k = 1:length(subject(i).targetAngle)
                if subject(i).targetAngle(k) > bins(j) && subject(i).targetAngle(k) < bins(j+1) % if targetAngle falls in bin
                    dist = [dist; absError(k)];
                    sum = sum + absError(k);
                    n = n + 1;
                end
            end
            meanError(j) = sum/n;
            stdev(j) = std(dist);
        end
    
        subject(i).meanErr = meanError;
        subject(i).stdev = stdev;
    end

    %% test
    % plot(subject(5).jointPos2);

end