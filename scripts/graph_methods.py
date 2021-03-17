import networkx as nx
import numpy as np
import pandas as pd
from utils import progressBar

def nx_algorithm(g, cases):
    """
    nx native based method for filtering cases. In each subgraph it maximizes the independent cases
 first and then proceeds with the rest of the subgraph

    :param g: nx graph
    :param cases: list of cases
    :return: list of related nodes that are discarded
    """
    unrelated_nodes = []
        
    for subgraph in connected_components(g):
        # list of local cases
        subcases = filter_graph_cases(subgraph, cases)
        if len(subcases) > 0:
            # graph induced by local cases
            case_graph = subgraph.subgraph(cases)
            # get maximal set of cases in case graph
            unrelated_subcases = nx.maximal_independent_set(case_graph)
            # get maximal set of nodes in subgraph
            unrelated_nodes += nx.maximal_independent_set(subgraph, unrelated_subcases)
        else:
            unrelated_nodes += nx.maximal_independent_set(subgraph)

    # result summaries
    related_nodes = list(set(g.nodes()) - set(unrelated_nodes))
    unrelated_cases = filter_node_cases(unrelated_nodes, cases)

    # sanity_check: makes sure that the unrelated cases/nodes are in fact not connected
    sanity_check(g, unrelated_nodes)
    sanity_check(g, unrelated_cases)

    return related_nodes, len(unrelated_cases), len(unrelated_nodes)


def bridge_algorithm(g, deg_filter, cases):
    unrelated_nodes = []
    for subgraph in connected_components(g):
        unrelated_nodes += graph_algorithm(deg_filter, subgraph, cases)

    related_nodes = list(set(g.nodes()) - set(unrelated_nodes))
    unrelated_cases = filter_node_cases(unrelated_nodes, cases)
    # sanity_check: makes sure that the unrelated cases/nodes are in fact not connected
    sanity_check(g, unrelated_nodes)
    sanity_check(g, unrelated_cases)

    return related_nodes, len(unrelated_cases), len(unrelated_nodes)


def graph_algorithm(deg_filter, subgraph, cases):
    '''
    Algorithm that returns the unrelated individuals and unrelated cases by trying to preserve as many cases as possible.
    It starts by filtering out the highest degree individuals without taking into considerations cases/controls.
    It then removes all nodes connecting the two subgraphs of controls/cases.
    It then uses a greedy algorithm to remove all nodes from the remaining of the graph.

    '''
    # remove nodes with hig degree
    remove_nodes_high_degree(subgraph, deg_filter)
    # here i need to separate the two graphs
    remaining_cases = filter_graph_cases(subgraph, cases)
    remove_bridge_nodes(subgraph, remaining_cases)
    # remaining node cases after splitting
    greedy_algorithm(subgraph)

    assert subgraph.number_of_edges() == 0
    return list(subgraph.nodes())


def greedy_algorithm(g=None):
    '''
    Removes sequentially the node with highest degree until there are no nodes left
    '''

    # print(g.number_of_nodes())

    degrees = dict(g.degree())
    while g.number_of_edges() > 0:
        maxNode = max(degrees, key=degrees.get)
        for neighbor in g[maxNode]:  # update degree
            degrees[neighbor] -= 1
        del degrees[maxNode]
        g.remove_node(maxNode)  # remove node


def remove_bridge_nodes(g, case_nodes):
    '''
    Given a graph g and a nodelist it removes all nodes not in nodelist that are connected to nodes in nodelist
    '''

    removed_nodes = []
    for case in case_nodes:
        for neighbor in g.neighbors(case):
            if neighbor not in case_nodes:
                removed_nodes.append(neighbor)

    g.remove_nodes_from(removed_nodes)


def remove_nodes_high_degree(g, deg_filter):
    '''
    Given a graph g and a filter value it removes all nodes wih degree >= than the value
    '''
    # removing degrees with deg higher than degFilter
    degrees = dict(g.degree())
    # start from highest degree node
    max_node = max(degrees, key=degrees.get)
    max_deg = degrees[max_node]
    while max_deg >= deg_filter:
        for neighbor in g[max_node]:
            degrees[neighbor] -= 1
        g.remove_node(max_node)
        del degrees[max_node]
        max_node = max(degrees, key=degrees.get)
        max_deg = degrees[max_node]


def return_case_graph(args, pheno):
    """

    :param args:
    :param pheno:
    :return: graph induced by only cases and controls, cases

    """
    g = nx.read_edgelist(args.edgelist)
    args.v_print(1, f'{pheno} graph loaded')
    samples = np.genfromtxt(args.samples, dtype=str,skip_header = 1)
    args.v_print(1, f'{pheno} samples loaded')
    case_bool, missing_bool = return_cases(args.pheno_file, pheno)
    args.v_print(1, f'{pheno} masks loaded')

    cases = samples[case_bool]
    missing = samples[missing_bool]
    g.remove_nodes_from(missing)
    args.v_print(1, f'{pheno} final graph returned')

    return g, cases


def return_cases(f, pheno):
    '''
    Given a pheno it returns the cases and control bools
    '''
    column = return_column(f, pheno)

    caseBool = (column == 1)
    # controlBool = (column == 0)
    missingBool = np.ma.masked_invalid(column).mask
    return caseBool, missingBool


def return_column(f, pheno, dtype=float):
    """

    :param f: pheno file
    :param pheno: phenotype name
    :param dtype:
    :return: column of case/control info
    """

    if f.endswith('gz'):
        column = pd.read_csv(f, dtype=dtype, compression='gzip', sep='\t', usecols=[pheno]).values.flatten()
    else:
        column = pd.read_csv(f, sep='\t', usecols=[pheno], dtype=dtype).values.flatten()

    return column


def filter_node_cases(nodes, cases):
    return [elem for elem in nodes if elem in cases]


def filter_graph_cases(graph, cases):
    return [elem for elem in graph.nodes() if elem in cases]


def sanity_check(g, nodes):
    '''
    Given a list of nodes it makes sure that the algorithms are working properly.
    That is that the subgraph induced by the remaining nodes does not contain edges.
    '''
    assert g.subgraph(nodes).number_of_edges() == 0

def connected_components(G):
    for c in nx.connected_components(G):
        yield G.subgraph(c).copy()
