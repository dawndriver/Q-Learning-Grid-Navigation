function alpha = getAlpha(step,mode)
    % get the epsilon and learning rate based on 
    % given step number and function mode
    switch mode
        case 1
            v = 1.0*1/step;
        case 2
            v = 1.0*100/(100+step);
        case 3
            v = (1+log(step))/step;
        case 4
            v = (1+5*log(step))/step;
    end
    if v > 1 % if > 1 set it to be 1, which forces it to explore
        alpha = 1;
    else
        alpha = v;
    end
end