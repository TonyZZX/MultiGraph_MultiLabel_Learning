#pragma once

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#include "argh.h"
#include "vflib\argraph.h"
#include "vflib\argedit.h"
#include "vflib\vf2_mono_state.h"
#include "vflib\match.h"

class Arguments
{
public:
	std::string graph_file_path;
	std::string sub_graph_file_path;
	std::string instance_file_path = "instance";
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

/*
split: receives a char delimiter; returns a vector of strings
By default ignores repeated delimiters, unless argument rep == 1.
via: http://www.cplusplus.com/articles/1UqpX9L8/
*/
std::vector<std::string> split(std::string data, char delim, int rep = 0);

// Read graphs from file.
std::vector<Graph> read_graphs(std::string file_name);

// Print current progress.
void print_progress(int current, int total);

// return if g1 is a sub-graph of g2 (using monomorphism - VF2 algorithm)
bool is_vf2mono_match(Graph *g1, Graph *g2);

// Only return super-graphs.
std::vector<Graph> keep_super_graphs(std::vector<Graph> &graphs);

//Transform graphs to instances according to features
std::vector<std::vector<short>> transform_instances(std::vector<Graph> &graphs, std::vector<Graph> &features);

// Output instances to file.
void output_instances(std::string file_name, const std::vector<std::vector<short>> &instances);