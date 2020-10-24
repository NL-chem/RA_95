Evaluate_Euler.sh is the most developed evaluation script for design experiments, written for execution on the cluster.
It can deal with several entries per score file and determines the column number of the specified sore terms on its own.
The ten best structures for every ligand and mutation are compressed together with the data of all strcutures as tar.gz file for easy download.

Extr_Best_pdb_wpos_sub2.sh is the analogue for execution on a local computer.
It has the feature of automatically opening the best scorinf structures in pymol if requested.
Extr_Best_pdb_sub2.sh is the precursor script, which cannot report the amino acid at a specified position.

Extr_Best_pdb_sub1.sh is for evaluation of relax experiments on a local computer. For this task no script for the cluster as written.
