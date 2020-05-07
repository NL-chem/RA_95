#!/bin/bash

#################SETTINGS################
#array with all ligand names
all_ligands=(NIR NIS)

#arrays with mutation positions and corresponding mutations
all_mutations=(112I+12G 112I+12A 112L+12G 112L+12A 112V+12G 112V+12A 112I+133F 112L+133F 112V+133F 133F+12G 133F+12A)

#number of iterations per ligand
iteration=1

#maximal duration
dur=3:59

#flags file name
flags=Design_NK_Double.flags

#pdb input file name; triplett code for ligands replaced by XXX
pdb_name=RA_WT_XXX_relaxed.pdb
#################SETTINGS################

#to print bold
bold=$(tput bold)
normal=$(tput sgr0)

#variable to count the number of submitted jobs
declare -i counter=0

#variable to collect all the output statments that is prineted in the end
output="############################JOB SUMMARY############################\n"

#check if the flags file exists
if [ -f "$flags" ]
then
	output+="Found flags file $flags.\n\n"
	
	#check if the run directory exists and create it otherwise
	if [ -d "run" ]
	then
		output+="Found run directory for output.\n\n"
	else
		output+="run directory for output doesn't exist and is created.\n"
		mkdir run
		output+="run was created.\n\n"
	fi

	#loop over all ligands
	for ligand in ${all_ligands[@]}; do
	
		#check if the subdirectory already exists and creat it otherwise
		if [ -d "run/$ligand" ]
		then
			output+="Found run/$ligand directory for output.\n"
		else
			output+="run/$ligand directory for output doesn't exist and is created.\n"
			mkdir run/$ligand
			output+="run/$ligand was created.\n"
		fi
	
		#generating the file names for params, constrains, rotlib and pdb input
		pdb_input=$(echo $pdb_name | sed "s/XXX/$ligand/g")
		params=$(echo $ligand".params")
		cst=$(echo $ligand".enzdes.cst")
		rotlib=$(echo $ligand".rotlib.pdb")
		#echo $pdb_input $params $cst $rotlib
		
		#check if all input files exist
		if [[ -f "pdb_inp/$pdb_input" && -f "ligs/$params" && -f "ligs/$cst" && -f "ligs/$rotlib" ]]
		then
			output+="Found all required input files: $pdb_input $params $cst $rotlib\n"
		
			#loop over all mutations
			for mutation in ${all_mutations[@]}; do
				
				#check if subsubdirectory exists and create it otherwise
				if [ -d "run/$ligand/$mutation" ]
				then
					output+="Found run/$ligand/$mutation directory for output.\n"
				else
					output+="run/$ligand/$mutation directory for output doesn't exist and is created.\n"
					mkdir run/$ligand/$mutation
					output+="run/$ligand/$mutation was created.\n"
				fi
			
				#generating positions and amino acid one letter code for the two mutation from the input vector
				position1=$(echo $mutation | sed 's/[A-Z]//g; s/+.*//g')
				aa1=$(echo $mutation | sed 's/[1-9]//g; s/+.*//g')
				
				position2=$(echo $mutation | sed 's/[A-Z]//g; s/.*+//g')
				aa2=$(echo $mutation | sed 's/[1-9]//g; s/.*+//g')
				
				#loop over specified number of iterations
				for i in $(seq 1 $iteration); do
					bsub -n 1 -W $dur /cluster/apps/rosetta/3.11/x86_64/main/source/bin/rosetta_scripts.hdf5.linuxgccrelease @$flags -out:suffix _$i -out:path:all run/$ligand/$mutation -in:file:s pdb_inp/$pdb_input -extra_res_fa ligs/$params -enzdes:cstfile ligs/$cst -parser:script_vars position1="$position1"A -parser:script_vars aa1=$aa1 -parser:script_vars position2="$position2"A -parser:script_vars aa2=$aa2
					counter+=1
				done
			done
			output+="All jobs for $ligand were submitted!\n\n"
		else
			output+="${bold}Missing input file!${normal} At least one of the files ($pdb_input, $params, $cst, $rotlib) was not found! The jobs were not submitted! Please check the input folders ligs/ and pdb_inp/!\n\n"
		fi
	done
	output+="Submitted $counter jobs!\n"
else
	output+="${bold}flags file not found!${normal} Please check if it exists and if you specified the correct name!\n"
fi
#printing output summary
output+="###################################################################"
echo -e "$output"
