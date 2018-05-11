#include "arguments.h"

Arguments *Arguments::arguments_ = nullptr;

Arguments::Arguments(int argc, char *argv[])
{
	argc_ = argc;
	argv_ = argv;
}

void Arguments::init_from_cmd()
{
	auto cmd = argh::parser(argc_, argv_, argh::parser::PREFER_PARAM_FOR_UNREG_OPTION);

	if (cmd({"-h", "--help"}))
	{
		print_help();
		exit(EXIT_SUCCESS);
	}
	if (!(cmd({"-g", "--graph"}) >> graph_file_path))
	{
		print_help();
		exit(EXIT_FAILURE);
	}
	if (!(cmd({"-s", "--sub-graph"}) >> sub_graph_file_path))
	{
		print_help();
		exit(EXIT_FAILURE);
	}
	cmd({"-i", "--instance"}, "instance") >> instance_file_path;
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

Arguments *Arguments::get_instance(int argc, char *argv[])
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