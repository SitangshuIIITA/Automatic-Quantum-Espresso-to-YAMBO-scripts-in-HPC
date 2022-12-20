#!/bin/bash

#--------------- Variables of YAMBO Calculations from this section onwards--------#
#---------------- Yambo & CPU Parallel structure ---------- #

PARALLEL_YAMBO="mpiexec"
MPIRUN_YAMBO="$PARALLEL_YAMBO -np 384"
YAMBO_PH="yambo_ph"
YPP_PH="ypp_ph"
P2Y="p2y"
YAMBO="yambo"
YPP="ypp"

se_cpu="16 4 6"
x_and_io="1 1 16 4 6"
dip_cpu="16 4 6"
bs_cpu="16 4 6"
#---------------------------------------------------#

#---------------- Hartree-Fock Convergence ---------#
exxrlvecs="60 Ry"       # This value is converged at the Hartree-Fock Level
vxcrlvecs="60 Ry"       # This value is converged at the Hartree-Fock Level
slab="box z"		# HF/GW/BSE RIM cut	
#---------------------------------------------------#

 
# Converge the followings for GW:
#---------------------------------------------------#
ngsblkp="20 Ry"         # Converge this value here. This is response block size. 
fftgvecs="60 Ry"        # Converge this value here. This is no. of  [FFT] Plane-waves in DFT.
bndsrnxp="200"          # Converge this screening bands. This is [Xp] Polarization function bands. See line 29 in QE_variables less than equal to NBND.
gbndrnge="200"          # Converge this sum over states bands. This is G[W] bands range. See line 29 in QE_variables less than equal to NBND.
#-------------------------------------------------- #    

# Converge the followings for BSE:
#---------------------------------------------------#
ngsblks="25 Ry"         # Converge this value here. This is response block size. Keep this same as ngsblkp.
bsengblk="25 Ry"        # Converge this value here. This is response block size. Keep this same as ngsblks.
bsengexx="25 Ry"        # Converge this value here. This is response block size. Keep this same as ngsblks.

#-----------GW/BSE Choice of transition bands-------#
nc="3"   #This is the no. of lowest conduction bands
nv="3"   #This is the no. of highest valence bands

#-----------Exciton dispersion states---------------#
exciton_states="1 - 15"  #This is first five exciton states whose dispersion diagram will be plotted along the BZ. MIND THE GAPS.

#-----Temperature file names------------------------#
temp_value="0 300"
Kelvin="K"


#------------ File names --------------------#
hf_filename=$prefix.yambo_hf_input.in
hf_ypp_bands=$prefix.hf_bands.in
gw_filename=$prefix.yambo_GW_input.in
gw_ypp_bands=$prefix.GW_bands.in
bse_filename=$prefix.yambo_bse_input.in
sci_filename=$prefix.yambo_bse_scissor_input.in
ex_prefix=$prefix.bse_scissor
exc_disp_filename=$prefix.yambo_exc_disp_input.in
ypp_exciton_disp=$prefix.ypp_exciton_disp.in
#---------------------------------------------#


#-----Temperature file names------------------#
temp_prefix="$temp_value Kn"
bse_temp_filename=$prefix.yambo_bse.$temp_value$Kelvin.input.in
exprefix0K=$prefix.$temp_value$Kelvin
exc_disp_temp=$prefix.yambo_bse_exc_disp.$temp_value$Kelvin.input.in
#---------------------------------------------#

