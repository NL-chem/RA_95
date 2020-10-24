#!/usr/bin/python

# This script should generate a Constraint File based on c-alpha to c-alpha distances 
# within 9A of each other for semi-FixBB design

# Should start at residue 1, scan all other positions and find pairs within 9A. 

# Should also prevent redundancy (i.e. double pairing) by hashing against the list


# Cst file format:
#	AtomPair CA <res1> CA <res2> HARMONIC <xtal-distance> 0.5

from pymol import cmd

name='RA_WT_NIR'
cutoff=9.0
atom_list=[]
missing_positions={58,59,60,61,98}

if os.path.exists('cstfile.txt'):
	os.remove('cstfile.txt')
	
write_cst=open('cstfile.txt','w')

for i in [x for x in range(2,249) if x not in missing_positions]:
# Starting point for pair search
	for j in [x for x in range(2,249) if x not in missing_positions]:
		if i != j:
			# Hash against other CAs
			distance=cmd.get_distance(name+' and name CA and resi '+str(i),name+' and name CA and resi '+str(j))
		
			if distance < cutoff:
				element=[i-1,j-1,distance]
				inverse_element=[j-1,i-1,distance]
				
				if inverse_element not in atom_list:
					atom_list.append(element)
					
for element in atom_list:
	write_cst.write('AtomPair CA '+str(element[0])+' CA '+str(element[1])+' HARMONIC '+str(element[2])+' 0.5\n')
	
write_cst.close()

	
