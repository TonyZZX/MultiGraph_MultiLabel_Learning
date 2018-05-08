class Edge(object):

    def __init__(self, from_id, to_id, label):
        self.from_id = from_id
        self.to_id = to_id
        self.label = label

    def __hash__(self):
        return hash('{} {} {}'.format(self.from_id, self.to_id, self.label))

    def __eq__(self, other):
        return (self.from_id == other.from_id) and (self.to_id == other.to_id) and (self.label == other.label)


class Node(object):

    def __init__(self, id_, label):
        self.id_ = id_
        self.label = label
        self.edges = set()

    def add_edge(self, to_id, label):
        self.edges.add(Edge(self.id_, to_id, label))


class Graph(object):

    def __init__(self):
        self.nodes = {}

    def add_node(self, id_, label):
        if not self.nodes.get(id_):
            self.nodes[id_] = Node(id_, label)

    def add_edge(self, from_id, to_id, label=1):
        if from_id != to_id:
            self.nodes[from_id].add_edge(to_id, label)


class MultiGraph(object):

    def __init__(self):
        self.graphs = []

    def add_graph(self, graph):
        self.graphs.append(graph)

    def add_multi_graph(self, multi_graph):
        """
        Add graphs in MultiGraph

        Parameters
        ---
        multi_graph: `MultiGraph`
        """
        for graph in multi_graph.graphs:
            self.add_graph(graph)

    def get_num(self):
        return len(self.graphs)

    def write(self, output_file_path):
        output_str = ''
        for i, graph in enumerate(self.graphs):
            output_str += 't # {}\n'.format(i)

            new_node_id = {}  # give nodes new ids (which start from zero)
            for i, node_id in enumerate(graph.nodes):
                output_str += 'v {} {}\n'.format(i, graph.nodes[node_id].label)
                new_node_id[node_id] = i

            for node_id, node in graph.nodes.items():
                from_id = new_node_id[node_id]
                sorted_edge_to_ids = sorted(
                    new_node_id[edge.to_id] for edge in node.edges)
                for to_id in sorted_edge_to_ids:
                    if from_id < to_id:
                        # TODO: edge's label is always one.
                        output_str += 'e {} {} 1\n'.format(from_id, to_id)

        with open(output_file_path, 'w') as output_file:
            output_file.write(output_str)
