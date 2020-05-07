#!/bin/bash

################SETTINGS################################################
#position
read -p "aa distrubution at which position should be evaluated? " pos

#aas to look for
aa_array=(ALA VAL ILE LEU MET PHE TYR TRP SER THR ASN GLN CYS ARG HIS LYS ASP GLU PRO GLY)
########################################################################

#declaring required variables
num_aa=${#aa_array[@]}

#generating zero array with the sane number of elements as the aa_array array
declare -a count_array=( $(for i in $(seq 1 $num_aa); do echo 0; done) )
declare -a frac_array

for dir in */; do
	cd $dir
	summary_all+="$dir:\n"
	for subdir in */; do
		cd $subdir
		summary_all+="$subdir:\n"
		
		#declaring required variables
		declare -i counter=0
		
		#loop over all pdb files
		for struc in *.pdb; do
			counter+=1
			
			#reading aa at the specified position form pdb file
			pos_struc=$(grep "ATOM" "$struc" | awk '{printf("%+5s%+5s\n",$4,$6)}' | uniq | grep -w "$pos" | awk '{print $1}')
			
			#declaring required variables for comparision
			declare -i j=0
			bool=false
			
			#loop over length of aa_array that stops after a match was found
			while [[ j -lt $num_aa && "$bool" == false ]]; do
				
				#matching
				if [ $pos_struc == ${aa_array[j]} ]
				then
					count_array[j]=$(echo "${count_array[j]}+1" | bc)
					bool=true
				fi
				
				j+=1
			done	
		done	
		cd ..
		
		#clculating precent values
		for k in $(seq 0 $(($num_aa-1))); do
			frac_array[k]+=$(echo "scale=4;${count_array[k]}/$counter*100" | bc -l)
		done
		
		#output
		summary_all+=$(printf '%-9s' "aa" ${aa_array[@]})
		summary_all+="\n"
		summary_all+=$(printf '%-9s' "absolute" ${count_array[@]})
		summary_all+="\n"
		summary_all+=$(printf '%-9s' "percent" ${frac_array[@]})
		summary_all+="\n"
		summary_all+=$(echo "For a total number of $counter structures.\n\n")
		
		
	done
	summary_all+="#############################################################################################################################################################################################\n\n"
	cd ..
done
echo -e "$summary_all"
echo -e "$summary_all" > summary_fractions.txt
