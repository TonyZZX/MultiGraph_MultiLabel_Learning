package cn.edu.neu.gspan;

import java.util.ArrayList;

import cn.edu.neu.gspan.model.Edge;
import cn.edu.neu.gspan.model.Graph;
import cn.edu.neu.gspan.model.Vertex;

public class Misc {
	/*
	 * graph の vertex からはえる edge を探す ただし,
	 * fromlabel <= tolabel の性質を満たす.
	 */
	public static boolean get_forward_root(Graph g, Vertex v, ArrayList<Edge> result) {
		result.clear();
		for (Edge it : v.edge) {
			assert (it.to >= 0 && it.to < g.size());
			if (v.label <= g.get(it.to).label)
				result.add(it);
		}

		return (!result.isEmpty());
	}
}
