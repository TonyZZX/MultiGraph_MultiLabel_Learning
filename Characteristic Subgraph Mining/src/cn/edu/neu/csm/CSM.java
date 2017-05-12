package cn.edu.neu.csm;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import cn.edu.neu.csm.model.Label;

public class CSM {
	// 多标记矩阵
	public ArrayList<Label> labelMatrix;

	public CSM() {
		labelMatrix = new ArrayList<>();
	}

	public void run(FileReader is) throws IOException {
		read(is);
	}

	private FileReader read(FileReader is) throws IOException {
		BufferedReader read = new BufferedReader(is);
		while (true) {
			Label l = new Label();
			read = l.read(read);
			if (l.multiLabels.isEmpty())
				break;
			labelMatrix.add(l);
		}
		return is;
	}
}
