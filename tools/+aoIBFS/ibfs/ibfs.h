
#ifndef _IBFS_H__
#define _IBFS_H__


//#define STATS


#pragma warning(disable:4786)
#include <time.h>
#include <sys/timeb.h>


template <typename captype, typename tcaptype, typename flowtype> class IBFSGraph
{
public:
	typedef enum
	{
		SOURCE	= 0,
		SINK	= 1
	} termtype;
	typedef int node_id;

	IBFSGraph(int numNodes, int numEdges, void (*errorFunction)(const char*) = NULL);
	~IBFSGraph();
	int add_node(int numNodes);
	void add_edge(int nodeIndexFrom, int nodeIndexTo, captype capacity, captype reverseCapacity);
	void add_tweights(int nodeIndex, tcaptype capacityFromSource, tcaptype CapacityToSink);

	// to separate the graph creation and maximum flow for measurements,
	// call prepareGraph and then call maxflowClean
	// prepareGraph is only required because of the limited API for building the graph
	// (specifically - the degree of nodes is not given)
	void prepareGraph();
	flowtype maxflowClean();

	flowtype maxflow()
	{
		prepareGraph();
		return maxflowClean();
	}

	termtype what_segment(int nodeIndex, termtype default_segm = SOURCE);


private:

	struct node;
	struct arc;

	struct arc
	{
		node*		head;
		arc*		sister;
//		int			sister_rCap :1;
//		captype		rCap :31;
// CHANGE by ANTON: 
		char		sister_rCap;
		captype		rCap;

	};

	struct node
	{
		arc			*firstArc;
		arc			*parent;
		node		*nextActive;
		node		*firstSon;
		int			nextSibling;
		int			label;		// distance to the source or the sink
								// label > 0: distance from src
								// label < 0: -distance from sink
		union
		{
			tcaptype	srcSinkCap;		// srcSinkCap > 0: capacity from the source
										// srcSinkCap < 0: -capacity to the sink
			node		*nextOrphan;
		};
	};

	struct AugmentationInfo
	{
		captype remainingDeficit;
		captype remainingExcess;
		captype flowDeficit;
		captype flowExcess;
	};

	node		*nodes, *nodeLast;
	arc			*arcs, *arcLast;
	flowtype	flow;

	void augment(arc *bridge, AugmentationInfo* augInfo);
	void adoptionSrc();
	void adoptionSink();

	node* orphanFirst;
	node* orphanLast;

	int activeLevel;
	node* activeFirst0;
	node* activeFirst1;
	node* activeLast1;

	void (*errorFunction)(const char *);
	int nNodes;

#ifdef STATS
	double numAugs;
	double grownSinkTree;
	double grownSourceTree;
	double numOrphans;

	double growthArcs;
	double numPushes;
	double orphanArcs1;
	double orphanArcs2;
	double orphanArcs3;
	
	double numOrphans0;
	double numOrphans1;
	double numOrphans2;
	double augLenMin;
	double augLenMax;
#endif

};





template <typename captype, typename tcaptype, typename flowtype> inline void IBFSGraph<captype, tcaptype, flowtype>::add_tweights(int nodeIndex, tcaptype capacitySource, tcaptype capacitySink)
{
	flowtype f = nodes[nodeIndex].srcSinkCap;
	if (f > 0)
	{
		capacitySource += f;
	}
	else
	{
		capacitySink -= f;
	}
	if (capacitySource < capacitySink)
	{
		flow += capacitySource;
	}
	else
	{
		flow += capacitySink;
	}
	nodes[nodeIndex].srcSinkCap = capacitySource - capacitySink;
}

template <typename captype, typename tcaptype, typename flowtype> inline void IBFSGraph<captype, tcaptype, flowtype>::add_edge(int nodeIndexFrom, int nodeIndexTo, captype capacity, captype reverseCapacity)
{
	arc *aFwd = arcLast;
	arcLast++;
	arc *aRev = arcLast;
	arcLast++;

	node* x = nodes + nodeIndexFrom;
	x->label++;
	node* y = nodes + nodeIndexTo;
	y->label++;

	aRev->sister = aFwd;
	aFwd->sister = aRev;
	aFwd->rCap = capacity;
	aRev->rCap = reverseCapacity;
	aFwd->head = y;
	aRev->head = x;
}



template <typename captype, typename tcaptype, typename flowtype> inline typename IBFSGraph<captype, tcaptype, flowtype>::termtype IBFSGraph<captype, tcaptype, flowtype>::what_segment(int nodeIndex, termtype default_segm)
{
	if (nodes[nodeIndex].parent != NULL)
	{
		if (nodes[nodeIndex].label > 0)
		{
			return SOURCE;
		}
		else
		{
			return SINK;
		}
	}
	return default_segm;
}

template <typename captype, typename tcaptype, typename flowtype> inline int IBFSGraph<captype, tcaptype, flowtype>::add_node(int numNodes)
{
	int n = nNodes;
	nNodes += numNodes;
	return n;
}

#endif


