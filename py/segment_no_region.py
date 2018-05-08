import numpy as np

from skimage import color
from skimage.future import graph
from skimage.io import imread
from skimage.segmentation import slic

from model.graph import *


def segment_no_region(img_path, node_num):
    """
    Segment an image to graph.

    Parameters
    ---
    img_path: `str`

    node_num: `int`

    Returns
    ---
    graph_: `Graph`
    """

    img = imread(img_path)
    # Segment the image to node_num picese (approximately).
    nodes = slic(img, sigma=1, n_segments=node_num)
    # true_node_num = len(np.unique(nodes))
    # Segment nodes to regions (graphs) based on Normalized Cut.
    regions = graph.cut_normalized(
        nodes, graph.rag_mean_color(img, nodes, mode='similarity'))
    regions_colors = color.label2rgb(
        regions, img, kind='avg')  # avg color for each region
    # region_num = len(np.unique(regions))

    # Build graph
    graph_ = Graph()
    x_len = len(regions)
    for x in range(x_len):
        y_len = len(regions[x])
        for y in range(y_len):
            node_id = regions[x][y]

            # Add nodes
            # 5-bit (32 colors)
            r = int(regions_colors[x][y][0] / 256 * 32)
            g = int(regions_colors[x][y][1] / 256 * 32)
            b = int(regions_colors[x][y][2] / 256 * 32)
            label = r + (g << 5) + (b << 10)
            graph_.add_node(node_id, label)

            # Add edges
            for xx, yy in [(x, y + 1), (x, y - 1), (x + 1, y), (x - 1, y)]:
                if xx < x_len and xx > 0 and yy < y_len and yy > 0:
                    graph_.add_edge(node_id, regions[xx][yy])

    return graph_
