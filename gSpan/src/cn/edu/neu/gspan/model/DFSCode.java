package cn.edu.neu.gspan.model;

import java.util.ArrayList;

public class DFSCode extends ArrayList<DFS> {
	public void push(int from, int to, int fromlabel, int elabel, int tolabel) {
		DFS d = new DFS();
		d.from = from;
		d.to = to;
		d.fromlabel = fromlabel;
		d.elabel = elabel;
		d.tolabel = tolabel;
		this.add(d);
	}

	public void pop() {
		this.remove(this.size() - 1);
	}
}
