#!/bin/bash

#--------1. Working & Pseudo QE bin Directory Location-------------------------------#
currentlocation=$(pwd)
DIR=${currentlocation%/*\/*}/work_dir
PSEUDO_DIR=$DIR/pseudo
#---------------------------------------------------------------------------------#

#---------2. HPC-CPU parallel distribution and prefix------------------------------#

QE_PATH=/apps/scratch/compile/new/q-e-qe-6.3/bin

PARALLEL="mpiexec.hydra -ppn 40 -f $DIR/nodes"

  MPIRUN_PW="$PARALLEL -np 10 $QE_PATH/pw.x -ndiag 1 -inp"
MPIRUN_nscf="$PARALLEL -np 4 $QE_PATH/pw.x -ndiag 1 -inp"
MPIRUN_Bnds="$PARALLEL -np 6 $QE_PATH/pw.x -inp"
MPIRUN_Bndx="$PARALLEL -np 8 $QE_PATH/bands.x -inp"
MPIRUN_proj="$PARALLEL -np 8 $QE_PATH/projwfc.x -inp"

#For phonon & electron-phonon:
PW_RUN="$PARALLEL -np 10 $QE_PATH/pw.x -npool 2"
PH_RUN="$PARALLEL -np 6 $QE_PATH/ph.x"
MATDYN_RUN="$PARALLEL -np 120 $QE_PATH/matdyn.x"
Q2R_RUN="$PARALLEL -np 120 $QE_PATH/q2r.x"


#----------3. DFT input prefix----------------------------------------------------#
prefix=BN

kgrid="12 12 1"	#kpoint grid. write the first three values only.
shifted_grid="0 0 0"	


#----------4. Double-grid k points: to be used in BSE scissor---------------------#
dgkpoint="24 24 1 1 1 0" 		#Put as double the k-grid on shifted 1 1 0



#----------5. nscf no. of bands (occupied+unoccupied)-----------------------------#
NBND="                                              nbnd = 150"
#---------------------------------------------#



#----------6. Choice of BZ route for band diagram---------------------------------#
bands_path="G K M G"
#-----------------End of DFT Script-----------------------------------------------#

