classdef FlyStates
    properties
        mdx
        mdy
        mqv
        nr
        t
        x
        y
        theta
        vx
        vy
        vtheta
        vforward
    end
    methods
        function newFlyStates = FlyStates(mdx_in, mdy_in, mqv_in, nr_in, t_in)
            if nargin == 0 % Do nothing constructor
                return;
            end
            newFlyStates.mdx = mdx_in;
            newFlyStates.mdy = mdy_in;
            newFlyStates.mqv = mqv_in;
            newFlyStates.nr = nr_in;
            newFlyStates.t = t_in;
        end
    end        
end