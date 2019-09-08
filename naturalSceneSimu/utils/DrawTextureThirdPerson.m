function DrawTextureThirdPerson(Q)

% uses texStr to draw the textures onto a cylinder
% options within texStr.opts are 'full','leftright', 'leftrightfront', and
% 'leftrightspecial'

global GL AGL GLU;   
    [gltex, gltextarget] = Screen('GetOpenGLTexture', Q.windowIDs.active, Q.texStr.tex);

    % each time, we've got to draw the background
    Screen('Fillrect',Q.windowIDs.active,[0;0;0]);

    Screen('BeginOpenGL', Q.windowIDs.active);
    glEnable(GL.SCISSOR_TEST);
    glEnable(GL.DEPTH_TEST);
    glEnable(GL.TEXTURE_2D);
    
    glClear(GL.DEPTH_BUFFER_BIT);

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
    glScalef(-1,1,1);

    % Clamping behaviour shall be a cyclic repeat:
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);

    % Set up minification and magnification filters.
    % use nearest neighbor filtering because we will be designing stimuli
    % on the pixel scale
    glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    best_aniso = glGetFloatv(GL.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
    glTexParameterf(GL.TEXTURE_2D, GL.TEXTURE_MAX_ANISOTROPY_EXT, best_aniso);

    % Create the cylinder as a quadric object. 'mycylinder' is a handle that you
    % need to pass to all quadric functions:
    mycylinder = gluNewQuadric;

    % Enable automatic generation of texture coordinates for our quadric object:
    gluQuadricTexture(mycylinder, GL.TRUE);


    cylinderRadius = Q.cylinder.cylinderRadius;
    cylinderHeight = Q.cylinder.cylinderHeight;
    
    % Set up a clipping plane so that the back of the cylinder isn't shown
    glEnable(GL.CLIP_DISTANCE0);
    planeEquation = [0 -1 0 sind(45)*cylinderRadius];
    glClipPlane(GL.CLIP_PLANE0,planeEquation);
    % set up virtual camera
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;
    glMatrixMode(GL.MODELVIEW);
    glLoadIdentity;
    glClearColor(0.0,0.0,0.0,0.0);
    glClear(GL.COLOR_BUFFER_BIT);
    gluPerspective(70, 1, 5, 200);
    gluLookAt(0,18,60,0,-15,20,0,-1,0);
    
    % draw the damn cylinder
    gluCylinder(mycylinder, cylinderRadius, cylinderRadius, cylinderHeight, 100, 1);

    glDeleteTextures(1,gltex);
    Screen('EndOpenGL', Q.windowIDs.active);
    Screen('Close',Q.texStr.tex);
    Screen('DrawingFinished', Q.windowIDs.active);
end