directory = fileparts(mfilename('fullpath'));

mex([directory '\twod_gpu.cpp'],[directory '\extract_kernel.cpp'],[directory '\OpenCLErrorStrings.cpp'],'-outdir',directory,'-g','-lopencl','-LC:\Program Files (x86)\AMD APP SDK\2.9-1\lib\x86_64','-IC:\Program Files (x86)\AMD APP SDK\2.9-1\include');

mex([directory '\oned_gpu.cpp'],[directory '\extract_1Dkernel.cpp'],[directory '\OpenCLErrorStrings.cpp'],'-outdir',directory,'-g','-lopencl','-LC:\Program Files (x86)\AMD APP SDK\2.9-1\lib\x86_64','-IC:\Program Files (x86)\AMD APP SDK\2.9-1\include');