import os, argparse, multiprocessing
import numpy as np
import networkx as nx
from collections import Counter
from itertools import product
from Tools.utils import basic_iterator, file_exists, make_sure_path_exists, return_header, get_path_info, tmp_bash, \
    pretty_print, mapcount, cpus, timing_function, get_filepaths, progressBar, return_header
from graph_methods import return_case_graph, nx_algorithm, bridge_algorithm, return_column


def main(args):
    """
    Harmonizes input data
    :param args: command line arguments
    :return: a new edgelist and a final set of samples
    """

    # harmonize phenotype file with imputed data
    if not args.samples:
        extract_samples(args)

    save_graph(args)

    run_phenos(args)


def run_phenos(args):
    """
    Runs all phenos

    :param args:
    :return:
    """

    phenos = np.genfromtxt(args.pheno_list, dtype=str)
    raw_phenos = return_header(args.pheno_file)
    phenos = [pheno for pheno in phenos if pheno in raw_phenos]
    if args.test: phenos = phenos[:args.pools]

    args.v_print(3, f"{len(phenos)} {args.pools}")
    args.summary_path = os.path.join(args.out_path, 'summaries')
    make_sure_path_exists(args.summary_path)
    args.column_path = os.path.join(args.out_path, 'columns')
    make_sure_path_exists(args.column_path)

    param_list = list(product([args], phenos))
    pool = multiprocessing.Pool(args.pools)
    pool.map(alg_wrapper, param_list)
    pool.close()

    all_files = " ".join([args.samples] + [os.path.join(args.column_path, f"{pheno}_column.txt") for pheno in phenos])
    args.v_print(1, all_files)
    out_file = os.path.join(args.out_path, 'independent_phenos.txt.gz')
    tmp_bash(f"paste {all_files} | gzip > {out_file}")


def alg_wrapper(args):
    func_wrapper(*args)


def func_wrapper(args, pheno):
    """
    Function that runs the two separated algorithms and saves the new pheno column
    :param args:
    :param pheno:
    :return:
    """
    summary_file = os.path.join(args.summary_path, f"{pheno}_summary.txt")
    new_column = os.path.join(args.column_path, f"{pheno}_column.txt")

    if not os.path.isfile(new_column) or args.force:
        args.v_print(1, f'{pheno}')
        g, cases = return_case_graph(args, pheno)
        args.v_print(3, f"{pheno} : {len(cases)} total cases, {g.number_of_nodes()} total nodes")

        nx_related, nx_cases, nx_nodes = nx_algorithm(g, cases)
        bridge_related, bridge_cases, bridge_nodes = bridge_algorithm(g, args.deg_filter, cases)

        with open(summary_file, 'wt') as o:
            o.write(f"start : {g.number_of_nodes()} nodes and {len(cases)} cases\n")
            o.write(f"nx    : {nx_nodes} nodes and {nx_cases} cases\n")
            o.write(f"bridge: {bridge_nodes} nodes and {bridge_cases} cases\n")

        related_nodes = nx_related if nx_cases > bridge_cases else bridge_related
        save_pheno_column(args, pheno, related_nodes, new_column)

    args.v_print(1, f'{pheno}')
    progress(args)


def extract_samples(args):
    """
    Extracts the samples from the pheno file
    :param args:
    :return: File with list of samples
    """
    args.samples = os.path.join(args.out_path, "samples.txt")
    if not os.path.isfile(args.samples) or args.force:
        args.force = True

        file_path, file_root, file_extension = get_path_info(args.pheno_file)
        cat_func = "zcat" if 'gz' in file_extension else "cat"
        cmd = f"{cat_func}  {args.pheno_file} | cut -f {args.samples_column}  > {args.samples}"
        args.v_print(1, cmd)
        tmp_bash(cmd)

    args.v_print(3, f"{mapcount(args.samples) - 1} samples ")


def save_pheno_column(args, pheno, related_nodes, new_column):
    """
    Write the updated pheno column to file

    :param args:
    :param pheno: phenotype
    :param related_nodes: list of nodes to flag as related
    :return: the updated column of the pheno file
    """
    samples = np.genfromtxt(args.samples, dtype=str, skip_header=1)
    old_column = return_column(args.pheno_file, pheno, dtype=str)

    results = [pheno]
    for i, sample in enumerate(samples):
        sample_case = str(old_column[i])
        if sample in related_nodes:
            sample_case += "_R"
        results.append(sample_case)

    summary_file = os.path.join(args.summary_path, f"{pheno}_summary.txt")
    with open(summary_file, "a") as o:
        o.write(str(dict(Counter(results))))

    with open(new_column, 'wt') as o:
        o.write('\n'.join(results))


def save_graph(args):
    """
    Saves graph using only nodes present both in the phenotype data
    """

    args.edgelist = os.path.join(args.out_path, 'edgelist')
    if not os.path.isfile(args.edgelist) or args.force:
        args.force = True

        args.v_print(3, 'saving graph..')
        z = nx.read_edgelist(args.related_couples)
        if args.rejected:
            old_nodes = z.number_of_nodes()
            rejected = np.loadtxt(args.rejected,dtype = str)
            z.remove_nodes_from(rejected)
            args.v_print(1, f"{old_nodes - z.number_of_nodes()} non Finnish nodes removed")
        
        pheno_graph = z.subgraph(np.genfromtxt(args.samples, dtype=str, skip_header=1))            
        args.v_print(1, f"{z.number_of_nodes() - pheno_graph.number_of_nodes()} nodes removed")
        args.v_print(1, f"{z.number_of_edges() - pheno_graph.number_of_edges()} edges removed")
        nx.write_edgelist(pheno_graph, args.edgelist, data=False)
        args.v_print(2, 'done.')
    else:
        args.v_print(2, 'edgelist already generated')


def progress(args):
    phenos = np.genfromtxt(args.pheno_list, dtype=str)
    raw_phenos = return_header(args.pheno_file)
    phenos = [pheno for pheno in phenos if pheno in raw_phenos]
    if args.test: phenos = phenos[:args.pools]

    all_files = []
    for pheno in phenos:
        f = os.path.join(args.column_path, f"{pheno}_column.txt")
        if os.path.isfile(f):
            all_files.append(f)

    progressBar(len(all_files), len(phenos))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Case-Control based network trimming")
    parser.add_argument("-f", '--pheno-file', metavar='F', type=file_exists,
                        help="Phenotype filepath", required=True)
    parser.add_argument("-r", "--related-couples", metavar='R', type=file_exists,
                        help="File that contains list of related couples", required=True)
    parser.add_argument('-o', "--out-path", type=str, help="folder in which to save the results", required=True)
    parser.add_argument("-p", "--pheno-list", type=file_exists,
                        help="File that contains list of phenotypes", required=True)

    sample_group = parser.add_mutually_exclusive_group()
    sample_group.add_argument('-s', "--samples", type=file_exists, help='final list of samples')
    sample_group.add_argument("--rejected", type=file_exists, help='list of samples to exclude')
    sample_group.add_argument('--samples-column', type=int, help="Index of samples ids in pheno file", default=1)

    parser.add_argument('--deg-filter', type=int, help='Degree at which to split cases/controls (12 default)',
                        default=12)

    parser.add_argument('--pools', type=int, help='number of processors to use', default=cpus)
    parser.add_argument('--force', action='store_true', help="Replaces files by force", default=False)
    parser.add_argument('--test', action='store_true', help="Runs in test mode", default=False)
    parser.add_argument('-v', '--verbosity', action="count",
                        help="increase output verbosity (e.g., -vv is more than -v)")

    args = parser.parse_args()

    make_sure_path_exists(args.out_path)

    if args.verbosity:
        def _v_print(*verb_args):
            if verb_args[0] > (3 - args.verbosity):
                print(verb_args[1])
    else:
        def _v_print(*args):
            pass

    args.v_print = _v_print

    # in test mode cap the cpus to 4
    if args.test: args.pools = min(4, args.pools)

    main(args)
