% Initilize Q values, set value to be -1 if not available
init_Q = zeros(100,4);
for s=1:100
    for a=1:4
        if qevalreward(s,a) < 0
            init_Q(s,a)=-1;
        end
    end
end

gamma = 0.9;

% the Q value difference threshold to determine termination or each run
q_diff_thres = 10^-8;

Q = init_Q;
trial = 0;
qchanged = 1;  % the flag indicating wether Q has changed significantly

while qchanged==1 && trial < 3000 % each run for at most 3000 trials
    trial = trial + 1;
    qchanged = 0;
    state = 1;
    step = 0;
    alpha = 1;
    epsilon = alpha;
    old_Q = Q;  % record down old Q value
    
    while state~=100 && alpha>=0.005  % execute one trial
        [current_best_action,~] = getMaxQval(Q,reward,state);
        pick = randsample(0:1,1,true,[1-epsilon epsilon]);
        if pick==0 % exploit strategy
            action = current_best_action;
        else  % explore strategy   
            other_actions = [];
            for a=1:4
                % filter out current best action and those not available moves
                if a~=current_best_action && reward(state,a)>0 
                    other_actions = [other_actions a];
                end
            end
            if numel(other_actions)==1 % single value no need to use randsample
                action = other_actions;
            else
                action = randsample(other_actions,1);
            end
        end
        
        next_reward = reward(state,action); % the reward got for the chosen action           
        next_state = getState(state,action); % next state if taken this action         
        [~,next_max_qval] = getMaxQval(Q,reward,next_state); % get possible max Q value for next move
        Q(state,action) = Q(state,action)+alpha*(next_reward+gamma*next_max_qval-Q(state,action));
            
        step = step + 1;
        state = next_state;
        alpha = 100/(100+step);
        epsilon = alpha;
    end
    
    if sum(sum(abs(old_Q-Q))) > q_diff_thres % the absulate Q value difference
        qchanged = 1;
    end
end

current_s = 1;
qevalstates = [];
actions_taken = [];
rewards_acc = 0;
% Note: if the steps are too many, there must be loop inside
while current_s~=100 && numel(actions_taken)<100 
   [a,~] = getMaxQval(Q,reward,current_s);
   rewards_acc = rewards_acc + reward(current_s,a);
   current_s = getState(current_s,a);
   qevalstates = [qevalstates; current_s];
   actions_taken = [actions_taken a];
end

grid = cell(100,1);
for i=1:100
   grid(i) = cellstr('');
end
state = 1;
for i=1:numel(actions_taken)
    switch actions_taken(i)
        case 1
            outStr = '^';
        case 2
            outStr = '>';
        case 3
            outStr = 'V';
        case 4
            outStr = '<';
    end
    grid(state) = cellstr(outStr);
    state = getState(state,actions_taken(i));
end

if current_s==100
    fprintf('Total Reward is %d\n', rewards_acc);
    disp('The trajectory of actions is:');
    disp(reshape(grid,[10,10]));
else
    disp('Cannot reach goal.....');
    disp('The trajectory of actions is:');
    disp(reshape(grid,[10,10]));
end