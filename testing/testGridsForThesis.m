
%%
% % curved well pluss two vertical wells
% close all; clear;
% 
% x = linspace(0.2,0.8);
% wellLine = {[0.7105,0.1842], ...
%             [0.2,0.1842], ...
%             [x', 0.5*sin(pi*x)'+0.2]};%, ...
%             %[0.3,0.3;0.7,0.8]}
%             
% 
% % With refinement
% %Gp = compositeGridPEBI([1/19,1/19/4,1/40], [1, 1], 'wellLines', wellLine, 'padding', 1, ...
% %                       'wellGridSize',0.02, 'mlqtMaxLevel', 2, ...
% %                       'mlqtLevelSteps',[0.07,0.03]');
% %Gdist = compositeGridPEBIdistmesh(1/19, [1, 1], 'wellLines', wellLine, ...
% %                              'wellGridFactor', 0.25, 'wellRefDist',1/15);
%  
% %Without refinement
% Gp = compositeGridPEBI([1/19,1/19/2,1/40], [1, 1], 'wellLines', wellLine, 'padding', 1, ...
%                        'wellGridSize',0.02, 'mlqtMaxLevel', 0, ...
%                        'mlqtLevelSteps',[0.07,0.03]');
% Gdist = compositeGridPEBIdistmesh(1/19, [1, 1], 'wellLines', wellLine, ...
%                               'wellGridFactor', 0.5, 'wellRefDist',1/500);
%                            
% Gp.cells
% Gdist.cells
% 
% figure()
% hold on
% plotGrid(Gp, 'faceColor', 'none')
% axis equal tight off
% hold on
% %plotFault(Gp)
% %plotWells(Gp)
% for i = 1:numel(wellLine)
%   line = wellLine{i};
%   if size(line,1) == 1
%       plot(line(1,1), line(1,2),'.r', 'markersize', 8);
%   end
%   plot(line(:, 1), line(:, 2),'r');
% end
% figure()
% hold on
% plotGrid(Gdist, 'faceColor', 'none')
% axis equal tight off
% hold on
% %plotFault(Gp)
% %plotWells(Gp)
% for i = 1:numel(wellLine)
%   line = wellLine{i};
%   if size(line,1) == 1
%       plot(line(1,1), line(1,2),'.r', 'markersize', 8);
%   end
%   plot(line(:, 1), line(:, 2),'r');
% end


%% Single fault intersected by several wells 
close all

wellLine = {[0.6,0.2;0.65,0.6],...        
            [0.3,0.3;0.7,0.8],...
            [0.6,0.2;0.85,0.4],...
            [0.15,0.7;0.4,0.7]};
        
fracture = {[0.2,0.8;0.8,0.2]};

% Without refinement
% Gp = compositeGridPEBI(1/24, [1, 1], ...
%                        'wellLines', wellLine, 'wellGridFactor', 24/26/2, ...
%                        'faultLines',fracture, 'faultGridFactor', 1/sqrt(2),...
%                         'circleFactor', 0.6);
% Gdist = compositeGridPEBIdistmesh(1/24, [1, 1], 'wellLines', wellLine, ...
%                                 'wellGridFactor', 0.5*24/26, 'wellRefDist',1/500, ...
%                                 'faultlines', fracture, 'circleFactor', .6,...
%                                 'faultGridFactor', 1/sqrt(2));

% Whith refinement      
Gp = compositeGridPEBI(1/24, [1, 1], ...
                       'wellLines', wellLine, 'wellGridFactor', 24/26/2, ...
                       'faultLines',fracture, 'faultGridFactor', 1/sqrt(2),...
                        'circleFactor', 0.6,'mlqtMaxLevel', 2, ...
                        'mlqtLevelSteps',[0.06,0.02]');

Gdist = compositeGridPEBIdistmesh(1/24, [1, 1], 'wellLines', wellLine, ...
                                'wellGridFactor', 0.01*24, 'wellRefDist',1/19, ...
                                'faultlines', fracture, 'circleFactor', .6,...
                                'faultGridFactor', 0.03*24);

Gp.cells
Gdist.cells



%% Complex wells intersecting
% close all; clear
% fracture = {};
% x = linspace(0.2,0.8);
% wellLine = {[0.5,0.2; 0.5,0.3;0.47,0.4;0.4,0.5; 0.33,0.6;0.26,0.7], ...
%             [0.5,0.3;0.53,0.4;0.58,0.5],...            
%             [0.5,0.45;0.5,0.55;0.45,0.65;0.4,0.75;0.38,0.85],...
%             [0.5,0.55;0.55,0.65;0.6,0.75;0.62,0.85]};
%                         
% 
% Gp = compositeGridPEBI(1/19, [1, 1], 'wellLines', wellLine, ...
%                       'wellGridFactor', 0.02*19, ...
%                       'mlqtMaxLevel', 2, 'mlqtLevelSteps',[0.07,0.035]');
% Gdist = compositeGridPEBIdistmesh(1/19, [1, 1], 'wellLines', wellLine, ...
%                                  'wellGridFactor', 0.02*19, 'wellRefDist',1/5);
%                   
%                   
% Gp.cells
% Gdist.cells
%                             
%% Plotting                       
orange = [1,138/255,0.1];      
figure()
hold on
plotGrid(Gp, 'faceColor', 'none')
axis equal tight off
hold on
%plotFault(Gp)
plotWells(Gp)
for i = 1:numel(wellLine)
  line = wellLine{i};
  if size(line,1) == 1
      plot(line(1,1), line(1,2),'.r', 'markersize', 8);
  end
  plot(line(:, 1), line(:, 2),'r');
end
for i = 1:numel(fracture)
  line = fracture{i};
  plot(line(:, 1), line(:, 2),'color',orange);
end


figure()
hold on
plotGrid(Gdist, 'faceColor', 'none')
axis equal tight off
hold on
%&plotFault(Gdist)
plotWells(Gdist)
for i = 1:numel(wellLine)
  line = wellLine{i};
  if size(line,1) == 1
      plot(line(1,1), line(1,2),'.r', 'markersize', 8);
  end
  plot(line(:, 1), line(:, 2),'r');
end
for i = 1:numel(fracture)
  line = fracture{i};
  plot(line(:, 1), line(:, 2),'color', orange);
end
