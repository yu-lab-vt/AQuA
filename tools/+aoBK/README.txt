This software implements the MATLAB wrapper for Boykov-Kolmogorov max-flow/min-cut algorithm.

Anton Osokin, (firstname.lastname@gmail.com)
19.05.2013
https://github.com/aosokin/graphCutMex_BoykovKolmogorov

Please cite the following paper in any resulting publication:

Yuri Boykov and Vladimir Kolmogorov, An experimental comparison of Min-Cut/Max-Flow algorithms for energy minimization in vision, 
IEEE TPAMI, 26(9):1124-1137, 2004.

PACKAGE
-----------------------------

./graphCutMex.cpp, ./graphCutMex.h - the C++ code of the wrapper

./build_graphCutMex.m - function to build the wrapper

./graphCutMex.m - the description of the implemented function

./example_graphCutMex.m - the example of usage

./maxflow-v3.03.src - C++ code by Vladimir Kolmogorov (the code was slightly modified)
http://pub.ist.ac.at/~vnk/software/maxflow-v3.03.src.zip

./graphCutMex.mexw64 - Win x64 binary file for the MEX-function compiled using MATLAB R2014a + MSVC 2012

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

* BK max-flow/min-cut algorithm with interface supporting dynamic graph cuts:
https://github.com/aosokin/graphCutDynamicMex_BoykovKolmogorov

If you need to solve many similar graph cut problems in a row consider using dynamic graph cuts.

* IBFS max-flow/min-cut algorithm: https://github.com/aosokin/graphCutMex_IBFS

The IBFS algorithm has polynomial time runtime guarantees. The BK does not.
In my experience BK works faster for graphs built for standard 4(8)-connected grid MRFs.
If the graph becomes more complicated (especially hierarchical) consider trying IBFS instead.

* QPBO algorithm
https://github.com/aosokin/qpboMex

If you need to minimize energy with just a few non-submodular edges try using the QPBO algorithm 
