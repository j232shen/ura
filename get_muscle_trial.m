function [trials] = get_muscle_trial(trials, set, activeRange, i)
% This function takes the "trials" structure array, inserts the signal for 
% the ith trial for each muscle in the struct, and returns the updated struct.

    % trial length of the ith signal
    trial_length = activeRange(i,2) - activeRange(i,1) + 1;

    trials.bicep(i,1:trial_length) = set(1, activeRange(i,1):activeRange(i,2));
    trials.tricep(i,1:trial_length) = set(5, activeRange(i,1):activeRange(i,2));
    trials.delt(i,1:trial_length) = set(9, activeRange(i,1):activeRange(i,2));
    trials.trap(i,1:trial_length) = set(13, activeRange(i,1):activeRange(i,2));
    trials.pecMajor(i,1:trial_length) = set(17, activeRange(i,1):activeRange(i,2));
    trials.infra(i,1:trial_length) = set(21, activeRange(i,1):activeRange(i,2));
end