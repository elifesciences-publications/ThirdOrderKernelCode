function eye = GrabEye(Z)

connDb = connectToDatabase;
sysConfig = GetSystemConfiguration;

relativeDataPath = Z.params.pathName(length(sysConfig.twoPhotonDataPath)+1:end-1);
relativeDataPath(relativeDataPath == '/') = '\';


eye = fetch(connDb, sprintf('select eye from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%s"', relativeDataPath));
eye = eye{1};