function str = DateStrGen
dataFormatSpec = '%04u%02u%02u_%02u%02u%02u' ;
timeCur = fix(clock);
str = sprintf(dataFormatSpec,timeCur);