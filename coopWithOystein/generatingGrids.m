%% Grid with single source centered at 0.5,0.5
close all; clear;
addpath('../')

xmax = 1;                              % Set grid dimentions
ymax = 1; 
gridSize = 1/20;                       % Set size of grid cells

faultLine = {};
wellLine = {[0.5,0.5]};                % Set source center

mlqtMax = 2;                        % Set number of reminement levels
wellGridSize = 0.5/2^mlqtMax;       % Set relative well grid size
mlqtSizes = 2*linspace(gridSize,gridSize*wellGridSize,mlqtMax+1)';
                                    % Set distance around wells to be
                                    % refined.

wellEps = 1/4;                         % Size around wells to be refined
                                       % (For unstructured grid)


% Create semi-structured grid
Gp = compositeGridPEBI(gridSize, [xmax, ymax], 'wellLines', wellLine, ...
                      'wellGridFactor', wellGridSize, ...
                      'mlqtMaxLevel', 2, 'mlqtLevelSteps', mlqtSizes,...
                      'padding', 1);
                  
% Create fully unstructured grid
Gdist = compositeGridPEBIdistmesh(1/19, [1, 1], 'wellLines', wellLine, ...
                                 'wellGridFactor', 0.02*19, ...
                                 'wellRefDist',wellEps, 'padding',1);

                             
         
%% Single fault
% close all; clear
% xmax = 1;                              % Set grid dimentions
% ymax = 1; 
% gridSize = 1/20;                       % Set size of grid cells
% 
% x1 = linspace(0.2,0.8,10);
% y1 = [0.2,0.25,0.3,0.34,0.40,0.5,0.6,0.65,0.7,0.85];
% faultLine = {[x1',y1']};                % Set fault line
% wellLine = {};
% 
% 
% faultGridSize = 0.5;                   % Set relative well grid size
% 
% % Create semi-structured grid
% Gp = compositeGridPEBI(gridSize, [xmax, ymax], 'faultLines', faultLine,...
%                        'faultGridFactor', faultGridSize);
%                   
% % Create fully unstructured grid
% Gdist = compositeGridPEBIdistmesh(1/19, [1, 1], 'faultLines', faultLine,...
%                                  'faultGridFactor', faultGridSize);

                             

                             
                             
                             
%% Ploting
figure()
hold on
plotGrid(Gp, 'faceColor', 'none')
axis equal tight off
hold on

%Plot cells taged as wells.
if (numel(faultLine)>0), plotFault(Gp); end
if (numel(wellLine)>0), plotWells(Gp);end

for i = 1:numel(wellLine)
  line = wellLine{i};
  if size(line,1) == 1
      plot(line(1,1), line(1,2),'.r', 'markersize', 8);
  end
  plot(line(:, 1), line(:, 2),'r');
end


figure()
hold on
plotGrid(Gdist, 'faceColor', 'none')
axis equal tight off
hold on
if numel(faultLine)>0, plotFault(Gp); end
if numel(wellLine)>0, plotWells(Gp);end
for i = 1:numel(wellLine)
  line = wellLine{i};
  if size(line,1) == 1
      plot(line(1,1), line(1,2),'.r', 'markersize', 8);
  end
  plot(line(:, 1), line(:, 2),'r');
end

