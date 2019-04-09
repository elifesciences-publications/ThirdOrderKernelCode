function resptime_perline = SAC_Timealign_frame2lin(resptime_perframe, nlines)
    nframes = length(resptime_perframe);
    x = 0:nframes;
    resptime_perframe = [resptime_perframe;resptime_perframe(end) + mean(diff(resptime_perframe))]; % curr time + estimation for the last frame.
    xq = 0:1/nlines:(nframes-1/nlines);
    resptime_perline = interp1(x', resptime_perframe, xq);
    % this should be a line, by time.
    resptime_perline = reshape(resptime_perline, [nlines, nframes]);
    resptime_perline =  resptime_perline';
end