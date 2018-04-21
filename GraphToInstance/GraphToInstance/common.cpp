#include "common.h"

Arguments* Arguments::arguments_ = nullptr;

Arguments::Arguments(int argc, char * argv[])
{
	argc_ = argc;
	argv_ = argv;
}

void Arguments::init_from_cmd()
{
	auto cmd = argh::parser(argc_, argv_, argh::parser::PREFER_PARAM_FOR_UNREG_OPTION);

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
	if (!(cmd({ "-s", "--sub-graph" }) >> sub_graph_file_path))
	{
		print_help();
		exit(EXIT_FAILURE);
	}
	cmd({ "-i", "--instance" }, "instance") >> instance_file_path;
}

void Arguments::init_from_run()
{
	std::cout << "Please input the file path of graphs: \n";
	std::cin >> graph_file_path;
	std::cout << "Please input the file path of sub-graphs: \n";
	std::cin >> sub_graph_file_path;
}

void Arguments::print_help()
{
	std::cout << "-g, --graph <arg> \t (Required) File path of graphs\n";
	std::cout << "-h, --help \t Help\n";
	std::cout << "-i, --instance <arg> \t File path of output instances\n";
	std::cout << "-s, --sub-graph <arg> \t (Required) File path of sub-graphs\n";
}

Arguments* Arguments::get_instance(int argc, char * argv[])
{
	if (arguments_ == nullptr)
	{
		arguments_ = new Arguments(argc, argv);
	}
	if (argc > 1)
	{
		arguments_->init_from_cmd();
	}
	else
	{
		arguments_->init_from_run();
	}
	return arguments_;
}

std::vector<std::string> split(std::string data, char delim, int rep) {
	std::vector<std::string> flds;
	std::string work = data;
	std::string buf = "";
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

std::vector<Graph> read_graphs(std::string file_name)
{
	std::ifstream graph_file(file_name);
	std::vector<Graph> graphs;
	if (graph_file.is_open())
	{
		// The object used to create the graph
		ARGEdit ed;
		std::string line;
		while (getline(graph_file, line))
		{
			auto splitStr = split(line, ' ');
			if (splitStr[0] == "t")
			{
				if (ed.NodeCount() > 0)
				{
					graphs.push_back(Graph(&ed));
				}
				ed = ARGEdit();
			}
			else if (splitStr[0] == "v" && splitStr.size() >= 3)
			{
				ed.InsertNode((void*)stoi(splitStr[2]));
			}
			else if (splitStr[0] == "e" && splitStr.size() >= 4)
			{
				ed.InsertEdge(stoi(splitStr[1]), stoi(splitStr[2]), (void*)stoi(splitStr[3]));
			}
		}
		if (ed.NodeCount() > 0)
		{
			graphs.push_back(Graph(&ed));
		}
	}
	else
		std::cout << "Unable to open the file: " << file_name << '\n';
	return graphs;
}

void print_progress(int current, int total)
{
	if (current % (total / 10) == 0)
		std::cout << '*';
}

bool is_vf2mono_match(Graph *g1, Graph *g2)
{
	// Create the initial state of the search space
	VF2MonoState s0(g1, g2);
	int n;
	node_id ni1[USHRT_MAX], ni2[USHRT_MAX];
	return match(&s0, &n, ni1, ni2);
}

std::vector<Graph> keep_super_graphs(std::vector<Graph> &graphs)
{
	auto graphs_size = graphs.size();
	std::vector<Graph> super_graphs;
	for (auto i = 0; i < graphs_size; i++)
	{
		bool is_matched = false;
		print_progress(i, graphs_size);
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
	std::cout << '\n';
	return super_graphs;
}

std::vector<std::vector<short>> transform_instances(std::vector<Graph> &graphs, std::vector<Graph> &features)
{
	auto graphs_size = graphs.size();
	auto features_size = features.size();
	std::vector<std::vector<short>> instances(graphs_size);
	for (auto i = 0; i < graphs_size; i++)
	{
		print_progress(i, graphs_size);
		std::vector<short> instance(features_size);
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
	std::cout << '\n';
	return instances;
}

void output_instances(std::string file_name, const std::vector<std::vector<short>> &instances)
{
	std::ofstream instance_file(file_name);
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
