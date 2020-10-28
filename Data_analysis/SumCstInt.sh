#!/bin/bash

#asking how many of the top results should be included in the analysis
echo "Analysis of the top x. Please enter number"
read top

#generating array of equential numbers between 1 and $top for later anotation before reordering
for i in $(seq 1 $top); do
	order_tot+="$i\n"
done

#checking if output directory exists and procede only in this case
if [ -d "output" ]
then
	cd output
	
	#loop over all directories
	for dir in */; do
	
		cd $dir
		dir_wo=${dir%?}
		summary_all_cst+="$dir_wo SUM CST SUMMARY\n\n" 
		summary_all_int+="$dir_wo INTERFACE SUMMARY\n\n"
		
		for subdir in */; do
			
			cd $subdir
			subdir_wo=${subdir%?}
			summary_all_cst+="$subdir_wo:\n"
			summary_all_int+="$subdir_wo:\n"
			
			#read structure name, total score, sum of the cst scores and interface score from the sorted all scores file
			top_res=$(head -n $top all_scores_* | awk '{printf("%-10.3f%-10.3f%-10.3f%-50s\n", $2, $5+$7+$8, $21, $NF)}')
			
			#fusing both tables
			top_res=$(paste -d "" <(echo "$top_res") <(echo -e "$order_tot" | head -n $top | awk '{printf("%-10s\n", $1)}'))
			
			#sort by sum of cst and interface
			top_res_sort_cst=$(echo "$top_res" | sort -n -k2)
			top_res_sort_int=$(echo "$top_res" | sort -n -k3)
			
			#reading top result and calculating average
			best_cst=$(echo "$top_res_sort_cst" | head -n 1 | awk '{print $2}')
			av_cst=$(echo "$top_res_sort_cst" | awk '{sum+=$2}END{printf "%.3f",sum/NR}')
			
			best_int=$(echo "$top_res_sort_int" | head -n 1 | awk '{print $3}')
			av_int=$(echo "$top_res_sort_int" | awk '{sum+=$3}END{printf "%.3f",sum/NR}')
			
			#reformating tables and adding header
			table_top_res_sort_cst=$(echo "$top_res_sort_cst" | awk 'BEGIN {printf("%-47s%-10s%-10s%-10s%-13s\n","Structure","Total","Sum Cst","Interface","Pos Tot Score")}{printf("%-47s%-10.3f%-10.3f%-10.3f%-13s\n", $4, $1, $2, $3, $5)}')
			table_top_res_sort_int=$(echo "$top_res_sort_int" | awk 'BEGIN {printf("%-47s%-10s%-10s%-10s%-13s\n","Structure","Total","Interface","Sum Cst","Pos Tot Score")}{printf("%-47s%-10.3f%-10.3f%-10.3f%-13s\n", $4, $1, $3, $2, $5)}')
			
			#creating summay for on subdirectory
			summary_cst=$(printf "$table_top_res_sort_cst \n\nAverage Sum Cst score of the top $top structures: $av_cst\n")
			summary_int=$(printf "$table_top_res_sort_int \n\nAverage Interface score of the top $top structures: $av_int\n")
			
			#print summary to standrad output
			echo -e "$dir_wo $subdir_wo: SUM CST SUMMARY \n$summary_cst\n"
			echo -e "$dir_wo $subdir_wo: INTERFACE SUMMARY \n$summary_int\n"
			
			#save summary in the respective subdirectory
			echo -e "$dir_wo $subdir_wo: SUM CST SUMMARY \n$summary_cst\n" > sum_cst_summary_${dir_wo}_${subdir_wo}.txt
			echo -e "$dir_wo $subdir_wo: INTERFACE SUMMARY \n$summary_int\n" > interface_summary_${dir_wo}_${subdir_wo}.txt
			
			#add to summary variables
			summary_all_cst+="$summary_cst\n\n\n"
			summary_all_int+="$summary_int\n\n\n"
			
			#add values to best score list
			list_best_scores_cst+="$dir_wo $subdir_wo $best_cst $av_cst\n"
			list_best_scores_int+="$dir_wo $subdir_wo $best_int $av_int\n"
			
			cd ..
		done
		
		#print summaries for whole directory into files
		echo -e "$summary_all_cst" > summary_all_cst_$dir_wo.txt
		echo -e "$summary_all_int" > summary_all_int_$dir_wo.txt
		
		#remove blank lines
		list_best_scores_cst=$(echo -e "$list_best_scores_cst" | sed '/^$/d' )
		list_best_scores_int=$(echo -e "$list_best_scores_int" | sed '/^$/d' )
		
		#sort best score list and print it
		list_best_scores_cst_sorted=$(echo -e "$list_best_scores_cst" | sort -n -k4)
		echo -e "SUM CST SORTED LIST $dir_wo \nLig Mut  top sc av $top best sc \n$list_best_scores_cst_sorted\n"
		echo -e "SUM CST SORTED LIST $dir_wo \nLig Mut  top sc av $top best sc \n$list_best_scores_cst_sorted" > list_best_scores_cst_$dir_wo.txt
		
		list_best_scores_int_sorted=$(echo -e "$list_best_scores_int" | sort -n -k4)
		echo -e "INTERFACE SORTED LIST $dir_wo \nLig Mut  top sc av $top best sc \n$list_best_scores_int_sorted\n"
		echo -e "INTERFACE SORTED LIST $dir_wo \nLig Mut  top sc av $top best sc \n$list_best_scores_int_sorted" > list_best_scores_int_$dir_wo.txt
		
		#save best score list in other variable
		list_best_scores_cst_all+=$list_best_scores_cst
		list_best_scores_int_all+=$list_best_scores_int
		
		#reset variable for run over next dir
		unset summary_all_cst
		unset list_best_scores_cst
		
		unset summary_all_int
		unset list_best_scores_int
		
		cd ..
	done
	
	#sort best score lists for all dirs and print it
	list_best_scores_cst_sorted_all=$(echo -e "$list_best_scores_cst_all" | sort -n -k4)
	echo -e "SUM CST SORTED LIST ALL \nLig Mut  top sc av $top best sc\n$list_best_scores_cst_sorted_all\n"
	echo -e "SUM CST SORTED LIST ALL \nLig Mut  top sc av $top best sc\n$list_best_scores_cst_sorted_all" > list_best_scores_cst_all.txt
	
	list_best_scores_int_sorted_all=$(echo -e "$list_best_scores_int_all" | sort -n -k4)
	echo -e "INTERFACE SORTED LIST ALL \nLig Mut  top sc av $top best sc\n$list_best_scores_int_sorted_all\n"
	echo -e "INTERFACE SORTED LIST ALL \nLig Mut  top sc av $top best sc\n$list_best_scores_int_sorted_all" > list_best_scores_int_all.txt
	
	cd ..
else
	echo "output directory not found!"
fi
