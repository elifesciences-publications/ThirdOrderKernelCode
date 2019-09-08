function DrawTexture(Q)

% uses texStr to draw the textures onto a cylinder
% options within texStr.opts are 'full','leftright', 'leftrightfront', and
% 'leftrightspecial'

global GL AGL GLU;
    [gltex, gltextarget] = Screen('GetOpenGLTexture', Q.windowIDs.active, Q.texStr.tex);

    % each time, we've got to draw the background
    Screen('Fillrect',Q.windowIDs.active,[0;0;0]);

    Screen('BeginOpenGL', Q.windowIDs.active);
    glEnable(GL.SCISSOR_TEST);

    %% from cylinderannulus example
    % Enable texture mapping for this type of textures...
    glEnable(gltextarget);

    % Bind our texture, so it gets applied to all following objects:
    glBindTexture(gltextarget, gltex);
    
    % Rotate texture
    glMatrixMode(GL.TEXTURE);
    glLoadIdentity();
    glTranslatef(0.5,0.5,0.0);
    glRotatef(90,0.0,0.0,1.0);
    glTranslatef(-0.5,-0.5,0.0);

    % Clamping behaviour shall be a cyclic repeat:
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);

    % Set up minification and magnification filters.
    % use nearest neighbor filtering because we will be designing stimuli
    % on the pixel scale
    glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.NEAREST);

    % Create the cylinder as a quadric object. 'mycylinder' is a handle that you
    % need to pass to all quadric functions:
    mycylinder = gluNewQuadric;

    % Enable automatic generation of texture coordinates for our quadric object:
    gluQuadricTexture(mycylinder, GL.TRUE);

    %% get frustrum parameters
    flyX = Q.cylinder.flyX;
    flyY = Q.cylinder.flyY;
    flyZ = Q.cylinder.flyZ;
    
    frustLeft = Q.cylinder.frustLeft;
    frustRight = Q.cylinder.frustRight;
    frustTop = Q.cylinder.frustTop;
    frustBottom = Q.cylinder.frustBottom;
    frustNear = Q.cylinder.frustNear;
    frustFar = Q.cylinder.frustFar;
    
    cylinderRadius = Q.cylinder.cylinderRadius;
    cylinderHeight = Q.cylinder.cylinderHeight;
    heightBelowMid = Q.cylinder.heightBelowMid;
    flyHeadAngle = Q.cylinder.flyHeadAngle;
    
    
    
    for ii=1:3
        % set up viewports
        glViewport(Q.OGL.viewLocs(ii,1), Q.OGL.viewLocs(ii,2), abs(Q.OGL.viewLocs(ii,3)), abs(Q.OGL.viewLocs(ii,4)));
        glScissor(Q.OGL.viewLocs(ii,1), Q.OGL.viewLocs(ii,2), abs(Q.OGL.viewLocs(ii,3)), abs(Q.OGL.viewLocs(ii,4)));
        xDirection = sign(Q.OGL.viewLocs(ii,3));
        yDirection = sign(Q.OGL.viewLocs(ii,4));
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        glScalef (xDirection, yDirection, 1.0);
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;
        glClearColor(0.0,0.0,0.0,0.0);
        glClear(GL.COLOR_BUFFER_BIT);
        
        
        switch ii
            case 1
%                 right eye
%                 looks at +x because we're considering the front of the
%                 cylinder to be -y. -y has to be the top because when
%                 we reflect our mirrors we rotate side screens 90 deg
%                 away from front which ends with +z as top.
%                 top and bottom, left and right are switched
                glFrustum(-frustTop, -frustBottom, -frustRight, -frustLeft, frustNear, frustFar);
                gluLookAt(flyX,flyY,flyZ,1,0,0,0,-1,0);
            case 2
                %center
                %have it look backwards so that the middle of
                %the bitmap is the middle of the screen up is positive z
%                 glFrustum(frustLeft, frustRight, frustBottom, frustTop, frustNear, frustFar*30);
%                 gluLookAt(30,flyY,flyZ,-1,0,0,0,0,1); % center
                glFrustum(frustLeft, frustRight, frustBottom, frustTop, frustNear, frustFar);
                gluLookAt(flyX,flyY,flyZ,0,-1,0,0,0,1); % center

            case 3
                %left eye, looks at -x
                glFrustum(frustBottom, frustTop, frustLeft, frustRight, frustNear, frustFar);
                gluLookAt(flyX,flyY,flyZ,-1,0,0,0,-1,0);
        end

        
        glPushMatrix;
        glTranslatef(0,(heightBelowMid)*sin(flyHeadAngle),-(heightBelowMid)*cos(flyHeadAngle));
        glRotatef(flyHeadAngle*180/pi,1,0,0);
        % draw the damn cylinder
        gluCylinder(mycylinder, cylinderRadius, cylinderRadius, cylinderHeight, 100, 1);

        glPopMatrix;
    end
    
    if Q.usePhotoDiode
        x = Q.OGL.viewLocs(4,1);
        y = Q.OGL.viewLocs(4,2);
        width = Q.OGL.viewLocs(4,3);
        height = Q.OGL.viewLocs(4,4);
        glViewport(x,y,width,height);
        glScissor(x,y,width,height);

        color = Q.stims.stimData.photoDiodeColor/255;
        glClearColor(color,color,color,1.0);
        glClear(GL.COLOR_BUFFER_BIT)
    end
    
    Screen('EndOpenGL', Q.windowIDs.active);
    Screen('Close',Q.texStr.tex);
    Screen('DrawingFinished', Q.windowIDs.active);
end