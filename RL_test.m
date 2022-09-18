clear;
load('task1.mat');

% Initilize Q values, set value to be -1 if not available
init_Q = zeros(100,4);
for s=1:100
    for a=1:4
        if reward(s,a) < 0
            init_Q(s,a)=-1;
        end
    end
end

% different values for discount rate gamma
gammas = [0.5 0.9];

% open a file for recording results
file = fopen('~/Desktop/RL_result.txt','w');

% 1 means 1/k
% 2 means 100/100+k
% 3 means (1+log(k))/k
% 4 means (1+5*log(k))/k
for func_idx=1:4

fprintf(file,'func_idx:%d\n\n',func_idx);
    
for gamma_idx=1:2

gamma = gammas(gamma_idx);
fprintf(file,'gamma:%f\n\n',gamma);

reach_goals = 0; % number of runs which can reach goal
max_rewards = 0; % the max rewards get from those reached goals
total_time = 0;  % the total running time (including those not reaching goals)
total_complete_time = 0;  % the total running time only for those reached goals

% the Q value difference threshold to determine termination or each run
q_diff_thres = 10^-10;

for i = 1:10 % for 10 runs
    start_t = cputime;
    
    Q = init_Q;
    trial = 0;
    qchanged = 1;  % the flag indicating wether Q has changed significantly
    
    while qchanged==1 && trial < 3000 % each run for at most 3000 trials
    %for j=1:3000
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
            alpha = getAlpha(step,func_idx);
            epsilon = alpha;
       end
       
       if sum(sum(abs(old_Q-Q))) > q_diff_thres % the absulate Q value difference
           qchanged = 1;
       end
       
%        if state==100
%           fprintf('%d:%d - %d\n',trial,step);
%        end
       
    end
    
    time_elps = cputime - start_t;
    total_time = total_time + time_elps;
    
    % Ues optimal policy to get the steps
    current_s = 1;
    actions_taken = [];
    rewards_acc = 0;
    % Note: if the steps are too many, there must be loop inside
    while current_s~=100 && numel(actions_taken)<100 
        [a,~] = getMaxQval(Q,reward,current_s);
        rewards_acc = rewards_acc + reward(current_s,a);
        current_s = getState(current_s,a);
        actions_taken = [actions_taken a];
    end
    
    if current_s==100
        total_complete_time = total_complete_time + time_elps;
        fprintf('Reach goal at %d steps', numel(actions_taken));
        disp(actions_taken);
        reach_goals = reach_goals + 1;
        if rewards_acc > max_rewards
            max_rewards = rewards_acc;
            max_actions = actions_taken;
        end
    else
        disp('Cannot reach goal....');
        disp(actions_taken(:,1:20)); % print the first 20 moves
    end
end

% save workspace data
workspace_file_name = sprintf('~/Desktop/%d_%f.mat',func_idx,gamma);
save(workspace_file_name);

fprintf(file,'%d runs reach goals.\n', reach_goals);
fprintf(file,'%f total rewards.\n', max_rewards);
fprintf(file,'avg reach goal time is %f\n', total_complete_time / reach_goals);
fprintf(file,'avg total time is %f\n\n', total_time / 10);

end
end

fclose(file);