function WriteRespData(Q)
fprintf(Q.handles.respdata,'%.3f,%d,',[Q.timing.flipt-Q.timing.t0,Q.timing.framenumber]);
fprintf(Q.handles.respdata,'%d,',Q.flyloc.mdX);
fprintf(Q.handles.respdata,'%d,',Q.flyloc.mdY);
fprintf(Q.handles.respdata,'%d,',Q.flyloc.mqv);
fprintf(Q.handles.respdata,'%d,',Q.flyloc.nr);
fprintf(Q.handles.respdata,'\n');
end