package cn.edu.neu.csm;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.NavigableMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.Map.Entry;

import cn.edu.neu.csm.gspan.gSpan;
import cn.edu.neu.csm.gspan.model.Graph;
import cn.edu.neu.csm.model.Label;

public class CSM {
	// 多标记矩阵
	public ArrayList<Label> labelMatrix;

	private FileWriter os;
	// 最多返回的子图个数
	private int maxNum = 0;

	private long ID = 0;
	// 图包个数
	private int graphNum = 0;
	// 一个图包对应的标记个数
	private int labelNum = 0;
	// 最后频繁子图个数
	private int subgraphNum = 0;
	// 最后的频繁子图，都出现在哪些图中
	private NavigableMap<Integer, ArrayList<Integer>> appearedGraphMap;
	// 最后的频繁子图挖掘结果
	private NavigableMap<Integer, Graph> subgraphMap;

	public CSM() {
		labelMatrix = new ArrayList<>();
	}

	public void run(FileReader is, FileWriter os, gSpan gSpan, int maxNum) throws IOException {
		this.os = os;
		ID = 0;
		appearedGraphMap = gSpan.appearedGraphMap;
		subgraphMap = gSpan.subgraphMap;
		subgraphNum = subgraphMap.size();
		this.maxNum = maxNum;

		read(is);
		run_intern();
		os.write("t # -1");
		os.flush();
	}

	private FileReader read(FileReader is) throws IOException {
		BufferedReader read = new BufferedReader(is);
		while (true) {
			Label l = new Label();
			read = l.read(read);
			if (l.multiLabels.isEmpty())
				break;
			labelMatrix.add(l);

			if (labelNum == 0) {
				labelNum = l.multiLabels.size();
			}
		}
		graphNum = labelMatrix.size();
		read.close();
		return is;
	}

	private void run_intern() throws IOException {
		NavigableMap<Integer, Double> subgraphEntropy = new TreeMap<>();
		for (Entry<Integer, ArrayList<Integer>> mEntry : appearedGraphMap.entrySet()) {
			// 熵
			double entropy = 0.0;
			for (int i = 0; i < labelNum; i++) {
				// 正负标记的出现次数
				int countPos = 0, countNeg = 0;
				for (int graphId : mEntry.getValue()) {
					if (labelMatrix.get(graphId).multiLabels.get(i) > 0) {
						countPos++;
					} else {
						countNeg++;
					}
				}
				// 计算正负标记p值
				double pPos = countPos * 1.0 / (countPos + countNeg), pNeg = countNeg * 1.0 / (countPos + countNeg);
				// 计算熵
				entropy += -pPos * Common.log(pPos, 2) - pNeg * Common.log(pNeg, 2);
			}
			entropy = entropy / (labelNum * 1.0);
			subgraphEntropy.put(mEntry.getKey(), entropy);
		}
		
		SortedSet<Entry<Integer, Double>> sortedEntropy = Common.entriesSortedByValues(subgraphEntropy);
		for (Entry<Integer, Double> entry : sortedEntropy) {
			report(entry);
		}
	}

	private void report(Entry<Integer, Double> entry) throws IOException {
		if (ID >= maxNum) {
			return;
		}
		
		Graph g = subgraphMap.get(entry.getKey());
		os.write("t # " + ID + " * " + entry.getValue() + System.getProperty("line.separator"));
		g.write(os);
		++ID;
	}
}
