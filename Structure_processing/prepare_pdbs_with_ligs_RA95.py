#!/usr/bin/python

from pymol import cmd
from os import sys

### First load all ligand pdb files generated with molfile_to_params
cmd.delete('*')
cmd.load('RA_I133F.pdb','RA95_target')
current_cwd=os.getcwd()
loaded_ligs=[]
for file in os.listdir('ligs'):
	if file.endswith('0001.pdb'):
		ligand_name=file.split('_')[0]
		loaded_ligs.append(ligand_name)
		cmd.load('ligs/'+file,ligand_name)

#select the ligand atomes of the original ligand to align with
target_atom1='RA95_target and name C3'
target_atom2='RA95_target and name C4'
target_atom3='RA95_target and name C5'

#select the ligand atomes of the new ligand to align with and align the selected atoms of old and new ligand
for ligand in loaded_ligs:
	mobile_atom1=ligand+' and name CL1'
	mobile_atom2=ligand+' and name CL'
	mobile_atom3=ligand+' and name CL2'
	cmd.pair_fit(mobile_atom1,target_atom1,mobile_atom2,target_atom2,mobile_atom3,target_atom3)

#remove old ligand
cmd.remove('RA95_target and resn PEN')

#build bond between Lys83 and the new ligand and generate pdb file
for ligand in loaded_ligs:
	cmd.copy('RA95_'+ligand,'RA95_target')
	cmd.fuse(ligand+' and name CL','RA95_'+ligand+' and resn LYX and name NZ','3')
	cmd.bond('RA95_'+ligand+' and resn LYX and name NZ','RA95_'+ligand+' and name CL')
	cmd.alter('RA95_'+ligand+' and resn '+ligand,'segi="B"')
	cmd.sort('RA95_'+ligand)
	cmd.save('RA95_'+ligand+'.pdb','RA95_'+ligand,'0')

