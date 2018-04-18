This software implements the MATLAB wrapper for IBFS max-flow/min-cut algorithm.

Anton Osokin, (firstname.lastname@gmail.com)
29.09.2014
https://github.com/aosokin/graphCutMex_IBFS

Please cite the following paper in any resulting publication:

A. V. Goldberg, S. Hed, H. Kaplan, R. E. Tarjan, and R. F. Werneck, 
Maximum Flows by Incremental Breadth-First Search,
In Proceedings of the 19th European conference on Algorithms, ESA'11, pages 457-468.
http://www.cs.tau.ac.il/~sagihed/ibfs/

DIFFERENCE TO BOYKOV-KOLMOGOROV algorithm (https://github.com/aosokin/graphCutMex_BoykovKolmogorov )
-----------------------------

The IBFS algorithm has polynomial time runtime guarantees. The BK does not.

In my experience BK works faster for graphs built for standard 4(8)-connected grid MRFs.
If the graph becomes more complicated (especially hierarchical) consider trying IBFS instead.

PACKAGE
-----------------------------

./graphCutMex.cpp - the C++ code of the wrapper

./build_graphCutMex.m - function to build the wrapper

./graphCutMex.m - the description of the implemented function

./example_graphCutMex.m - the example of usage

./ibfs - C++ code of IBFS (an old version modified to work with double weights)

./graphCutMex.mexw64 - binary file for the MEX-function compiled using MATLAB R2014a + MSVC 2012

./graphCutMex.mexa64 - Linux x64 binary file for the MEX-function compiled using  MATLAB R2012a + gcc-4.4

USING THE CODE
-----------------------------

0) Install MATLAB and one of the supported compilers

1) Run build_graphCutMex.m

2) Run example_graphCutMex.m to check if the code works

The code was tested under 
- Win7-x64 using MATLAB R2014a and MSVC 2012;
- ubuntu-12.04-x64 using MATLAB R2012a and gcc-4.4

OTHER PACKAGES
-----------------------------

* BK max-flow/min-cut algorithm:
https://github.com/aosokin/graphCutMex_BoykovKolmogorov

BK-algorithm would be the most standard one to solve the graph cut problems.

* BK max-flow/min-cut algorithm with interface supporting dynamic graph cuts:
https://github.com/aosokin/graphCutDynamicMex_BoykovKolmogorov

If you need to solve many similar graph cut problems in a row consider using dynamic graph cuts.

* QPBO algorithm
https://github.com/aosokin/qpboMex

If you need to minimize energy with just a few non-submodular edges try using the QPBO algorithm 
