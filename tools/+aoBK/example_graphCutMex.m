% example of usage of package graphCutMex
%
% Anton Osokin (firstname.lastname@gmail.com),  19.05.2013

nNodes=4;
%source,sink
terminalWeights=[
    16,0;
    13,0;
    0,20;
    0,4
];

%From,To,Capacity,Rev_Capacity
edgeWeights=[
    1,2,10,4;
    1,3,12,-1;
    2,3,-1,9;
    2,4,14,0;
    3,4,0,7
    ];

[cut, labels] = graphCutMex(terminalWeights,edgeWeights);

% correct answer: cut = 22; labels = [0; 0; 1; 0];
if ~isequal(cut, 22)
    warning('Wrong value of cut!')
end
if ~isequal(labels, [0; 0; 1; 0])
    warning('Wrong value of labels!')
end
