import numpy as np

from skimage import color
from skimage.future import graph
from skimage.io import imread
from skimage.segmentation import slic, mark_boundaries

from graph import *


def segment(img_path, node_num):
    """
    Segment an image to multiple graphs.

    Parameters
    ---
    img_path: `str`

    node_num: `int`

    Returns
    ---
    graphs: `MultiGraph`
    """

    img = imread(img_path)
    # Segment the image to node_num picese (approximately).
    nodes = slic(img, sigma=1, n_segments=node_num)
    # true_node_num = len(np.unique(nodes))
    nodes_colors = color.label2rgb(
        nodes, img, kind='avg')  # avg color for each node
    # Segment nodes to regions (graphs) based on Normalized Cut.
    regions = graph.cut_normalized(
        nodes, graph.rag_mean_color(img, nodes, mode='similarity'))
    # region_num = len(np.unique(regions))
    region_set = np.unique(regions)

    # Build multi-graphs
    graphs = MultiGraph()
    for i in region_set:
        region_graph = Graph()
        x_len = len(regions)
        for x in range(x_len):
            y_len = len(regions[x])
            for y in range(y_len):
                if regions[x][y] == i:
                    node_id = nodes[x][y]

                    # Add nodes
                    r = nodes_colors[x][y][0]
                    g = nodes_colors[x][y][1]
                    b = nodes_colors[x][y][2]
                    label = r * 1000000 + g * 1000 + b
                    region_graph.add_node(node_id, label)

                    # Add edges
                    for xx in [x - 1, x, x + 1]:
                        for yy in [y - 1, y, y + 1]:
                            if xx < x_len and xx > 0 and yy < y_len and yy > 0 and regions[xx][yy] == i:
                                region_graph.add_edge(node_id, nodes[xx][yy])

        graphs.add_graph(region_graph)

    return graphs
