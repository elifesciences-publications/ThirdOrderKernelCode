function windMask = ICA_DFOVERF_Untils_InferWindowMask(roiMask,imageSize)
   [nVer,nHor] = size(roiMask);
   % 
   verStart = (imageSize(1) - nVer)/2 + 1;
   verEnd = imageSize(1) - (imageSize(1) - nVer)/2;
   
   horStart = (imageSize(2) - nHor)/2 + 1;
   horEnd = imageSize(2) - (imageSize(2) - nHor)/2; 
   
   windMask = false(imageSize);
   windMask(verStart:verEnd,horStart:horEnd) = true;
end