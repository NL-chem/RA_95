#!/bin/bash

#this script is intended to evaluate Rosetta experiments were all Rosetta
#output files are in folders three levels above the execution directory
#of this script. It will search for a directors called run and loop over
#all directories and subdirectories in this directory. The output is saved
#in the output directory with the same directory architecture as the run
#directory and in the end compressed into a tar.gz archive.
#The kind of experiment that can be evaluated with this script is:
#Performing different mutations (at a single position) for different ligands
#and one enzyme
#The script evaluates every ligand seperately. In contrast the different
#mutations for one ligand are compared in the end. That's why the architecture
#of the run directory has to be: run/$LIGANDS/$MUTATIONS
#required input files: score files can contain the entries of several
#experiments. The script is automatically looking for specific colums in
#the score files. If you want to change the evaluated columns you have to
#change the scrit. In contrast, for every single experiment a pdb output file
#is required.
#The scipt will ask for a pdb position it should report. This is meant to
#control if the mutation was successfully introduced but is not required
#for the script to perform a proper evaluation.


#asking for position at which the aa should be reported
echo "aa at which position (pdb) should be reported?"
read pos

#checking if run directory exists and procede only in this case
if [ -d "run" ]
then
	
	#check if output directory exists, delete it if it is the case and make a new output directory
	if [ -d "output" ]
	then
		rm -r output
	fi
	mkdir output

	cd run
	
	#loop over all directories
	for dir in */; do
		
		#make directory with the same name in the output folder
		mkdir ../output/$dir
		
		cd $dir
		dir_wo=${dir%?}
		dir_all+="_$dir_wo"
		summary_all+="$dir_wo:\n" 
		
		for subdir in */; do
		
			#make subdirectory with the same name in the output folder
			mkdir ../../output/$dir$subdir
		
			cd $subdir
			subdir_wo=${subdir%?}
			summary_all+="$subdir_wo:\n"
			
			#######################EVALUATION#######################
			
			#auto identification of the columns needed for evaluation
			header=$(sed -ns 2p *.sc | uniq)
			header_tansp=$(echo "$header" | tr -s ' ' '\n')
			
			#determine column numbers
			c_int=$(echo "$header_tansp" | grep -n "interface_en" | cut -d: -f1)
			c_Y51=$(echo "$header_tansp" | grep -n "tyr51_en" | cut -d: -f1)
			c_K83=$(echo "$header_tansp" | grep -n "lys83_en" | cut -d: -f1)
			c_N110=$(echo "$header_tansp" | grep -n "asn110_en" | cut -d: -f1)
			c_Y180=$(echo "$header_tansp" | grep -n "tyr180_en" | cut -d: -f1)
			c_L1=$(echo "$header_tansp" | grep -n "ligand_cst_en" | cut -d: -f1)
			c_L2=$(echo "$header_tansp" | grep -n "ligand_en" | cut -d: -f1)
			#echo $c_int $c_Y51 $c_K83 $c_N110 $c_Y180 $c_L1 $c_L2
			
			
			if (( $(echo "$header" | wc -l) == 1 ))
			then
			
				###reading starting at the third line of every file and sort the lines by the second column###
				#scores=$(sed -ns 3p *.sc)
				scores=$(find . -name "*.sc" -exec sed -se1,2d {} +)
				scores_sorted=$(echo "$scores" | sort -n -k2)

				###reading out the best score and the coresponding pdb file###
				best_score=$(echo "$scores_sorted" | head -n 1 | awk '{print $2}')
				best_pdb=$(echo "$scores_sorted" | head -n 1 | awk '{print $NF}')

				###calculating the average score###
				average=$(echo "$scores_sorted" | awk '{sum+=$2}END{printf "%.3f",sum/NR}')

				###determining number of structures###
				number=$(echo "$scores_sorted" | wc -l)

				###extract specified columns for the 10 best scoring entries and print them in table###
				best_score_10=$(echo "$scores_sorted" | head -n 10 | awk -v c1=$c_int -v c2=$c_Y51 -v c3=$c_K83 -v c4=$c_N110 -v c5=$c_Y180 -v c6=$c_L1 -v c7=$c_L2 'BEGIN {printf("%-45s%+10s%+10s%+10s%+10s%+10s%+10s%+10s\n","Structure","Total","Interface","Tyr51","Lys83","Asn110","Tyr180","Ligand")}{printf("%-45s%+10.3f%+10.3f%+10.3f%+10.3f%+10.3f%+10.3f%+10.3f\n", $NF, $2, $c1, $c2, $c3, $c4, $c5, $c6+$c7)}')
			
				average_best_score_10=$(echo "$scores_sorted" | head -n 10 | awk '{sum+=$2}END{printf "%.3f",sum/NR}')
				
				list_best_scores+="$dir_wo $subdir_wo $best_score $average_best_score_10\n"
				
				#extract aa at specified position
				best_pdb_10=$(echo "$scores_sorted" | head -n 10 | awk '{print $NF}')
				mutation="Pos$pos\n"
				for struct in $best_pdb_10; do
					struct_pdb=$(echo "$struct.pdb")
					mut_struc=$(grep "ATOM" "$struct_pdb" | awk '{printf("%+5s%+5s\n",$4,$6)}' | uniq | grep -w "$pos" | awk '{print $1}')
					mutation+="$mut_struc\n"
				done

				#fusing both tables
				best_score_10=$(paste -d "" <(echo "$best_score_10") <(echo -e "$mutation" | head -n 11 | awk '{printf("%+10s\n", $1)}'))

				###best partial scores###
				#determine best interface score and its position with respect to total score
				best_interface_score=$(echo "$scores" | awk -v c1=$c_int '{printf("%-7.3f%-5s%-28s\n",$c1,"for",$NF)}' | sort -n -k1 | head -n 1)
				pattern=$(echo $best_interface_score | awk '{print $NF}')
				pos_best_interface_score=$(echo "$scores_sorted" | sed -n "/$pattern/=")

				#determine best single residue scores and its position with respect to total score
				best_tyr51_score=$(echo "$scores" | awk -v c1=$c_Y51 '{printf("%-7.3f%-5s%-28s\n",$c1,"for",$NF)}' | sort -n -k1 | head -n 1)
				pattern=$(echo $best_tyr51_score | awk '{print $NF}')
				pos_best_tyr51_score=$(echo "$scores_sorted" | sed -n "/$pattern/=")

				best_lys83_score=$(echo "$scores" | awk -v c1=$c_K83 '{printf("%-7.3f%-5s%-28s\n",$c1,"for",$NF)}' | sort -n -k1 | head -n 1)
				pattern=$(echo $best_lys83_score | awk '{print $NF}')
				pos_best_lys83_score=$(echo "$scores_sorted" | sed -n "/$pattern/=")
				
				best_lys83_score_test=$(echo "$scores" | awk  '{printf("%-7.3f%-5s%-28s\n",$25,"for",$NF)}') # | sort -n -k1 | head -n 1)
				echo "$best_lys83_score_test"

				best_asn110_score=$(echo "$scores" | awk -v c1=$c_N110 '{printf("%-7.3f%-5s%-28s\n",$c1,"for",$NF)}' | sort -n -k1 | head -n 1)
				pattern=$(echo $best_asn110_score | awk '{print $NF}')
				pos_best_asn110_score=$(echo "$scores_sorted" | sed -n "/$pattern/=")

				best_tyr180_score=$(echo "$scores" | awk -v c1=$c_Y180 '{printf("%-7.3f%-5s%-28s\n",$c1,"for",$NF)}' | sort -n -k1 | head -n 1)
				pattern=$(echo $best_tyr180_score | awk '{print $NF}')
				pos_best_tyr180_score=$(echo "$scores_sorted" | sed -n "/$pattern/=")

				#determine best ligand score and its position with respect to total score
				best_ligand_score=$(echo "$scores" | awk -v c1=$c_L1 -v c2=$c_L2 '{printf("%-7.3f%-5s%-28s\n",$c1+$c2,"for",$NF)}' | sort -n -k1 | head -n 1)
				pattern=$(echo $best_ligand_score | awk '{print $NF}')
				pos_best_ligand_score=$(echo "$scores_sorted" | sed -n "/$pattern/=")

				#calculate the averages
				average_interface=$(echo "$scores_sorted" | awk -v c1=$c_int '{sum+=$c1}END{printf "%.3f",sum/NR}')
				average_tyr51=$(echo "$scores_sorted" | awk -v c1=$c_Y51 '{sum+=$c1}END{printf "%.3f",sum/NR}')
				average_lys83=$(echo "$scores_sorted" | awk -v c1=$c_K83 '{sum+=$c1}END{printf "%.3f",sum/NR}')
				average_asn110=$(echo "$scores_sorted" | awk -v c1=$c_N110 '{sum+=$c1}END{printf "%.3f",sum/NR}')
				average_tyr180=$(echo "$scores_sorted" | awk -v c1=$c_Y180 '{sum+=$c1}END{printf "%.3f",sum/NR}')
				average_ligand=$(echo "$scores_sorted" | awk -v c1=$c_L1 -v c2=$c_L2 '{sum+=$c1+$c2}END{printf "%.3f",sum/NR}')
				
				#######################EVALUATION#######################
				
				
				#########################OUTPUT#########################
				#create summary
				summary=$(printf "Best score: \t$best_score for $best_pdb \nAverage score: \t$average from $number structures \n\nBest partial scores:\nInterface: \t$best_interface_score \t($pos_best_interface_score) \tAverage: $average_interface\nTyr51: \t\t$best_tyr51_score \t($pos_best_tyr51_score) \tAverage: $average_tyr51\nLys83: \t\t$best_lys83_score \t($pos_best_lys83_score) \tAverage: $average_lys83\nAsn110: \t$best_asn110_score \t($pos_best_asn110_score) \tAverage: $average_asn110\nTyr180: \t$best_tyr180_score \t($pos_best_tyr180_score) \tAverage: $average_tyr180\nLigand: \t$best_ligand_score \t($pos_best_ligand_score) \tAverage: $average_ligand\n\nScore overview best 10 structures: \n$best_score_10 \n")
				
				#print summary to standard output
				echo -e "$summary\n"
				
				#save summary in output directory
				echo "$summary" > ../../../output/$dir_wo/$subdir_wo/summary_${dir_wo}_${subdir_wo}.txt
				
				#add summary to total summary
				summary_all+="$summary\n\n"
				
				#save all sorted scores in output directory
				echo "$scores_sorted" > ../../../output/$dir_wo/$subdir_wo/all_scores_${dir_wo}_${subdir_wo}.txt
				
				#save 10 best structures in output directory
				best_10_pdb=$(echo "$best_score_10" | awk '{print $1}' | tail -n 10)
				
				for loop_over_files in $best_10_pdb;do
							
					old_file_name=$(echo "$loop_over_files.pdb")
					new_file_name=$(echo "${loop_over_files}_${subdir_wo}.pdb")
					cp $old_file_name ../../../output/$dir_wo/$subdir_wo/$new_file_name
					
				done			
				
			else
				echo "No unique header found. Check your data!"
			fi
			
			cd ..
		done
		summary_all+="####################################################################################################################\n\n"
		
		#create a sorted list with the best score and the average of the best 10 scores for each mutation sorted by the average result and print it to standard output as well as to the output directory
		list_best_scores_sorted=$(echo -e "$list_best_scores" | sort -n -k4)
		echo -e "Lig Mut  top sc   av 10 best sc\n$list_best_scores_sorted\n"
		echo -e "Lig Mut  top sc   av 10 best sc\n$list_best_scores_sorted" > ../../output/$dir_wo/list_best_scores_$dir_wo.txt
		
		#save best score list in other variable
		list_best_scores_all+=$list_best_scores
		
		#print total summary to output directory
		echo -e "$summary_all" > ../../output/$dir_wo/summary_all_$dir_wo.txt
		
		#reset variable for run over next dir
		unset summary_all
		unset list_best_scores
		
		cd ..
	done
	cd ..
	
	#create a sorted list with the best score and the average of the best 10 scores for all Lignads and each mutation sorted by the average result and print it to standard output as well as to the output directory
	list_best_scores_sorted_all=$(echo -e "$list_best_scores_all" | sort -n -k4)
	echo -e "Lig Mut  top sc   av 10 best sc\n$list_best_scores_sorted_all\n"
	echo -e "Lig Mut  top sc   av 10 best sc\n$list_best_scores_sorted_all" > output/list_best_scores_all.txt
	
	#create tar.gz archive of the output directory; first delete it if it already exists
	if [ -f output${dir_all}_${pos}.tar.gz ]
	then
		rm output${dir_all}_${pos}.tar.gz
	fi

	tar -czf output${dir_all}_${pos}.tar.gz output
	
	#final statement
	echo -e "All output files can be found in the output directory.\nA tar.gz.archive of the output directory was created: output_${dir_wo}_${pos}.tar.gz\nEvaluation finished!\nGood bye!\n"

else
	echo "run directory not found!"
fi
