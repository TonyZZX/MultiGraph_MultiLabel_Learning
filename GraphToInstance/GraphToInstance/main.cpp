#include "argh.h"
#include "common.h"

using namespace std;

int main(int argc, char *argv[])
{
	auto *arguments = Arguments::get_instance(argc, argv);

	cout << "Runing...\n";

	// Read informative sub-graphs from file.
	auto sub_graphs = read_graphs(arguments->sub_graph_file_path);

	cout << "Reading sub-graphs done!\n";

	// Only keep super-graphs as features.
	auto features = keep_super_graphs(sub_graphs);

	cout << "Features done!\n";

	// Read all graphs from file.
	auto graphs = read_graphs(arguments->graph_file_path);

	cout << "Reading all graphs done!\n";

	// Transform graphs to instances according to features
	auto instances = transform_instances(graphs, features);

	cout << "Instances done!\n";

	output_instances(arguments->instance_file_path, instances);

	cout << "All done! There are " << graphs.size() << " instances and each instance has " << features.size() << " dimentions.\n";

	system("pause");
	return EXIT_SUCCESS;
}