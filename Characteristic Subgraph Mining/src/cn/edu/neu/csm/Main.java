package cn.edu.neu.csm;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import cn.edu.neu.csm.gspan.gSpan;

public class Main {
	public static void main(String[] args) throws IOException {
		int sup = 100;
		int nodeMax = Integer.MAX_VALUE;
		int nodeMin = 2;
		int subgraphMax = 600;
		String graphFileName = "MSRC_graph_train_GT_9x15";
		String labelFileName = "MSRC_label_train_GT_9x15";
		
		File readfile = new File(graphFileName);
		File writefile = new File(readfile.getName() + "_result");
		FileReader reader = new FileReader(readfile);
		FileWriter writer = new FileWriter(writefile);
		writer.flush();

		gSpan gSpan = new gSpan();
		gSpan.run(reader, writer, sup, nodeMax, nodeMin, false);

		readfile = new File(labelFileName);
		writefile = new File(readfile.getName() + "_result");
		reader = new FileReader(readfile);
		writer = new FileWriter(writefile);
		writer.flush();
		
		CSM csm = new CSM();
		csm.run(reader, writer, gSpan, subgraphMax);
	}
}
