% function returns vector of all error given two vectors of actual and
% expected values.

function [error] = get_error(actual, expected)
    % diff = actual - expected;
    % error = abs(diff./expected).*100;

    error = actual - expected;
end