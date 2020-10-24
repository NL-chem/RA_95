#!/bin/bash

#################SETTINGS################
#arrays with all subdirectories to be processed
subdir_all=(112I/ 112L/ 112V/)

#maximal duration
dur=0:59

#flags file name
flags=Rescore.flags
#################SETTINGS################

#to print bold
bold=$(tput bold)
normal=$(tput sgr0)

#variable to count the number of submitted jobs
declare -i counter_job=0

#variable to collect all the output statments that is prineted in the end
output="############################JOB SUMMARY############################\n"

#check if the run directory with output of design experiment exists
if [ -d "run" ]
then
	output+="Found run directory for output.\n\n"

	#check if the flags file exists
	if [ -f "$flags" ]
	then
		output+="Found flags file $flags.\n\n"
	
		#check if the run_score directory exists and create it otherwise
		if [ -d "run_score" ]
		then
			output+="Found run_score directory for output.\n\n"
		else
			output+="run_score directory for output doesn't exist and is created.\n"
			mkdir run_score
			output+="run_score was created.\n\n"
		fi
		
		#make directories in run_score according to run
		cd run/
		
		for dir in */; do
		
			dir_wo=${dir%?}
			
			#generating the file names for params, constrains and rotlib
			params=$(echo $dir_wo".params")
			cst=$(echo $dir_wo".enzdes.cst")
			rotlib=$(echo $dir_wo".rotlib.pdb")
			#echo $pdb_input $params $cst $rotlib
		
			if [[ -f ../ligs/$params && -f ../ligs/$cst && -f ../ligs/$rotlib ]]
			then
				output+="Found all required input files: $params $cst $rotlib\n\n"
		
		
				if [ -d ../run_score/$dir ]
				then
					output+="Found run_score/$dir directory for output.\n"
				else
					mkdir ../run_score/$dir
					output+="run_score/$dir was created.\n"
				fi
			
				cd $dir
				for subdir in ${subdir_all[@]}; do
					#variable to count the number of submitted jobs
					declare -i counter_suf=1
					
					if [ -d ../../run_score/$dir/$subdir ]
					then
						output+="Found run_score/$dir$subdir directory for output.\n"
					else	
						mkdir ../../run_score/$dir/$subdir
						output+="run_score/$dir$subdir was created.\n"
					fi
				
					cd $subdir
					for pose in *.pdb; do
						cd ../../../
						bsub -n 1 -W $dur /cluster/apps/rosetta/3.11/x86_64/main/source/bin/rosetta_scripts.hdf5.linuxgccrelease @$flags -out:suffix _$counter_suf -out:path:all run_score/$dir$subdir -in:file:s run/$dir$subdir$pose -extra_res_fa ligs/$params -enzdes:cstfile ligs/$cst
						counter_job+=1
						counter_suf+=1
						cd run/$dir/$subdir
					done
					cd ..
				done
				cd ..	
			else
				output+="${bold}Missing input file!${normal} At least one of the files ($params, $cst, $rotlib) was not found! The jobs were not submitted! Please check the input folder ligs/!\n\n"
			fi
		done
		cd ..
		output+="\nSubmitted $counter_job jobs!\n"
	else
		output+="${bold}flags file not found!${normal} Please check if it exists and if you specified the correct name!\n"
	fi
else
	output+="${bold}run directory not found!${normal}\n"
fi
#printing output summary
output+="###################################################################"
echo -e "$output"
