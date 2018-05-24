ref = [0,1,1,1; 0,1,1,1];
tst = [0,1,0,1; 0,1,0,1];

s = 1;  % use (s,t) pairs to describe all edges in the graph
t = 2;
smoBase = 1;  % smoothness
winSize = 3;  % window size
s2 = 0.01;  % noise standard deviation

[ ss,ee,gI ] = gtw.buildGTWGraph( ref,tst,s,t,smoBase,winSize,s2);

[~, L] = aoIBFS.graphCutMex(ss,ee);

path0 = gtw.label2path4Aosokin( L, ee, ss, gI );

%% show path and graphs
plt.dtwPath(path0,1:2);
lbl00 = L(1:gI.nNodeGrid);
ew00 = ee(1:gI.nEdgeGrid,:);
plt.graph(gI.pEdge,gI.dEdge,gI.srcSinkPos,gI.nodePos,lbl00,ew00);



