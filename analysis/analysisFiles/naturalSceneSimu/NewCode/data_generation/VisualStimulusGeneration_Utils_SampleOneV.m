function  vel = VisualStimulusGeneration_Utils_SampleOneV(velocity)
vel_direction = (rand > 0.5) * 2 - 1;
switch velocity.distribution
    case 'binary'
        speed = velocity.range;
    case 'uniform'
        speed = rand * velocity.range;
    case 'gaussian'
        speed = randn * velocity.range;
end
vel = vel_direction * speed;

end