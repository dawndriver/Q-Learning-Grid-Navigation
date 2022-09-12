function [max_action,max_qval] = getMaxQval(Q,R,state)
    % Get the possible max Q value and its action
    % with given Q function, Rewards(used for action availability check)
    % and the state index, note that if there are more than one
    % actions giving max Q value, then randomly pick one
    max_qval = -1;
    actions = [];
    for a=1:4
        if R(state,a) > 0
            if Q(state,a) > max_qval;
                max_qval = Q(state,a);
                actions = a;  % overwrite the action list if found new max
            else if Q(state,a) == max_qval
                actions = [actions a]; % build a action list
                end
            end
        end
    end
    if numel(actions) ==1
        max_action = actions;
    else
        max_action = randsample(actions,1);
    end
end