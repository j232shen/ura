function [startIdx, endIdx] = get_range(time, startTime, endTime)
    startIdx = binarySearch(time, startTime);
    endIdx = binarySearch(time, endTime);
end
