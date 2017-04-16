package cn.edu.neu.gspan.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Vector;

public class History extends ArrayList<Edge> {
	private Vector<Integer> edge;
	private Vector<Integer> vertex;

	public History(Graph g, PDFS p) {
		edge = new Vector<>();
		vertex = new Vector<>();
		build(g, p);
	}

	public void build(Graph graph, PDFS e) {
		// first build history
		clear();
		edge.clear();
		edge.setSize(graph.edge_size);
		vertex.clear();
		vertex.setSize(graph.size());

		if (e != null) {
			add(e.edge);
			edge.set(e.edge.id, 1);
			vertex.set(e.edge.from, 1);
			vertex.set(e.edge.to, 1);

			for (PDFS p = e.prev; p != null; p = p.prev) {
				add(p.edge); // this line eats 8% of overall instructions(!)
				edge.set(e.edge.id, 1);
				vertex.set(e.edge.from, 1);
				vertex.set(e.edge.to, 1);
			}
			Collections.reverse(this);
		}
	}

	public boolean hasEdge(int id) {
		if (edge.get(id) != null) {
			return true;
		} else {
			return false;
		}
	}

	public boolean hasVertex(int id) {
		if (vertex.get(id) != null) {
			return true;
		} else {
			return false;
		}
	}
}
