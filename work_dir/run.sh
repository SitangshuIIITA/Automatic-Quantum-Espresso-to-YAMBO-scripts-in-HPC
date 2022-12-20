

# Note: How to run:

# 1. Run this script run.sh by uncommenting input_relax.sh line below to generate the input script. Once the input is generated, comment it and go to the QE and Yambo lines below. Uncomment them one by one or all of them) and run this script again:
# 2. In the Yambo BSE command runs, SlepC module for yambo is required. Install them if you dont have.
# 3. In BSE, the Slepc solver includes firt 15 excitons.

cd ../core_files/QE_VAR
set -a
source ./QE_variables.sh
set +a

cd ../../work_dir

#                sh input_relax.sh                                       # Relax input file generation

cd ../core_files/QE_VAR

cd ../YAM_VAR
set -a
source ./yambo_variables.sh
set +a


cd ../QE_RUN

# Run sequentially or at one shot, the following lines :

#		sh QE_relax.sh						# calculates energy/geometry minimization/relax.

#		sh QE_electron_stability.sh				# calculates enthaly of the system

#		sh QE_scf.sh						# calculates scf (both with spin and no-spin)	

#		sh QE_nscf.sh						# calculates non self consistent part

#		sh QE_bands.sh						# calculates bands using QE band interpolator

#		sh QE_double_nscf.sh					# calculates nscf on denser grid.

#		sh QE_phon_disp.sh					# calculates phonon dispersion on regilar grid


	
cd ../YAM_RUN

# Run sequentially or at one shot, the following lines:

#		sh yambo_dft_bnd_struc.sh				# calculates DFT band structure using yambo interpolator.

#		sh hf.sh						# Hartree-Fock energy computation.

#		sh gw.sh						# GW calculation (includes 4 self-consistent GW. Conduction and valence slopes using regression method is also computed.)

#		sh bse_gw.sh						# BSE + GW calculation using SlepC solver for first 15 excitons.

#		sh wf_exciton.sh					# exciton wavefunction/amplitude, etc.

#		sh bse_scissor.sh                                       # BSE calculation using inversion solver with the automatic GW slope regression evaluation.

#		sh exciton_disp.sh					# exciton dispersion calculation. 

#		sh elph.sh						# elph phonon+Fan+Debye Waller for zero point energy calculation. Phonon double grid is also computed for emission processes. See yambo tutorials.

#		sh eliash.sh						# Electronic Eliashberg calculations for both direct and indirect conduction and valence bands.

#		sh bse_temp_inv.sh					# BSE Temperature calculation (in loop) using double grid and inversion solver with merged GW+elph database.

#		sh bse_temp_diago.sh					# BSE temperature calculation (in loop) using full daigonalization solver with merged GW + elph database.

#		sh exciton_eliash.sh					# Exciton-eliashberg calculation at various temperatures.

#		sh bse_temp_slepc.sh                                    # BSE Temperature calculation (loop) using slepC solver with merged GW+elph database.
	

cd ..
#		rm -rf count


exit;
