#!/bin/bash

#--------1. Working & Pseudo QE bin Directory Location-------------------------------#
currentlocation=$(pwd)
DIR=${currentlocation%/*\/*}/work_dir
PSEUDO_DIR=$DIR/pseudo
#---------------------------------------------------------------------------------#

#---------2. HPC-CPU parallel distribution and prefix------------------------------#

QE_PATH=/apps/scratch/compile/new/q-e-qe-6.3/bin

PARALLEL="mpiexec.hydra -ppn 40 -f $DIR/nodes"

  MPIRUN_PW="$PARALLEL -np 2  $QE_PATH/pw.x -ndiag 1 -inp"
MPIRUN_nscf="$PARALLEL -np 160 $QE_PATH/pw.x -inp"
MPIRUN_Bnds="$PARALLEL -np 160 $QE_PATH/pw.x  -inp"
MPIRUN_Bndx="$PARALLEL -np 160 $QE_PATH/bands.x -inp"
MPIRUN_proj="$PARALLEL -np 160 $QE_PATH/projwfc.x -inp"

#For phonon dispersion and dos

PH_DISP_RUN="$PARALLEL -np 96 $QE_PATH/ph.x -npool 2"  #k-point parallelization is supported.
MATDYN_DISP_RUN="$PARALLEL -np 36 $QE_PATH/matdyn.x"
Q2R_DISP_RUN="$PARALLEL -np 36 $QE_PATH/q2r.x"


#For electron-phonon:
PW_RUN="$PARALLEL -np 36 $QE_PATH/pw.x"
PH_RUN_phon="$PARALLEL -np 96 $QE_PATH/ph.x -npool 2"	#k-point (npool) parallelization is supported.
PH_RUN_dvscf="$PARALLEL -np 36 $QE_PATH/ph.x"	#k-point (npool) parallelization is not supported.
MATDYN_RUN="$PARALLEL -np 36 $QE_PATH/matdyn.x"
Q2R_RUN="$PARALLEL -np 36 $QE_PATH/q2r.x"


#----------3. DFT input prefix----------------------------------------------------#
prefix=mos2

ecutwfc=60 	#Kinetic cut-off for upf pseudo.

kgrid_nonsoc="12 12 1"  #kpoint grid in absence of SOC for nonsoc-scf, phonon dispersion & elph.

kgrid="12 12 1"	#kpoint grid- for nscf, GW, etc. 

shifted_grid="0 0 0"	


#----------4. Number of atoms-----------------------------------------------------#

atoms="Mo S"	#Write the atomic species to be used in electronic stability calculation.


#----------5. Phonon dispersion q-grid--------------------------------------------#

NQ1="8"	# Give these nq1, nq2, nq3 same as in kgrid_nonsoc for phonon dispersion.
NQ2="8"
NQ3="1"
TRN_PH="1.0d-16"
alpha_mx="0.9"


#----------6. Double-grid k points: to be used in BSE scissor---------------------#

dgkpoint="24 24 1 1 1 0" 		#Put as double the k-grid on shifted 1 1 0


#----------7. nscf no. of bands (occupied+unoccupied)-----------------------------#
NBND="                                              nbnd = 300"
#---------------------------------------------#



#----------8. Choice of BZ route for band diagram---------------------------------#
bands_path="G K M G"
#-----------------End of DFT Script-----------------------------------------------#

