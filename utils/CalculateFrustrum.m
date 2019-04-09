function cylinder = CalculateFrustrum(flyHeadAngle,flyHeight)
    % keep the fly in the middle of the virtual world changing this
    % code is not prepared for changes in these values
    flyX = 0;
    flyY = 0;
    flyZ = 0;

    screenHeight = 40; % height of screen in mm
    screenDist = 15; % distance to screen in mm
    cylinderRadius = screenDist; % radius of virtual cylinder in units

    % half of horizontal visual space one screen should represent in
    % radians
    halfVisualAsimuthRange = 45*pi/180;
    
    %% figure a
    distToFrustBottom = cylinderRadius*cos(halfVisualAsimuthRange);

    %% figure b
    % angles above and below the z = 0 plane
    topAngleOfFrust = atan2(screenHeight/2-flyHeight,screenDist);
    bottomAngleOfFrust = atan2(screenHeight/2+flyHeight,screenDist);

    %% figure c
    % distance to the near frustrum cropping window
    frustNear = distToFrustBottom*cos(bottomAngleOfFrust);
    frustTop = frustNear*tan(topAngleOfFrust);
    frustBottom = -frustNear*tan(bottomAngleOfFrust);

    %% figure d
    frustRight = frustNear*tan(halfVisualAsimuthRange);
    frustLeft = -frustRight;

    %% figure e
    distToFrustTop = cylinderRadius/cos(topAngleOfFrust+flyHeadAngle);
    frustFar = distToFrustTop*cos(topAngleOfFrust);

    %% figure f
    heightAboveMid = cylinderRadius*tan(topAngleOfFrust+flyHeadAngle);

    % In order to find "partialHeight2", the extent of the clylinder in the
    % downwards direction, we will shoot rays down in the direction of the
    % bottom corner and bottom middle of the side-facing frustum. We will
    % see where these rays intersect a virtual cylinder and set
    % partialHeight2 to the z coordinate of the intersection (whichever ray
    % intersects lowest). If both the bottom middle and the bottom corner
    % are covered by the cylinder, then almost all the frustum will be covered
    % by the cylinder for most rotations
    
    % Since we don't want to think about rotated cylinders we're going to
    % rotate the rays opposite to how we rotate the cylinder.
    rotationMatrix = [1       0         0      ; ...
                      0   cos(-flyHeadAngle)  -sin(-flyHeadAngle); ...
                      0   sin(-flyHeadAngle)   cos(-flyHeadAngle);];

    % Ray pointing to the bottom middle of the frustum
    vecMiddle = [-frustNear; 0; frustBottom];
    vecMiddleRotated = rotationMatrix * vecMiddle;
    % The ray intersects with the cylinder when (Mx)^2 + (My)^2 = r^2 for
    % some magnitude M. Solve for M.
    vecMiddleMagnitude = sqrt(cylinderRadius.^2 / (vecMiddleRotated(1)^2 + vecMiddleRotated(2)^2));
    vecMiddleIntersection = vecMiddleRotated*vecMiddleMagnitude;
    
    % Repeat for corner.
    vecCorner = [-frustNear; frustRight; frustBottom];
    vecCornerRotated = rotationMatrix * vecCorner;    
    vecCornerMagnitude = sqrt(cylinderRadius.^2 / (vecCornerRotated(1)^2 + vecCornerRotated(2)^2));    
    vecCornerIntersection = vecCornerRotated*vecCornerMagnitude;

    %partial2Height is a positive value, but these vectors point down in z.
    heightBelowMid = max(-vecCornerIntersection(3),-vecMiddleIntersection(3));


    cylinderHeight = heightAboveMid + heightBelowMid;
    
    
    cylinder.flyX = flyX;
    cylinder.flyY = flyY;
    cylinder.flyZ = flyZ;
    
    cylinder.flyHeight = flyHeight;
    
    cylinder.frustLeft = frustLeft;
    cylinder.frustRight = frustRight;
    cylinder.frustTop = frustTop;
    cylinder.frustBottom = frustBottom;
    cylinder.frustNear = frustNear;
    cylinder.frustFar = frustFar;
    
    cylinder.flyHeadAngle = flyHeadAngle;
    cylinder.cylinderRadius = cylinderRadius;
    cylinder.cylinderHeight = cylinderHeight;
    cylinder.heightAboveMid = heightAboveMid;
    cylinder.heightBelowMid = heightBelowMid;
end