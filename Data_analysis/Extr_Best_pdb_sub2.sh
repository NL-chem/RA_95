#!/bin/bash

######INPUT TO SPECIFY#######
#column number interface score
c_int=19
#column number tyr51
c_Y51=30
#column number lys83
c_K83=23
#column number asn110
c_N110=4
#column number tyr180
c_Y180=29
#column numbers ligand
c_L1=20
c_L2=21
#open in pymol or not
read -p "do you want the possibility to open the best scoring structure in pymol? " open
#############################

#loop over all directories
for dir in */; do
	cd $dir
	summary_all+="$dir:\n"
	for subdir in */; do
		cd $subdir
		summary_all+="$subdir:\n"
		
		###reading the third line of every file and sort the lines by the second column###
		scores=$(sed -ns 3p *.sc)
		scores_sorted=$(echo "$scores" | sort -n -k2)

		###reading out the best score and the coresponding pdb file###
		best_score=$(echo "$scores_sorted" | head -n 1 | awk '{print $2}')
		best_pdb=$(echo "$scores_sorted" | head -n 1 | awk '{print $NF}')

		###calculating the average score###
		average=$(echo "$scores_sorted" | awk '{sum+=$2}END{printf "%.3f",sum/NR}')

		###determining number of structures###
		number=$(echo "$scores_sorted" | wc -l)

		###extract specified columns for the 10 best scoring entries and print them in table###
		best_score_10=$(echo "$scores_sorted" | head -n 10 | awk -v c1=$c_int -v c2=$c_Y51 -v c3=$c_K83 -v c4=$c_N110 -v c5=$c_Y180 -v c6=$c_L1 -v c7=$c_L2 'BEGIN {printf("%-30s%+10s%+10s%+10s%+10s%+10s%+10s%+10s\n","Structure","Total","Interface","Tyr51","Lys83","Asn110","Tyr180","Ligand")}{printf("%-30s%+10.3f%+10.3f%+10.3f%+10.3f%+10.3f%+10.3f%+10.3f\n", $NF, $2, $c1, $c2, $c3, $c4, $c5, $c6+$c7)}')

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

		###output###
		summary=$(printf "Best score: \t$best_score for $best_pdb \nAverage score: \t$average from $number structures \n\nBest partial scores:\nInterface: \t$best_interface_score ($pos_best_interface_score) \tAverage: $average_interface\nTyr51: \t\t$best_tyr51_score ($pos_best_tyr51_score) \tAverage: $average_tyr51\nLys83: \t\t$best_lys83_score ($pos_best_lys83_score) \tAverage: $average_lys83\nAsn110: \t$best_asn110_score ($pos_best_asn110_score) \tAverage: $average_asn110\nTyr180: \t$best_tyr180_score ($pos_best_tyr180_score) \tAverage: $average_tyr180\nLigand: \t$best_ligand_score ($pos_best_ligand_score) \tAverage: $average_ligand\n\nScore overview best 10 structures: \n$best_score_10 \n")
		echo "$summary"
		echo "$summary" > summary.txt
		summary_all+="$summary\n\n"
		echo "$scores_sorted" > all_scores.txt

		#open best structure in Pymol if requested
		if [[ $open =~ ^[Yy]$ ]]
		then
			read -p "Do you want to open the best scoring structure in Pymol? " -n 1 -r
			echo
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
				pdb_file=$(echo "$best_pdb.pdb")
				/home/nils/06-Programme/Pymol/pymol/pymol $pdb_file
			fi
		fi
		cd ..
	done
	summary_all+="########################################################################################################\n\n"
	cd ..
done
echo -e "$summary_all" > summary_all.txt
