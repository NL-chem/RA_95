#!/usr/bin/python

from pymol import cmd

########### CHANGE THIS LIST AS NEEDED #######
delete_atoms=['N21','C26','H27','H28','H29'] # atoms to be removed from rotamer library
three_letter_code='NIR' # three-letter residue name specified in -n for molfile_to_params
atoms_to_align=['CL','CL1','CL2'] # atoms around the lysine-ligand bond for alignment and visualisation
##############################################

cmd.delete('*')
cmd.load('conformers.mol2')
target='conformers'
cmd.split_states(target,prefix="Molecule_Name_")
#cmd.split_states(target)
cmd.delete(target)
counter=0
#target_atom1=''
#target_atom2=''
#target_atom3=''
#target_atom4=''
for object in cmd.get_object_list('(all)'):
	cmd.alter(object,'resn="'+three_letter_code+'"')
	counter+=1
	if counter==1:
		target_object=object
		target_atom1=target_object+' and name '+atoms_to_align[0]
		target_atom2=target_object+' and name '+atoms_to_align[1]
		target_atom3=target_object+' and name '+atoms_to_align[2]
	if counter > 1:
		mobile_atom1=object+' and name '+atoms_to_align[0]
		mobile_atom2=object+' and name '+atoms_to_align[1]
		mobile_atom3=object+' and name '+atoms_to_align[2]
		print(target_atom1)
		print(mobile_atom1)
		cmd.pair_fit(mobile_atom1,target_atom1,mobile_atom2,target_atom2,mobile_atom3,target_atom3)
	for element in delete_atoms:
		print("got here")
		cmd.remove('{object} and name {element}'.format(object=object,element=element))
cmd.join_states(three_letter_code+'.rotlib','*')
7
