function [windows] = get_windows(muscleNormTrials, n, window_length)
% This function takes the normalTrials signal matrix for one muscle and
% returns a 2D matrix of overlapping windows for each signal (row).

    windows = zeros(size(muscleNormTrials, 1), n);
    for i = 1:size(muscleNormTrials, 1)
        for j = 1:n
            windowStart = floor(1+(j-1)*window_length/2);
            windowEnd = floor(window_length+(j-1)*window_length/2);
            windows(i,j) = mean(muscleNormTrials(i, windowStart:windowEnd));
        end
    end
end