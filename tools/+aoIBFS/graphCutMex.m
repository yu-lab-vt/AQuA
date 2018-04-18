% graphCutMex - Matlab wrapper to the IBFS max-flow/min-cut algorithm:
% A. V. Goldberg, S. Hed, H. Kaplan, R. E. Tarjan, and R. F. Werneck, 
% Maximum Flows by Incremental Breadth-First Search,
% In Proceedings of the 19th European conference on Algorithms, ESA'11, pages 457-468.
% http://www.cs.tau.ac.il/~sagihed/ibfs
%
% This version can automatically perform reparametrization on all submodular edges.
% 
% Usage:
% [cut] = graphCutMex(termWeights, edgeWeights);
% [cut, labels] = graphCutMex(termWeights, edgeWeights);
% 
% Inputs:
% termWeights	-	the edges connecting the source and the sink with the regular nodes (array of type double, size : [numNodes, 2])
% 				termWeights(i, 1) is the weight of the edge connecting the source with node #i
% 				termWeights(i, 2) is the weight of the edge connecting node #i with the sink
% 				numNodes is determined from the size of termWeights.
% edgeWeights	-	the edges connecting regular nodes with each other (array of type double, array size [numEdges, 4])
% 				edgeWeights(i, 3) connects node #edgeWeights(i, 1) to node #edgeWeights(i, 2)
% 				edgeWeights(i, 4) connects node #edgeWeights(i, 2) to node #edgeWeights(i, 1)
%				The only requirement on edge weights is submodularity: edgeWeights(i, 3) + edgeWeights(i, 4) >= 0
%
% Outputs:
% cut           -	the minimum cut value (type double)
% labels		-	a vector of length numNodes, where labels(i) is 0 or 1 if node #i belongs to S (source) or T (sink) respectively.
% 
% To build the code in Matlab choose reasonable compiler and run build_graphCutMex.m
% Run example_graphCutMex.m to test the code
% 
% 	Anton Osokin (firstname.lastname@gmail.com)
