%% graph based detection
bins = burst.sp2evt(sigDiMat,distMat,Lidx,H1,W1);

%%
A = zeros(3,3);
A(1,2) = 1.5;
A(3,2) = 0.5;
G = digraph(A);
p = plot(G,'Layout','layered','EdgeLabel',G.Edges.Weight);

d = distances(G,2);

Gt = digraph(A');
dt = distances(Gt,2);







