#!/usr/bin/python

from pymol import cmd

########### CHANGE THIS LIST AS NEEDED #######
delete_atoms=['N33','C35','H34','H36','H37','H38'] # atoms to be removed from rotamer library
three_letter_code='MKR' # three-letter residue name specified in -n for molfile_to_params
atoms_to_align=['CL','CL1','CL2'] # atoms around the lysine-ligand bond for alignment and visualisation
min_RMSD=0.1 #minimal RMSD value by which two rotamers must differ. Otherwise one is removed from the rotamer library.
conformers_name='conformers'
##############################################

#loading and preparing rotamers
cmd.delete('*')
cmd.load(conformers_name+'.mol2')
target=conformers_name
cmd.split_states(target,prefix="Molecule_Name_")
cmd.delete(target)

#list of all conformers
object_list=cmd.get_object_list('(all)')

#aligning rotamers and deleting spezified atoms
counter=0
for object in object_list:
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
		#print(target_atom1)
		#print(mobile_atom1)
		cmd.pair_fit(mobile_atom1,target_atom1,mobile_atom2,target_atom2,mobile_atom3,target_atom3)
	for element in delete_atoms:
		cmd.remove('{object} and name {element}'.format(object=object,element=element))

#finding very similar rotamers based on their RMSD
del_obj=[]
for object1 in range(0,len(object_list)):
	for object2 in range(object1+1,len(object_list)):
		align_out=cmd.align(object_list[object1], object_list[object2], cycles=0, transform=0)
		if align_out[0] < min_RMSD and object_list[object2] not in del_obj:
			#print(object_list[object2])
			del_obj.append(object_list[object2])

#deleting redundant rotamers
for i in range(0,len(del_obj)):
	cmd.delete(name=del_obj[i])	

#joining all rotamers in one object				
cmd.join_states(three_letter_code+'.rotlib','*')

#reporting total number of rotamers on the initial library and number of deleted rotamers
print(len(object_list),' rotamers in total.')
print(len(del_obj),' rotamers were deleted due to similarity.')
