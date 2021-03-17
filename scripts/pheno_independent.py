import os, argparse
import networkx as nx
import numpy as np
from graph_methods import return_case_graph, nx_algorithm, bridge_algorithm, return_column
from utils import file_exists,make_sure_path_exists,mapcount,pretty_print



def load_graph(args):
    """
    Loads specific graph
    """
    pretty_print(args.pheno)
    edgelist = os.path.join(args.out,'graphs',args.pheno + '.edgelist')
    make_sure_path_exists(os.path.dirname(edgelist))
    if not os.path.isfile(edgelist):
        z = nx.read_edgelist(args.related_couples)
        if args.rejected:
            old_nodes = z.number_of_nodes()
            rejected = np.loadtxt(args.rejected,dtype = str)
            z.remove_nodes_from(rejected)
            print(f"{old_nodes - z.number_of_nodes()} nodes removed")
        nx.write_edgelist(z,edgelist)
    else:
        z = nx.read_edgelist(edgelist)
        
    
    print(f"{mapcount(args.related_couples)} original edges")
    print('graph lodaded.')
    
    #print(f"{z.number_of_edges()} edges")
    return z
        
def return_final_nodes(args):

    z = load_graph(args)
    cases = np.genfromtxt(args.cases,dtype = str)
    print(f"{z.number_of_nodes()} nodes")
    print(f"{len(cases)} original cases")
    nx_related,nx_cases,nx_nodes = nx_algorithm(z,cases)
    print(f"{nx_cases} final nx cases")
    print(f"{nx_nodes} final nx nodes")
    bridge_related, bridge_cases, bridge_nodes = bridge_algorithm(z, 12, cases)
    print(f"{bridge_cases} final bridge cases")
    print(f"{bridge_nodes} final bridge nodes")

    final_related = nx_related if nx_cases > bridge_cases else bridge_related
    print(str(len(final_related)) + " final related samples")
    return final_related

def main(args):
    out_nodes = os.path.join(args.out,'results',args.pheno + '_related_samples.txt')
    make_sure_path_exists(os.path.dirname(out_nodes))
    if not os.path.isfile(out_nodes):
        related_samples = return_final_nodes(args)
        with open(out_nodes,'wt') as o:
            for node in related_samples:
                o.write(node + '\n')
    else:
        print(f"{mapcount(out_nodes)} related samples")
                



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Case-Control based network trimming")
    parser.add_argument("-r", "--related-couples", metavar='R', type=file_exists,
                        help="File that contains list of related couples", required=True)
    parser.add_argument('-o', "--out", type=str, help="folder in which to save the results", required=True)
    parser.add_argument("-p", "--pheno", type=str,
                        help="Name of outputs/phenotype", required=True)

    parser.add_argument( "--cases", type=file_exists, help='list of samples (case) to prioritize over',required = True)
    # optional
    
    parser.add_argument("--rejected", type=file_exists, help='list of samples to exclude')
    args = parser.parse_args()
    main(args)
