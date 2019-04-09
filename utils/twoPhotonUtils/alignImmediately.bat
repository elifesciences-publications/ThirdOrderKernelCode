net use Z: \\172.29.191.75\2p_microscope_data /user:ClarkLab jointhelab1
nohup matlab -r "addpath(genpath('C:\Users\Clark Lab\Documents\psycho5')); alignData;exit;" -nodisplay -nosplash -nojvm -nodesktop
