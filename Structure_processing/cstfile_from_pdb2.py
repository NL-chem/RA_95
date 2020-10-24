#!/usr/bin/python

# Duncan:
# This script should generate a Constraint File based on c-alpha to c-alpha distances 
# within 9A of each other for semi-FixBB design

# Should start at residue 1, scan all other positions and find pairs within 9A. 

# Should also prevent redundancy (i.e. double pairing)

# Nils:
# The script was modified towards higher efficiency (nested loops: prevention of redundancy is now included in the loop logic)
# and is also able to accept pdb files with missing positions. These must be specified in the variable missing_positions (pdb numbering).


# Cst file format:
#	AtomPair CA <res1> CA <res2> HARMONIC <xtal-distance> 2.0

from pymol import cmd

name='RA_I133F_wo_double_Pos'
cutoff=9.0
atom_list=[]
missing_positions=[1]

if os.path.exists('cstfile.txt'):
	os.remove('cstfile.txt')
	
write_cst=open('cstfile.txt','w')

for i in [x for x in range(1,248) if x not in missing_positions]:
	#determining number of missing positions for with respect to position i
	minus_i=0
	for miss_i in range(len(missing_positions)):
		if missing_positions[miss_i] < i:
			minus_i+=1
	
	for j in [x for x in range(i+1,249) if x not in missing_positions]:
		#determining number of missing positions for with respect to position j
		minus_j=0
		for miss_j in range(len(missing_positions)):
			if missing_positions[miss_j] < j:
				minus_j+=1
		
		distance=cmd.get_distance(name+' and name CA and resi '+str(i),name+' and name CA and resi '+str(j))
		
		if distance < cutoff:
			element=[i-minus_i,j-minus_j,distance]
			atom_list.append(element)
					
for element in atom_list:
	write_cst.write('AtomPair CA '+str(element[0])+' CA '+str(element[1])+' HARMONIC '+str(element[2])+' 2.0\n')
	
write_cst.close()

	
