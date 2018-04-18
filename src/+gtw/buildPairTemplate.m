function [pEdge, dEdge, cPos, cVal, st01, eType] = buildPairTemplate(T,winSize,pmCost,visMe)
% Get a template of graphs for single pair using coordinates
% Get both primal edges and dual edges in coordinates
% Use extra src and sink node to allow partial matching
% Specify partial matching cost by pmCost of size 1 x winSize
% weightPos gives pixel dependent portion of the weight based on position in the distance matrix
% If take position (1,T+1), it means not using the distance matrix
% weightVal gives prespecified weight independent of pixel, zero means not using
% Edge types (eType). 1: diagonal/from grid to sink 2: horizontal or vertical 3: from src to grid
%
% !! this could introduce bias, need better normalization
%
% Inf means maximum value (usually infinite capacity)
% 0 means there is nothing
%
% Pairs in the form (ref,tst). Weight position also (ref,tst)
% For coordinates, actually this means ref in x axis and tst in y axis

%% setup
if ~exist('T','var')
    T = 7;
end

if ~exist('winSize','var')
    winSize = 3;
end

if ~exist('pmCost','var')
    pmCost = (0:winSize)*0.5;
else
    if isempty(pmCost)
        pmCost = (0:winSize)*0.5;
    end
end

if ~exist('visMe','var')
    visMe = 0;
end

if winSize==1
    error('winSize should be integer larger than 1\n');
end

s0 = [0,0];
t0 = [T+1,T+1];
s1 = [T+1,0];
t1 = [0,T+1];
st01 = [s0,t0,s1,t1];

% diagnal, sub diagonals, extra edges to s and t, vertical and horizontal edges
% all in two directions, the reverse is infinite, but we ONLY build finite portion here
nEdges = T-1 + (T-2 + T-winSize)*(winSize-1) + 2*(2*winSize-1) + 2*(T-1 + T-winSize+1)*(winSize-1);

% primal and dual edges as well as weights in coordinate form
% node1 -> node2: (x,y) for node1, (x,y) for node 2
% (x,y) for weight matrix position, (1,T+1) means none exist position
pEdge = zeros(nEdges,4);
dEdge = zeros(nEdges,4);
cPos = [ones(nEdges,1),ones(nEdges,1)*(T+1)];
cVal = zeros(nEdges,1);
eType = zeros(nEdges,1);

%% assign edges
% loop through all nodes in primal graph, get edges to the right, top or top-right
% save each edge, and the corresponding dual edge, as well as the position in the weighting matrix
% edges outside the window is not included

% from s to nodes
pEdge(1,:) = [s0,1,1]; dEdge(1,:) = [1.5,0.5,0.5,1.5];
nn = 2;
for w = 2:winSize
    pEdge(nn,:) = [s0,1,w];  % close to top left
    pEdge(nn+1,:) = [s0,w,1];  % close to bottom right
    if w==winSize
        dEdge(nn,:) = [0.5,w-0.5,t1];
        dEdge(nn+1,:) = [s1,w-0.5,0.5];
    else
        dEdge(nn,:) = [0.5,w-0.5,0.5,w+0.5];
        dEdge(nn+1,:) = [w+0.5,0.5,w-0.5,0.5];
    end
    eType(nn:nn+1) = 3;
    cVal(nn) = pmCost(w);
    cVal(nn+1) = pmCost(w);
    nn = nn + 2;
end

% within grid
for x0=1:T  % ref
    for y0=1:T  % tst
        if x0==T && y0==T
            continue
        end
        if y0<(x0-winSize+1) || y0>(x0+winSize-1)
            continue
        end
        x = x0; y = y0+1;  % top
        if y>=(x-winSize+1) && y<=(x+winSize-1) && x<=T && y<=T
            pEdge(nn,:) = [x0,y0,x,y];
            cPos(nn,:) = [x0,y0];
            if x0==1
                dEdge(nn,:) = [x0+0.25,y0+0.75,0.5,y0+0.5];
            elseif x0==T
                dEdge(nn,:) = [T+0.5,y0+0.5,x0-0.25,y0+0.25];
            else
                dEdge(nn,:) = [x0+0.25,y0+0.75,x0-0.25,y0+0.25];
            end
            eType(nn) = 2;
            nn = nn + 1;
        end
        x = x0+1; y = y0;  % right
        if y>=(x-winSize+1) && y<=(x+winSize-1) && x<=T && y<=T
            pEdge(nn,:) = [x0,y0,x,y];
            cPos(nn,:) = [x0,y0];
            if y0==1
                dEdge(nn,:) = [x0+0.5,0.5,x0+0.75,y0+0.25];
            elseif y0==T
                dEdge(nn,:) = [x0+0.25,y0-0.25,x0+0.5,T+0.5];
            else
                dEdge(nn,:) = [x0+0.25,y0-0.25,x0+0.75,y0+0.25];
            end
            eType(nn) = 2;
            nn = nn + 1;
        end
        x = x0+1; y = y0+1;  % topright (diagonal)
        if y>=(x-winSize+1) && y<=(x+winSize-1) && x0<T && y0<T
            pEdge(nn,:) = [x0,y0,x,y];
            cPos(nn,:) = [x0,y0];
            if y==(x+winSize-1)
                dEdge(nn,:) = [x0+0.75,y0+0.25,t1];
            elseif y==(x-winSize+1)
                dEdge(nn,:) = [s1,x0+0.25,y0+0.75];
            else
                dEdge(nn,:) = [x0+0.75,y0+0.25,x0+0.25,y0+0.75];
            end
            eType(nn) = 1;
            nn = nn + 1;
        end
    end
end

% from nodes to t
pEdge(nn,:) = [T,T,t0]; dEdge(nn,:) = [T+0.5,T-0.5,T-0.5,T+0.5]; cPos(nn,:) = [T,T];
nn = nn + 1;
for w = 2:winSize
    pEdge(nn,:) = [T-w+1,T,t0];  % close to top left
    pEdge(nn+1,:) = [T,T-w+1,t0];  % close to bottom right
    if w==winSize
        dEdge(nn,:) = [T+1-w+0.5,T+0.5,t1];
        dEdge(nn+1,:) = [s1,T+0.5,T+1-w+0.5];
    else
        dEdge(nn,:) = [T+1-w+0.5,T+0.5,T+1-w-0.5,T+0.5];
        dEdge(nn+1,:) = [T+0.5,T+1-w-0.5,T+0.5,T+1-w+0.5];
    end
    cPos(nn,:) = [T-w+1,T];
    cPos(nn+1,:) = [T,T-w+1];
    cVal(nn) = pmCost(w);
    cVal(nn+1) = pmCost(w);
    eType(nn:nn+1) = 1;
    nn = nn + 2;
end

%% plot
if visMe && T<=10
    figure;
    scatter(st01(1:2:end),st01(2:2:end),100,[1 0.5 0]);hold on
    for ii=1:size(pEdge,1)
        io.drawArrow([pEdge(ii,1),pEdge(ii,3)],[pEdge(ii,2),pEdge(ii,4)],{'Color',[1 0.5 0]});
        io.drawArrow([dEdge(ii,1),dEdge(ii,3)],[dEdge(ii,2),dEdge(ii,4)],{'Color',[0 0 1]});
    end
    xlabel('Test');ylabel('Ref');
end

end






