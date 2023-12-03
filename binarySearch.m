function idx = binarySearch(time, val)
    l = 1;
    r = length(time);
    idx = 0;

    time = round(time, 3);
    val = round(val, 3);

    while(l <= r)
        mid = l + floor((r-l)/2); 

        % check if x is present at mid
        if time(mid) == val
            idx = mid;
            break
        % if val is greater, ignore left half
        elseif time(mid) < val
            l = mid + 1;
        % if val is smaller, ignore right half
        else
            r = mid - 1;
        end
    end
end