function [trials] = partition(emg, max_trial_length, activeRange, edge)
% This function creates a structure array of muscle structs, which are 2D
% matrices where the EMG signals from each trial are separated into rows.

    % padding signals < max_trial_length with 0's
    trials = struct('bicep', zeros(length(activeRange), max_trial_length), ...
        'tricep', zeros(length(activeRange), max_trial_length), ...
        'delt', zeros(length(activeRange), max_trial_length), ...
        'trap', zeros(length(activeRange), max_trial_length), ...
        'pecMajor', zeros(length(activeRange), max_trial_length), ...
        'infra', zeros(length(activeRange), max_trial_length));

    prevIdx = 0;
    setNum = 1; 

    % IDEA: INSTEAD OF SINGLE BOOL EDGE MAKE ARRAY OF BOOLS WHERE THE 1
    % ELEMENT THAT IS TRUE TELLS YOU WHICH SETNUM TO SKIP
    % IN SWITCH CASE, IF ARRAY(SETNUM) == TRUE -> CONTINUE

    for i = 1:length(activeRange)
        if activeRange(i,1) < prevIdx % only checking startIdx; endIdx has same pattern)
            setNum = setNum + 1;
            prevIdx = 0; % reset
        else
            prevIdx = activeRange(i,1);
        end

        if edge(setNum) == true
            setNum = setNum + 1; % skips set
        end

        switch setNum
            case 1 % P ONLY: if yewon, skip S1
                trials = get_muscle_trial(trials, emg.S1.Data, activeRange, i);
                % disp(i);
                % disp(activeRange(i,1));
            case 2 % N ONLY: if steph, skip S2
                trials = get_muscle_trial(trials, emg.S2.Data, activeRange, i);
                % disp(i);
                % disp(activeRange(i,1));
            case 3 % N ONLY: if yewon, skip S3
                trials = get_muscle_trial(trials, emg.S3.Data, activeRange, i);
                % disp(i);
                % disp(activeRange(i,1));
            case 4
                trials = get_muscle_trial(trials, emg.S4.Data, activeRange, i);
                % disp(i);
                % disp(activeRange(i,1));
            case 5
                trials = get_muscle_trial(trials, emg.S5.Data, activeRange, i);
                % disp(i);
                % disp(activeRange(i,1));
        end
    end
end