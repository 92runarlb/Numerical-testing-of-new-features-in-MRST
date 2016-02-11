clc; clear; close all


% Sett the convex boundary
boundary = [-1,-1,-1;  ...
             1,-1,-1;  ...
             1, 1,-1;  ...
            -1, 1,-1;  ...
            -1,-1, 1;  ...
             1,-1, 1;  ...
             1, 1, 1;  ...
            -1, 1, 1]; ...

% Generate random seed points
%pts = -1+2*rand(5,3);
pts=    [-0.5443    0.4773    0.2519;...
         -0.0038    0.1720    0.3219;...
          0.8017   -0.5065    0.4595;...
          0.1493    0.3328    0.7815;...
          0.6904   -0.8330    0.9646];...
%pts = [0,0,0;0.5,0.5,0.5];

% Generate voronoi grid
G = voronoi3D(pts, boundary);

plotGrid(G);
