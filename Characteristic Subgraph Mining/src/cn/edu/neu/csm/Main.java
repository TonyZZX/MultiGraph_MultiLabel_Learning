package cn.edu.neu.csm;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.Map.Entry;

import cn.edu.neu.csm.gspan.gSpan;
import cn.edu.neu.csm.model.Label;

public class Main {
	public static void main(String[] args) throws IOException {
		/**
		 * TODO
		 * 1. 记录每个子图都出现在哪几个graph里，记录主graph的编号
		 * 	- map<子图编号, List（都出现在哪些图里）>
		 * 实现！
		 * 
		 * 2. 读入标记。根据每个图包的大小，给包内每个图都打上标记
		 * 	- 多标记矩阵
		 * 实现！
		 * 
		 * 3. 遍历子图map，算出信息分数map<子图编号, 信息分数>
		 * 实现！
		 * 
		 * 4. 按照信息分数重排序
		 */

		int minsup = 1;
		int maxpat = Integer.MAX_VALUE;
		int minnodes = 0;
		boolean directed = false;

		Scanner sc = new Scanner(System.in);
		System.out.println("频繁子图挖掘：\n请输入文件名");
//		String filepath = sc.nextLine();
		String filepath = "graph";
		System.out.println("请输入频数");
//		minsup = sc.nextInt();
		minsup = 2;
		File readfile = new File(filepath);
		File writefile = new File(readfile.getName() + "_result");
		FileReader reader = new FileReader(readfile);
		FileWriter writer = new FileWriter(writefile);
		writer.flush();

		gSpan gSpan = new gSpan();
		gSpan.run(reader, writer, minsup, maxpat, minnodes, directed);

		System.out.println("特征子图挖掘：\n请输入多标记文件名");
//		filepath = sc.nextLine();
		filepath = "label";
		readfile = new File(filepath);
		reader = new FileReader(readfile);
		
		CSM csm = new CSM();
		csm.run(reader, gSpan, 0);
		
		String result = "频繁子图：\n";
		for (Entry<Integer, ArrayList<Integer>> mEntry : gSpan.appearedGraphMap.entrySet()) {
			result += mEntry.getKey() + ": ";
			for (int graphId : mEntry.getValue()) {
				result += graphId + ", ";
			}
			result += "\n";
		}
		result += "多标记矩阵：\n";
		for (Label label : csm.labelMatrix) {
			for (int mLabel : label.multiLabels) {
				result += mLabel + " ";
			}
			result += "\n";
		}
		System.out.println(result);
		
		sc.close();
	}
}
