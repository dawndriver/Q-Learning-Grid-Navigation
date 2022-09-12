function s = getState(state,action)
    % get the next state index with given current state and action taken
    switch action
        case 1
            s = state-1;
        case 2
            s = state+10;
        case 3
            s = state+1;
        case 4
            s = state-10;
    end
end