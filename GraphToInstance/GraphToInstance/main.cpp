#include "argh.h"
#include "common.h"

using namespace std;

int main(int argc, char *argv[])
{
	auto *arguments = Arguments::get_instance(argc, argv);

	cout << "Reading sub-graphs...\n";
	// Read informative sub-graphs from file.
	auto sub_graphs = read_graphs(arguments->sub_graph_file_path);
	cout << "Done!\nGenerating features...\n";
	// Only keep super-graphs as features.
	auto features = keep_super_graphs(sub_graphs);
	cout << "Done!\nReading all graphs...\n";
	// Read all graphs from file.
	auto graphs = read_graphs(arguments->graph_file_path);
	cout << "Done!\nGenerating instances...\n";
	// Transform graphs to instances according to features
	auto instances = transform_instances(graphs, features);
	cout << "Done!\nOutputing instances...\n";
	output_instances(arguments->instance_file_path, instances);
	cout << "All done! There are " << graphs.size() << " instances and each instance has " << features.size() << " dimentions.\n";

	system("pause");
	return EXIT_SUCCESS;
}