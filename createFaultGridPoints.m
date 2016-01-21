function [Pts, gridSpacing, circCenter, circRadius, CCid] = ...
    createFaultGridPoints(faultLine, fracDs, circleFactor, varargin) 
    % Places fault grid points on both sides of a fault
    % Arguments:
    %   faultLine       k*n array of poits, [x,y] describing the fault
    %   fracDs          Desired distance between fault points
    %   circleFactor    ratio between fracDs and circles used to create
    %                   points
    %
    % varargin:
    %   distFunc        Function setting the grid spacing
    %
    % Returns:
    % Pts               Fault points
    % gridSpacing       Grid spacing for each fault point
    % circCenter        Center of each circle used for creating the fault
    %                   points
    % circRadius        The radius of the above circles
    % CCid              Mapping from fault points to circles.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Load options
    opt = struct('distFunc', @eqSize);

    opt = merge_options(opt,varargin{:});
    fh = opt.distFunc;
    assert(0.5<circleFactor && circleFactor<1)
    assert(size(faultLine,1)>1 && size(faultLine,2)==2);
    
    %% interpolate fault line to get desired grid spacing. 
    circCenter = interFaultLine(faultLine, fh, fracDs);
    
    %% Create fault points
    numOfFracPts = size(circCenter,1)-1;
    if numOfFracPts <= 0
        Pts = [];
        gridSpacing = [];
        return
    end
    % Calculate the line lenth and circle radiuses. If you experience
    % imaginary faultOffset you might want to try the max lineLength
    % instead of the mean.
    lineLength = sqrt(sum((circCenter(2:end,:)-circCenter(1:end-1,:)).^2, 2));
    circRadius = circleFactor*[lineLength(1); ...
                              (lineLength(1:end-1) + lineLength(2:end))/2; ...
                               lineLength(end)];
                           
    % Calculate the crossing of the circles
    bisectPnt = (lineLength.^2 - circRadius(2:end).^2 + circRadius(1:end-1).^2)...
                ./(2*lineLength);
    faultOffset = sqrt(circRadius(1:end-1).^2 - bisectPnt.^2);
    n1 = (circCenter(2:end,:)-circCenter(1:end-1,:))./repmat(lineLength,1,2); %Unit vector
    n2 = [-n1(:, 2), n1(:,1)];                                                %Unit normal
    
    % Set fault points on left and right side of fault
    left   = circCenter(1:end-1,:) + bsxfun(@times, bisectPnt, n1)  ...
             + bsxfun(@times, faultOffset, n2);
    right  = circCenter(1:end-1,:) + bsxfun(@times, bisectPnt, n1)  ...
             - bsxfun(@times, faultOffset, n2);
         
    % Put together result
    Pts = [right;left];
    CCid = [1:size(left,1),1:size(right,1)]';
    gridSpacing = 2*[faultOffset;faultOffset];
end


function [p] = interFaultLine(line, fh, lineDist, varargin)
    % Interpolate a fault line. 
    % Arguments:
    %   line        Coordinates of the fault line. Must be ordered.
    %   fh          A function handle for the relative distance function 
    %               for the interpolation fh = 1 will give a equiv distant
    %               interpolation
    %   lineDist    Scalar which set the distance between interpolation
    %               points (Relative to fh = 1)
    %   varargin    Arguments passed to fh

    % Parameters
    TOL = 1e-4; maxIt = 10000;

    % Create initial points, equally distributed.
    p = eqInterpret(line, lineDist);

    count=0;
    while count<maxIt
      count = count+1;
      % Calculate distances, and wanted distances
      d = distAlLine(line, p);
      pmid = (p(1:end-1,:) + p(2:end,:))/2;
      dw = lineDist*fh(pmid,varargin{:}); % Multiply by lineDist since fh is 
                                          % the relative size fuction

      % Possible insert or remove points
      if sum(d - dw) > min(dw)
          id = find(min(d));
          p = [p(1:id,:); pmid(id,:); p(id+1:end,:)];
          continue
      elseif sum(d - dw) < - max(dw)
          id = find(min(d));
          if id == 1, id = 2; end
          p = p([1:id-1,id+1:end],:);
          continue
      end
      % If we only have external nodes, we can do nothing.
      if size(p,1)<=2, return, end
      % Move points based on desired length
      Fb = dw - d;                       % Bar forces
      Fn = Fb(1:end-1) - Fb(2:end);      % Force on internal nodes
      moveNode = Fn*0.2;                 % Movement of each internal node.
      d = d + [moveNode(1); moveNode(2:end) - moveNode(1:end-1); -moveNode(end)];
      p = interpLine(line,d);            % Update node positions
        
      % Terminate if Nodes have moved (relative) less  than TOL
      if all(moveNode<TOL*lineDist), return; end
    end

    if count == maxIt
        warning('Fault interpolation did not converge.')
    end

end


function [d] = distAlLine(line, p)
    % Calculates the distace between consecutive interpolation points along
    % line
    % Arguments:
    %   line    line that is interpolated
    %   p       Interpolation points
    % Returns:
    %   d       distance between consecutive points of p, along line
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TOL = 50*eps;
    
    N = size(p,1);
    d = zeros(N-1,1);
    jointDist = 0;
    for i = 1:size(line,1)-1
        lineStart = repmat(line(i,:), size(p,1),1);
        lineEnd = repmat(line(i+1,:), size(p,1),1);
        distA = eucDist(lineStart, p) + eucDist(p,lineEnd);
        distB = eucDist(lineStart,lineEnd);
        indx  = find(abs(distA - distB) < TOL); %Find points on line segment
        if numel(indx)==0 
            jointDist = jointDist + eucDist(line(i,:), line(i+1,:));
            continue
        elseif numel(indx)>=2
            d(indx(1:end-1)) = sqrt(sum((p(indx(1:end-1),:) ... 
                             - p(indx(2:end),:)).^2,2));
            
        end
        if indx(1)>1 && eucDist(line(i,:),p(indx(1),:))>TOL
            d(indx(1)-1) = jointDist + eucDist(line(i,:), p(indx(1),:));
        end
        jointDist = eucDist(p(indx(end),:), line(i+1,:));
    end
end


function [d] = eucDist(a, b)
    d = sqrt(sum((a - b).^2,2));
end

function [newPoints, dt] = eqInterpret(path, dt)
    linesDist = sqrt(sum(diff(path,[],1).^2,2));
    linesDist = [0; linesDist]; % add the starting point
    cumDist = cumsum(linesDist);
    dt = cumDist(end)/ceil(cumDist(end)/dt);
    newPointsLoc = 0:dt:cumDist(end);
        
    newPoints = interp1(cumDist, path, newPointsLoc);    
end


function [newPoints] = interpLine(path, dt)
    distS = sqrt(sum(diff(path,[],1).^2,2));
    t = [0; cumsum(distS)];
    
    newPtsEval = [0; cumsum(dt)];
    newPtsEval(end) = t(end); % Last point can not move

    newX = interp1(t,path(:,1),newPtsEval);
    newY = interp1(t,path(:,2),newPtsEval);
    newPoints = [newX,newY];
end


function h = eqSize(p,varargin)
h=ones(size(p,1),1);
end
