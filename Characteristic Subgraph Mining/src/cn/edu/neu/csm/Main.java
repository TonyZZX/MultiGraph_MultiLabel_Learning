package cn.edu.neu.csm;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import cn.edu.neu.csm.gspan.gSpan;

public class Main {
	public static void main(String[] args) {
		try {
			readFromFile("list.txt");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * 通过文件输入调用参数
	 *
	 * @param fileName
	 *            参数文件 格式： 第一行：需要测试的数据集个数 第二行：第一个数据集的子图的最小支持度
	 *            第三行：第一个数据集的子图的最小点个数 第四行：第一个数据集的子图的最大个数 第四行：第一个数据集的名字
	 *            训练图包的名字为【数据集名字_graph_train】 训练标记包的名字为【数据集名字_label_train】
	 *            输出的子图的名字为【数据集名字_CSM_fre支持度_time运行时间ms_subg子图个数】
	 * @throws IOException
	 */
	private static void readFromFile(String fileName) throws IOException {
		File file = new File(fileName);
		FileReader fileReader = new FileReader(file);
		BufferedReader bufReader = new BufferedReader(fileReader);
		int dataNum = Integer.parseInt(bufReader.readLine());
		for (int i = 0; i < dataNum; i++) {
			System.out.println("Processing: " + (i + 1) + "/" + dataNum);
			int sup = Integer.parseInt(bufReader.readLine());
			int nodeMin = Integer.parseInt(bufReader.readLine());
			int subgraphMax = Integer.parseInt(bufReader.readLine());
			String dataSetName = bufReader.readLine();
			String graphFileName = dataSetName + "_graph_train";
			String labelFileName = dataSetName + "_label_train";
			String resultFileName = dataSetName + "_CSM_result";

			long startTime = System.currentTimeMillis();
			runCSM(sup, nodeMin, subgraphMax, graphFileName, labelFileName, resultFileName);
			long endTime = System.currentTimeMillis();

			File oldFile = new File(resultFileName);
			File newFile = new File(dataSetName + "_CSM" + "_fre" + sup + "_time" + (endTime - startTime)
					+ "ms_subg" + subgraphMax);
			newFile.delete();
			oldFile.renameTo(newFile);
		}
		System.out.println("Done!");
		bufReader.close();
		fileReader.close();
	}

	private static void runCSM(int sup, int nodeMin, int subgraphMax, String graphFileName, String labelFileName,
			String resultFileName) throws IOException {
		File readfile = new File(graphFileName);
		FileReader reader = new FileReader(readfile);
		gSpan gSpan = new gSpan();
		gSpan.run(reader, null, sup, Integer.MAX_VALUE, nodeMin, false, false);

		readfile = new File(labelFileName);
		reader = new FileReader(readfile);
		File writefile = new File(resultFileName);
		FileWriter writer = new FileWriter(writefile);
		writer.flush();

		CSM csm = new CSM();
		csm.run(reader, writer, gSpan, subgraphMax);

		writer.close();
		reader.close();
	}
}
