package cn.edu.neu.gspan.model;

import java.util.ArrayList;
import java.util.TreeMap;

public class Projected extends ArrayList<PDFS> {
	public void push(int id, Edge edge, PDFS prev) {
		PDFS d = new PDFS();
		d.id = id;
		d.edge = edge;
		d.prev = prev;
		this.add(d);
	}
}
