classdef FlyTimeline < handle
    properties
        curFlyStates
        num_timepoints = 0;
        timeline = FlyStates.empty(1,0);
        next_t;
    end
    methods
        function T = updateTimeline(T)
            prevFlyStates = T.timeline(T.num_timepoints);
            
            % normalize to the number of reads. Multiply by the assumed
            % time (1/60) in seconds then divide by the measured mouse time
            % which is the number of reads multiplied by read time
            % 0.0026 in seconds
            T.curFlyStates.mdx = (1/60) * T.curFlyStates.mdx / (T.curFlyStates.nr * 0.0026);
            T.curFlyStates.mdy = (1/60) * T.curFlyStates.mdy / (T.curFlyStates.nr * 0.0026);
            %change dX to degrees change dY to mm
            %each ball is 1/4 inch diameter so dots per circumference is 1000*1/4*pi
            %divide by 360 to get dots per degree 1000*1/4*pi/360
            dtheta = T.curFlyStates.mdx/(1000*1/4*pi/360);
            dforward = T.curFlyStates.mdy*0.0254;%mdy is in inches/1000 and we want to get it to meters/1000 meters/inch = 0.0254
            T.curFlyStates.theta = prevFlyStates.theta + dtheta;
            
            
%             %We approximate that the fly is moving around a circle of a
%             %certain radius and achieves a certain arc length.
%             
%             %abs(dforward) = 2*pi*radius*abs(dtheta)/360, solve for radius
%             radius = abs(dforward*360./(2*pi()*dtheta));
%             
%             %now convert from polar coordinates to rectangular relative to
%             %the cicle center
%             start_pos = [radius.*cosd(prevFlyStates.theta); radius.*sind(prevFlyStates.theta)];
%             end_pos = [radius.*cosd(T.curFlyStates.theta); radius.*sind(T.curFlyStates.theta)];
%              
%             
%             dxdy = end_pos - start_pos;
%             dx = dxdy(1,:);
%             dy = dxdy(2,:);

            dx_forward_first = dforward.*cosd(prevFlyStates.theta);
            dy_forward_first = dforward.*sind(prevFlyStates.theta);
            dx_turn_first = dforward.*cosd(T.curFlyStates.theta);
            dy_turn_first = dforward.*sind(T.curFlyStates.theta);
            dx = (dx_forward_first + dx_turn_first)/2;
            dy = (dy_forward_first + dy_turn_first)/2;
            T.curFlyStates.x = dx + prevFlyStates.x;
            T.curFlyStates.y = dy + prevFlyStates.y;
            
            dt = T.curFlyStates.t - prevFlyStates.t;
            T.curFlyStates.vx = dx/dt;
            T.curFlyStates.vy = dy/dt;
            T.curFlyStates.vtheta = dtheta/dt;
            T.curFlyStates.vforward = dforward/dt;
            
            T.num_timepoints = T.num_timepoints + 1;
            T.timeline(T.num_timepoints) = T.curFlyStates;
        end
        function addTimepoint(T,mdx, mdy, mqv, nr, t)
            T.curFlyStates = FlyStates(mdx, mdy, mqv, nr, T.next_t);
            T.updateTimeline();
            T.next_t = t;
        end
        function outputTimeline = FlyTimeline(t,next_t,totalTimepoints)
            if nargin < 3
                totalTimepoints = 2*60*60*60;
            end
            outputTimeline.curFlyStates = FlyStates(zeros(1,5),zeros(1,5),zeros(1,5),0,t);
            outputTimeline.curFlyStates.theta = zeros(1,5);
            outputTimeline.curFlyStates.x = zeros(1,5);
            outputTimeline.curFlyStates.y = zeros(1,5);
            outputTimeline.curFlyStates.nr = 0;
            outputTimeline.curFlyStates.vx = zeros(1,5);
            outputTimeline.curFlyStates.vy = zeros(1,5);
            outputTimeline.curFlyStates.vtheta = zeros(1,5);
            outputTimeline.curFlyStates.vforward = zeros(1,5);
            outputTimeline.num_timepoints = 1;
            %Preallocate a little more than neccessary
            outputTimeline.timeline(totalTimepoints+100) = FlyStates(zeros(1,5),zeros(1,5),zeros(1,5),0,0);
            outputTimeline.timeline(1) = outputTimeline.curFlyStates;
            outputTimeline.next_t = next_t;
        end
    end
end