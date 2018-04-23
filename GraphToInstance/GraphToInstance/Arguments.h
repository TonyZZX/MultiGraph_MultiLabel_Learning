#pragma once

#include <iostream>
#include <string>

#include "argh.h"

class Arguments
{
public:
	std::string graph_file_path;
	std::string sub_graph_file_path;
	std::string instance_file_path = "instance.csv";
	static Arguments* get_instance(int argc, char *argv[]);

private:
	Arguments(int argc, char *argv[]);
	static Arguments* arguments_;
	int argc_;
	char **argv_;
	// User inputs args.
	void init_from_cmd();
	// User runs it directly.
	void init_from_run();
	void print_help();
};