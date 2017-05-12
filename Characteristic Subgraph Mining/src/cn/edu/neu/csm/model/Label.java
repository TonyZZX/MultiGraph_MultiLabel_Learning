package cn.edu.neu.csm.model;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;

// 1个 graph 对应的多标记
public class Label {
	// 是否有未标记的标记
	private boolean isHaveUnlabel = false;
	// 多标记
	public ArrayList<Integer> multiLabels;
	
	public Label() {
		multiLabels = new ArrayList<>();
	}
	
	public BufferedReader read(BufferedReader is) throws IOException {
		ArrayList<String> result = new ArrayList<>();
		String line = null;

		multiLabels.clear();

		while ((line = is.readLine()) != null) {
			result.clear();
			String[] splitRead = line.split(" ");
			for (String str : splitRead) {
				result.add(str);
			}

			if (result.isEmpty()) {
				// do nothing
			} else if (result.get(0).equals("t")) {
				if (!multiLabels.isEmpty()) { // use as delimiter
					break;
				}
			} else if (result.get(0).equals("l") && result.size() >= 3) {
				int label = Integer.parseInt(result.get(2));
				// 正标记为1，负标记为-1
				if (!isHaveUnlabel && label <= 0) {
					multiLabels.add(-1);
				} else {
					multiLabels.add(label);
				}
			}
		}

		return is;
	}
	
}
