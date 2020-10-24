Pack_tar.sh and Pack_tar_score.sh are scripts to collect data on the cluster and pack them as tar.gz archive.
The first script compresses the directory /run that is created during a normal Rosetta experiment.
The second script compresses the directory /run_score. It is created by the script SH_rescore.sh, that can be used to score existing Rosetta output once more with another score function.

SH_Design_X_new.sh and SH_Design_XX_new.sh are submission scripts for design experiments at one (X) or two (XX) positions without hydrogen bond constraints.
The corresponding scripts for design with hydrogen bond constraints are SH_Design_X_new_Hbond.sh and SH_Design_XX_new_Hbond.sh.

SH_Relax.sh is the submission script for relax experiments without hydrogen bond constraints, SH_Relax_Hbond.sh for experiments with these constraints.

SH_Rescore.sh can be used to rescore existing Rosetta output with another score function.
