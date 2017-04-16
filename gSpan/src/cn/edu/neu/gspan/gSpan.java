package cn.edu.neu.gspan;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map.Entry;

import cn.edu.neu.gspan.model.DFSCode;
import cn.edu.neu.gspan.model.Edge;
import cn.edu.neu.gspan.model.Graph;
import cn.edu.neu.gspan.model.Projected;
import cn.edu.neu.gspan.model.Vertex;

import java.util.NavigableMap;
import java.util.TreeMap;
import java.util.Vector;

public class gSpan {
	private ArrayList<Graph> TRANS;
	private DFSCode DFS_CODE;

	private long ID;
	private long minsup;
	private long maxpat_min;
	private long maxpat_max;
	private boolean directed;
	private boolean self_loop;
	private FileWriter os;

	/*
	 * Singular vertex handling stuff [graph][vertexlabel] = count.
	 */
	NavigableMap<Integer, NavigableMap<Integer, Integer>> singleVertex;
	NavigableMap<Integer, Integer> singleVertexLabel;

	public gSpan() {
		TRANS = new ArrayList<>();
		DFS_CODE = new DFSCode();

		singleVertex = new TreeMap<>();
		singleVertexLabel = new TreeMap<>();
	}

	public void run(FileReader is, FileWriter _os, long _minsup, long _maxpat_max, long _maxpat_min, boolean _directed)
			throws IOException {
		os = _os;
		ID = 0;
		minsup = _minsup;
		maxpat_min = _maxpat_min;
		maxpat_max = _maxpat_max;
		directed = _directed;
		self_loop = false;

		read(is);
		run_intern();
	}

	private FileReader read(FileReader is) throws IOException {
		BufferedReader read = new BufferedReader(is);
		while (true) {
			Graph g = new Graph(directed);
			read = g.read(read);
			if (g.isEmpty())
				break;
			TRANS.add(g);
		}
		return is;
	}

	private void run_intern() {
		/*
		 * In case 1 node subgraphs should also be mined for, do this as
		 * preprocessing step.
		 */
		if (maxpat_min <= 1) {
			/*
			 * Do single node handling, as the normal gspan DFS code based
			 * processing cannot find subgraphs of size |subg|==1. Hence, we
			 * find frequent node labels explicitly.
			 */
			for (int id = 0; id < TRANS.size(); ++id) {
				for (int nid = 0; nid < TRANS.get(id).size(); ++nid) {
					int key = TRANS.get(id).get(nid).label;
					if (singleVertex.get(id) == null) {
						singleVertex.put(id, new TreeMap<>());
					}
					if (singleVertex.get(id).get(key) == null) {
						// number of graphs it appears in
						singleVertexLabel.put(key, Common.getValue(singleVertexLabel.get(key)) + 1);
					}

					singleVertex.get(id).put(key, Common.getValue(singleVertex.get(id).get(key)) + 1);
				}
			}
		}
		/*
		 * All minimum support node labels are frequent 'subgraphs'.
		 * singleVertexLabel[nodelabel] gives the number of graphs it appears
		 * in.
		 */
		for (Entry<Integer, Integer> it : singleVertexLabel.entrySet()) {
			if (it.getValue() < minsup)
				continue;

			int frequent_label = it.getKey();

			/*
			 * Found a frequent node label, report it.
			 */
			Graph g = new Graph(directed);
			Vertex v = new Vertex();
			v.label = frequent_label;
			g.add(v);

			/*
			 * [graph_id] = count for current substructure
			 */
			Vector<Integer> counts = new Vector<>(TRANS.size());
			for (Entry<Integer, NavigableMap<Integer, Integer>> it2 : singleVertex.entrySet()) {
				counts.add(it2.getKey(), it2.getValue().get(frequent_label));
			}
			NavigableMap<Integer, Integer> gycounts = new TreeMap<>();
			for (int n = 0; n < counts.size(); ++n)
				gycounts.put(n, counts.get(n));

			report_single(g, gycounts);
		}

		ArrayList<Edge> edges = new ArrayList<>();
		NavigableMap<Integer, NavigableMap<Integer, NavigableMap<Integer, Projected>>> root = new TreeMap<>();

		for (int id = 0; id < TRANS.size(); ++id) {
			Graph g = TRANS.get(id);
			for (int from = 0; from < g.size(); ++from) {
				if (Misc.get_forward_root(g, g.get(from), edges)) {
					for (Edge it : edges) {
						int key_1 = g.get(from).label;
						NavigableMap<Integer, NavigableMap<Integer, Projected>> root_1 = root.get(key_1);
						if (root_1 == null) {
							root_1 = new TreeMap<>();
							root.put(key_1, root_1);
						}
						int key_2 = it.elabel;
						NavigableMap<Integer, Projected> root_2 = root_1.get(key_2);
						if (root_2 == null) {
							root_2 = new TreeMap<>();
							root_1.put(key_2, root_2);
						}
						int key_3 = g.get(it.to).label;
						Projected root_3 = root_2.get(key_3);
						if (root_3 == null) {
							root_3 = new Projected();
							root_2.put(key_3, root_3);
						}
						root_3.push(id, it, null);
					}
				}
			}
		}

		for (Entry<Integer, NavigableMap<Integer, NavigableMap<Integer, Projected>>> fromlabel : root.entrySet()) {
			for (Entry<Integer, NavigableMap<Integer, Projected>> elabel : fromlabel.getValue().entrySet()) {
				for (Entry<Integer, Projected> tolabel : elabel.getValue().entrySet()) {
					/*
					 * Build the initial two-node graph. It will be grown
					 * recursively within project.
					 */
					DFS_CODE.push(0, 1, fromlabel.getKey(), elabel.getKey(), tolabel.getKey());
					// project (tolabel->second);
					DFS_CODE.pop();
				}
			}
		}
	}

	/*
	 * Special report function for single node graphs.
	 */
	private void report_single(Graph g, NavigableMap<Integer, Integer> ncount) {
		// int sup = 0;
		// for (Entry<Integer, Integer> it : ncount.entrySet())
		// {
		// sup += Common.getValue(it.getValue());
		// }

		if (maxpat_max > maxpat_min && g.size() > maxpat_max)
			return;
		if (maxpat_min > 0 && g.size() < maxpat_min)
			return;

		// System.out.println("t # * " + sup);
	}
}
