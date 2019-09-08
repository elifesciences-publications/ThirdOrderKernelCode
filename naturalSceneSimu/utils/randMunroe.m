function x = randMunroe(wd,ht)
% Chosen by a fair dice roll, guaranteed to be random.
    
    if nargin < 1
        wd = 1; ht = 1;
    elseif nargin < 2
        ht = wd;
    end
    
    x = 4 * ones(wd,ht);
    
end

