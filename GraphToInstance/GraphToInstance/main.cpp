#include <climits>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "argh.h"
#include "label.h"
#include "vflib/allocpool.h"
#include "vflib/argedit.h"
#include "vflib/argloader.h"
#include "vflib/argraph.h"
#include "vflib/match.h"
#include "vflib/vf2_mono_state.h"

using namespace std;

using LabelGraph = ARGraph<Label, Label>;

// File path of graphs
string graph_file_path;
// File path of sub-graphs
string sub_graph_file_path;
// File path of output instances
string output_instance_path;
// If not none, save features to the path
string output_saved_feature_path;
// If not none, load features from the path
string saved_feature_list_path;

void init_args(int argc, char *argv[]);

// Read graphs from file.
vector<LabelGraph> read_graphs(string file_name);

// Only return super-graphs.
vector<LabelGraph> keep_super_graphs(vector<LabelGraph> &graphs);

void save_features(vector<LabelGraph> &graphs, string output_saved_feature_path);

vector<LabelGraph> load_features(string saved_feature_list_path);

//Transform graphs to instances according to features
vector<vector<short>> transform_instances(vector<LabelGraph> &graphs, vector<LabelGraph> &features);

// Output instances to file.
void output_instances(string file_name, const vector<vector<short>> &instances);

LabelGraph new_label_graph(ARGLoader *loader);

int main(int argc, char *argv[])
{
	init_args(argc, argv);

	vector<LabelGraph> features;
	if (saved_feature_list_path == "")
	{
		cout << "Reading sub-graphs...\n";
		// Read informative sub-graphs from file.
		auto sub_graphs = read_graphs(sub_graph_file_path);
		cout << "Generating features...\n";
		// Only keep super-graphs as features.
		features = keep_super_graphs(sub_graphs);
		if (output_saved_feature_path != "")
			save_features(features, output_saved_feature_path);
	}
	else
	{
		cout << "Reading features...\n";
		// Load features from the path
		features = load_features(saved_feature_list_path);
	}
	cout << "Reading all graphs...\n";
	// Read all graphs from file.
	auto graphs = read_graphs(graph_file_path);
	cout << "Generating instances...\n";
	// Transform graphs to instances according to features
	auto instances = transform_instances(graphs, features);
	cout << "Outputing instances...\n";
	output_instances(output_instance_path, instances);
	cout << "Done! There are " << graphs.size() << " instances and each instance has " << features.size() << " dimentions.\n";
	return EXIT_SUCCESS;
}

void print_help()
{
	cout << "-h, --help \t Help\n";
	cout << "-g, --graph <arg> \t (Required) File path of graphs\n";
	cout << "-s, --sub-graph <arg> \t File path of sub-graphs\n";
	cout << "-i, --instance <arg> \t File path of output instances\n";
	cout << "-o, --output-feature <arg> \t If not none, save features to the path\n";
	cout << "-l, --load-feature <arg> \t If not none, load features from the path\n";
}

void init_args(int argc, char *argv[])
{
	auto cmd = argh::parser(argc, argv, argh::parser::PREFER_PARAM_FOR_UNREG_OPTION);

	if (cmd({ "-h", "--help" }))
	{
		print_help();
		exit(EXIT_SUCCESS);
	}
	if (!(cmd({ "-g", "--graph" }) >> graph_file_path))
	{
		print_help();
		exit(EXIT_FAILURE);
	}
	cmd({ "-s", "--sub-graph" }, "") >> sub_graph_file_path;
	cmd({ "-i", "--instance" }, "instance.csv") >> output_instance_path;
	cmd({ "-o", "--output-feature" }, "") >> output_saved_feature_path;
	cmd({ "-l", "--load-feature" }, "") >> saved_feature_list_path;
	if (sub_graph_file_path == "" && saved_feature_list_path == "")
	{
		cout << "Must input either sub-graph file path or saved feature list path!\n";
		print_help();
		exit(EXIT_FAILURE);
	}
}

/*
split: receives a char delimiter; returns a vector of strings
By default ignores repeated delimiters, unless argument rep == 1.
via: http://www.cplusplus.com/articles/1UqpX9L8/
*/
vector<string> split(string data, char delim, int rep = 0)
{
	vector<string> flds;
	string work = data;
	string buf = "";
	int i = 0;
	while (i < work.length())
	{
		if (work[i] != delim)
			buf += work[i];
		else if (rep == 1)
		{
			flds.push_back(buf);
			buf = "";
		}
		else if (buf.length() > 0)
		{
			flds.push_back(buf);
			buf = "";
		}
		i++;
	}
	if (!buf.empty())
		flds.push_back(buf);
	return flds;
}

vector<LabelGraph> read_graphs(string file_name)
{
	ifstream graph_file(file_name);
	vector<LabelGraph> graphs;
	if (graph_file.is_open())
	{
		// The object used to create the graph
		ARGEdit ed;
		string line;
		while (getline(graph_file, line))
		{
			auto splitStr = split(line, ' ');
			if (splitStr[0] == "t")
			{
				if (ed.NodeCount() > 0)
				{
					auto g = new_label_graph(&ed);
					graphs.push_back(g);
				}
				ed = ARGEdit();
			}
			else if (splitStr[0] == "v" && splitStr.size() >= 3)
			{
				ed.InsertNode(new Label(stoi(splitStr[2])));
			}
			else if (splitStr[0] == "e" && splitStr.size() >= 4)
			{
				ed.InsertEdge(stoi(splitStr[1]), stoi(splitStr[2]), new Label(stoi(splitStr[3])));
			}
		}
		if (ed.NodeCount() > 0)
		{
			auto g = new_label_graph(&ed);
			graphs.push_back(g);
		}
	}
	else
		cout << "Unable to open the file: " << file_name << '\n';
	return graphs;
}

// return if g1 is a sub-graph of g2 (using monomorphism - VF2 algorithm)
bool is_vf2mono_match(LabelGraph *g1, LabelGraph *g2)
{
	// Create the initial state of the search space
	VF2MonoState s0(g1, g2);
	int n;
	node_id ni1[USHRT_MAX], ni2[USHRT_MAX];
	return match(&s0, &n, ni1, ni2);
}

vector<LabelGraph> keep_super_graphs(vector<LabelGraph> &graphs)
{
	auto graphs_size = graphs.size();
	vector<LabelGraph> super_graphs;
	for (auto i = 0; i < graphs_size; i++)
	{
		bool is_matched = false;
		for (auto j = 0; j < graphs_size; j++)
		{
			if (i == j)
				continue;

			if (is_vf2mono_match(&graphs[i], &graphs[j]))
			{
				is_matched = true;
				break;
			}
		}
		if (!is_matched)
		{
			super_graphs.push_back(graphs[i]);
		}
	}
	return super_graphs;
}

void save_features(vector<LabelGraph> &graphs, string output_saved_feature_path)
{
	auto graphs_size = graphs.size();
	string feature_file_names;
	for (auto i = 0; i < graphs_size; i++)
	{
		string feature_file_name = output_saved_feature_path + "feature_" + to_string(i);
		ofstream out(feature_file_name);
		StreamARGLoader<Label, Label>::write(out, graphs[i]);
		out.close();
		feature_file_names += feature_file_name + '\n';
	}
	// Save all feature files' names to a file
	ofstream feature_names_file(output_saved_feature_path + "list.txt");
	if (feature_names_file.is_open())
	{
		feature_names_file << feature_file_names;
	}
}

vector<LabelGraph> load_features(string saved_feature_list_path)
{
	ifstream feature_list_file(saved_feature_list_path + "list.txt");
	vector<LabelGraph> graphs;
	if (feature_list_file.is_open())
	{
		string line;
		while (getline(feature_list_file, line))
		{
			NewAllocator<Label> node_allocator;
			NewAllocator<Label> edge_allocator;
			ifstream in(line);
			StreamARGLoader<Label, Label> loader(&node_allocator, &edge_allocator, in);
			auto graph = new_label_graph(&loader);
			graphs.push_back(graph);
		}
	}
	return graphs;
}

vector<vector<short>> transform_instances(vector<LabelGraph> &graphs, std::vector<LabelGraph> &features)
{
	auto graphs_size = graphs.size();
	auto features_size = features.size();
	vector<vector<short>> instances(graphs_size);
	for (auto i = 0; i < graphs_size; i++)
	{
		vector<short> instance(features_size);
		for (auto j = 0; j < features_size; j++)
		{
			if (is_vf2mono_match(&features[j], &graphs[i]))
			{
				instance[j] = 1;
			}
			else
			{
				instance[j] = 0;
			}
		}
		instances[i] = move(instance);
	}
	return instances;
}

void output_instances(string file_name, const vector<vector<short>> &instances)
{
	ofstream instance_file(file_name);
	if (instance_file.is_open())
	{
		for (auto &instance : instances)
		{
			auto instance_size = instance.size();
			for (auto i = 0; i < instance_size; i++)
			{
				instance_file << instance[i];
				if (i != instance_size - 1)
				{
					instance_file << ',';
				}
			}
			instance_file << '\n';
		}
	}
	else
		std::cout << "Unable to open the file.\n";
}

LabelGraph new_label_graph(ARGLoader *loader)
{
	LabelGraph graph(loader);
	graph.SetNodeDestroyer(new LabelDestroyer());
	graph.SetNodeComparator(new LabelComparator());
	graph.SetEdgeDestroyer(new LabelDestroyer());
	graph.SetEdgeComparator(new LabelComparator());
	return graph;
}
