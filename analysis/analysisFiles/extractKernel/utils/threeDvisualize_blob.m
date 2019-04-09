function [ void ] = threeDvisualize_blob(maxLen,K_3D,thresh1,thresh2,thresh3)
 
figure;
axis = linspace(1,maxLen,maxLen);
G = patch(isosurface(axis,axis,axis,K_3D,thresh1));
H = patch(isosurface(axis,axis,axis,K_3D,thresh2));
I = patch(isosurface(axis,axis,axis,K_3D,thresh3));
isonormals(axis,axis,axis,K_3D,G)
set(G, 'FaceColor', 'blue', 'EdgeColor', 'none');
isonormals(axis,axis,axis,K_3D,H)
set(H, 'FaceColor', 'red', 'EdgeColor', 'none');
isonormals(axis,axis,axis,K_3D,H)
set(I, 'FaceColor', 'green', 'EdgeColor', 'none');
camlight; lighting gouraud; material shiny;


void = 0;

end

